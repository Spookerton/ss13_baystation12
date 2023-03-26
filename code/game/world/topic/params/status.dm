/datum/topic/params/proc/status(list/body)
	var/static/response
	var/static/last_update
	if (!response || world.time - last_update > 10 SECONDS)
		var/list/players = list()
		var/list/admins = list()
		var/active = 0
		for (var/client/client in GLOB.clients)
			if (client.holder)
				if (client.is_stealthed())
					continue
				admins[client.ckey] = client.holder.rank
			players += client.ckey
			if (istype(client.mob, /mob/living))
				++active
		response = list2params(list(
			"version" = config.game_version,
			"mode" = SSticker.master_mode,
			"stationtime" = stationtime2text(),
			"roundduration" = roundduration2text(),
			"map" = replacetext_char(GLOB.using_map.full_name, "\improper", ""),
			"players" = length(players),
			"admins" = length(admins),
			"playerlist" = list2params(players),
			"adminlist" = list2params(admins),
			"active_players" = active
		))
		last_update = world.time
	return response
