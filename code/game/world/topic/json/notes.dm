/datum/topic/json/proc/notes(list/body)
	var/ckey = body["ckey"]
	if (!ckey)
		return @(~){"error":"missing ckey"}~
	var/path = "data/player_saves/[copytext_char(ckey, 1, 2)]/[ckey]/info.sav"
	if (!fexists(path))
		return @(~){"notes":[]}~
	var/list/info_list
	var/savefile/info_file = new (path)
	from_save(info_file, info_list)
	if (!info_list)
		info_list = list()
	var/skipped = 0
	var/list/notes = list()
	var/approx_result_size = 12
	for (var/index = length(info_list) to 1 step -1)
		var/datum/player_info/info = info_list[index]
		if (!info?.content)
			continue
		var/approx_note_size = 9 + length(info.content)
		var/list/note = list(
			"body" = info.content
		)
		if (info.timestamp)
			note["time"] = info.timestamp
			approx_note_size += 9 + length(info.timestamp)
		if (info.author)
			note["user"] = info.author
			approx_note_size += 9 + length(info.author)
		if (info.game_id)
			note["game"] = info.game_id
			approx_note_size += 9 + length(info.game_id)
		approx_result_size += approx_note_size
		if (approx_result_size > 32000)
			skipped = index
			break
		notes += list(note)
	return list(
		"skipped" = skipped,
		"notes" = notes
	)
