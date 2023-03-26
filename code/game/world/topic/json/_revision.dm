/datum/topic/json/proc/_revision(list/body)
	return list(
		"revision" = revdata.revision || "unknown",
		"branch" = revdata.branch,
		"date" = revdata.date,
		"gameid" = game_id,
		"dm_version" = DM_VERSION,
		"dm_build" = DM_BUILD,
		"dd_version" = world.byond_version,
		"dd_build" = world.byond_build
	)
