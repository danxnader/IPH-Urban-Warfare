/datum/controller/process/fancydaynight
	name = "day night cycler"
	schedule_interval = 20 //short time for testing purposes
	var/stateofday = "day" //starts off on day
	var/turf/dayturf = /turf/simulated/floor/grass //Wanna make day time turn the world to lava? Adminbus makes it possible.
	var/turf/nightturf = /turf/simulated/floor/grass
	var/turf/currentturf //Turf for stuff to be made into
	var/currentlum = 255 //Game starts off white and transition to night later on
	var/intx = 0

/datum/controller/process/fancydaynight/setup()
	nighttoday() //game starts off dark; make it daytime

/datum/controller/process/fancydaynight/doWork()
	if(stateofday == "day")
		stateofday = "night"
		daytonight()
	else
		stateofday = "day"
		nighttoday()

/datum/controller/process/fancydaynight/proc/daytonight()
	to_world("<span class='warning'>The night begins to come.</span>")
	while(currentlum != 255) //loop it a couple of times from darkness to complete day
		intx = 0
		while(intx != 255)
			sleep(1)
			for(var/turf/turf in block(locate(intx, 1, 1), locate(intx, world.maxy, 1)))
				if(!turf)
					continue
				turf.adjustambientlight(currentlum)
			intx += 1
		currentlum = max(currentlum + 50, 255)
	to_world("<span class='warning'>The night is coming. It is now dangerous.</span>")


/datum/controller/process/fancydaynight/proc/nighttoday()
	to_world("<span class='warning'>The night is slowly going away.</span>")
	while(currentlum != 1) //loop it a couple of times from darkness to complete day
		intx = 0
		while(intx != 255)
			sleep(1)
			for(var/turf/turf in block(locate(intx, 1, 1), locate(intx, world.maxy, 1)))
				if(!turf)
					continue
				turf.adjustambientlight(currentlum)
			intx += 1
		currentlum = max(currentlum - 50, 1)
	to_world("<span class='warning'>The night has now ended.</span>")


/turf/proc/adjustambientlight(currentlum)
	for (var/datum/lighting_corner/corner in corners)
		corner.lum_r = currentlum
		corner.lum_g = currentlum
		corner.lum_b = currentlum
		corner.update_overlays()