/datum/topic/json
	var/static/list/actions
	var/static/regex/legal_start


/datum/topic/json/New()
	Setup()


/datum/topic/json/Setup()
	actions = list()
	legal_start = regex(@"^[a-z_]")
	for (var/path as anything in typesof(/datum/topic/json/proc))
		var/action = splittext("[path]", "/")
		action = action[length(action)]
		if (findtext_char(action, legal_start))
			actions += action


/datum/topic/json/Handle(list/body, address, is_master, list/keys, bytes)
	try
		body = json_decode(body)
	catch (var/exception/err_json)
		err_json = err_json //TODO 515 use pragma to de-warn
		world.log << "world/Topic PARSE [address] [bytes]"
		return @(~){"error":"bad json"}~
	var/action = body["action"]
	if (action in actions)
		if (action[1] != "_" && (!config.topic_secret || body["auth"] != config.topic_secret))
			world.log << "world/Topic AUTH [address] [action]"
			return @(~){"error":"unauthorized"}~
		try
			var/result = call(src, action)(body)
			if (!istext(result))
				result = json_encode(result)
			world.log << "world/Topic OK [address] [action]"
			return result
		catch (var/exception/err_call)
			err_call = err_call //TODO use runtime usefully
			world.log << "world/Topic CRASH [address] [action]"
			return @(~){"error":"action crash"}~
	world.log << "world/Topic UNKNOWN [address] [action]"
	return @(~){"error":"unknown action"}~
