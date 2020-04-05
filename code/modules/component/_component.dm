/datum/proc/RegisterSignal(datum/target, sig_type_or_types, proctype, override = FALSE)
	if(QDELETED(src) || QDELETED(target))
		return

	var/list/procs = signal_procs
	if(!procs)
		signal_procs = procs = list()
	if(!procs[target])
		procs[target] = list()
	var/list/lookup = target.comp_lookup
	if(!lookup)
		target.comp_lookup = lookup = list()

	var/list/sig_types = islist(sig_type_or_types) ? sig_type_or_types : list(sig_type_or_types)
	for(var/sig_type in sig_types)
		if(!override && procs[target][sig_type])
			stack_trace("[sig_type] overridden. Use override = TRUE to suppress this warning")

		procs[target][sig_type] = proctype

		if(!lookup[sig_type]) // Nothing has registered here yet
			lookup[sig_type] = src
		else if(lookup[sig_type] == src) // We already registered here
			continue
		else if(!length(lookup[sig_type])) // One other thing registered here
			lookup[sig_type] = list(lookup[sig_type]=TRUE)
			lookup[sig_type][src] = TRUE
		else // Many other things have registered here
			lookup[sig_type][src] = TRUE

	signal_enabled = TRUE

/**
  * Stop listening to a given signal from target
  *
  * Breaks the relationship between target and source datum, removing the callback when the signal fires
  *
  * Doesn't care if a registration exists or not
  *
  * Arguments:
  * * datum/target Datum to stop listening to signals from
  * * sig_typeor_types Signal string key or list of signal keys to stop listening to specifically
  */
/datum/proc/UnregisterSignal(datum/target, sig_type_or_types)
	var/list/lookup = target.comp_lookup
	if(!signal_procs || !signal_procs[target] || !lookup)
		return
	if(!islist(sig_type_or_types))
		sig_type_or_types = list(sig_type_or_types)
	for(var/sig in sig_type_or_types)
		if(!signal_procs[target][sig])
			continue
		switch(length(lookup[sig]))
			if(2)
				lookup[sig] = (lookup[sig]-src)[1]
			if(1)
				stack_trace("[target] ([target.type]) somehow has single length list inside comp_lookup")
				if(src in lookup[sig])
					lookup -= sig
					if(!length(lookup))
						target.comp_lookup = null
						break
			if(0)
				lookup -= sig
				if(!length(lookup))
					target.comp_lookup = null
					break
			else
				lookup[sig] -= src

	signal_procs[target] -= sig_type_or_types
	if(!signal_procs[target].len)
		signal_procs -= target
