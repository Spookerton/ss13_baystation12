/obj/structure/bunk
	name = "bunk"
	desc = "A raised bed with convenient storage underneath."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "bunk"
	anchored = TRUE
	can_buckle = TRUE
	buckle_dir = SOUTH
	buckle_lying = TRUE
	buckle_pixel_shift = list(
		"y" = 16
	)
	var/obj/item/device/radio/intercom/announcer
	var/base_icon = "bunk"
	var/despawn_interval = 15 MINUTES
	var/despawn_time


/obj/structure/bunk/Destroy()
	QDEL_NULL(announcer)
	unbuckle_mob()
	return ..()


/obj/structure/bunk/buckle_mob(mob/living/carbon/human/bucklee)
	. = ..()
	if (. && istype(bucklee))
		despawn_time = Uptime() + despawn_interval
		START_PROCESSING(SSobj, src)


/obj/structure/bunk/unbuckle_mob()
	..()
	STOP_PROCESSING(SSobj, src)
	despawn_time = 0


/obj/structure/bunk/CanPass(atom/movable/mover, turf/target, height, air_group)
	if (istype(mover))
		return FALSE
	return ..()


/obj/structure/bunk/Process()
	if (!cryo_time)
		return PROCESS_KILL
	if (QDELETED(buckled_mob))
		buckled_mob = null
		return PROCESS_KILL
	if (Uptime() < despawn_time)
		return
	despawn()
	return PROCESS_KILL


/obj/structure/bunk/proc/despawn()
	if (QDELETED(buckled_mob))
		return
	var/mob/living/carbon/human/despawnee = buckled_mob
	unbuckle_mob()
	var/datum/mind/mind = despawnee.mind
	if (mind)
		if (mind.assigned_job)
			mind.assigned_job.clear_slot()
		if (length(mind.objectives))
			mind.objectives = null
			mind.special_role = null
	if (!istype(despawnee))
		qdel(despawnee)
		return
	var/clean_name = sanitize(despawnee.real_name)
	var/datum/computer_file/report/crew_record/record = get_crewmember_record(clean_name)
	if (record)
		record.set_status("Retired")


	var/list/removed = list()
	var/list/retained = list()
	var/list/queue = list()
	var/list/next_queue = list()
	for (var/obj/item/item in buckled_mob)
		buckled_mob.drop_from_inventory(item, src)
		queue += item
	for (var/i = 1 to 4) // max depth for sanity
		if (!queue.len)
			break
		next_queue = list()
		for (var/obj/item/item as anything in queue)
			if (item.flags & ITEM_FLAG_PRESERVE_ON_DESPAWN)
				preserved += item
				continue
			removed += item
			if (istype(item, /obj/item/storage))
				var/obj/item/storage/storage = item
				for (var/obj/item/item in storage)
					storage.contents -= item
					next_queue += item
					contents += item
			else if (istype(item, /obj/item/clothing))
				var/obj/item/clothing/clothing = item
				for (var/obj/item/clothing/accessory/storage/storage in clothing.accessories)
					next_queue += storage.container
		queue = next_queue
