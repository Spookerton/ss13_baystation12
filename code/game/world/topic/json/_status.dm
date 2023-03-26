/datum/topic/json/proc/_status(list/body)
	var/active = 0
	var/list/players = list()
	var/list/admins = list()
	for (var/client/client as anything in GLOB.clients)
		if (!client)
			continue
		if (client.holder && !client.is_stealthed())
			admins += client.ckey
		else
			players += client.ckey
		if (istype(client.mob, /mob/living))
			++active
	return list(
		"version" = config.game_version,
		"mode" = SSticker.master_mode,
		"duration" = roundduration2text(),
		"map" = replacetext_char(GLOB.using_map?.full_name, "\improper", ""),
		"players" = players,
		"admins" = admins,
		"active" = active
	)
