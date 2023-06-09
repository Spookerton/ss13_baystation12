/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the space newspaper."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = ITEM_SIZE_SMALL	//Let's make it fit in trashbags!
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/news_channel/news_content = list()
	var/datum/news_article/important_message = null
	var/scribble=""
	var/scribble_page = null


/obj/item/newspaper/attack_self(mob/user)
	user.update_personal_goal(/datum/goal/achievement/newshound, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B>[SPAN_SIZE(6, "The Griffon")]</B></div>"
				dat+="<DIV ALIGN='center'>[FONT_NORMAL("[GLOB.using_map.company_name]-standard newspaper, for use on [GLOB.using_map.company_name] Space Facilities")]</div><HR>"
				if(!length(news_content))
					if(important_message)
						dat+="Contents:<BR><ul><B>[SPAN_COLOR("red", "**")]Important Security Announcement[SPAN_COLOR("red", "**")]</B> [FONT_NORMAL("\[page [src.pages+2]\]")]<BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/news_channel/NP in news_content)
						pages++
					if(important_message)
						dat+="<B>[SPAN_COLOR("red", "**")]Important Security Announcement[SPAN_COLOR("red", "**")]</B> [FONT_NORMAL("\[page [src.pages+2]\]")]<BR>"
					var/temp_page=0
					for(var/datum/news_channel/NP in news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> [FONT_NORMAL("\[page [temp_page+1]\]")]<BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=\ref[human_user];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/news_channel/NP in src.news_content)
					pages++ //Let's get it right again.
				var/datum/news_channel/C = news_content[src.curr_page]
				dat+="[FONT_HUGE("<B>[C.channel_name]</B>")][FONT_SMALL(" \[created by: [SPAN_COLOR("maroon", C.author)]\]")]<BR><BR>"
				if(C.censored)
					dat+="This channel was deemed dangerous to the general welfare of the [station_name()] and therefore marked with a [SPAN_COLOR("red", "<B>D-Notice</B>")]. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(!length(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/news_article/MESSAGE in C.messages)
							++i
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								var/resource_name = "newscaster_photo_[sanitize(C.channel_name)]_[i].png"
								send_asset(user.client, resource_name)
								dat+="<img src='[resource_name]' width = '180'><BR>"
							dat+="[FONT_SMALL("\[[MESSAGE.message_type] by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV>"
			if(2) //Last page
				for(var/datum/news_channel/NP in src.news_content)
					pages++
				if(important_message!=null)
					dat+="<DIV STYLE='float:center;'>[FONT_HUGE("<B>Wanted Issue:</B>")]</DIV><BR><BR>"
					dat+="<B>Criminal name</B>: [SPAN_COLOR("maroon", important_message.author)]<BR>"
					dat+="<B>Description</B>: [important_message.body]<BR>"
					dat+="<B>Photo:</B>: "
					if(important_message.img)
						send_rsc(user, important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting Classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

		dat+="<BR><HR><div align='center'>[curr_page+1]</div>"
		show_browser(human_user, dat, "window=newspaper_main;size=300x400")
		onclose(human_user, "newspaper_main")
	else
		to_chat(user, "The paper is full of intelligible symbols!")


/obj/item/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==pages+1)
				return //Don't need that at all, but anyway.
			if(curr_page == pages) //We're at the middle, get to the end
				screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					screen=1
			curr_page++
			playsound(src.loc, "pageturn", 50, 1)
		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				screen = 0
			else
				if(curr_page == pages+1) //we're at the end, let's go back to the middle.
					screen = 1
			curr_page--
			playsound(loc, "pageturn", 50, 1)
		if (istype(loc, /mob))
			attack_self(loc)


/obj/item/newspaper/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/pen))
		if(scribble_page == curr_page)
			to_chat(user, SPAN_COLOR("blue", "There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?"))
		else
			var/s = sanitize(input(user, "Write something", "Newspaper", ""))
			s = sanitize(s)
			if (!s)
				return
			if (!in_range(src, usr) && loc != usr)
				return
			scribble_page = curr_page
			scribble = s
			attack_self(user)
