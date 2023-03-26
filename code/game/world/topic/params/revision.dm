/datum/topic/params/proc/revision(list/body)
	var/static/response
	if (!response)
		response = list2params(list(
			"gameid" = game_id,
			"dm_version" = DM_VERSION,
			"dm_build" = DM_BUILD,
			"dd_version" = world.byond_version,
			"dd_build" = world.byond_build,
			"revision" = revdata.revision || "unknown",
			"branch" = revdata.branch || "unknown",
			"date" = revdata.date || "unknown"
		))
	return response
