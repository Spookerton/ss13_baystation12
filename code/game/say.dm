/// Allows printable symbols in the Basic Latin codeblock, except for > and <
GLOBAL_DATUM_INIT(sanitize_say_en, /regex, regex(@"[^\x20-\x3b\x3d\x3f-\x7e\n]", "g"))

/// Allows sanitize_say_en, as well as the Cyrillic codeblock
GLOBAL_DATUM_INIT(sanitize_say_ru, /regex, regex(@"[^\x20-\x3b\x3d\x3f-\x7e\n\u0400-\u04ff]", "g"))

/// Removes leading and trailing whitespace
GLOBAL_DATUM_INIT(sanitize_say_trim, /regex, regex(@"^\s*(.*)\s*$", "g"))

var/global/const/SAY_SKIP_SANITIZE = FLAG(0)
var/global/const/SAY_VISIBLE = FLAG(1)
var/global/const/SAY_DISTANT_OBSERVER = FLAG(2)


/atom/movable/proc/Speak(message, list/classes = list(), list/mutators = list(), range = 7, flags = EMPTY_BITFIELD)
	SendMessage(message, classes, mutators, range, flags)


/atom/movable/proc/AudibleEmote(message, list/classes = list(), list/mutators = list(), range = 7, flags = EMPTY_BITFIELD)
	SendMessage(message, classes, mutators, range, flags)


/atom/movable/proc/VisibleEmote(message, list/classes = list(), list/mutators = list(), range = 7, flags = EMPTY_BITFIELD)
	SendMessage(message, classes, mutators, range, flags | SAY_VISIBLE)


/atom/movable/proc/SendMessage(message, list/classes, list/mutators, range, flags)
	if (!(flags & SAY_SKIP_SANITIZE))
		message = replacetext_char(message, GLOB.sanitize_say_trim, "$1")
		message = replacetext_char(message, GLOB.sanitize_say_en, "")
		if (!message)
			return
	var/turf/source = get_turf(src)
	if (!source)
		return
	var/list/receivers = list()
	for (var/atom/movable/candidate in dview(range, source, INVISIBILITY_MAXIMUM))
		if (candidate?.movable_flags & MOVABLE_FLAG_HEARER)
			receivers[candidate] = flags
	for (var/mob/player as anything in GLOB.player_list)
		if (player.stat == dead)
			if (player in receivers)
				receivers[player] = flags | SAY_NEARBY_OBSERVER
			else
				receivers[player] = flags
	for (var/atom/movable/receiver as anything in receivers)
		receiver.ReceiveMessage(message, src, classes, mutators, receivers[receiver])


/atom/movable/proc/ReceiveMessage(message, atom/movable/sender, list/classes = list(), list/mutators = list(), flags = EMPTY_BITFIELD)
	return


/mob/living/ReceiveMessage(message, atom/movable/sender, list/classes = list(), list/mutators = list(), flags = EMPTY_BITFIELD)
	if (!client)
		return
	var/datum/language/language = mutators["language"]
	var/datum/accent/accent = mutators["accent"]
	//TODO

/mob/observer/ghost/ReceiveMessage(message, atom/movable/sender, list/classes = list(), list/mutators = list(), flags = EMPTY_BITFIELD)
	return


/obj/item/device/taperecorder/ReceiveMessage(message, atom/movable/sender, list/classes = list(), list/mutators = list(), flags = EMPTY_BITFIELD)
	if (!recording)
		return
	//TODO


/obj/item/device/radio/ReceiveMessage(message, atom/movable/sender, list/classes = list(), list/mutators = list(), flags = EMPTY_BITFIELD)
	if (!on || !listening)
		return
	if (istype(source, /obj/item/device/radio))
		return
	//TODO
