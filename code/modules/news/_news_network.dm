/datum/news_network
	var/list/levels
	var/list/datum/computer_file/program/news_reader/readers
	var/list/datum/news_channel/channels
	var/list/datum/news_channel/censored_channels
	var/list/datum/news_article/censored_articles


/datum/news_network/Destroy()
	LAZYCLEARLIST(levels)
	LAZYCLEARLIST(readers)
	for (var/datum/news_channel/channel as anything in channels)
		if (channel.type != /datum/news_channel)
			continue
		qdel(channel)
	LAZYCLEARLIST(channels)
	LAZYCLEARLIST(censored_channels)
	LAZYCLEARLIST(censored_articles)
	return ..()
