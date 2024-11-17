
/obj/item/reagent_containers/injector/auto
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "injector"
	item_state = "autoinjector"
	reagent_container_flags = REAGENT_CONTAINER_INIT_UPDATE_ICON
	amount_per_transfer_from_this = 5
	reagents_volume = 5
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	slot_flags = SLOT_BELT | SLOT_EARS
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_PLASTIC = 150, MATERIAL_GLASS = 50)

	/**
	* Color. If set, forces the autoinjectors window color to instead be a solid band color matching
	* the provided color. If not set, the band color instead matches the contained reagent color.
	*/
	var/band_color


/obj/item/reagent_containers/injector/auto/on_update_icon()
	ClearOverlays()
	if(reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"
	var/overlay_color = band_color
	if (isnull(overlay_color))
		if (reagents.total_volume)
			overlay_color = reagents.get_color()
		else
			overlay_color = COLOR_GRAY
	AddOverlays(overlay_image(icon, "injector_band", overlay_color, RESET_COLOR))


/obj/item/reagent_containers/injector/auto/on_reagent_change()
	update_icon()


/obj/item/reagent_containers/injector/auto/examine(mob/user, distance, is_adjacent)
	. = ..(user)
	if (distance > 3 && !isobserver(user))
		return
	if (length(reagents?.reagent_list))
		to_chat(user, SPAN_NOTICE("It is currently loaded."))
	else
		to_chat(user, SPAN_NOTICE("It is spent."))


/obj/item/reagent_containers/injector/auto/detox
	name = "autoinjector (antitox)"
	reagents = /datum/reagent/dylovene


/obj/item/reagent_containers/injector/auto/pain
	name = "autoinjector (painkiller)"
	reagents = /datum/reagent/tramadol


/obj/item/reagent_containers/injector/auto/combatpain
	name = "autoinjector (oxycodone)"
	reagents = /datum/reagent/tramadol/oxycodone


/obj/item/reagent_containers/injector/auto/antirad
	name = "autoinjector (anti-rad)"
	reagents = /datum/reagent/hyronalin


/obj/item/reagent_containers/injector/auto/mindbreaker
	name = "autoinjector"
	reagents = /datum/reagent/drugs/mindbreaker


/obj/item/reagent_containers/injector/auto/dexalin_plus
	name ="autoinjector (dexalin plus)"
	reagents = /datum/reagent/dexalinp


/obj/item/reagent_containers/injector/auto/inaprovaline
	name = "autoinjector (inaprovaline)"
	reagents = /datum/reagent/inaprovaline


/obj/item/reagent_containers/injector/auto/coagulant
	name ="autoinjector (coagulant)"
	reagents = list(
		/datum/reagent/coagulant = 1,
		/datum/reagent/nanoblood = 4
	)


/obj/item/reagent_containers/injector/auto/combatstim
	name ="autoinjector (combat Stimulants)"
	reagents_volume = 15
	amount_per_transfer_from_this = 15
	reagents = list(
		/datum/reagent/inaprovaline = 10,
		/datum/reagent/hyperzine = 3,
		/datum/reagent/synaptizine = 1
	)


/obj/item/reagent_containers/injector/auto/allergy
	name = "emergency allergy autoinjector"
	desc = "The ingredient label reads 1.5 units of epinephrine and 3.5 units of inaprovaline."
	reagents = list(
		/datum/reagent/adrenaline = 1.5,
		/datum/reagent/inaprovaline = 3.5
	)
