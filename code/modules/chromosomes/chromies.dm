/client/proc/get_chromie_count()
	establish_db_connection()
	var/DBQuery/query = dbcon.NewQuery("SELECT chromosomes FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	var/chr_count = 0
	if(query.Execute())
		if(query.NextRow())
			chr_count = query.item[1]

	qdel(query)
	return text2num(chr_count)

/client/proc/set_chromie_count(chr_count, ann=TRUE)
	establish_db_connection()
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET chromosomes = '[chr_count]' WHERE ckey = '[ckey]'")
	query.Execute()
	qdel(query)
	if(ann)
		if(chr_count >= 0)
			to_chat(src, "<span class='info'>You gain [chr_count] chromosomes.</span>")
		else
			to_chat(src, "<span class='danger'>You lose [chr_count] chromosomes.</span>")

/client/proc/inc_chromie_count(chr_count, ann=TRUE)
	establish_db_connection()
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("player")] SET chromosomes = chromosomes + '[chr_count]' WHERE ckey = '[ckey]'")
	query.Execute()
	qdel(query)
	if(ann)
		to_chat(src, "[chr_count] chromosomes have been transferred to your account.")

//query_get_chromie
//query_set_chromie
//query_inc_chromie

/mob/living/carbon/human/Stat(client/C)
	var/chr_count = C.get_chromie_count()
	. = ..()
	if(statpanel("Status"))
		stat(uppertext(CHROMOSOMES), "[round(chr_count)]")
