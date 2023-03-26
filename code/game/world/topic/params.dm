/datum/topic/params
	var/static/list/actions
	var/static/regex/legal_start


/datum/topic/json/New()
	Setup()


/datum/topic/params/Setup()
	actions = list()
	legal_start = regex(@"^[a-z]") //only lowercase letters
	for (var/path as anything in typesof(/datum/topic/params/proc))
		var/action = splittext("[path]", "/")
		action = action[length(action)]
		if (findtext_char(action, legal_start))
			actions += action


/datum/topic/params/Handle(list/body, address, from_main, list/keys, bytes)
	if (!findtext_char(body, legal_start))
		return "error=bad%23action"
	body = params2list(body)
	if (!length(body))
		return "error=bad%23action"
	for (var/action in actions)
		if (body[action])
			return call(src, action)(body)
	return "error=bad%23action"
