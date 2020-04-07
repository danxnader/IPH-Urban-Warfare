/datum/job/separatist
	faction = "Station"

/datum/job/separatist/grunt
	title = "Separatist Grunt"
	department = "Separatists"
	department_flag = SPR

	total_positions = 10
	spawn_positions = 1
	supervisors = "whoever is higher ranked"
	selection_color = "#FF0000"
	economic_modifier = 4 //Poor lads.
	//access = list(
	//minimal_access = list(
	//minimal_player_age = 14
	//ideal_character_age = 21
	//outfit_type = /decl/hierarchy/outfit/job/separatist/grunt

/datum/job/separatist/medic //this role, unlike the federal medic, will rely on brute surgery instead of expensive chemicals.
	title = "Separatist Medic"
	department = "Separatists"
	department_flag = SPR

	total_positions = 2
	spawn_positions = 1
	supervisors = "whoever is higher ranked"
	selection_color = "#FF6347"
	economic_modifier = 4 //Poor lads 2
	//access = list(
	//minimal_player_age = 7
	//outfit_type = /decl/hierarchy/outfit/job/separatist/medic

/datum/job/separatist/partisan
	title = "Separatist Partisan" //unga bunga local populace who just got enlisted
	department = "Separatists"
	department_flag = SPR

	total_positions = 7
	spawn_positions = 1
	supervisors = "every separatist"
	selection_color = "#ff3232"
	economic_modifier = 1 //VERY POOR. They didn't join because they had a good life.
	//access = list(
	//minimal_player_age = 7
	//outfit_type = /decl/hierarchy/outfit/job/separatist/partisan

/datum/job/separatist/officer
	title = "Separatist Officer"
	department = "Separatists"
	department_flag = COMSPR

	total_positions = 2
	spawn_positions = 1
	supervisors = "the separatist leader"
	selection_color = "#800000"
	economic_modifier = 8 //richer than usual
	//access = list(
	//minimal_access = list(
	//minimal_player_age = 3
	//outfit_type = /decl/hierarchy/outfit/job/separatist/officer

/datum/job/separatist/leader
	title = "Separatist Leader"
	head_position = 1
	req_admin_notify = 1
	department = "Separatists"
	department_flag = COMSPR

	total_positions = 1
	spawn_positions = 1
	supervisors = "Leader of Postia and your good will"
	selection_color = "#32CD32"
	economic_modifier = 10 //barons at this point
	//access = list(
	//minimal_access = list(
	//minimal_player_age = 7
	//outfit_type = /decl/hierarchy/outfit/job/separatist/leader
