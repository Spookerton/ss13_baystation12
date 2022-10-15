SUBSYSTEM_DEF(chat)
	name = "Chat"
	wait = 1
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	priority = SS_PRIORITY_CHAT

	/// A map of "ckey" => /datum/chat instance
	var/static/list/chats = list()

	/// A list of ckeys currently being processed
	var/static/list/queue = list()


/datum/controller/subsystem/chat/fire(resumed, no_mc_tick)
	if (!resumed)
		queue = list()
		for (var/client/client as anything in GLOB.clients)
			queue += client.ckey
		if (!length(queue))
			return
	var/cut_until = 1
	var/datum/chat/chat
	for (var/ckey in queue)
		++cut_until
		chat = chats[ckey]
		chat.Dispatch()
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(1, cut_until)
			return
	queue.Cut()


/datum/controller/subsystem/chat/proc/GetChat(ckey)
	if (!chats[ckey])
		chats[ckey] = new /datum/chat
	return chats[ckey]


/datum/chat
	var/available
	var/client/client
	var/list/messages = list()


/datum/chat/proc/Dispatch()
	if (!available || !client || !length(messages))
		return
	var/payload = json_encode(list("type" = "chat", "data" = messages))
	send_output(client, payload, "chat:ingress")
	messages.Cut()


/client/var/datum/chat/chat


/client/New()
	chat = SSchats.GetChat(ckey)
	chat.client = src


/client/Destroy()
	chat.client = null
	chat = null
	return ..()


/proc/to_world(list/message)
	to_chat(GLOB.clients, message)


/proc/to_chat(target, list/message)
	if (islist(target))
		var/mob/mob
		for (var/client/client as anything in target)
			if (ismob(client))
				mob = client
				client = mob.client
			if (!isclient(client))
				continue
			client.chat.messages += list(message)
		return
	if (ismob(target))
		var/mob/mob = target
		target = mob.client
	if (!isclient(target))
		return
	client.chat.messages += list(message)


//atom/proc/visible_message()
	//return


//atom/proc/audible_message()
	//return


#define SPAN_ITALIC(X) list("[X]", "italic")

#define SPAN_BOLD(X) list("[X]", "bold")

#define SPAN_NOTICE(X) list("[X]", "notice")

#define SPAN_WARNING(X) list("[X]", "warning")

#define SPAN_GOOD(X) list("[X]", "good")

#define SPAN_BAD(X) list("[X]", "bad")

#define SPAN_DANGER(X) list("[X]", "danger")

#define SPAN_OCCULT(X) list("[X]", "cult")

#define SPAN_MFAUNA(X) list("[X]", "mfauna")

#define SPAN_SUBTLE(X) list("[X]", "subtle")

#define SPAN_INFO(X) list("[X]", "info")

#define SPAN_DEBUG(X) list("[X]", "debug")

#define SPAN_STYLE(style, X) list("[X]", null, "[style]")

#define FONT_COLORED(color, X) list("[X]", null, "color:[color]")

#define FONT_SMALL(X) list("[X]", null, "font-size:12px")

#define FONT_NORMAL(X) list("[X]", null, "font-size:16px")

#define FONT_LARGE(X) list("[X]", null, "font-size:18px")

#define FONT_HUGE(X) list("[X]", null, "font-size:20px")

#define FONT_GIANT(X) list("[X]", null, "font-size:22px")

#define STYLE_SMALLFONTS(X, S, C1) list("[X]", null, "font-family:'Small Fonts';color:[C1];font-size:[S]px")

#define STYLE_SMALLFONTS_OUTLINE(X, S, C1, C2) list("[X]", null, "font-family:'Small Fonts';color:[C1];-dm-text-outline:1 [C2];font-size:[S]px")
