/obj/item/storage/med_pouch
	abstract_type = /obj/item/storage/med_pouch
	name = "emergency medical pouch"
	desc = "For use in emergency situations only."
	icon = 'icons/obj/medical.dmi'
	storage_slots = 7
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_SMALL
	icon_state = "pack0"
	opened = FALSE
	open_sound = 'sound/effects/rip1.ogg'

	var/instructions


/obj/item/storage/med_pouch/Initialize()
	. = ..()
	make_exact_fit()
	for (var/obj/item/reagent_containers/container in contents)
		if (istype(container, /obj/item/reagent_containers/pill))
			container.color = color
		else if (istype(container, /obj/item/reagent_containers/injector/auto))
			var/obj/item/reagent_containers/injector/auto/autoinjector = container
			autoinjector.band_color = color
			autoinjector.update_icon()
	var/static/image/cross_overlay = image_flags(icon, "cross", flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR)
	AddOverlays(cross_overlay)


/obj/item/storage/med_pouch/on_update_icon()
	icon_state = "pack[opened]"


/obj/item/storage/med_pouch/examine(mob/user)
	. = ..()
	if (!isnull(instructions))
		to_chat(user, "<A href='?src=\ref[src];show_info=1'>Please read instructions before use.</A>")


/obj/item/storage/med_pouch/CanUseTopic()
	return STATUS_INTERACTIVE


/obj/item/storage/med_pouch/OnTopic(user, list/href_list)
	if (href_list["show_info"] && !isnull(instructions))
		to_chat(user, instructions)
		return TOPIC_HANDLED


/obj/item/storage/med_pouch/attack_self(mob/user)
	open(user)


/obj/item/storage/med_pouch/open(mob/user)
	if (!opened)
		user.visible_message(
			SPAN_NOTICE("\The [user] tears open [src], breaking the vacuum seal!"),
			SPAN_NOTICE("You tear open [src], breaking the vacuum seal!")
		)
	..()


/obj/item/storage/med_pouch/trauma
	name = "emergency trauma pouch"
	color = COLOR_RED
	startswith = list(
		/obj/item/reagent_containers/injector/auto/pouch_inaprovaline,
		/obj/item/reagent_containers/pill/pouch_inaprovaline,
		/obj/item/reagent_containers/pill/pouch_paracetamol,
		/obj/item/stack/medical/bruise_pack = 2
	)
	instructions = {"\
		\t1) Tear open the emergency medical pack using the easy open tab at the top.\n\
		\t2) Carefully remove all items from the pouch and discard the pouch.\n\
		\t3) Apply all autoinjectors to the injured party.\n\
		\t4) Use bandages to stop bleeding if required.\n\
		\t5) Force the injured party to swallow all pills.\n\
		\t6) Contact the medical team with your location.\n\
		\t7) Stay in place once they respond.\
	"}


/obj/item/storage/med_pouch/burn
	name = "emergency burn pouch"
	color = COLOR_SEDONA
	startswith = list(
		/obj/item/reagent_containers/injector/auto/pouch_inaprovaline,
		/obj/item/reagent_containers/injector/auto/pouch_deletrathol,
		/obj/item/reagent_containers/injector/auto/pouch_adrenaline,
		/obj/item/reagent_containers/pill/pouch_paracetamol,
		/obj/item/stack/medical/ointment = 2
	)
	instructions = {"\
		\t1) Tear open the emergency medical pack using the easy open tab at the top.\n\
		\t2) Carefully remove all items from the pouch and discard the pouch.\n\
		\t3) Apply the emergency deletrathol autoinjector to the injured party.\n\
		\t4) Apply all remaining autoinjectors to the injured party.\n\
		\t5) Force the injured party to swallow all pills.\n\
		\t6) Use ointment on any burns if required\n\
		\t7) Contact the medical team with your location.\n\
		\t8) Stay in place once they respond.\
	"}

/obj/item/storage/med_pouch/oxyloss
	name = "emergency hypoxia pouch"
	color = COLOR_BLUE
	startswith = list(
		/obj/item/reagent_containers/injector/auto/pouch_inaprovaline,
		/obj/item/reagent_containers/injector/auto/pouch_dexalin,
		/obj/item/reagent_containers/injector/auto/pouch_adrenaline,
		/obj/item/reagent_containers/pill/pouch_inaprovaline,
		/obj/item/reagent_containers/pill/pouch_dexalin
	)
	instructions = {"\
		\t1) Tear open the emergency medical pack using the easy open tab at the top.\n\
		\t2) Carefully remove all items from the pouch and discard the pouch.\n\
		\t3) Apply all autoinjectors to the injured party.\n\
		\t4) Force the injured party to swallow all pills.\n\
		\t5) Contact the medical team with your location.\n\
		\t6) Find a source of oxygen if possible.\n\
		\t7) Update the medical team with your new location.\n\
		\t8) Stay in place once they respond.\
	"}


/obj/item/storage/med_pouch/toxin
	name = "emergency toxin pouch"
	color = COLOR_GREEN
	startswith = list(
		/obj/item/reagent_containers/injector/auto/pouch_dylovene,
		/obj/item/reagent_containers/pill/pouch_dylovene
	)
	instructions = {"\
		\t1) Tear open the emergency medical pack using the easy open tab at the top.\n\
		\t2) Carefully remove all items from the pouch and discard the pouch.\n\
		\t3) Apply all autoinjectors to the injured party.\n\
		\t4) Force the injured party to swallow all pills.\n\
		\t5) Contact the medical team with your location.\n\
		\t6) Stay in place once they respond.\
	"}


/obj/item/storage/med_pouch/radiation
	name = "emergency radiation pouch"
	color = COLOR_AMBER
	startswith = list(
		/obj/item/reagent_containers/injector/auto/antirad,
		/obj/item/reagent_containers/pill/pouch_dylovene
	)
	instructions = {"\
		\t1) Tear open the emergency medical pack using the easy open tab at the top.\n\
		\t2) Carefully remove all items from the pouch and discard the pouch.\n\
		\t3) Apply all autoinjectors to the injured party.\n\
		\t4) Force the injured party to swallow all pills.\n\
		\t5) Contact the medical team with your location.\n\
		\t6) Stay in place once they respond.\
	"}


/obj/item/reagent_containers/pill/pouch_inaprovaline
	name = "emergency inaprovaline pill (15u)"
	icon_state = "pill2"
	reagents_volume = 15
	reagents = /datum/reagent/inaprovaline


/obj/item/reagent_containers/pill/pouch_dylovene
	name = "emergency dylovene pill (15u)"
	icon_state = "pill2"
	reagents_volume = 15
	reagents = /datum/reagent/dylovene


/obj/item/reagent_containers/pill/pouch_dexalin
	name = "emergency dexalin pill (15u)"
	icon_state = "pill2"
	reagents_volume = 15
	reagents = /datum/reagent/dexalin


/obj/item/reagent_containers/pill/pouch_paracetamol
	name = "emergency paracetamol pill (15u)"
	icon_state = "pill2"
	reagents_volume = 15
	reagents = /datum/reagent/paracetamol


/obj/item/reagent_containers/injector/auto/pouch_inaprovaline
	name = "emergency inaprovaline autoinjector"
	reagents = /datum/reagent/inaprovaline


/obj/item/reagent_containers/injector/auto/pouch_deletrathol
	name = "emergency deletrathol autoinjector"
	reagents = /datum/reagent/deletrathol


/obj/item/reagent_containers/injector/auto/pouch_dylovene
	name = "emergency dylovene autoinjector"
	reagents = /datum/reagent/dylovene


/obj/item/reagent_containers/injector/auto/pouch_dexalin
	name = "emergency dexalin autoinjector"
	reagents = /datum/reagent/dexalin


/obj/item/reagent_containers/injector/auto/pouch_adrenaline
	name = "emergency adrenaline autoinjector"
	reagents = /datum/reagent/adrenaline

/obj/item/reagent_containers/injector/auto/allergy
	name = "emergency allergy autoinjector"
	desc = "The ingredient label reads 1.5 units of adrenaline and 3.5 units of inaprovaline."
	reagents = list(
		/datum/reagent/adrenaline = 1.5,
		/datum/reagent/inaprovaline = 3.5
	)

