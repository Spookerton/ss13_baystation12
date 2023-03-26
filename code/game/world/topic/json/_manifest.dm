/datum/topic/json/proc/_manifest(list/body)
	var/list/result = list()
	var/list/manifest = nano_crew_manifest()
	for (var/group_name in manifest)
		var/list/group = manifest[group_name]
		if (!length(group))
			continue
		var/list/people = list()
		for (var/person in group)
			people[person["name"]] = person["rank"]
		result[group_name] = people
	return list(
		"manifest" = result
	)
