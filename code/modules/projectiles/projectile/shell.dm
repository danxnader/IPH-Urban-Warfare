/obj/item/projectile/shell
	name = "bullet"
	icon_state = "shell"
	damage = 200
	damage_type = BRUTE
	nodamage = FALSE
	embed = TRUE
	sharp = TRUE
	var/mob_passthrough_check = FALSE
	var/move_tiles = -1
	var/moved_tiles = FALSE
	penetrating = 10
	armor_penetration = 80
	var/caliber = 75
	atype = "HE"
	muzzle_type = /obj/effect/projectile/bullet/muzzle

/obj/item/projectile/shell/get_structure_damage()
	if (damage_type == BRUTE || damage_type == BURN)
		return damage/2
	return FALSE

/obj/item/projectile/shell/attack_mob(var/mob/living/target_mob)
	if (prob(80))
		mob_passthrough_check = TRUE
	else
		mob_passthrough_check = FALSE
	return ..()

/obj/item/projectile/shell/can_embed()
	//prevent embedding if the projectile is passing through the mob
	if (mob_passthrough_check)
		return FALSE
	return ..()

/obj/item/projectile/shell/on_impact(var/atom/A)
	impact_effect(effect_transform)		// generate impact effect
	playsound(src, "ric_sound", 50, TRUE, -2)
	if (istype(A, /turf))
		var/turf/T = A
		if (atype == "HE")
			if (!istype(T, /turf/unsimulated/beach/sand))
				T.ChangeTurf(/turf/simulated/floor/dirty)
			explosion(T, 1, 2, 2, 3)
		else
			if (!istype(T, /turf/unsimulated/beach/sand))
				T.ChangeTurf(/turf/simulated/floor/dirty)
			explosion(T, 0, 0, 1, 3)
	spawn(50)
		if (src)
			qdel(src)
	return TRUE


/obj/item/projectile/shell/launch(atom/target, mob/user, obj/structure/cannon/modern/tank/launcher, var/x_offset=0, var/y_offset=0)
	var/turf/curloc = null

	switch(launcher.dir)
		if (NORTH)
			curloc = locate(launcher.x, launcher.y+4, launcher.z)
		if (SOUTH)
			curloc = locate(launcher.x, launcher.y-4, launcher.z)
		if (WEST)
			curloc = locate(launcher.x-4, launcher.y, launcher.z)
		if (EAST)
			curloc = locate(launcher.x+4, launcher.y, launcher.z)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		qdel(src)
		return TRUE

	firer = user
	firer_original_dir = firer.dir
	shot_from = launcher

	original = target
	loc = curloc
	starting = curloc

	yo = targloc.y - curloc.y + y_offset
	xo = targloc.x - curloc.x + x_offset
	shot_from = launcher
	silenced = FALSE

	return FALSE