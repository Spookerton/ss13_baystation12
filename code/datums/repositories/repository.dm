/datum/cache_entry
	var/timestamp
	var/data

/datum/cache_entry/New()
	timestamp = world.time

/datum/cache_entry/proc/is_valid()
	return FALSE

/datum/cache_entry/valid_until/New(valid_duration)
	..()
	timestamp += valid_duration

/datum/cache_entry/valid_until/is_valid()
	return world.time < timestamp
