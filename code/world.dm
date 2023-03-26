/**
* World and hub definitions. See ./config.dm and ./game/world/...
* for options and where world-related code should live.
*/

#define WORLD_ICON_SIZE 32


/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 7
	hub = "Exadv1.spacestation13"
	icon_size = WORLD_ICON_SIZE
	fps = 30
#ifdef GC_FAILURE_HARD_LOOKUP
	loop_checks = FALSE
#endif
	hub = "Exadv1.spacestation13"
	name = "Space Station 13"


/world/proc/update_hub_visibility(new_status)
	if (isnull(new_status))
		new_status = !config.hub_visible
	config.hub_visible = new_status
	if (config.hub_visible)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"
