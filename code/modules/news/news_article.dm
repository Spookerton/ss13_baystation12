/datum/news_article
	var/datum/news_channel/channel

	/// The in-game datetime that this article was created
	var/created

	/// The name of the author of this article
	var/author

	/// The rendered text matter of the article
	var/body

	/// The image associated with this article
	var/image

	/// The caption associated with this article's image
	var/caption


/datum/news_article/Destroy()
	if (channel)
		channel.articles -= src
		channel = null
	img = null
	return ..()


/datum/news_article/New(datum/news_channel/channel, author, body, obj/item/photo/photo)
	src.channel = channel
	src.author = author
	src.body = body
	created = time_stamp()
	if (photo)
		SetImage(photo.img, photo.scribble)
	channel.articles += src


/datum/news_article/proc/SetImage(image, caption)
	src.image = image
	src.caption = caption
	register_asset("article_image_[ckey(channel.name)]_[ckey(created)].png", image)
