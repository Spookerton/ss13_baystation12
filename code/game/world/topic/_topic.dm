/world/Topic(list/body, address, from_main, list/keys)
	var/bytes = length(body)
	if (!bytes || bytes > 1024)
		return -1
	if (!address)
		return -2
	var/static/list/cooldown_by_address = list()
	var/list/cooldown = cooldown_by_address[address]
	if (!cooldown)
		cooldown_by_address[address] = list(world.time, 1)
	else
		var/burst = cooldown[2] + 1
		if (burst > 3)
			burst = max(0, burst - (world.time - cooldown[1]) * 0.1)
			cooldown[1] = world.time
			cooldown[2] = burst
			if (burst > 3)
				return -3
	if (body[1] != "{")
		if (config.topic_allow_params)
			var/static/datum/topic/params/params
			if (!params)
				params = new
			return params.Handle(body, address, from_main, keys, bytes)
		return -4
	if (config.topic_allow_json)
		var/static/datum/topic/json/json
		if (!json)
			json = new
		return json.Handle(body, address, from_main, keys, bytes)
	return -5


/datum/topic
	abstract_type = /datum/topic


/datum/topic/proc/Setup()
	return


/datum/topic/proc/Handle(list/body, address, from_main, list/keys, bytes)
	return
