/datum/news_article
	var/content
	var/author
	var/created
	var/image
	var/caption
	var/image_cache_id


/datum/news_article/Destroy()
	if (image_cache_id)
		var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
		asset_cache.cache -= image_cache_id
	image = null
	return ..()
