/datum/fireteam
	var/name = null
	var/code = null
	var/list/members = list()
	var/list/required = list()
	var/side = null

	var/can_set_name = null
	var/name_set = 0
	var/id = 1
	var/squad_type
	var/max_fireteams = -1

	var/list/fireteam_codes = list()
	var/list/fireteam_access = list()

/datum/fireteam/proc/add_member(var/mob/living/carbon/human/H, var/datum/job/job)
	if(!(job.type in required))
		return 0
	required -= job.type
	members += H
	greet_and_equip_member(H)
	if(required.len <= 0)
		trigger_full()
	if(!name_set && job.type == can_set_name)
		name_set = 1
		var/new_name = input(H, "Enter new squad name. Leave empty to use default.", "Name", "") as text
		new_name = sanitizeName(new_name)
		if(new_name && new_name != code)
			name = new_name
			for(var/member in members)
				to_chat(member, "<b>Your fireteam [code] is now called \"[name]\".</b>")
	return 1

/datum/fireteam/proc/greet_and_equip_member(var/mob/living/carbon/human/H)
	var/remembered_info = ""
	if(!name)
		remembered_info += "<b><font size=3>You are in the [squad_type]</font></b>"
		to_chat(H, "<b><font size=3>You are in the [squad_type] [code]</font></b>")
	else
		remembered_info += "<b><font size=3>You are in the [squad_type] [code] \"[name]\</font></b>"
		to_chat(H, "<b><font size=3>You are in the [squad_type] [code] \"[name]\</font></b>")

	H.mind.store_memory(remembered_info)

/datum/fireteam/proc/init()
	for(var/type_name in required)
		for(var/datum/job/job in job_master.occupations)
			if(job.type == type_name)
				job.total_positions++
				break

	code = get_code()

/datum/fireteam/proc/trigger_full()
	job_master.not_full_fireteams -= src

	job_master.add_fireteam(type)
	return 1

/datum/fireteam/proc/is_full()
	return required.len <= 0

/datum/fireteam/proc/get_code()
	var/c = fireteam_codes[id]
	if(!c)
		return ""
	return c

/datum/fireteam/separatist_squad
	required = list(/datum/job/separatist/leader,
					/datum/job/separatist/officer,
					/datum/job/separatist/medic,
					/datum/job/separatist/grunt,
					/datum/job/separatist/partisan,
					/datum/job/separatist/partisan,
					/datum/job/separatist/partisan,
					/datum/job/separatist/grunt,
					/datum/job/separatist/grunt
					)

	can_set_name = /datum/job/separatist/leader
	squad_type = "squad"
	side = "Separatists"
	max_fireteams = 3

	fireteam_codes = list(
		1 = "Borz",
		2 = "Allah",
		3 = "Islamabad",
		4 = "Grozny"
		)

/datum/fireteam/federal_squad
	required = list(/datum/job/federal/general,
					/datum/job/federal/officer,
					/datum/job/federal/medic,
					/datum/job/federal/medic,
					/datum/job/federal/soldier,
					/datum/job/federal/soldier,
					/datum/job/federal/soldier,
					/datum/job/federal/soldier,

					)

	can_set_name = /datum/job/federal/general
	squad_type = "squad"
	side = "Federals"
	max_fireteams = 3

	fireteam_codes = list(
		1 = "Anna",
		2 = "Boris",
		3 = "Vasiliy",
		4 = "Grigoriy",
		)
