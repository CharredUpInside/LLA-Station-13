/datum/round_event_control/xenosky_infestation
	name = "Xenosky Infestation"
	typepath = /datum/round_event/xenosky_infestation
	max_occurrences = 0
	needs_ghosts = 1
	players_needed = 10
	rating = list(
				"Gameplay"	= 90,
				"Dangerous"	= 90
				)

/datum/round_event/xenosky_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/round_event/xenosky_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)

/datum/round_event/xenosky_infestation/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/round_event/xenosky_infestation/announce()
	if(successSpawn)
		priority_announce("Unidentified security hardware detected aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg')

/datum/round_event/xenosky_infestation/tick_queue()
	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
	if(candidates.len)
		unqueue()

/datum/round_event/xenosky_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 20)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
	if(!candidates.len && events.queue_ghost_events && !loopsafety)
		queue()
		return
	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/carbon/alien/beepsky/larva/new_xeno = new(vent.loc)
		new_xeno.key = C.key

		spawncount--
		successSpawn = 1

/datum/round_event/xenosky_infestation/declare_completion()
	var/alien_count = 0
	for(var/mob/living/carbon/alien/beepsky/humanoid/H in world)
		if(H.stat != DEAD)
			alien_count++
	for(var/mob/living/carbon/alien/beepsky/larva/L in world)
		if(L.stat != DEAD)
			alien_count++
	if(alien_count)
		return "<b>Xenosky Infestation:</b> <font color='red'>[alien_count] Alien(s) survived</font>"
	else
		return "<b>Xenosky Infestation:</b> <font color='green'>All aliens were wiped out from [station_name]</font>"