/datum/religion/allah
	name = ALLAH
	holy_item = new /obj/item/weapon/grenade/frag()
	var/bloodgold = FALSE
	whisper_lines = list("You will fight them off, my children.", "Be wise, and fortune will come.")
	offering_items = list(/obj/item/weapon/spacecash/bundle/c100, /obj/item/stack/material/gold/ten, /obj/item/stack/material/silver/ten)

/datum/religion/greed/generate_random_phrase()
		var/phrase = pick("Oh great [name] ", "Oh [name]. ", "[name], our Benefactor. ")
		phrase += pick("You enrich our lives ", "You will shower us with eternal paradise in afterlife ", "You bathe our cities and villages in your opulence. ")
		phrase += pick("In your golden light ", "[name] bless us all. ", "[name] look over us all. ")
		phrase += "Amen."
		return phrase
