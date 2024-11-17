/obj/item/reagent_containers/injector
	abstract_type = /obj/item/reagent_containers/injector
	icon = 'icons/obj/tools/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	origin_tech = list(TECH_MATERIAL = 4, TECH_BIO = 5)
	matter = list(MATERIAL_STEEL = 8000, MATERIAL_GLASS = 8000, MATERIAL_SILVER = 2000)
	amount_per_transfer_from_this = 5
	unacidable = TRUE
	reagents_volume = 30
	possible_transfer_amounts = null
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	slot_flags = SLOT_BELT

	/**
	* Injectors takes less time than a normal syringe. This delay is only applied
	* when injecting another who is conscious. Scales according to medicine skill:
	* 1.47, 1.00, 0.68, 0.53, 0.39 Seconds
	*/
	var/time = (1 SECONDS) / 1.9

	/// Some injectors are single use.
	var/single_use = TRUE


/obj/item/reagent_containers/injector/use_before(mob/living/M, mob/user)
	. = FALSE
	if (!istype(M))
		return FALSE
	if (!reagents.total_volume)
		to_chat(user, SPAN_WARNING("[src] is empty."))
		return TRUE
	var/allow = M.can_inject(user, check_zone(user.zone_sel.selecting))
	if (!allow)
		return TRUE
	if (allow == INJECTION_PORT)
		if (M != user)
			user.visible_message(SPAN_WARNING("\The [user] begins hunting for an injection port on \the [M]'s suit!"))
		else
			to_chat(user, SPAN_NOTICE("You begin hunting for an injection port on your suit."))
		if(!user.do_skilled(INJECTION_PORT_DELAY, SKILL_MEDICAL, M, do_flags = DO_MEDICAL))
			return TRUE
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(M)
	if (user != M && !M.incapacitated() && time) // you're injecting someone else who is concious, so apply the device's intrisic delay
		to_chat(user, SPAN_WARNING("\The [user] is trying to inject \the [M] with \the [name]."))
		if (!user.do_skilled(time, SKILL_MEDICAL, M, do_flags = DO_MEDICAL))
			return TRUE
	if (single_use && reagents.total_volume <= 0) // currently only applies to autoinjectors
		atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER // Prevents autoinjectors to be refilled.
		update_icon()
	to_chat(user, SPAN_NOTICE("You inject [M] with [src]."))
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		H.custom_pain(SPAN_WARNING("You feel a tiny prick!"), 1, TRUE, H.get_organ(user.zone_sel.selecting))
	playsound(src, 'sound/effects/hypospray.ogg',25)
	user.visible_message(SPAN_WARNING("[user] injects [M] with [src]."))
	if (M.reagents)
		var/should_admin_log = reagents.should_admin_log()
		var/contained = reagentlist()
		var/trans = reagents.trans_to_mob(M, amount_per_transfer_from_this, CHEM_BLOOD)
		if (should_admin_log)
			admin_inject_log(user, M, src, contained, trans)
		to_chat(user, SPAN_NOTICE("[trans] units injected. [reagents.total_volume] units remaining in \the [src]."))
	return TRUE
