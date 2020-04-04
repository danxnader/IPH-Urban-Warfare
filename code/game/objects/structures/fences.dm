/obj/structure/fence
	name = "fence"
	desc = "A fence. There's nothing else to say."
	icon = 'icons/turf/fence.dmi'
	icon_state = "fence"
	density = 1
	anchored = 1
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	layer = BELOW_OBJ_LAYER
	explosion_resistance = 1
	var/health = 15
	var/destroyed = 0

/obj/structure/fence/ex_act(severity)
	qdel(src)

/obj/structure/fence/update_icon()
	if(destroyed)
		icon_state = "[initial(icon_state)]-b"
	else
		icon_state = initial(icon_state)

/*
/obj/structure/fence/Bumped(atom/user)
	if(ismob(user)) shock(user, 70) // electric fences later?
*/

/obj/structure/fence/attack_hand(mob/user as mob)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.do_attack_animation(src)

	var/damage_dealt = 1
	var/attack_message = "kicks"
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_message = "mangles"
			damage_dealt = 5

	//if(shock(user, 70))
		//return

	if(HULK in user.mutations)
		damage_dealt += 5
	else
		damage_dealt += 1

	attack_generic(user,damage_dealt,attack_message)

/obj/structure/fence/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover) && mover.checkpass(PASS_FLAG_GRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !density

/obj/structure/fence/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return

	//Fences are not that great at stopping, well, anything, but they can still make someone miss if they're REALLY dumb.
	var/damage = Proj.get_structure_damage()
	var/passthrough = 0

	if(!damage) return

	switch(Proj.damage_type)
		if(BRUTE)
			//bullets
			if(Proj.original == src || prob(10)) //more likely to pass through
				Proj.damage *= between(0, Proj.damage/60, 0.5)
				if(prob(max((damage-10)/25, 0))*100)
					passthrough = 1
			else
				Proj.damage *= between(0, Proj.damage/60, 1)
				passthrough = 1
		if(BURN)
			if(!(Proj.original == src || prob(20)))
				Proj.damage *= 0.5
				passthrough = 1

	if(passthrough)
		. = PROJECTILE_CONTINUE
		damage = between(0, (damage - Proj.damage)*(Proj.damage_type == BRUTE? 0.4 : 1), 10)

	src.health -= damage*0.2
	spawn(0) healthcheck()

/obj/structure/fence/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			set_density(0)
			destroyed = 1
			update_icon()
			new /obj/item/stack/rods(get_turf(src))

		else
			if(health <= -6)
				new /obj/item/stack/rods(get_turf(src))
				qdel(src)
				return
	return
