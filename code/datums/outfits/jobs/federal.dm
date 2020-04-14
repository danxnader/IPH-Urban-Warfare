/decl/hierarchy/outfit/job/federal
	hierarchy_type = /decl/hierarchy/outfit/job/federal
	//id = /obj/item/device/radio/headset/federal //radio revamp someday...WRONG
	shoes = /obj/item/clothing/shoes/jackboots
	backpack_contents = list(/obj/item/ammo_magazine/c762 = 2) //Yep. Everyone has mags for now.

/*
/decl/hierarchy/outfit/job/federal/New()
	..()
	BACKPACK_OVERRIDE_FEDERAL //will add later
*/

/decl/hierarchy/outfit/job/federal/soldier
	name = OUTFIT_JOB_NAME("Federal Soldier")
	uniform = /obj/item/clothing/under/uniform/federal
	head = /obj/item/clothing/head/helmet/coldwar/ssh68
	l_hand = /obj/item/weapon/gun/projectile/automatic/ak74
	suit = /obj/item/clothing/suit/storage/vest/vest/a6b5

/decl/hierarchy/outfit/job/federal/medic
	name = OUTFIT_JOB_NAME("Federal Medic")
	uniform = /obj/item/clothing/under/uniform/federal
	head = /obj/item/clothing/head/cap/federal
	l_hand = /obj/item/weapon/gun/projectile/automatic/ak74
	suit = /obj/item/clothing/suit/armor/pcarrier/tan/tactical//let's see how this looks...

/decl/hierarchy/outfit/job/federal/medic/post_equip(var/mob/living/carbon/human/H)
	..()
	if(H.age>17)
		var/obj/item/clothing/uniform = H.w_uniform
		if(uniform)
			var/obj/item/clothing/accessory/armband/med = new()
			if(uniform.can_attach_accessory(med))
				uniform.attach_accessory(null, med)
			else
				qdel(med)

///decl/hierarchy/outfit/job/federal/officer

///decl/hierarchy/outfit/job/federal/general
