/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB

/datum/keybinding/carbon/toggle_throw_mode
	hotkey_keys = list("R")
	classic_keys = list("Southwest") // END
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	keybind_signal = COMSIG_KB_CARBON_TOGGLETHROWMODE_DOWN

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	if(!iscarbon(user.mob))
		return FALSE
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE


/datum/keybinding/carbon/select_help_intent
	hotkey_keys = list("1")
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTHELPINTENT_DOWN

/datum/keybinding/carbon/select_help_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(I_HELP)
	return TRUE


/datum/keybinding/carbon/select_disarm_intent
	hotkey_keys = list("2")
	name = "select_disarm_intent"
	full_name = "Select disarm intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTDISARMINTENT_DOWN

/datum/keybinding/carbon/select_disarm_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(I_DISARM)
	return TRUE


/datum/keybinding/carbon/select_grab_intent
	hotkey_keys = list("3")
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTGRABINTENT_DOWN

/datum/keybinding/carbon/select_grab_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(I_GRAB)
	return TRUE


/datum/keybinding/carbon/select_harm_intent
	hotkey_keys = list("4")
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTHARMINTENT_DOWN

/datum/keybinding/carbon/select_harm_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(I_HURT)
	return TRUE

/*
/datum/keybinding/carbon/specialclick
	hotkey_keys = list("Ctrl")
	name = "specialclick"
	full_name = "Special Click"
	description = "Hold this hotkey_keys and click to trigger special object interactions."
	keybind_signal = COMSIG_KB_CARBON_SPECIALCLICK_DOWN


/datum/keybinding/carbon/specialclick/down(client/user)
	. = ..()
	if(.)
		return
	RegisterSignal(user.mob, list(COMSIG_MOB_CLICKON), .proc/specialclicky)
	RegisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP), .keybinding/proc/intercept_mouse_special)
	return TRUE


/datum/keybinding/carbon/specialclick/up(client/user)
	UnregisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_CLICKON))
	return TRUE

/datum/keybinding/carbon/specialclick/proc/specialclicky(datum/source, atom/A, params)
	var/mob/living/carbon/user = source
	if(!user.client || !(user.client.eye == user || user.client.eye == user.loc))
		UnregisterSignal(user, (COMSIG_MOB_CLICKON))
		return
	A.specialclick(user)
*/