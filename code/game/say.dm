GLOBAL_DATUM_INIT(sanitize_say, /regex, regex(@"[^\x20-\x3b\x3d\x3f-\x7e\n]", "g"))

/atom/movable/proc/Say(message, list/classes = list(), list/mutators = list(), range = 7)
	GLOB.sanitize_say
	DoSay(message, classes, mutators, range)

/atom/movable/proc/DoSay(message, list/classes = list(), list/mutators = list(), range = 7)
	set waitfor = FALSE
	var/turf/source = get_turf(src)
	if (!source)
		return
	var/list/already_heard = list()
	for (var/atom/movable/candidate in dview(range, source, INVISIBILITY_MAXIMUM))
		if (candidate.movable_flags & MOVABLE_FLAG_HEARER)
			candidate.Hear(message, src, classes, mutators)
			already_heard += candidate
	for (var/mob/player as anything in GLOB.player_list)
		if (player.stat == DEAD && !(player in already_heard))
			player.Hear(message, src, classes, mutators + list("distant_observer" = TRUE))


/atom/movable/proc/Hear(message, atom/movable/source, list/classes, list/mutators)
	return



/mob/living/Hear(message, atom/movable/source, list/classes, list/mutators)
	if (!client)
		return
	//TODO

/obj/item/device/taperecorder/Hear(message, atom/movable/source, list/classes, list/mutators)
	if (!recording)
		return
	//TODO

/obj/item/device/radio/Hear(message, atom/movable/source, list/classes, list/mutators)
	if (!on || !listening)
		return
	if (istype(source, /obj/item/device/radio))
		return
	//TODO
