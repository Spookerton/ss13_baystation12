/datum/topic/json/proc/_players(list/body)
	var/list/players = list()
	for (var/client/client as anything in GLOB.clients)
		players += client?.ckey
	return list(
		"players" = players
	)
