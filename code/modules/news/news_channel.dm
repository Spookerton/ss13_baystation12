/datum/news_channel
	abstract_type = /datum/news_channel

	var/static/regex/disallowed_identity_symbols = regex(@"[^A-Za-z0-9 -_()&!]", "g")

	/// A shared cache map of ("name" => list(articles))
	var/static/list/datum/news_article/articles_cache = list()

	/// The list of articles in this channel
	var/list/datum/news_article/articles

	/// Whether to use the articles cache
	var/use_cache = FALSE

	/// The name of this channel
	var/name

	/// The name of the creator of this channel
	var/creator

	/// The default author names to pick from, or fixed name if text, for this channel
	var/list/author

	/// The number of times this channel has been opened across all newscasters
	var/views = 0

	/// Only the author can post articles to this channel
	var/locked = FALSE

	/// The articles in this channel cannot be viewed
	var/censored = FALSE

	/// Protected channels and their articles cannot be censored
	var/protected = FALSE

	/// The last world.time this channel was updated
	var/updated = 0

	/// The message to display when a new article is added
	var/announcement

	/// The path where this channel's articles are stored, if any
	var/articles_dir


/datum/news_channel/Destroy()
	if (!use_cache)
		QDEL_NULL_LIST(articles)
	articles = null
	return ..()


/datum/news_channel/proc/CreateArticles()
	if (use_cache && length(articles_cache))
		articles = articles_cache[name]
	if (articles)
		return
	if (news_path)
		ReadArticles()
	if (articles)
		return
	articles = list()
	if (use_cache)
		articles_cache[name] = articles


/datum/news_channel/proc/ReadArticles()
	if (articles)
		return
	for (var/filename in flist(articles_dir))
		if (copytext_char(filename, 1, 2) == ".")
			continue
		if (copytext_char(filename, -4) != ".art")
			continue
		var/file = trimtext(file2text("[articles_dir][filename]"))
		if (!file)
			continue
		var/details
		if (copytext_char(file, 1, 2) == "{")
			details = findtext_char(file, "}")
		if (details)
			var/body = copytext_char(file, details + 1)
			details = copytext_char(file, 1, details + 1)
			try
				details = json_decode(details)
			catch (var/exception/exception)
				log_debug("Article at [articles_dir][filename] has an invalid json header.")
				continue
			file = trimtext(body)
		file = digitalPencode2html(file)
		var/datum/news_article/article = new (src, details?["author"] || creator, file)
		if (details?["created"])
			article.created = details["created"]
		if (details?["has_image"])
			var/image = icon("data/news/[articles_dir][copytext_char(filename, 1, -4)].png")
			article.SetImage(image, details["caption"])
	if (use_cache)
		articles_cache[name] = articles
