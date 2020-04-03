/obj/structure/sign/flag
	var/ripped = FALSE
	icon = 'icons/obj/decals.dmi'
/obj/structure/sign/flag/attack_hand(mob/user as mob)
	if (!ripped)
		playsound(loc, 'sound/items/poster_ripped.ogg', 100, TRUE)
		for (var/i = FALSE to 3)
			if (do_after(user, 10))
				playsound(loc, 'sound/items/poster_ripped.ogg', 100, TRUE)
			else
				return
		visible_message("<span class='warning'>[user] rips [src]!</span>" )
		qdel(src)

/obj/structure/sign/flag/soviet
	name = "Soviet flag"
	desc = "A gloryful flag."
	icon_state = "flag_soviet"

/obj/structure/sign/flag/russia
	name = "Russian flag"
	desc = "A flag showing the russian colors flag."
	icon_state = "flag_russia"

/obj/structure/sign/flag/un
	name = "UN flag"
	desc = "A flag showing peace."
	icon_state = "flag_un"

/obj/structure/sign/flag/chechen
	name = "Chechen flag"
	desc = "A gloryful flag."
	icon_state = "flag_chechen"
