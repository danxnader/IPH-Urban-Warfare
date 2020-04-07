
/datum/job/var/allow_spies = FALSE
/datum/job/var/is_officer = FALSE
/datum/job/var/is_squad_leader = FALSE
/datum/job/var/is_commander = FALSE
/datum/job/var/is_petty_commander = FALSE
/datum/job/var/is_nonmilitary = FALSE
/datum/job/var/spawn_delay = FALSE
/datum/job/var/delayed_spawn_message = ""
/datum/job/var/is_SS = FALSE
/datum/job/var/is_SS_TV = FALSE
/datum/job/var/is_prisoner = FALSE
/datum/job/var/is_reichstag = FALSE
/datum/job/var/is_dirlewanger = FALSE
/datum/job/var/is_partisan = FALSE
/datum/job/var/is_primary = TRUE
/datum/job/var/is_secondary = FALSE
/datum/job/var/is_paratrooper = FALSE
/datum/job/var/is_special = FALSE
/datum/job/var/is_sturmovik = FALSE
/datum/job/var/is_guard = FALSE
/datum/job/var/is_tankuser = FALSE
/datum/job/var/blacklisted = FALSE
/datum/job/var/is_redcross = FALSE
/datum/job/var/is_terek = FALSE
/datum/job/var/is_uia = FALSE
/datum/job/var/is_croation = FALSE
/datum/job/var/is_prisoner_unique = FALSE
/datum/job/var/is_escort = FALSE
/datum/job/var/is_target = FALSE //for VIP modes
/datum/job/var/is_occupation = FALSE
/datum/job/var/rank_abbreviation = null

// new autobalance stuff - Kachnov
/datum/job/var/min_positions = 1 // absolute minimum positions if we reach player threshold
/datum/job/var/max_positions = 1 // absolute maximum positions if we reach player threshold
/datum/job/var/player_threshold = 0 // number of players who have to be on for this job to be open
/datum/job/var/scale_to_players = 50 // as we approach this, our open positions approach max_positions. Does nothing if min_positions == max_positions, so just don't touch it

/* type_flag() replaces flag, and base_type_flag() replaces department_flag
 * this is a better solution than bit constants, in my opinion */

/datum/job
	var/_base_type_flag = -1

/datum/job/proc/specialcheck()
	return TRUE

/datum/job/proc/type_flag()
	return "[type]"

/datum/job/proc/base_type_flag(var/most_specific = FALSE)

	if (_base_type_flag != -1)
		return _base_type_flag

	if (istype(src, /datum/job/federal))
		. = FEDERAL
	else if (istype(src, /datum/job/partisan))
		if (istype(src, /datum/job/partisan/bandit))
			. = PARTISAN
	else if (istype(src, /datum/job/separatist))
		if (!most_specific)
			. = SEPARATIST


	_base_type_flag = .
	return _base_type_flag

/datum/job/proc/get_side_name()
	return capitalize(lowertext(base_type_flag()))

/datum/job/proc/assign_faction(var/mob/living/carbon/human/user)

	if (!squad_leaders[SEPARATIST])
		squad_leaders[SEPARATIST] = FALSE
	if (!squad_leaders[FEDERAL])
		squad_leaders[FEDERAL] = FALSE
	if (!squad_leaders[PARTISAN])
		squad_leaders[PARTISAN] = FALSE

	if (!officers[SEPARATIST])
		officers[SEPARATIST] = FALSE
	if (!officers[FEDERAL])
		officers[FEDERAL] = FALSE
	if (!officers[PARTISAN])
		officers[PARTISAN] = FALSE

	if (!commanders[SEPARATIST])
		commanders[SEPARATIST] = FALSE
	if (!commanders[FEDERAL])
		commanders[FEDERAL] = FALSE
	if (!commanders[PARTISAN])
		commanders[PARTISAN] = FALSE

	if (!soldiers[SEPARATIST])
		soldiers[SEPARATIST] = FALSE
	if (!soldiers[FEDERAL])
		soldiers[FEDERAL] = FALSE
	if (!soldiers[PARTISAN])
		soldiers[PARTISAN] = FALSE


	if (!squad_members[SEPARATIST])
		squad_members[SEPARATIST] = FALSE
	if (!squad_members[FEDERAL])
		squad_members[FEDERAL] = FALSE
	if (!squad_members[PARTISAN])
		squad_members[PARTISAN] = FALSE

	if (!istype(user))
		return

	if (istype(src, /datum/job/separatist))
		user.faction_text = "SEPARATIST"
			user.base_faction = new/datum/faction/separatist(user, src)

		if (is_officer && !is_commander)
			user.officer_faction = new/datum/faction/separatist/officer(user, src)

		else if (is_commander)
			user.officer_faction = new/datum/faction/separatist/commander(user, src)

	else if (istype(src, /datum/job/federal))
		user.faction_text = "FEDERAL"
		user.base_faction = new/datum/faction/federal(user, src)

		if (is_officer && !is_commander)
			user.officer_faction = new/datum/faction/federal/officer(user, src)

		else if (is_commander)
			user.officer_faction = new/datum/faction/federal/commander(user, src)

	else if (istype(src, /datum/job/partisan))
		user.faction_text = "PARTISAN"
		user.base_faction = new/datum/faction/partisan(user, src)
		if (is_officer && !is_commander)
			user.officer_faction = new/datum/faction/partisan/officer(user, src)
		else if (is_commander)
			user.officer_faction = new/datum/faction/partisan/commander(user, src)

/datum/job/proc/try_make_jew(var/mob/living/carbon/human/user)
	return // disabled

/datum/job/proc/try_make_initial_spy(var/mob/living/carbon/human/user)
	return // disabled

/datum/job/proc/try_make_latejoin_spy(var/mob/user)
	return //disabled

/datum/job/proc/opposite_faction_name()
	if (istype(src, /datum/job/federal))
		return "Separatist Rebels"
	else
		return FEDERAL
		/*
// make someone a spy regardless, allowing them to swap uniforms
/datum/job/proc/make_spy(var/mob/living/carbon/human/user)
	user << "<span class = 'danger'>You are the spy.</span><br>"
	user << "<span class = 'warning'>Sabotage your own team wherever possible. To change your uniform and radio to the [opposite_faction_name()] one, right click your uniform and use 'Swap'. You know both Russian and German; to change your language, use the IC tab.</span>"
	user.add_memory("Spy Objectives")
	user.add_memory("")
	user.add_memory("")
	user.add_memory("Sabotage your own team wherever possible. To change your uniform and radio to the [opposite_faction_name()] one, right click your uniform and use 'Swap'. You know both Russian and German; to change your language, use the IC tab.")
	user.is_spy = TRUE // lets admins see who's a spy
	var/mob/living/carbon/human/H = user
	if (istype(H))
		var/obj/item/clothing/under/under = H.w_uniform
		if (under && istype(under))
			under.add_alternative_setting()
	if (istype(src, /datum/job/german))
		if (!H.languages.Find(RUSSIAN))
			H.add_language(RUSSIAN, TRUE)
		H.spy_faction = new/datum/faction/soviet()
	else
		if (!H.languages.Find(GERMAN))
			H.add_language(GERMAN, TRUE)
		H.spy_faction = new/datum/faction/german()
*/

/proc/get_side_name(var/side, var/datum/job/j)
	if (side == PARTISAN)
		return "Civilians and Banditry"
	if (side == FEDERAL)
		return "Federal Forces"
	if (side == SEPARATIST)
		return "Separatist Rebels"
	return null
