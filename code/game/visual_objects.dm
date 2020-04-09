/atom/movable/vis_obj

/atom/movable/vis_obj/action
	appearance_flags = NO_CLIENT_COLOR
	layer = HUD_LAYER
	plane = HUD_PLANE
	icon = 'icons/mob/actions.dmi'

/atom/movable/vis_obj/effect/muzzle_flash
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "muzzle_flash"
	layer = ABOVE_HUMAN_LAYER
	plane = GAME_PLANE
	var/applied = FALSE

/atom/movable/vis_obj/effect/muzzle_flash/Initialize(mapload, new_icon_state)
	. = ..()
	if(new_icon_state)
		icon_state = new_icon_state