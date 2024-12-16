////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/pill
	name = "pill"
	desc = "A pill."
	icon = 'icons/obj/pills.dmi'
	icon_state = null
	item_state = "pill"
	randpixel = 7
	possible_transfer_amounts = null
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	reagents_volume = 30
	reagent_container_flags = REAGENT_CONTAINER_INIT_UPDATE_ICON | REAGENT_CONTAINER_USE_REAGENTS_COLOR


/obj/item/reagent_containers/pill/on_update_icon()
	if (!icon_state)
		icon_state = "pill[rand(1, 5)]"
	..()


/obj/item/reagent_containers/pill/use_before(mob/M, mob/user)
	. = FALSE
	if (!istype(M))
		return FALSE
	if (M == user)
		if (!M.can_eat(src))
			return TRUE
		M.visible_message(SPAN_NOTICE("[M] swallows a pill."), SPAN_NOTICE("You swallow \the [src]."), null, 2)
		if (reagents.total_volume)
			reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
		qdel(src)
		return TRUE
	if (ishuman(M))
		if (!M.can_force_feed(user, src))
			return TRUE
		user.visible_message(SPAN_WARNING("[user] attempts to force [M] to swallow \the [src]."))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (!do_after(user, 3 SECONDS, M, DO_MEDICAL))
			return TRUE
		if (user.get_active_hand() != src)
			return TRUE
		user.visible_message(SPAN_WARNING("[user] forces [M] to swallow \the [src]."))
		var/contained = reagentlist()
		if (reagents.should_admin_log())
			admin_attack_log(user, M, "Fed the victim with [name] (Reagents: [contained])", "Was fed [src] (Reagents: [contained])", "used [src] (Reagents: [contained]) to feed")
		if (reagents.total_volume)
			reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
		qdel(src)
		return TRUE


/obj/item/reagent_containers/pill/use_after(atom/target, mob/living/user, click_parameters)
	if (target.is_open_container() && target.reagents)
		if (!target.reagents.total_volume)
			to_chat(user, SPAN_NOTICE("\The [target] is empty. Can't dissolve \the [src]."))
			return TRUE
		to_chat(user, SPAN_NOTICE("You dissolve \the [src] in \the [target]."))
		if (reagents.should_admin_log())
			admin_attacker_log(user, "spiked \a [target] with a pill. Reagents: [reagentlist()]")
		reagents.trans_to(target, reagents.total_volume)
		user.visible_message(SPAN_WARNING("\The [user] puts something in \the [target]."))
		qdel(src)
		return TRUE
	else return FALSE


/obj/item/reagent_containers/pill/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (is_sharp(W) || istype(W, /obj/item/card/id))
		user.visible_message(
			SPAN_WARNING("\The [user] starts to gently cut up \the [src] with \a [W]!"),
			SPAN_NOTICE("You start to gently cut up \the [src] with \the [W]."),
			SPAN_WARNING("You hear quiet grinding.")
		)
		playsound(loc, 'sound/effects/chop.ogg', 50, 1)
		if (!do_after(user, 5 SECONDS, src, DO_PUBLIC_UNIQUE))
			return TRUE
		var/obj/item/reagent_containers/powder/powder = new (loc)
		if (reagents)
			reagents.trans_to_obj(powder, reagents.total_volume)
		powder.update_icon()
		user.visible_message(
			SPAN_WARNING("\The [user] gently cuts up \the [src] with \a [W]!"),
			SPAN_NOTICE("You gently cut up \the [src] with \the [W].")
		)
		playsound(loc, 'sound/effects/chop.ogg', 50, 1)
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/pill/antitox
	name = "Dylovene (25u)"
	desc = "Neutralizes many common toxins."
	icon_state = "pill1"
	reagents = list(/datum/reagent/dylovene = 25)


/obj/item/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill4"
	reagents_volume = 50
	reagents = list(/datum/reagent/toxin = 50)


/obj/item/reagent_containers/pill/cyanide
	name = "cyanide pill"
	desc = "It's marked 'KCN'. Smells vaguely of almonds."
	icon_state = "pillC"
	reagent_container_flags = EMPTY_BITFIELD
	reagents_volume = 50
	reagents = list(/datum/reagent/toxin/cyanide = 50)


/obj/item/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pillA"
	reagent_container_flags = EMPTY_BITFIELD
	reagents = list(/datum/reagent/adminordrazine = 1)


/obj/item/reagent_containers/pill/stox
	name = "Soporific (15u)"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill3"
	reagents = list(/datum/reagent/soporific = 15)


/obj/item/reagent_containers/pill/kelotane
	name = "Kelotane (15u)"
	desc = "Used to treat burns."
	icon_state = "pill2"
	reagents = list(/datum/reagent/kelotane = 15)


/obj/item/reagent_containers/pill/paracetamol
	name = "Paracetamol (15u)"
	desc = "A painkiller for the ages. Chewables!"
	icon_state = "pill3"
	reagents = list(/datum/reagent/paracetamol = 15)


/obj/item/reagent_containers/pill/tramadol
	name = "Tramadol (15u)"
	desc = "A simple painkiller."
	icon_state = "pill3"
	reagents = list(/datum/reagent/tramadol = 15)


/obj/item/reagent_containers/pill/inaprovaline
	name = "Inaprovaline (30u)"
	desc = "Used to stabilize patients."
	icon_state = "pill1"
	reagents = list(/datum/reagent/inaprovaline = 30)


/obj/item/reagent_containers/pill/dexalin
	name = "Dexalin (15u)"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill1"
	reagents = list(/datum/reagent/dexalin = 15)


/obj/item/reagent_containers/pill/dexalin_plus
	name = "Dexalin Plus (15u)"
	desc = "Used to treat extreme oxygen deprivation."
	icon_state = "pill2"
	reagents = list(/datum/reagent/dexalinp = 15)


/obj/item/reagent_containers/pill/dermaline
	name = "Dermaline (15u)"
	desc = "Used to treat burn wounds."
	icon_state = "pill2"
	reagents = list(/datum/reagent/dermaline = 15)


/obj/item/reagent_containers/pill/dylovene
	name = "Dylovene (15u)"
	desc = "A broad-spectrum anti-toxin."
	icon_state = "pill1"
	reagents = list(/datum/reagent/dylovene = 15)


/obj/item/reagent_containers/pill/bicaridine
	name = "Bicaridine (20u)"
	desc = "Used to treat physical injuries."
	icon_state = "pill2"
	reagents = list(/datum/reagent/bicaridine = 20)


/obj/item/reagent_containers/pill/happy
	name = "happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill4"
	reagents = list(
		/datum/reagent/drugs/hextro = 15,
		/datum/reagent/sugar = 15
	)


/obj/item/reagent_containers/pill/zoom
	name = "zoom pill"
	desc = "Zoooom!"
	icon_state = "pill4"
	reagents = list(
		/datum/reagent/impedrezene = 10,
		/datum/reagent/synaptizine = 5,
		/datum/reagent/hyperzine = 5
	)


/obj/item/reagent_containers/pill/three_eye
	name = "strange pill"
	desc = "The surface of this unlabelled pill crawls against your skin."
	icon_state = "pill2"
	reagents = list(/datum/reagent/drugs/three_eye = 10)


/obj/item/reagent_containers/pill/spaceacillin
	name = "Spaceacillin (10u)"
	desc = "Contains antiviral agents."
	icon_state = "pill3"
	reagents = list(/datum/reagent/spaceacillin = 10)


/obj/item/reagent_containers/pill/diet
	name = "diet pill"
	desc = "Guaranteed to get you slim!"
	icon_state = "pill4"
	reagents = list(/datum/reagent/lipozine = 2)


/obj/item/reagent_containers/pill/noexcutite
	name = "Noexcutite (15u)"
	desc = "Feeling jittery? This should calm you down."
	icon_state = "pill4"
	reagents = list(/datum/reagent/noexcutite = 15)


/obj/item/reagent_containers/pill/antidexafen
	name = "Antidexafen (15u)"
	desc = "Common cold mediciation. Safe for babies!"
	icon_state = "pill4"
	reagents = list(
		/datum/reagent/antidexafen = 10,
		/datum/reagent/drink/juice/lemon = 5,
		/datum/reagent/menthol = REM * 0.2
	)


/obj/item/reagent_containers/pill/methylphenidate
	name = "Methylphenidate (15u)"
	desc = "Improves the ability to concentrate."
	icon_state = "pill2"
	reagents = list(/datum/reagent/methylphenidate = 15)


/obj/item/reagent_containers/pill/citalopram
	name = "Citalopram (15u)"
	desc = "Mild anti-depressant."
	icon_state = "pill4"
	reagents = list(/datum/reagent/citalopram = 15)


/obj/item/reagent_containers/pill/paroxetine
	name = "Paroxetine (10u)"
	desc = "Before you swallow a bullet: try swallowing this!"
	icon_state = "pill4"
	reagents = list(/datum/reagent/paroxetine = 15)


/obj/item/reagent_containers/pill/hyronalin
	name = "Hyronalin (10u)"
	desc = "Used to treat radiation poisoning."
	icon_state = "pill1"
	reagents = list(/datum/reagent/hyronalin = 10)


/obj/item/reagent_containers/pill/antirad
	name = "AntiRad"
	desc = "Used to treat radiation poisoning."
	icon_state = "yellow"
	reagent_container_flags = EMPTY_BITFIELD
	reagents = list(
		/datum/reagent/hyronalin = 5,
		/datum/reagent/dylovene = 10
	)


/obj/item/reagent_containers/pill/sugariron
	name = "Sugar-Iron (10u)"
	desc = "Used to help the body naturally replenish blood."
	icon_state = "pill1"
	reagents = list(
		/datum/reagent/iron = 5,
		/datum/reagent/sugar = 5
	)


/obj/item/reagent_containers/pill/detergent
	name = "detergent pod"
	desc = "Put in water to get space cleaner. Do not eat. Really."
	icon_state = "pod21"
	reagent_container_flags = EMPTY_BITFIELD
	reagents = list(/datum/reagent/ammonia = 30)


/obj/item/reagent_containers/pill/cream
	name = "creamer pod"
	desc = "A cellulose pod containing some kind of flavoring."
	icon_state = "pill4"
	reagents = list(/datum/reagent/drink/milk = 5)


/obj/item/reagent_containers/pill/cream_soy
	name = "non-dairy creamer pod"
	desc = "A cellulose pod containing some kind of flavoring."
	icon_state = "pill4"
	reagents = list(/datum/reagent/drink/milk/soymilk = 5)


/obj/item/reagent_containers/pill/orange
	name = "orange flavorpod"
	desc = "A cellulose pod containing some kind of flavoring."
	icon_state = "pill4"
	reagents = list(/datum/reagent/drink/juice/orange = 5)


/obj/item/reagent_containers/pill/mint
	name = "mint flavorpod"
	desc = "A cellulose pod containing some kind of flavoring."
	icon_state = "pill4"
	reagents = list(/datum/reagent/nutriment/mint = 1)
