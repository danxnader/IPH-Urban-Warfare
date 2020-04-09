//Amount of time in deciseconds to wait before deleting all drawn segments of a projectile.
#define SEGMENT_DELETION_DELAY 2

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	pass_flags = PASS_FLAG_TABLE
	mouse_opacity = 0
	var/list/mob_hit_sound = list('sound/effects/gore/bullethit2.ogg', 'sound/effects/gore/bullethit3.ogg') //Sound it makes when it hits a mob. It's a list so you can put multiple hit sounds there.
	var/wall_hitsound = "hitwall"
	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/shot_from = "" // name of the object which shot us
	var/firer_original_dir = null
	var/atom/original = null // the target clicked (not necessarily where the projectile is headed). Should probably be renamed to 'target' or something.
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/list/segments = list() //For hitscan projectiles with tracers.
	var/turf/starting_turf = null // the projectile's starting turf
	var/atom/original_target = null // the original target clicked
	var/turf/original_target_turf = null // the original target's starting turf

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center
	var/apx //Pixel location in absolute coordinates. This is (((x - 1) * 32) + 16 + pixel_x)
	var/apy //These values are floats, not integers. They need to be converted through CEILING or such when translated to relative pixel coordinates.

	var/accuracy = 0
	var/dispersion = 0.0

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE, PAIN are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/check_armour = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = /obj/item/projectile
	var/penetrating = 0 //If greater than zero, the projectile will pass through dense objects as specified by on_penetrate()
	var/kill_count = 50 //This will de-increment every process(). When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/embed = 0 // whether or not the projectile can embed itself in the mob
	var/penetration_modifier = 0.2 //How much internal damage this projectile can deal, as a multiplier.

	var/bonus_projectiles_type 					// Type path of the extra projectiles
	var/bonus_projectiles_amount 	= 0 		// How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together
	var/bonus_projectiles_scatter	= 8			// Degrees scattered per two projectiles, each in a different direction.

	var/hitscan = 0		// whether the projectile should be hitscan
	var/step_delay = 1	// the delay between iterations if not a hitscan projectile

	var/shell_speed 				= 2 		// How fast the projectile moves

	// effect types to be used
	var/muzzle_type
	var/tracer_type
	var/impact_type

	var/fire_sound
	var/list/impact_sounds
	var/shrapnel_type = /obj/item/weapon/material/shard/shrapnel
	var/miss_sounds
	var/ricochet_sounds

	var/vacuum_traversal = 1 //Determines if the projectile can exist in vacuum, if false, the projectile will be deleted if it enters vacuum.

	var/datum/plot_vector/trajectory	// used to plot the path of the projectile
	var/datum/vector_loc/location		// current location of the projectile in pixel space
	var/matrix/effect_transform			// matrix to rotate and scale projectile effects - putting it here so it doesn't
										//  have to be recreated multiple times

	var/btype = "normal" //normal, AP (armor piercing) and HP (hollow point)
	var/atype = "normal"

	//Fired processing vars
	var/last_projectile_move = 0
	var/projectile_to_fire //What projectile the gun will fire.
	var/stored_moves = 0
	var/projectile_speed = 1 //Tiles travelled per full tick.
	var/dir_angle //0 is north, 90 is east, 180 is south, 270 is west. BYOND angles and all.
	var/x_offset //Float, not integer.
	var/y_offset

	var/proj_max_range = 30

	var/distance_travelled = 0

	var/speed = 2

/obj/item/projectile/proc/checktype()
	if (btype == "AP")
		damage *= 0.70
		penetrating *= 2
		armor_penetration *= 3
		return
	else if (btype == "HP")
		damage *= 1.3
		penetrating = 0
		armor_penetration /= 3
		return

/obj/item/projectile/Initialize()
	damtype = damage_type //TODO unify these vars properly
	if(!hitscan)
		animate_movement = SLIDE_STEPS
	else animate_movement = NO_STEPS
	. = ..()

/obj/item/projectile/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	return ..()

/obj/item/projectile/forceMove()
	..()
	if(istype(loc, /turf/space/) && istype(loc.loc, /area/space))
		qdel(src)

//TODO: make it so this is called more reliably, instead of sometimes by bullet_act() and sometimes not
/obj/item/projectile/proc/on_hit(var/atom/target, var/blocked = 0, var/def_zone = null)
	var/turf/target_loca = get_turf(target)
	if(blocked >= 100)		return 0//Full block
	if(!isliving(target))	return 0
	if(isanimal(target))	return 0

	var/mob/living/L = target
	if(damage && damage_type == BRUTE)//&& L.blood_volume
		var/splatter_dir = dir
		if(starting)
			splatter_dir = get_dir(starting, target_loca)
			target_loca = get_step(target_loca, splatter_dir)
		if(isalien(L))
			new /obj/effect/overlay/temp/dir_setting/bloodsplatter/xenosplatter(target_loca, splatter_dir)
		else
			var/blood_color = "#C80000"
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				blood_color = H.species.blood_color
			new /obj/effect/overlay/temp/dir_setting/bloodsplatter(target_loca, splatter_dir, blood_color)
		if(prob(50))
			target_loca.add_blood(L)

	L.apply_effects(0, weaken, paralyze, 0, stutter, eyeblur, drowsy, agony, blocked)
	L.stun_effect_act(stun, agony, def_zone, src)
	//radiation protection is handled separately from other armour types.
	L.apply_effect(irradiate, IRRADIATE, L.getarmor(null, "rad"))


	return 1

//called when the projectile stops flying because it collided with something
/obj/item/projectile/proc/on_impact(var/atom/A)
	impact_effect(effect_transform)		// generate impact effect
	if(damage && damage_type == BURN)
		var/turf/T = get_turf(A)
		if(T)
			T.hotspot_expose(700, 5)

//Checks if the projectile is eligible for embedding. Not that it necessarily will.
/obj/item/projectile/proc/can_embed()
	//embed must be enabled and damage type must be brute
	if(!embed || damage_type != BRUTE)
		return 0
	return 1

/obj/item/projectile/proc/get_structure_damage()
	if(damage_type == BRUTE || damage_type == BURN)
		return damage
	return 0

//return 1 if the projectile should be allowed to pass through after all, 0 if not.
/obj/item/projectile/proc/check_penetrate(var/atom/A)
	return 1

/obj/item/projectile/proc/check_fire(atom/target as mob, var/mob/living/user as mob)  //Checks if you can hit them or not.
	check_trajectory(target, user, pass_flags, item_flags, obj_flags)

//sets the click point of the projectile using mouse input params
/obj/item/projectile/proc/set_clickpoint(var/params)
	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		p_y = text2num(mouse_control["icon-y"])

	//randomize clickpoint a bit based on dispersion
	if(dispersion)
		var/radius = round((dispersion*0.443)*world.icon_size*0.8) //0.443 = sqrt(pi)/4 = 2a, where a is the side length of a square that shares the same area as a circle with diameter = dispersion
		p_x = between(0, p_x + rand(-radius, radius), world.icon_size)
		p_y = between(0, p_y + rand(-radius, radius), world.icon_size)
/*
		var/firing_angle = get_angle_with_scatter(shooter, target, get_scatter(projectile_to_fire.scatter, shooter), projectile_to_fire.p_x, projectile_to_fire.p_y)
		muzzle_flash(firing_angle, shooter)
*/

//called to launch a projectile
/obj/item/projectile/proc/launch(atom/target, var/target_zone, var/x_offset=0, var/y_offset=0, var/angle_offset=0)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return 1

	if(targloc == curloc) //Shooting something in the same turf
		target.bullet_act(src, target_zone)
		on_impact(target)
		qdel(src)
		return 0

		if(!isnull(speed))
			projectile_speed = speed

	original = target
	def_zone = target_zone

	firer = usr
	firer_original_dir = firer.dir
	shot_from = src

	spawn()
		setup_trajectory(curloc, targloc, x_offset, y_offset, angle_offset) //plot the initial trajectory
		Process()
		spawn(SEGMENT_DELETION_DELAY)
			QDEL_NULL_LIST(segments)

	return 0

//called to launch a projectile from a gun
/obj/item/projectile/proc/launch_from_gun(atom/target, mob/user, obj/item/weapon/gun/launcher, var/target_zone, var/x_offset=0, var/y_offset=0)
	if(user == target) //Shooting yourself
		user.bullet_act(src, target_zone)
		var/turf/t1 = get_turf(src)
		var/list/heard = playsound(t1, fire_sound, 0, TRUE)
		playsound(t1, "Distant_1", 100, TRUE, excluded = heard)
		qdel(src)
		return 0

	loc = get_turf(user) //move the projectile out into the world

	firer = user
	shot_from = launcher.name
	silenced = launcher.silenced

	return launch(target, target_zone, x_offset, y_offset)

//Used to change the direction of the projectile in flight.
/obj/item/projectile/proc/redirect(var/new_x, var/new_y, var/atom/starting_loc, var/mob/new_firer=null)
	var/turf/new_target = locate(new_x, new_y, src.z)

	original = new_target
	if(new_firer)
		firer = src

	setup_trajectory(starting_loc, new_target)

//Called when the projectile intercepts a mob. Returns 1 if the projectile hit the mob, 0 if it missed and should keep flying.
/obj/item/projectile/proc/attack_mob(var/mob/living/target_mob, var/distance, var/miss_modifier=0)
	if(!istype(target_mob))
		return

	//roll to-hit
	//miss_modifier = max(15*(distance-2) - round(15*accuracy) + miss_modifier, 0)
	miss_modifier = 15*(distance-2) - round(15*accuracy) + miss_modifier
	if(target_mob == src.original)
		miss_modifier -= 60
	var/hit_zone = get_zone_with_miss_chance(def_zone, target_mob, miss_modifier, ranged_attack=(distance > 1 || original != target_mob)) //if the projectile hits a target we weren't originally aiming at then retain the chance to miss

	var/result = PROJECTILE_FORCE_MISS
	if(hit_zone)
		def_zone = hit_zone //set def_zone, so if the projectile ends up hitting someone else later (to be implemented), it is more likely to hit the same part
		if(!target_mob.aura_check(AURA_TYPE_BULLET, src,def_zone))
			return 1
		result = target_mob.bullet_act(src, def_zone)

	if(result == PROJECTILE_FORCE_MISS)
		if(!silenced)
			var/miss_sounds = "sound/weapons/guns/misc/miss[rand(1,4)].ogg"
			target_mob.visible_message("<span class='notice'>\The [src] misses [target_mob] narrowly!</span>")
			if(LAZYLEN(miss_sounds))
				playsound(target_mob.loc, pick(miss_sounds), 60, 1)
		return 0

	//hit messages
	if(silenced)
		to_chat(target_mob, "<span class='danger'>You've been hit in the [parse_zone(def_zone)] by \the [src]!</span>")
	else
		target_mob.visible_message("<span class='danger'>\The [target_mob] is hit by \the [src] in the [parse_zone(def_zone)]!</span>")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
	playsound(target_mob, pick(mob_hit_sound), 60, 1)
	//admin logs
	if(!no_attack_log)
		if(istype(firer, /mob))

			var/attacker_message = "shot with \a [src.type]"
			var/victim_message = "shot with \a [src.type]"
			var/admin_message = "shot (\a [src.type])"

			admin_attack_log(firer, target_mob, attacker_message, victim_message, admin_message)
		else
			admin_victim_log(target_mob, "was shot by an <b>UNKNOWN SUBJECT (No longer exists)</b> using \a [src]")

	//sometimes bullet_act() will want the projectile to continue flying
	if (result == PROJECTILE_CONTINUE)
		return 0

	return 1

/obj/item/projectile/Bump(atom/A as mob|obj|turf|area, forced=0)
	if(A == src)
		return 0 //no

	if(A == firer)
		loc = A.loc
		return 0 //cannot shoot yourself

	if((bumped && !forced) || (A in permutated))
		return 0

	var/passthrough = 0 //if the projectile should continue flying
	var/distance = get_dist(starting,loc)

	bumped = 1
	if(ismob(A))
		var/mob/M = A
		if(istype(A, /mob/living))
			//if they have a neck grab on someone, that person gets hit instead
			var/obj/item/grab/G = locate() in M
			if(G && G.shield_assailant())
				visible_message("<span class='danger'>\The [M] uses [G.affecting] as a shield!</span>")
				if(Bump(G.affecting, forced=1))
					return //If Bump() returns 0 (keep going) then we continue on to attack M.

			passthrough = !attack_mob(M, distance)
		else
			passthrough = 1 //so ghosts don't stop bullets
	else
		playsound(loc, wall_hitsound, 50)
		passthrough = (A.bullet_act(src, def_zone) == PROJECTILE_CONTINUE) //backwards compatibility
		if(isturf(A))
			for(var/obj/O in A)
				O.bullet_act(src)
			for(var/mob/living/M in A)
				attack_mob(M, distance)

	//penetrating projectiles can pass through things that otherwise would not let them
	if(!passthrough && penetrating > 0)
		if(check_penetrate(A))
			passthrough = 1
		penetrating--

	//the bullet passes through a dense object!
	if(passthrough)
		//move ourselves onto A so we can continue on our way.
		if(A)
			if(istype(A, /turf))
				loc = A
			else
				loc = A.loc
			permutated.Add(A)
		bumped = 0 //reset bumped variable!
		return 0

	//stop flying
	on_impact(A)

	set_density(0)
	set_invisibility(101)

	qdel(src)
	return 1

/obj/item/projectile/ex_act()
	return //explosions probably shouldn't delete projectiles

/obj/item/projectile/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/obj/item/projectile/Process()
	var/first_step = 1

	spawn while(src && src.loc)
		if(kill_count-- < 1)
			on_impact(src.loc) //for any final impact behaviours
			qdel(src)
			return
		if((!( current ) || loc == current))
			current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
		if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
			qdel(src)
			return

		trajectory.increment()	// increment the current location
		location = trajectory.return_location(location)		// update the locally stored location data

		if(!location)
			qdel(src)	// if it's left the world... kill it
			return

		if (is_below_sound_pressure(get_turf(src)) && !vacuum_traversal) //Deletes projectiles that aren't supposed to bein vacuum if they leave pressurised areas
			qdel(src)
			return

		before_move()
		Move(location.return_turf())

		if(!bumped && !isturf(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					if(Bump(original))
						return

		if(first_step)
			muzzle_effect(effect_transform)
			first_step = 0
		//else if(!bumped)
			//tracer_effect(effect_transform)
		if(!hitscan)
			sleep(step_delay)	//add delay between movement iterations if it's not a hitscan weapon

//Target, firer, shot from. Ie the gun
/obj/item/projectile/proc/fire_at(atom/target, atom/shooter, atom/source, range, speed, angle, recursivity)
	if(!isnull(speed))
		projectile_speed = speed

	//Safety checks.
	if(QDELETED(target) && !isnum(angle)) //We can work with either a target or an angle, or both, but not without any.
		stack_trace("fire_at called on a QDELETED target ([target]) with no original_target_turf and a null angle.")
		qdel(src)
		return
	if(projectile_speed <= 0) //Shouldn't happen without a coder oofing, but if they do, it risks breaking a lot, so better safe than sorry.
		stack_trace("[src] achieved [projectile_speed] velocity somehow at fire_at. Type: [type]. From: [target]. Shot by: [shooter].")
		qdel(src)
		return

	if(!isnull(range))
		proj_max_range = range
	if(shooter)
		firer = shooter
		permutated += firer //Don't hit the shooter
	if(source)
		shot_from = source
	permutated += src //Don't try to hit self.
	if(!isturf(loc))
		forceMove(get_turf(src))
	starting_turf = loc

	if(target)
		original_target = target
		original_target_turf = get_turf(target)
		if(original_target_turf == loc) //Shooting from and towards the same tile. Why not?
			scan_a_turf(loc)
			qdel(src)
			return

	apx = ABS_COOR(x) //Set the absolute coordinates. Center of a tile is assumed to be (16,16)
	apy = ABS_COOR(y)

	if(isnum(angle))
		dir_angle = angle
	else
		if(isliving(target)) //If we clicked on a living mob, use the clicked atom tile's center for maximum accuracy. Else aim for the clicked pixel.
			dir_angle = round(Get_Pixel_Angle((ABS_COOR(target.x) - apx), (ABS_COOR(target.y) - apy))) //Using absolute pixel coordinates.
		else
			dir_angle = round(Get_Pixel_Angle((ABS_COOR_OFFSET(target.x, p_x) - apx), (ABS_COOR_OFFSET(target.y, p_y) - apy)))

	x_offset = round(sin(dir_angle), 0.01)
	y_offset = round(cos(dir_angle), 0.01)

	var/proj_dir
	switch(dir_angle) //The projectile starts at the edge of the firer's tile (still inside it).
		if(0, 360)
			proj_dir = NORTH
			pixel_x = 0
			pixel_y = 16
		if(1 to 44)
			proj_dir = NORTHEAST
			pixel_x = round(16 * ((dir_angle) / 45))
			pixel_y = 16
		if(45)
			proj_dir = NORTHEAST
			pixel_x = 16
			pixel_y = 16
		if(46 to 89)
			proj_dir = NORTHEAST
			pixel_x = 16
			pixel_y = round(16 * ((90 - dir_angle) / 45))
		if(90)
			proj_dir = EAST
			pixel_x = 16
			pixel_y = 0
		if(91 to 134)
			proj_dir = SOUTHEAST
			pixel_x = 16
			pixel_y = round(-15 * ((dir_angle - 90) / 45))
		if(135)
			proj_dir = SOUTHEAST
			pixel_x = 16
			pixel_y = -15
		if(136 to 179)
			proj_dir = SOUTHEAST
			pixel_x = round(16 * ((180 - dir_angle) / 45))
			pixel_y = -15
		if(180)
			proj_dir = SOUTH
			pixel_x = 0
			pixel_y = -15
		if(181 to 224)
			proj_dir = SOUTHWEST
			pixel_x = round(-15 * ((dir_angle - 180) / 45))
			pixel_y = -15
		if(225)
			proj_dir = SOUTHWEST
			pixel_x = -15
			pixel_y = -15
		if(226 to 269)
			proj_dir = SOUTHWEST
			pixel_x = -15
			pixel_y = round(-15 * ((270 - dir_angle) / 45))
		if(270)
			proj_dir = WEST
			pixel_x = -15
			pixel_y = 0
		if(271 to 314)
			proj_dir = NORTHWEST
			pixel_x = -15
			pixel_y = round(16 * ((dir_angle - 270) / 45))
		if(315)
			proj_dir = NORTHWEST
			pixel_x = -15
			pixel_y = 16
		if(316 to 359)
			proj_dir = NORTHWEST
			pixel_x = round(-15 * ((360 - dir_angle) / 45))
			pixel_y = 16
	set_dir(proj_dir)

	apx += pixel_x //Update the absolute pixels with the offset.
	apy += pixel_y

	var/matrix/rotate = matrix() //Change the bullet angle.
	rotate.Turn(dir_angle)
	transform = rotate

	var/first_move = min(projectile_speed, 1)
	var/first_moves = projectile_speed
	if(projectile_batch_move(first_move)) //Hit on first movement.
		qdel(src)
		return
	invisibility = 0 //Let there be light (visibility).
	first_moves -= first_move
	if(first_moves && projectile_batch_move(first_moves)) //First movement batch happens on the same tick.
		qdel(src)
		return

	START_PROCESSING(SSprojectiles, src) //If no hits on the first moves, enter the processing queue for next.

/obj/item/projectile/proc/required_moves_calc()
	var/elapsed_time_deciseconds = world.time - last_projectile_move
	if(!elapsed_time_deciseconds)
		return 0 //No moves needed if not a tick has passed.
	var/required_moves = (elapsed_time_deciseconds * projectile_speed) + stored_moves
	stored_moves = 0
	var/modulus_excess = MODULUS(required_moves, 1) //Fractions of a move.
	if(modulus_excess)
		required_moves -= modulus_excess
		stored_moves += modulus_excess

	if(required_moves > SSprojectiles.global_max_tick_moves)
		stored_moves += required_moves - SSprojectiles.global_max_tick_moves
		required_moves = SSprojectiles.global_max_tick_moves

	return required_moves

/*
CEILING() is used on some contexts:
1) For absolute pixel locations to tile conversions, as the coordinates are read from left-to-right (from low to high numbers) and each tile occupies 32 pixels.
So if we are on the 32th absolute pixel coordinate we are on tile 1, but if we are on the 33th (to 64th) we are then on the second tile.
2) For number of pixel moves, as it is counting number of full (pixel) moves required.
*/
#define PROJ_ABS_PIXEL_TO_TURF(abspx, abspy, zlevel) (locate(CEILING((abspx / 32), 1), CEILING((abspy / 32), 1), zlevel))
#define PROJ_ANIMATION_SPEED ((end_of_movement/projectile_speed) || (required_moves/projectile_speed)) //Movements made times deciseconds per movement.

/obj/item/projectile/proc/projectile_batch_move(required_moves)
	var/end_of_movement = 0 //In batch moves this loop, only if the projectile stopped.
	var/turf/last_processed_turf = loc
	var/x_pixel_dist_travelled = 0
	var/y_pixel_dist_travelled = 0
	for(var/i in 1 to required_moves)
		distance_travelled++
		//Here we take the projectile's absolute pixel coordinate + the travelled distance and use PROJ_ABS_PIXEL_TO_TURF to first convert it into tile coordinates, and then use those to locate the turf.
		var/turf/next_turf = PROJ_ABS_PIXEL_TO_TURF((apx + x_pixel_dist_travelled + (32 * x_offset)), (apy + y_pixel_dist_travelled + (32 * y_offset)), z)
		if(!next_turf) //Map limit.
			end_of_movement = (i-- || 1)
			break
		if(next_turf == last_processed_turf)
			x_pixel_dist_travelled += 32 * x_offset
			y_pixel_dist_travelled += 32 * y_offset
			continue //Pixel movement only, didn't manage to change turf.
		var/movement_dir = get_dir(last_processed_turf, next_turf)

		if(ISDIAGONALDIR(movement_dir)) //Diagonal case. We need to check the turf to cross to get there.
			if(!x_offset || !y_offset) //Unless a coder screws up this won't happen. Buf if they do it will cause an infinite processing loop due to division by zero, so better safe than sorry.
				stack_trace("projectile_batch_move called with diagonal movement_dir and offset-lacking. x_offset: [x_offset], y_offset: [y_offset].")
				return TRUE
			var/turf/turf_crossed_by
			var/rel_pixel_x_pre = ABS_PIXEL_TO_REL(apx + x_pixel_dist_travelled)
			var/rel_pixel_y_pre = ABS_PIXEL_TO_REL(apy + y_pixel_dist_travelled)
			var/pixel_moves_until_crossing_x_border
			var/pixel_moves_until_crossing_y_border
			switch(movement_dir)
				if(NORTHEAST)
					pixel_moves_until_crossing_x_border = CEILING(((33 - rel_pixel_x_pre) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((33 - rel_pixel_y_pre) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border) //Escapes vertically.
						turf_crossed_by = get_step(last_processed_turf, NORTH)
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border) //Escapes horizontally.
						turf_crossed_by = get_step(last_processed_turf, EAST)
					else //Escapes both borders at the same time, perfectly diagonal.
						turf_crossed_by = get_step(last_processed_turf, pick(NORTH, EAST)) //So choose at random to preserve behavior of no purely diagonal movements allowed.
				if(SOUTHEAST)
					pixel_moves_until_crossing_x_border = CEILING(((33 - rel_pixel_x_pre) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((0 - rel_pixel_y_pre) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						turf_crossed_by = get_step(last_processed_turf, SOUTH)
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						turf_crossed_by = get_step(last_processed_turf, EAST)
					else
						turf_crossed_by = get_step(last_processed_turf, pick(SOUTH, EAST))
				if(SOUTHWEST)
					pixel_moves_until_crossing_x_border = CEILING(((0 - rel_pixel_x_pre) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((0 - rel_pixel_y_pre) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						turf_crossed_by = get_step(last_processed_turf, SOUTH)
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						turf_crossed_by = get_step(last_processed_turf, WEST)
					else
						turf_crossed_by = get_step(last_processed_turf, pick(SOUTH, WEST))
				if(NORTHWEST)
					pixel_moves_until_crossing_x_border = CEILING(((0 - rel_pixel_x_pre) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((33 - rel_pixel_y_pre) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						turf_crossed_by = get_step(last_processed_turf, NORTH)
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						turf_crossed_by = get_step(last_processed_turf, WEST)
					else
						turf_crossed_by = get_step(last_processed_turf, pick(NORTH, WEST))
			if(turf_crossed_by == original_target_turf && AMMO_EXPLOSIVE)
				last_processed_turf = turf_crossed_by
				//bullet.on_hit(turf_crossed_by, src)
				turf_crossed_by.bullet_act(src)
				if(pixel_moves_until_crossing_x_border <= pixel_moves_until_crossing_y_border)
					x_pixel_dist_travelled += pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_x_border * y_offset
				else
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				end_of_movement = i
				break
			if(scan_a_turf(turf_crossed_by))
				last_processed_turf = turf_crossed_by
				if(pixel_moves_until_crossing_x_border <= pixel_moves_until_crossing_y_border) //Escapes through X or pure diagonal.
					x_pixel_dist_travelled += pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_x_border * y_offset
				else
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				end_of_movement = i
				break
		last_processed_turf = next_turf
		x_pixel_dist_travelled += 32 * x_offset
		y_pixel_dist_travelled += 32 * y_offset
		//if(next_turf == original_target_turf && AMMO_EXPLOSIVE)
			//ammo.on_hit(next_turf, src)
			//next_turf.bullet_act(src)
			//end_of_movement = i
			//break
		if(scan_a_turf(next_turf))
			end_of_movement = i
			break

	if(end_of_movement && last_processed_turf == loc)
		last_projectile_move = world.time
		return TRUE

	apx += x_pixel_dist_travelled
	apy += y_pixel_dist_travelled

	var/new_pixel_x = ABS_PIXEL_TO_REL(apx) //The final pixel offset after this movement. Float value.
	var/new_pixel_y = ABS_PIXEL_TO_REL(apy)
	if(projectile_speed > 5) //At this speed the animation barely shows. Changing the vars through animation alone takes almost 5 times the CPU than setting them directly. No need for that if there's nothing to show for it.
		pixel_x = round(new_pixel_x, 1) - 16
		pixel_y = round(new_pixel_y, 1) - 16
		forceMove(last_processed_turf)
	else //Pixel shifts during the animation, which happens after the fact has happened. Light travels slowly here...
		var/old_pixel_x = new_pixel_x - x_pixel_dist_travelled //The pixel offset relative to the new position of where we came from. Float value.
		var/old_pixel_y = new_pixel_y - y_pixel_dist_travelled
		pixel_x = round(old_pixel_x, 1) - 16 //Projectile's sprite is displaced back to where it came from through relative pixel offset. Integer value.
		pixel_y = round(old_pixel_y, 1) - 16 //We substract 16 because this value should range from 1 to 32, but pixel offset usually ranges within the same tile from -15 to 16 (depending on the sprite).
		if(last_processed_turf != loc)
			forceMove(last_processed_turf)
		animate(src, pixel_x = (round(new_pixel_x, 1) - 16), pixel_y = (round(new_pixel_y, 1) - 16), time = PROJ_ANIMATION_SPEED, flags = ANIMATION_END_NOW) //Then we represent the movement through the animation, which updates the position to the new and correct one.

	last_projectile_move = world.time
	if(end_of_movement) //We hit something ...probably!
		return TRUE
	return FALSE //No hits ...yet!

#undef PROJ_ABS_PIXEL_TO_TURF
#undef PROJ_ANIMATION_SPEED

/obj/item/projectile/proc/scan_a_turf(turf/turf_to_scan)
	if(turf_to_scan.density) //Handle wall hit.
		//ammo.on_hit_turf(turf_to_scan, src)
		turf_to_scan.bullet_act(src)
		return TRUE

/*
	if(shot_from)
		switch(SEND_SIGNAL(shot_from, COMSIG_PROJ_SCANTURF, turf_to_scan))
			if(COMPONENT_PROJ_SCANTURF_TURFCLEAR)
				return FALSE
			if(COMPONENT_PROJ_SCANTURF_TARGETFOUND)
				original_target.do_projectile_hit(src)
				return TRUE
*/

	for(var/i in turf_to_scan)
		if(i in permutated) //If we've already handled this atom, don't do it again.
			continue
		permutated += i //Don't want to hit them again, no matter what the outcome.

	//var/atom/movable/thing_to_hit = i

		//if(!thing_to_hit.projectile_hit(src)) //Calculated from combination of both ammo accuracy and gun accuracy.
			//continue

		//thing_to_hit.do_projectile_hit(src)
		//return TRUE

		//return FALSE

//----------------------------------------------------------
			//				    	\\
			//  HITTING THE TARGET  \\
			//						\\
			//						\\
//----------------------------------------------------------

/*
//returns probability for the projectile to hit us.
/atom/proc/projectile_hit(obj/item/projectile/proj)
	return FALSE

/atom/proc/do_projectile_hit(obj/item/projectile/proj)
	return


/obj/projectile_hit(obj/item/projectile/proj)
	if(!density)
		return FALSE
	if(layer >= OBJ_LAYER || src == proj.original_target)
		return TRUE
	return FALSE

/obj/do_projectile_hit(obj/item/projectile/proj)
	proj.ammo.on_hit_obj(src, proj)
	bullet_act(proj)


/obj/structure/projectile_hit(obj/item/projectile/proj)
	if(!density) //structure is passable
		return FALSE
	if(src == proj.original_target) //clicking on the structure itself hits the structure
		return TRUE
	if(!anchored) //unanchored structure offers no protection.
		return FALSE
	if(!throwpass)
		return TRUE
	if(proj.ammo.flags_ammo_behavior & AMMO_SNIPER || proj.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS || proj.ammo.flags_ammo_behavior & AMMO_ROCKET) //sniper, rockets and IFF rounds bypass cover
		return FALSE
	if(!(flags_atom & ON_BORDER))
		return FALSE //window frames, unflipped tables
	if(!(proj.dir & dir|REVERSE_DIR(dir)))
		return FALSE //no effect if bullet direction is perpendicular to barricade
	var/distance = proj.distance_travelled - 1
	if(distance < proj.ammo.barricade_clear_distance)
		return FALSE
	var/coverage = 90 //maximum probability of blocking projectile
	var/distance_limit = 6 //number of tiles needed to max out block probability
	var/accuracy_factor = 50 //degree to which accuracy affects probability   (if accuracy is 100, probability is unaffected. Lower accuracies will increase block chance)
	var/hitchance = min(coverage, (coverage * distance/distance_limit) + accuracy_factor * (1 - proj.accuracy/100))
	return prob(hitchance)
*/

/obj/item/projectile/proc/before_move()
	return 0

/obj/item/projectile/proc/setup_trajectory(turf/startloc, turf/targloc, var/x_offset = 0, var/y_offset = 0)
	// setup projectile state
	starting = startloc
	current = startloc
	yo = targloc.y - startloc.y + y_offset
	xo = targloc.x - startloc.x + x_offset

	// trajectory dispersion
	var/offset = 0
	if(dispersion)
		var/radius = round(dispersion*9, 1)
		offset = rand(-radius, radius)

	// plot the initial trajectory
	trajectory = new()
	trajectory.setup(starting, original, pixel_x, pixel_y, angle_offset=offset)

	// generate this now since all visual effects the projectile makes can use it
	effect_transform = new()
	effect_transform.Scale(trajectory.return_hypotenuse(), 1)
	effect_transform.Turn(-trajectory.return_angle())		//no idea why this has to be inverted, but it works

	transform = turn(transform, -(trajectory.return_angle() + 90)) //no idea why 90 needs to be added, but it works

/obj/item/projectile/proc/muzzle_effect(var/matrix/T)
	if(silenced)
		return

	if(ispath(muzzle_type))
		var/obj/effect/projectile/M = new muzzle_type(get_turf(src))

		if(istype(M))
			M.set_transform(T)
			//var/list/modifiers = params2list(params)
		//icon-x/y is relative to the object clicked. click_catcher may occupy several tiles. Here we convert them to the proper offsets relative to the tile.
			//M.modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
			//M.modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
			//M.params = list2params(M.modifiers)
			if(!hitscan) //Bullets don't hit their target instantly, so we can't link the deletion of the muzzle flash to the bullet's Destroy()
				spawn(1)
					qdel(M)
			else
				segments += M

/*
/obj/item/projectile/proc/tracer_effect(var/matrix/M)
	if(ispath(tracer_type))
		var/obj/effect/projectile/P = new tracer_type(location.loc)

		if(istype(P))
			P.set_transform(M)
		//icon-x/y is relative to the object clicked. click_catcher may occupy several tiles. Here we convert them to the proper offsets relative to the tile.
			P.modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
			P.modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
			P.params = list2params(P.modifiers)
			if(!hitscan)
				spawn(step_delay)	//if not a hitscan projectile, remove after a single delay. Do not spawn hitscan projectiles. EVER.
					qdel(P)
			else
				segments += P
*/

/obj/item/projectile/proc/impact_effect(var/matrix/M)
	if(ispath(impact_type))
		var/obj/effect/projectile/P = new impact_type(location.loc)

		if(istype(P))
			P.set_transform(M)
			P.pixel_x = location.pixel_x
			P.pixel_y = location.pixel_y
			segments += P

//"Tracing" projectile
/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101 //Nope!  Can't see me!
	yo = null
	xo = null
	var/result = 0 //To pass the message back to the gun.

/obj/item/projectile/test/Bump(atom/A as mob|obj|turf|area)
	if(A == firer)
		loc = A.loc
		return //cannot shoot yourself
	if(istype(A, /obj/item/projectile))
		return
	if(istype(A, /mob/living) || istype(A, /obj/mecha) || istype(A, /obj/vehicle))
		result = 2 //We hit someone, return 1!
		return
	result = 1
	return

/obj/item/projectile/test/launch(atom/target)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(target)
	if(!curloc || !targloc)
		return 0

	original = target

	//plot the initial trajectory
	setup_trajectory(curloc, targloc)
	return Process(targloc)

/obj/item/projectile/test/Process(var/turf/targloc)
	while(src) //Loop on through!
		if(result)
			return (result - 1)
		if((!( targloc ) || loc == targloc))
			targloc = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge

		trajectory.increment()	// increment the current location
		location = trajectory.return_location(location)		// update the locally stored location data

		Move(location.return_turf())

		var/mob/living/M = locate() in get_turf(src)
		if(istype(M)) //If there is someting living...
			return 1 //Return 1
		else
			M = locate() in get_step(src,targloc)
			if(istype(M))
				return 1

//Helper proc to check if you can hit them or not.
/proc/check_trajectory(atom/target as mob|obj, atom/firer as mob|obj, var/pass_flags=PASS_FLAG_TABLE|PASS_FLAG_GLASS|PASS_FLAG_GRILLE, item_flags = null, obj_flags = null)
	if(!istype(target) || !istype(firer))
		return 0

	var/obj/item/projectile/test/trace = new /obj/item/projectile/test(get_turf(firer)) //Making the test....

	//Set the flags and pass flags to that of the real projectile...
	if(!isnull(item_flags))
		trace.item_flags = item_flags
	if(!isnull(obj_flags))
		trace.obj_flags = obj_flags
	trace.pass_flags = pass_flags

	var/output = trace.launch(target) //Test it!
	qdel(trace) //No need for it anymore
	return output //Send it back to the gun!

/*
/proc/fire_bonus_projectiles(obj/item/projectile/main_proj, atom/shooter, atom/source, range, speed, angle)
	for(var/i = 1 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
		var/obj/item/projectile/new_proj = new /obj/item/projectile(main_proj.loc)
		if(bonus_projectiles_type)
			new_proj.generate_bullet(GLOB.ammo_list[bonus_projectiles_type]) //No bonus damage or anything.
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)
		new_proj.accuracy = round(new_proj.accuracy * main_proj.accuracy/initial(main_proj.accuracy)) //if the gun changes the accuracy of the main projectile, it also affects the bonus ones.

		 //Scatter here is how many degrees extra stuff deviate from the main projectile, first two the same amount, one to each side, and from then on the extra pellets keep widening the arc.
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((i % 2) ? -(i + 1 / 2) : i / 2))
		if(new_angle < 0)
			new_angle += 380
		else if(new_angle > 380)
			new_angle -= 380
		new_proj.fire_at(null, shooter, source, range, speed, new_angle, TRUE) //Angle-based fire. No target.
*/

/*
/turf/bullet_act(obj/item/projectile/proj)
	bullet_ping(proj)

	var/list/livings_list = list() //Let's built a list of mobs on the bullet turf and grab one.
	for(var/mob/living/L in src)
		if(L in proj.permutated)
			continue
		livings_list += L

	if(!length(livings_list))
		return TRUE

	var/mob/living/picked_mob = pick(livings_list)
	if(proj.projectile_hit(picked_mob))
		picked_mob.bullet_act(proj)
	return TRUE
*/