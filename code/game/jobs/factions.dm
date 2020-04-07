
/* Job Factions
 - These are/will be used for civils and the factions themselves.
 - They're like antagonist datums but much simpler. You can have many
 - different factions depending on your job
 - helper functions are at the bottom
*/

#define TEAM_RU 1
#define TEAM_SE 2
#define TEAM_CV 3
#define TEAM_BA 4


var/global/spies[6]
var/global/officers[6]
var/global/commanders[6]
var/global/squad_leaders[6]
var/global/soldiers[6]
var/global/squad_members[6]

/datum/faction
	// redefine these since they don't exist in /datum
	var/icon = 'icons/mob/hud_uw.dmi'
	var/icon_state = ""
	var/mob/living/carbon/human/holder = null
	var/title = "Something that shouldn't exist. Ping Turret."
	var/list/objectives = list()
	var/team = null
	var/image/last_returned_image = null
	var/obj/factionhud/last_returned_hud = null

/datum/faction/proc/base_type()
	return "/datum/faction"

/datum/faction/partisan
	icon_state = "partisan_soldier"
	title = "Bandit"
	team = TEAM_BA

/datum/faction/partisan/base_type()
	return "/datum/faction/partisan"

// you appear to be an officer to all other partisans (UNUSED)
/datum/faction/partisan/officer
	icon_state = "partisan_officer"
	team = TEAM_BA

// you appear to be a partisan leader to all other partisans
/datum/faction/partisan/commander
	icon_state = "partisan_commander"
	title = "Bandit Leader"
	team = TEAM_BA

/*
// you appear to be a partisan to all other partisans
/datum/faction/partisan
	icon_state = "partisan_soldier"
	title = "Partisan Soldier"
	team = TEAM_PN

/datum/faction/partisan/base_type()
	return "/datum/faction/partisan"

// you appear to be an officer to all other partisans (UNUSED)
/datum/faction/partisan/officer
	icon_state = "partisan_officer"
	team = TEAM_PN
// you appear to be a partisan leader to all other partisans
/datum/faction/partisan/commander
	icon_state = "partisan_commander"
	title = "Partisan Leader"
	team = TEAM_PN
*/

// you appear to be a german soldier to all other germans
/datum/faction/separatist
	icon_state = "chechen_soldier"
	title = "Separatist Grunt"
	team = TEAM_SE

/datum/faction/separatist/base_type()
	return "/datum/faction/separatist"
// you appear to be a SS soldier to all other germans/italians

// you appear to be an officer to all other germans/italians
/datum/faction/separatist/officer
	icon_state = "chechen_officer"
	title = "Separatist Officer"
	team = TEAM_SE
// you appear to be a german leader to all other germans/italians
/datum/faction/separatist/commander
	icon_state = "chechen_commander"
	title = "Separatist Leader"
	team = TEAM_SE

// you appear to be a soviet soldier to all other sovivets
/datum/faction/federal
	icon_state = "russian_soldier"
	title = "Federal Soldier"
	team = TEAM_RU

/datum/faction/federal/base_type()
	return "/datum/faction/federal"

/datum/faction/federal/officer
	icon_state = "soviet_officer"
	title = "Federal Officer"
	team = TEAM_RU
// you appear to be a soviet leader to all other soviets
/datum/faction/federal/commander
	icon_state = "soviet_commander"
	title = "Federal General"
	team = TEAM_RU

// squads: both german and soviet use the same types. What squad you appear
// to be in, and to whom, depends on your true faction. Spies

/datum/faction/squad
	var/squad = null
	var/is_leader = FALSE
	var/number = "#1"
	var/actual_number = TRUE
	New(var/mob/living/carbon/human/H, var/datum/job/J)

		var/squadmsg = ""

		if (!is_leader)
			squadmsg = "<span class = 'danger'>You've been assigned to squad [squad].[istype(J, /datum/job/federal) ? " Meet with the rest of your squad on train car [number]. " : " "]Examine people to see if they're in your squad, or if they're your squad leader."
		else
			squadmsg = "<span class = 'danger'>You are the [J.title] of squad [squad].[istype(J, /datum/job/federal) ? " Meet with your squad on train car [number]. " : " "]Examine people to see if they're one of your soldiers."

		squadmsg = replacetext(squadmsg, "<span class = 'danger'>", "")
		squadmsg = replacetext(squadmsg, "</span>", "")

		H.add_memory(squadmsg)

		..(H, J)

/datum/faction/squad/one
	icon_state = "squad_one"
	squad = "one"
	number = "#1"
	actual_number = TRUE
/datum/faction/squad/one/leader
	icon_state = "squad_one_leader"
	is_leader = TRUE

/datum/faction/squad/two
	icon_state = "squad_two"
	squad = "two"
	number = "#2"
	actual_number = 2
/datum/faction/squad/two/leader
	icon_state = "squad_two_leader"
	is_leader = TRUE

/datum/faction/squad/three
	icon_state = "squad_three"
	squad = "three"
	number = "#3"
	actual_number = 3
/datum/faction/squad/three/leader
	icon_state = "squad_three_leader"
	is_leader = TRUE

/datum/faction/squad/four
	icon_state = "squad_four"
	squad = "four"
	number = "#4"
	actual_number = 4
/datum/faction/squad/four/leader
	icon_state = "squad_four_leader"
	is_leader = TRUE

// spies use normal faction types

// CODE
/datum/faction/New(var/mob/living/carbon/human/H, var/datum/job/J)

	if (!H || !istype(H))
		return

	holder = H

/*
	if (findtext("[type]", "leader"))
		if (istype(J, /datum/job/german))
			squad_leaders[GERMAN]++
		else if (istype(J, /datum/job/soviet))
			squad_leaders[SOVIET]++
		else if (istype(J, /datum/job/partisan))
			squad_leaders[PARTISAN]++
*/
	if (findtext("[type]", "officer"))
		if (istype(J, /datum/job/separatist))
			officers[SEPARATIST]++
		else if (istype(J, /datum/job/federal))
			officers[FEDERAL]++
		else if (istype(J, /datum/job/partisan))
			officers[PARTISAN]++
/*
	else if (findtext("[type]", "commander"))
		if (istype(J, /datum/job/german))
			commanders[GERMAN]++
		else if (istype(J, /datum/job/soviet))
			commanders[SOVIET]++
		else if (istype(J, /datum/job/partisan))
			commanders[PARTISAN]++
*/

	else if (!J.is_officer && !J.is_commander && !J.is_squad_leader)
		if (istype(J, /datum/job/separatist))
			if ("[type]" == "/datum/faction/german")
				soldiers[SEPARATIST]++
		else if (istype(J, /datum/job/federal))
			if ("[type]" == "/datum/faction/federal")
				soldiers[FEDERAL]++
		else if (istype(J, /datum/job/partisan))
			if ("[type]" == "/datum/faction/partisan")
				soldiers[PARTISAN]++
	H.all_factions += src
	..()

/* HELPER FUNCTIONS */

/proc/issquadleader(var/mob/living/carbon/human/H)
	if (H.squad_faction && H.squad_faction.is_leader)
		return TRUE
	return FALSE

/proc/issquadmember(var/mob/living/carbon/human/H)
	if (H.squad_faction && !H.squad_faction.is_leader)
		return TRUE
	return FALSE

/proc/getsquad(var/mob/living/carbon/human/H)
	if (H.squad_faction)
		return H.squad_faction.squad
	return null

/proc/isseparatistsquadmember_or_leader(var/mob/living/carbon/human/H)
	return (istype(H.original_job, /datum/job/separatist) && getsquad(H))

/proc/isseparatistsquadleader(var/mob/living/carbon/human/H)
	return (istype(H.original_job, /datum/job/separatist) && issquadleader(H))

/proc/isfederalsquadmember_or_leader(var/mob/living/carbon/human/H)
	return (istype(H.original_job, /datum/job/federal) && getsquad(H))

/proc/isfederalsquadleader(var/mob/living/carbon/human/H)
	return (istype(H.original_job, /datum/job/federal) && issquadleader(H))

/proc/sharesquads(var/mob/living/carbon/human/H, var/mob/living/carbon/human/HH)
	return (getsquad(H) && getsquad(H) == getsquad(HH))

/proc/isleader(var/mob/living/carbon/human/H, var/mob/living/carbon/human/HH)
	if (issquadleader(H) && issquadmember(HH) && getsquad(H) == getsquad(HH))
		return TRUE
	return FALSE