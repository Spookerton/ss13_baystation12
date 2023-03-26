#define RECOMMENDED_VERSION 514


/proc/enable_debugging(mode, port)
	CRASH("auxtools not loaded")


/proc/auxtools_expr_stub()
	return


GLOBAL_VAR(href_logfile)


/world/New()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		call_ext(debug_server, "auxtools_init")()
		enable_debugging()
	name = "[server_name] - [GLOB.using_map.full_name]"
	SetupLogs()
	var/date_string = time2text(world.realtime, "YYYY/MM/DD")
	to_file(global.diary, "[log_end]\n[log_end]\nStarting up. (ID: [game_id]) [time2text(world.timeofday, "hh:mm.ss")][log_end]\n---------------------[log_end]")
	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		config.server_name += " #[(world.port % 1000) / 100]"
	if(config && config.log_runtime)
		var/runtime_log = file("data/logs/runtime/[date_string]_[time2text(world.timeofday, "hh:mm")]_[game_id].log")
		to_file(runtime_log, "Game [game_id] starting up at [time2text(world.timeofday, "hh:mm.ss")]")
		log = runtime_log // Note that, as you can see, this is misnamed: this simply moves world.log into the runtime log file.
	if (config && config.log_hrefs)
		GLOB.href_logfile = file("data/logs/[date_string] hrefs.htm")
	if(byond_version < RECOMMENDED_VERSION)
		to_world_log("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")
	callHook("startup")
	..()

#ifdef UNIT_TEST
	log_unit_test("Unit Tests Enabled. This will destroy the world when testing is complete.")
	load_unit_test_changes()
#endif
	Master.Initialize(10, FALSE)


/world/Del()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		call_ext(debug_server, "auxtools_shutdown")()
	callHook("shutdown")
	return ..()


/world/Reboot(reason)
	Master.Shutdown()
	var/datum/chatOutput/co
	for(var/client/C in GLOB.clients)
		co = C.chatOutput
		if(co)
			co.ehjax_send(data = "roundrestart")
	if(config.server)
		for(var/client/C in GLOB.clients)
			send_link(C, "byond://[config.server]")
	if(config.wait_for_sigusr1_reboot && reason != 3)
		text2file("foo", "reboot_called")
		to_world(SPAN_DANGER("World reboot waiting for external scripts. Please be patient."))
		return
	..(reason)


/world/proc/SetupLogs()
	GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM/DD")]/round-"
	if(game_id)
		GLOB.log_directory += "[game_id]"
	else
		GLOB.log_directory += "[replacetext(time_stamp(), ":", ".")]"
	GLOB.world_qdel_log = file("[GLOB.log_directory]/qdel.log")
	to_file(GLOB.world_qdel_log, "\n\nStarting up round ID [game_id]. [time_stamp()]\n---------------------")


/hook/startup/proc/loadMode()
	world.load_mode()
	return 1


var/global/game_id = null

/hook/global_init/proc/generate_gameid()
	if(game_id != null)
		return
	game_id = ""
	var/list/c = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/l = length(c)
	var/t = world.timeofday
	for(var/_ = 1 to 4)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	game_id = "-[game_id]"
	t = round(world.realtime / (10 * 60 * 60 * 24))
	for(var/_ = 1 to 3)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	return 1


/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		to_world_log("Your server failed to establish a connection with the feedback database.")
	else
		to_world_log("Feedback database connection established.")
	return 1


/hook/startup/proc/connectOldDB()
	if(!setup_old_database_connection())
		to_world_log("Your server failed to establish a connection with the SQL database.")
	else
		to_world_log("SQL database connection established.")
	return 1


#ifndef UNIT_TEST
/hook/startup/proc/set_visibility()
	world.update_hub_visibility(config.hub_visible)
#endif


#undef RECOMMENDED_VERSION
