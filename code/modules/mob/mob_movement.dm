/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !density || lying)
	else
		return (!mover.density || !density || lying)
	return

/mob/proc/setMoveCooldown(var/timeout)
	if(client)
		client.move_delay = max(world.time + timeout, client.move_delay)

/client/North()
	..()


/client/South()
	..()


/client/West()
	..()


/client/East()
	..()


/client/proc/client_dir(input, direction=-1)
	return turn(input, direction*dir2angle(dir))


/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living))
		var/mob/living/L = mob
		L.swap_hand()
	if(istype(mob,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return

/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return

/mob/proc/hotkey_drop()
	to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")

/mob/living/carbon/hotkey_drop()
	if(!get_active_hand())
		to_chat(usr, "<span class='warning'>You have nothing to drop in your hand.</span>")
	else
		drop_item()

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, "<span class='notice'>You are not pulling anything.</span>")
		return
	usr.stop_pulling()

/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return

/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob) && mob.stat == CONSCIOUS && isturf(mob.loc))
		return mob.drop_item()
	return

/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.set_dir(direct)
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return


/client/Move(n, direct)
	if(world.time < move_delay) //do not move anything ahead of this check please
		return FALSE
	else
		next_move_dir_add = 0
		next_move_dir_sub = 0

	if(!mob?.loc)
		return FALSE

	if(!n || !direct)
		return FALSE

	if(mob.notransform)
		return FALSE	//This is sota the goto stop mobs from moving var

	if(!isliving(mob))
		return mob.Move(n, direct)

	if(mob.stat == DEAD)
		mob.ghostize()
		return FALSE

	var/mob/living/L = mob  //Already checked for isliving earlier

	var/double_delay = FALSE
	if(direct in GLOB.diagonals)
		double_delay = TRUE

	//Check if you are being grabbed and if so attemps to break it
	if(L.pulledby)
		if(L.incapacitated(TRUE))
			return
		else if(L.restrained(TRUE))
			move_delay = world.time + 10 //to reduce the spam
			to_chat(src, "<span class='warning'>You're restrained! You can't move!</span>")
			return
		else
			return L.resist_grab(TRUE)

	if(L.buckled)
		return L.buckled.relaymove(L, direct)

	if(!L.canmove)
		return

	if(isobj(L.loc) || ismob(L.loc))//Inside an object, tell it we moved
		var/atom/O = L.loc
		return O.relaymove(L, direct)

	if(isturf(L.loc))
		if(double_delay && L.cadecheck()) //Hacky
			direct = get_cardinal_dir(n, L.loc)
			direct = DIRFLIP(direct)
			n = get_step(L.loc, direct)

		L.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1+config.run_speed
			if("walk")
				move_delay += 7+config.walk_speed
		move_delay += mob.movement_delay()
		//We are now going to move
		moving = TRUE
		glide_size = 32 / max(move_delay, tick_lag) * tick_lag

		if(L.confused)
			step(L, pick(GLOB.cardinal))
		else
			. = ..()

		moving = FALSE

		if(mob.pulling)
			mob.dir = turn(mob.dir, 180)
			mob.update_vision_cone()

		return

		if(double_delay)
			move_delay = world.time + (move_delay * SQRTWO)
		else
			move_delay = world.time + move_delay
		return .

/mob/proc/SelfMove(turf/n, direct)
	return Move(n, direct)

///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)

	switch(mob.incorporeal_move)
		if(1)
			var/turf/T = get_step(mob, direct)
			if(mob.check_is_holy_turf(T))
				to_chat(mob, "<span class='warning'>You cannot enter holy grounds while you are in this plane of existence!</span>")
				return
			else
				mob.forceMove(get_step(mob, direct))
				mob.dir = direct
		if(2)
			if(prob(25))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				mob.forceMove(locate(locx,locy,mobloc.z))
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, mob.loc))
						spawn(0)
							anim(T,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
				mob.forceMove(get_step(mob, direct))
			mob.dir = direct
	// Crossed is always a bit iffy
	for(var/obj/S in mob.loc)
		if(istype(S,/obj/effect/step_trigger) || istype(S,/obj/effect/beam))
			S.Crossed(mob)

	var/area/A = get_area_master(mob)
	if(A)
		A.Entered(mob)
	if(isturf(mob.loc))
		var/turf/T = mob.loc
		T.Entered(mob)
	mob.Post_Incorpmove()
	return 1

/mob/proc/Post_Incorpmove()
	return

///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(var/check_drift = 0)
	if(!Check_Dense_Object()) //Nothing to push off of so end here
		update_floating()
		return 0

	if(restrained()) //Check to see if we can do things
		return 0

	update_floating()
	return 1


/mob/proc/check_solid_ground()
	if(istype(loc, /turf/space))
		return 0

	//Check to see if we slipped
	if(prob(Process_Spaceslipping(0)) && !buckled)
		src << "<font color='blue'><B>You slipped!</B></font>"
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1

/mob/proc/Check_Dense_Object() //checks for anything to push off in the vicinity. also handles magboots on gravity-less floors tiles

	var/dense_object = 0
	var/shoegrip

	for(var/turf/turf in oview(1,src))
		if(istype(turf,/turf/space))
			continue

		if(istype(turf,/turf/simulated/floor)) // Floors don't count if they don't have gravity
			var/area/A = turf.loc
			if(istype(A) && A.has_gravity == 0)
				if(shoegrip == null)
					shoegrip = Check_Shoegrip() //Shoegrip is only ever checked when a zero-gravity floor is encountered to reduce load
				if(!shoegrip)
					continue

		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
		dense_object++

	if(!dense_object && (locate(/obj/structure/catwalk) in oview(1, src)))
		dense_object++


	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in oview(1, src))
			if((O) && (O.density) && (O.anchored))
				dense_object++
				break

	return dense_object

/mob/proc/Check_Shoegrip()
	return 0

/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		return 0
	if(Check_Shoegrip())
		return 0
	return prob_slip

	prob_slip = round(prob_slip)
	return(prob_slip)

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/update_gravity()
	return
/*
// The real Move() proc is above, but touching that massive block just to put this in isn't worth it.
/mob/Move(var/newloc, var/direct)
	. = ..(newloc, direct)
	if(.)
		post_move(newloc, direct)
*/
// Called when a mob successfully moves.
// Would've been an /atom/movable proc but it caused issues.
/mob/Moved(atom/oldloc)
	for(var/obj/O in contents)
		O.on_loc_moved(oldloc)

// Received from Moved(), useful for items that need to know that their loc just moved.
/obj/proc/on_loc_moved(atom/oldloc)
	return

/obj/item/weapon/storage/on_loc_moved(atom/oldloc)
	for(var/obj/O in contents)
		O.on_loc_moved(oldloc)

/client/verb/moveup()
	set name = ".moveup"
	set instant = 1
	Move(get_step(mob, NORTH), NORTH)
/client/verb/movedown()
	set name = ".movedown"
	set instant = 1
	Move(get_step(mob, SOUTH), SOUTH)
/client/verb/moveright()
	set name = ".moveright"
	set instant = 1
	Move(get_step(mob, EAST), EAST)
/client/verb/moveleft()
	set name = ".moveleft"
	set instant = 1
	Move(get_step(mob, WEST), WEST)

/mob/proc/cadecheck()
	var/list/coords = list(list(x + 1, y, z), list(x, y + 1, z), list(x - 1, y, z), list(x, y - 1, z))
	for(var/i in coords)
		var/list/L = i
		var/turf/T = locate(L[1], L[2], L[3])
		for(var/obj/structure/barricade/B in T.contents)
			return TRUE
	return FALSE
