/datum/topic/params/proc/manifest(list/body)
	var/static/response
	var/static/last_update
	if (!response || world.time - last_update > 10 SECONDS)
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
		response = list2params(result)
		last_update = world.time
	return response
