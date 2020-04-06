SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = SS_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_set
	var/list/macro_sets
	var/list/movement_keys


/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()

// This is for when macro sets are eventualy datumized
/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	macro_set = list(
	"Any" = "\"KeyDown \[\[*\]\]\"",
	"Any+UP" = "\"KeyUp \[\[*\]\]\"",
	"O" = "ooc",
	"L" = "looc",
	"T" = "say",
	"M" = "me",
	"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"Tab" = "\".winset \\\"input.focus=false ? mapwindow.map.focus=true : input.focus=false\\\"\"",,
	"Escape" = "\".winset \\\"input.text=\\\"\\\"\\\"\"")


/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to length(clients))
		var/client/user = clients[i]
		user.set_macros()
		user.update_movement_keys()


/datum/controller/subsystem/input/fire()
	var/list/clients = GLOB.clients //Cache, makes it faster.
	for(var/i in 1 to length(clients))
		var/client/C = clients[i]
		C.keyLoop()
