
/obj/machinery/streetlight
	name = "Streetlight"
	icon = 'icons/obj/streetlight.dmi'
	icon_state = "streetlamp1"
	density = 1
	var/on = 1 //should always be on
	var/obj/item/weapon/cell/cell = null
	var/use = 200 // 200W light
	var/unlocked = 0
	var/open = 0
	var/brightness_on = 12		//can't remember what the maxed out value is. also, it's a streetlight.

/obj/machinery/streetlight/New()
	cell = new/obj/item/weapon/cell/crap(src)
	turn_on()
	..()

/obj/machinery/streetlight/proc/turn_off(var/loud = 0)
	on = 0
	set_light(0, 0)
	update_icon()
	if(loud)
		visible_message("\The [src] shuts down.")


/obj/machinery/streetlight/update_icon()
	overlays.Cut()
	icon_state = "streetlamp0"

/obj/machinery/streetlight/Process()
	if(!on)
		return

	if(!cell || (cell.charge < (use * CELLRATE)))
		turn_off(1)
		return

	// If the cell is almost empty rarely "flicker" the light. Aesthetic only.
	if((cell.percent() < 10) && prob(5))
		set_light(brightness_on/2, brightness_on/4)
		spawn(20)
			if(on)
				set_light(brightness_on, brightness_on/2)

	cell.use(use*CELLRATE)

/obj/machinery/streetlight/attack_ai(mob/user as mob)
	if(istype(user, /mob/living/silicon/robot) && Adjacent(user))
		return attack_hand(user)

/obj/machinery/streetlight/proc/turn_on(var/loud = 0)
	if(!cell)
		return 0
	if(cell.charge < (use * CELLRATE))
		return 0

	on = 1
	set_light(brightness_on, brightness_on / 2)
	update_icon()
	if(loud)
		visible_message("\The [src] turns on.")
	return 1
