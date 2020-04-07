var/global/datum/controller/occupations/faction_master

#define RETURN_TO_LOBBY 0
#define MEMBERS_PER_SQUAD 6
#define LEADERS_PER_SQUAD 1
#define SL_LIMIT 4

/proc/setup_autobalance(var/announce = TRUE)

	spawn (0)
		if (job_master)
			job_master.toggle_roundstart_autobalance(0, announce)

/*
	var/list/faction_organized_occupations_separate_lists = list()
	for (var/datum/job/J in job_master.occupations)
		var/Jflag = J.department_flag()
		if (!faction_organized_occupations_separate_lists.Find(Jflag))
			faction_organized_occupations_separate_lists[Jflag] = list()
		faction_organized_occupations_separate_lists[Jflag] += J
	//if(!map)
		job_master.faction_organized_occupations |= faction_organized_occupations_separate_lists[SEPARATIST]
		job_master.faction_organized_occupations |= faction_organized_occupations_separate_lists[FEDERAL]
		job_master.faction_organized_occupations |= faction_organized_occupations_separate_lists[PARTISAN]
	//else
		//for (var/faction in map.faction_organization)
			//job_master.faction_organized_occupations |= faction_organized_occupations_separate_lists[faction]
*/
 // shit above doesn't work at the moment

/datum/faction_controller/occupations
		//List of all jobs
	var/list/occupations = list()
		//List of all jobs ordered by faction: German, Soviet, Italian, Ukrainian, Civilian, Partisan
	var/list/faction_organized_occupations = list()
		//Players who need jobs
	var/list/unassigned = list()
		//Debug info
	var/list/job_debug = list()
/*
	var/soviet_count = 0
	var/german_count = 0
	var/civilian_count = 0
	var/partisan_count = 0
*/
	var/current_german_squad = 1
	var/current_soviet_squad = 1

	var/german_squad_members = 0
	var/german_squad_leaders = 0

	var/soviet_squad_members = 0
	var/soviet_squad_leaders = 0

	var/german_squad_info[4]
	var/soviet_squad_info[4]

	var/german_officer_squad_info[4]
	var/soviet_officer_squad_info[4]

	var/partisans_were_enabled = FALSE

	var/admin_expected_clients = 0

/datum/controller/occupations/proc/toggle_roundstart_autobalance(var/_clients = 0, var/announce = TRUE)

	//if (map)
		//map.faction_organization = map.initial_faction_organization.Copy()

	//_clients = max(max(_clients, (map ? map.min_autobalance_players : 0)))

	var/autobalance_for_players = round(max(config.max_expected_players) * 50)

	if (announce == TRUE)
		to_chat(world, "<span class = 'notice'>Setting up roundstart autobalance for [max(_clients, autobalance_for_players)] players.</span>")
	else if (announce == 2)
		if (!roundstart_hour)
			to_chat(world, "<span class = 'warning'>An admin has changed autobalance to be set up for [max(_clients, autobalance_for_players)] players.</span>")
		else
			to_chat(world, "<span class = 'warning'>An admin has reset autobalance for [max(_clients, autobalance_for_players)] players.</span>")

/datum/controller/occupations/proc/spawn_with_delay(var/mob/new_player/np, var/datum/job/j)
	// for delayed spawning, wait the spawn_delay of the job
	// and lock up one job position while np is spawning
	if (!j.spawn_delay)
		return

	//if (j.delayed_spawn_message)
		//np << j.delayed_spawn_message

	np.delayed_spawning_as_job = j

	// occupy a position slot

	j.total_positions -= 1

	spawn (j.spawn_delay)
		if (np && np.delayed_spawning_as_job == j) // if np hasn't already spawned
			// if np did spawn, unoccupy the position slot
			np.AttemptLateSpawn(j.title)
			return

/*
// full squads, not counting SLs
/datum/controller/occupations/proc/full_squads(var/team)
	switch (team)
		if (SEPARATIST)
			return round(separatist_squad_members/MEMBERS_PER_SQUAD)
		if (FEDERAL)
			return round(federal_squad_members/MEMBERS_PER_SQUAD)
	return FALSE

/datum/controller/occupations/proc/must_have_squad_leader(var/team)
	switch (team)
		if (SEPARATIST)
			if (full_squads(team) > separatist_squad_leaders && !(separatist_squad_leaders == 4))
				return TRUE
		if (FEDERAL)
			if (full_squads(team) > federal_squad_leaders && !(federal_squad_leaders == 4))
				return TRUE
	return FALSE // not relevant for other teams

/datum/controller/occupations/proc/must_not_have_squad_leader(var/team)
	switch (team)
		if (SEPARATIST)
			if (separatist_squad_leaders > separatist_squads(team))
				return TRUE
		if (FEDERAL)
			if (federal_squad_leaders > federal_squads(team))
				return TRUE
	return FALSE // not relevant for other teams
*/

/*
// too many people joined as a soldier and not enough as SL
// return FALSE if j is anything but a squad leader or special roles
/datum/controller/occupations/proc/squad_leader_check(var/mob/new_player/np, var/datum/job/j)
	var/current_squad = istype(j, /datum/job/german) ? current_german_squad : current_soviet_squad
	if (!j.is_commander && !j.is_nonmilitary && !j.is_SS && !j.is_paratrooper)
		// we're trying to join as a soldier or officer
		if (j.is_officer) // handle officer
			if (must_have_squad_leader(j.base_type_flag())) // only accept SLs
				if (!j.SL_check_independent)
					to_chat(np, "<span class = 'danger'>Squad #[current_squad] needs a Squad Leader! You can't join as anything else until it has one. You can still spawn in through reinforcements, though.</span>")
					return FALSE
				else // we're joining as the SL or another allowed role
					return TRUE
		else
			if (must_have_squad_leader(j.base_type_flag())) // only accept SLs
				if (!j.SL_check_independent)
					to_chat(np, "<span class = 'danger'>Squad #[current_squad] needs a Squad Leader! You can't join as anything else until it has one. You can still spawn in through reinforcements, though.</span>")
					return FALSE
	else
		if (must_have_squad_leader(j.base_type_flag()))
			if (!j.SL_check_independent)
				to_chat(np, "<span class = 'danger'>Squad #[current_german_squad] needs a Squad Leader! You can't join as anything else until it has one. You can still spawn in through reinforcements, though.</span>")
				return FALSE
	return TRUE

// too many people joined as a SL and not enough as soldier
// return FALSE if j is a squad leader
/datum/controller/occupations/proc/squad_member_check(var/mob/new_player/np, var/datum/job/j)
	if (!j.is_commander && !j.is_nonmilitary && !j.is_SS && !j.is_paratrooper)
		// we're trying to join as a soldier or officer
		if (j.is_officer) // handle officer
			if (must_not_have_squad_leader(j.base_type_flag())) // don't accept SLs
				if (istype(j, /datum/job/separatist/officer) || istype(j, /datum/job/soviet/squad_leader))
					to_chat(np, "<span class = 'danger'>Squad #[current_german_squad] already has a Squad Leader! You can't join as one yet.</span>")
					return FALSE
				else
					return TRUE
	else
		if (must_have_squad_leader(j.base_type_flag()))
			if (!j.SL_check_independent)
				to_chat(np, "<span class = 'danger'>Squad #[current_german_squad] needs a Squad Leader! You can't join as anything else until it has one.</span>")
				return FALSE
	return TRUE
*/