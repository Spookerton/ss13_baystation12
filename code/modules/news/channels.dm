/datum/news_channel/standard
	abstract_type = /datum/news_channel/standard


/datum/news_channel/standard/announcements
	name = "Announcements"
	locked = TRUE
	protected = TRUE


/datum/news_channel/standard/canon
	name = "The Solar Observer"
	use_cache = TRUE
	locked = TRUE
	articles_dir = "data/news/solar_observer/"


/datum/news_channel/standard/tabloid
	name = "The Gibson Gazette"
	use_cache = TRUE
	locked = TRUE
	author = "Editor Mike Hammers"


/datum/news_channel/standard/broadsheet
	name = "Spacer's Digest"
	use_cache = TRUE
	locked = TRUE

	var/static/list/broadsheet_authors = list(
		"Anika Bhat, Associate Editor",
		"Pierce Sterling, Contributor",
		"Aken Klein, Contributor",
		"Mulekatete Uwera, Contributor",
		"Kathryn O'Connell, Contributor",
		"Mali Saejung, Contributor",
		"Aziz 19, Aggregator"
	)


/datum/news_channel/standard/broadsheet/Destroy()
	authors = null
	return ..()


/datum/news_channel/standard/broadsheet/New()
	authors = broadsheet_authors
