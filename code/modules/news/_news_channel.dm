/datum/news_channel
	var/list/datum/news_article/articles
	var/name
	var/creator
	var/list/author
	var/views = 0
	var/locked = FALSE
	var/protected = FALSE
	var/updated = 0


/datum/news_channel/Destroy()
	if (type != /datum/news_channel)
		for ()
		QDEL_NULL_LIST(articles)
	LAZYCLEARLIST(articles)
	if (islist(author))
		LAZYCLEARLIST(author)
	return ..()
