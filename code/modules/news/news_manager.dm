GLOBAL_DATUM_INIT(news_manager, /datum/news_manager, new)

/datum/news_manager
	/// A list of all news networks
	var/static/list/datum/news_network/networks = list()

	/// A map of (news_article -> list(news_network, ...))
	var/static/list/datum/news_article/censored_articles = list()

	/// A map of (news_channel -> list(news_network, ...))
	var/static/list/datum/news_channel/censored_channels = list()

	/// A map of ("channel name" => list(article, ...))
	var/static/list/datum/news_article/article_cache = list()

	/// A map of (channel/path => news_channel)
	var/static/list/datum/news_channel/channel_cache = list()


/datum/news_manager/New()
	for (var/datum/news_channel/channel as anything in subtypesof(/datum/news_channel))
		channel = new channel
		if (channel.load_path)
			LoadFromFiles(channel)
		channel_cache[channel.type] = channel


/datum/news_manager/proc/GetNetworkByZ(z)
	for (var/datum/news_network/network as anything in networks)
		if (z in network.levels)
			return network


/datum/news_manager/proc/ClearReader(datum/nano_module/program/news_reader/reader)
	if (reader.network)
		reader.network.readers -= reader
		reader.network = null
		return
	for (var/datum/news_network/network as anything in networks)
		if (reader in network.readers)
			network.readers -= reader
	reader.network = null


/datum/news_manager/proc/UpdateReader(datum/nano_module/program/news_reader/reader)
	ClearReader(reader)
	var/reader_z = get_host_z(reader)
	if (!reader_z)
		return
	var/datum/news_network/network = GetNetworkByZ(reader_z)
	if (network)
		network.readers += reader
		return
	network = new
	network.levels = GetConnectedZlevels(reader_z)
	network.readers = list(reader)
	network.channels = GetDefaultChannels()
	network.censored_channels = list()
	network.censored_articles = list()
	networks += network


/datum/news_manager/proc/SanitizeIdentityText(text)
	var/static/regex/disallowed_symbols = regex(@"[^A-Za-z0-9 -_()&!]", "g")
	text = copytext_char(1, 32)
	text = text_strip_symbols(text, disallowed_symbols)
	text = text_squash_whitespace(text)
	return text


/datum/news_manager/proc/CreateUserChannel(z, name, creator, locked)
	if (z < 1 || z > world.maxz || round(z) != z)
		return
	name = SanitizeIdentityText(name)
	creator = SanitizeIdentityText(creator)
	if (!name || !creator)
		return
	var/datum/news_channel/channel = new
	channel.name = name
	channel.creator = creator
	channel.locked = !!locked
	var/datum/news_network/network = GetNetworkByZ(z)
	if (!network)
		network = new
		network.levels = GetConnectedZlevels(z)
		network.channels = list()
	AddNetworkChannel(network, channel)


/datum/news_manager/proc/CreateArticle(datum/news_channel/channel, content, author, image, caption, created)
	var/static/regex/content_sanitizer = regex(@"[^\x20-\x3b\x3d\x3f-\x7e\n]", "g")
	if (!istype(channel))
		return 1
	if (author)
		author = SanitizeIdentityText(author)
		if (!author)
			return 2
	if (!author)
		if (islist(channel.author))
			author = pick(channel.author)
		else if (istext(channel.author))
			author = channel.author
		else
			return 3
	content = text_strip_symbols(text, content_sanitizer)
	if (!content)
		return 4
	if (!created)
		created = time_stamp()
	var/datum/news_article/article = new
	article.content = content
	article.author = author
	article.image = image
	if (image)
		image_cache_id = "[]"
		var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
		asset_cache.cache[]
	article.caption = caption
	article.created = created
	if (channel.type == /datum/news_channel)
		return
	var/list/cache = article_cache[channel.name]
	if (!cache)
		cache = list()
		article_cache[channel.name] = cache
	cache += article
