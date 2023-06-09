GLOBAL_LIST_EMPTY(news_networks)
GLOBAL_LIST_EMPTY(news_channels)


/// A news network is the collection of channels and receivers associated with a z-group.
/datum/news_network
	/// A cache of standard channels
	var/static/list/datum/news_channel/channel_cache = list()

	/// A map of ("channel name" = channel) associated with this news network
	var/list/datum/news_channel/channels = list()

	/// A list of newscasters associated with this news network
	var/list/obj/machinery/newscaster/newscasters = list()

	/// A list of nano programs currently open in this network's levels
	var/list/datum/nano_module/program/newsreel/programs = list()

	/// A list of z-levels this network is available on
	var/list/z_levels = list()


/datum/news_network/Destroy()
	GLOB.news_networks -= src
	var/list/safe_channels = subtypesof(/datum/news_channel/standard)
	for (var/channel in channels)
		if (channel in safe_channels)
			continue
		qdel(channel)
	LAZYCLEARLIST(channels)
	LAZYCLEARLIST(newscasters)
	LAZYCLEARLIST(programs)
	LAZYCLEARLIST(z_levels)
	return ..()


/datum/news_network/New()
	GLOB.news_networks += src


/datum/news_network/AddStandardChannels()
	for (var/datum/news_channel/channel as anything in subtypesof(/datum/news_channel/standard))
		if (length(GLOB.news_channels))


		channel = new channel
		channels[channel.name] = channel
		channel.CreateArticles(


	for (var/datum/news_channel/channel as anything in subtypesof(/datum/news_channel/default))
		if (length(GLOB.news_channels))

		channel = new channel
		channels[channel.name] = channel
		channel.CreateArticles()


/datum/news_network/proc/CreateChannel(name, creator, locked, protected, announcement)
	if (channels[name])
		qdel(channels[name])
	if (!announcement)
		announcement = "Breaking news from [name]!"
	channels[name] = new /datum/news_channel (name, creator, locked, protected, announcement)
	return channels[name]


/datum/news_network/proc/CreateArticle(datum/news_channel/channel, author, body, obj/item/photo)
	var/datum/news_channel/channel = channels[name]
	if (!channel)
		return
	new /datum/news_article (channel, author, body, photo)
	Alert(channel.announcement)


/datum/news_network/proc/Alert(announcement)
	for(var/obj/machinery/newscaster/newscaster as anything in newscasters)
		newscaster.Alert(announcement)
		newscaster.update_icon()
	for(var/datum/nano_module/program/newsreel/program as anything in programs)
		program.news_alert(announcement)




		CreateChannel("Announcements", "Announcements", TRUE, TRUE, "New Announcement Available")
	CreateChannel("Official News Bulletin", "Ministry of Solar Enlightenment", TRUE, FALSE)
	var/datum/event/mundane_news/mundane_news = /datum/event/mundane_news/mundane_news
	CreateChannel(initial(mundane_news.channel), initial(mundane_news.channel), TRUE, FALSE)
	var/datum/event/trivial_news/trivial_news = /datum/event/trivial_news/trivial_news
	CreateChannel(initial(trivial_news.channel), initial(trivial_news.channel), TRUE, FALSE)
