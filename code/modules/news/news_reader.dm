/datum/computer_file/program/news_reader
	filename = "chviewr"
	filedesc = "NewsReal!"
	program_icon_state = "generic"
	program_menu_icon = "image"
	extended_desc = "A simple feed reader for channels available on the local news network."
	size = 4
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_ALL
	nanomodule_path = /datum/nano_module/program/news_reader


/datum/nano_module/program/newsreel
	name = "Newscast"

	var/const/NEWSCAST_HOME = 1
	var/const/NEWSCAST_VIEW_CHANNEL = 2

	var/prog_state = NEWSCAST_HOME
	var/notifs_enabled = TRUE
	var/datum/news_channel/active_channel
	var/datum/news_network/network


/datum/nano_module/program/newsreel/proc/news_alert(announcement)
	if (!notifs_enabled || !announcement)
		return
	program.computer.visible_notification(announcement)
	program.computer.audible_notification("sound/machines/twobeep.ogg")


/datum/nano_module/program/newsreel/Destroy()
	if (network)
		LAZYREMOVE(network.programs, src)
	return ..()


/datum/nano_module/program/newsreel/Topic(href, href_list)
	if(..())
		return
	if (href_list["view_channel"])
		var/datum/news_channel/new_feed = locate(href_list["view_channel"]) in network.channels
		if (istype(new_feed))
			active_channel = new_feed
			prog_state = NEWSCAST_VIEW_CHANNEL
	else if (href_list["view_photo"])
		var/datum/news_article/story = locate(href_list["view_photo"]) in active_channel.messages
		if (istype(story) && story.img)
			send_rsc(usr, story.img, "tmp_photo.png")
			var/output = "<html><head><title>photo - [story.author]</title></head>"
			output += "<body style='overflow:hidden; margin:0; text-align:center'>"
			output += "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />"
			output += "</body></html>"
			show_browser(usr, output, "window=book; size=192x192]")
	else if (href_list["toggle_notifs"])
		notifs_enabled = !notifs_enabled
	else if (href_list["return_to_home"])
		active_channel = null
		prog_state = NEWSCAST_HOME


/datum/nano_module/program/newsreel/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = host.initial_data()
	var/datum/computer_file/program/newsreel/prog = program
	var/turf/T = get_turf(prog.computer.get_physical_host())
	if (!network)
		for (var/datum/news_network/G in GLOB.news_networks)
			if (T.z in G.z_levels)
				network = G
				LAZYADD(G.programs, src)
				break
	else if (!(T.z in network.z_levels))
		prog.computer.visible_error("Newscaster connection lost. Attempting to re-establish.")
		LAZYREMOVE(network.programs, src)
		network = null
	if (!network)
		data["has_network"] = FALSE
	else
		data["has_network"] = TRUE
		data["notifs_enabled"] = notifs_enabled
		data["prog_state"] = prog_state
		data["time_blurb"] = "The date is <b>[stationdate2text()]</b> at <b>[stationtime2text()]</b>."
		data["notifs_blurb"] = "New story notifications are <b>[notifs_enabled ? "enabled" : "disabled"]</b>."
		data["dnotice_blurb"] = "<h2 style='font-color: red'>CHANNEL LOCKED</h2><br>\
		<span style='font-color: red'>This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<br><br> \
		Stories may not be published or viewed while the D-Notice is in effect. For further information, please contact the network administrator or a security representative.</span>"
		data["channels"] = list()
		data["active_channels"] = list() // There will only ever be one active channel, but we use this for unified handling in nanoUI
		for(var/datum/news_channel/channel in network.channels)
			var/list/channel_data = list()
			channel_data["name"] = channel.channel_name
			channel_data["admin"] = channel.protected
			channel_data["censored"] = channel.censored
			channel_data["author"] = channel.author
			channel_data["ref"] = "\ref[channel]"
			data["channels"] += list(channel_data)
			if (channel == active_channel)
				data["active_channels"] += list(channel_data)
		if (active_channel)
			var/datum/news_channel/feed = active_channel
			data["active_channel"] = feed
			data["active_stories"] = list()
			for (var/i = 1 to length(feed.messages))
				var/datum/news_article/message = feed.messages[i]
				var/list/story = list()
				story["author"] = message.author
				story["body"] = message.body
				story["timestamp"] = message.time_stamp
				story["has_photo"] = message.img != null
				if (user && message.img) // user check here to avoid runtimes
					var/resource_name = "newscaster_photo_[sanitize(feed.channel_name)]_[i].png"
					send_asset(user.client, resource_name)
					story["photo_dat"] = "<img src='[resource_name]' width='180'><br>"
				story["story_ref"] = "\ref[message]"
				data["active_stories"] += list(story)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "newscast.tmpl", name, 450, 600, state = state)
		ui.auto_update_layout = 1
		ui.set_auto_update(1)
		ui.set_initial_data(data)
		ui.open()
