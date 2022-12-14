/obj
	layer = OBJ_LAYER
	animate_movement = 2

	var/obj_flags

	var/list/matter //Used to store information about the contents of the object.
	var/w_class // Size of the object.
	var/unacidable = FALSE //universal "unacidabliness" var, here so you can use it in any obj.
	var/throwforce = 1
	var/sharp = FALSE		// whether this object cuts
	var/edge = FALSE		// whether this object is more likely to dismember
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/damtype = DAMAGE_BRUTE
	var/armor_penetration = 0
	var/anchor_fall = FALSE
	var/holographic = 0 //if the obj is a holographic object spawned by the holodeck


	/**
	* A mixed flags and scalar field describing how to initialize object reagents. Any value below the
	* 17th bit is considered part of the volume of the reagents datum to be created. Higher bits are
	* reserved for flags. This means that explicitly set reagents volumes may range from 1 to 65535.
	* The reagents var will be nulled for cleanliness and an error produced when:
	* - This field is EMPTY_BITFIELD (0) and reagents is not already null.
	* - This field and the initial reagents list makes a valid initial reagents datum impossible.
	* Setting this field is expected to be done like <volume> | <flags ...>, where both are optional.
	* eg: (120) or (60 | REAGENTS_LAZY) or (REAGENTS_FIT)
	*/
	var/reagents_init = EMPTY_BITFIELD

	/// Causes initially added reagents to not be mixed during initialization.
	var/const/REAGENTS_INIT_LAZY = FLAG(23)

	/// Causes the reagents volume to resize if not large enough for the initial reagents.
	var/const/REAGENTS_INIT_FIT = FLAG(22)

	/// Map of (type = TRUE): Avoids spamming invalid configuration errors.
	var/static/list/obj/invalid_reagents_configurations = list()


/obj/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/Initialize()
	. = ..()
	if (isnull(temperature_coefficient))
		temperature_coefficient = clamp(MAX_TEMPERATURE_COEFFICIENT - w_class, MIN_TEMPERATURE_COEFFICIENT, MAX_TEMPERATURE_COEFFICIENT)
	if (!reagents_init)
		if (reagents)
			HandleInvalidReagentsConfiguration("A")
		return
	InitializeReagents()


/// Convenience thing for handling InitializeReagents failures
/obj/proc/HandleInvalidReagentsConfiguration(condition)
	QDEL_NULL(reagents)
	var/key = "[condition]-[type]"
	if (invalid_reagents_configurations[key])
		return
	invalid_reagents_configurations[key] = TRUE
	log_error("Invalid Reagents Configuration ([condition]): [type]")


/**
* Initializes reagents according to reagents_init and reagents.
* Skips /datum/reagents procs to maximize performance. Dragons?
*
* When reagents is a reagent path, fills reagents to volume with that reagent.
* When reagents is a map, assumes the keys are reagent paths to add.
* - When a value is a number, adds that amount of the reagent.
* - When the value is a list, adds the FIRST entry as amount and OTHERS as data.
*
* eg:
* reagents = /datum/reagent/water
* reagents = list(/datum/reagent/water = 30)
* reagents = list(/datum/reagent/blood = list(30, "blood_type" = "O-"))
*/
/obj/proc/InitializeReagents()
	var/volume = reagents_init & 0xFFFF
	var/restrict_volume = !HAS_FLAGS(reagents_init, REAGENTS_INIT_FIT)
	if (!volume)
		if (restrict_volume)
			HandleInvalidReagentsConfiguration("B")
			return
		if (!islist(reagents))
			HandleInvalidReagentsConfiguration("C")
			return
	var/list/datum/reagent/initial_reagents = reagents
	reagents = new (volume, src)
	if (isnull(initial_reagents))
		return
	if (ispath(initial_reagents, /datum/reagent)) // Shortcut; single simple reagent to a fixed max volume.
		var/datum/reagent/reagent = new initial_reagents (reagents)
		reagent.volume = volume
		reagents.total_volume = volume
		reagents.reagent_list += reagent
	else if (islist(initial_reagents))
		for (var/datum/reagent/reagent as anything in initial_reagents)
			if (!ispath(reagent, /datum/reagent))
				HandleInvalidReagentsConfiguration("E")
				return
			var/list/reagent_volume = initial_reagents[reagent] // Convenience typing for when compounded with data.
			var/list/reagent_data
			if (!isnum(reagent_volume))
				if (islist(reagent_volume))
					reagent_data = reagent_volume.Copy(2)
					reagent_volume = reagent_volume[1]
					if (!isnum(reagent_volume))
						HandleInvalidReagentsConfiguration("F")
						return
				else
					HandleInvalidReagentsConfiguration("G")
					return
			if (restrict_volume && reagents.total_volume + reagent_volume > volume)
				HandleInvalidReagentsConfiguration("H")
				return
			reagent = new reagent (reagents)
			if (reagent_data)
				reagent.data = reagent_data
			reagent.volume = reagent_volume
			reagents.total_volume += reagent_volume
			reagents.reagent_list += reagent
		if (reagents.total_volume > volume) // Resize to fit. We can't get here without allowing it anyway.
			reagents.maximum_volume = reagents.total_volume
	else
		HandleInvalidReagentsConfiguration("D")
		return
	if (!HAS_FLAGS(reagents_init, REAGENTS_INIT_LAZY))
		HANDLE_REACTIONS(src)
	on_reagent_change()


/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src) | usr
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				if(CanUseTopic(M, DefaultTopicState()) > STATUS_CLOSE)
					is_in_use = 1
					interact(M)
				else
					M.unset_machine()
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				if(CanUseTopic(M, DefaultTopicState()) > STATUS_CLOSE)
					is_in_use = 1
					interact(M)
				else
					M.unset_machine()
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/attack_ghost(mob/user)
	ui_interact(user)
	..()

/obj/proc/interact(mob/user)
	return

/mob/proc/unset_machine()
	src.machine = null

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(hide)
	set_invisibility(hide ? INVISIBILITY_MAXIMUM : initial(invisibility))

/obj/proc/hides_under_flooring()
	return level == ATOM_LEVEL_UNDER_TILE

/obj/proc/hear_talk(mob/M as mob, text, verb, datum/language/speaking)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = SPAN_CLASS("game say", "[SPAN_CLASS("name", "[M.name]: ")] [SPAN_CLASS("message", text))]"
		mo.show_message(rendered, 2)
		*/
	return

/obj/proc/see_emote(mob/M as mob, text, emote_type)
	return

/obj/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	return

/obj/proc/damage_flags()
	. = 0
	if(has_edge(src))
		. |= DAMAGE_FLAG_EDGE
	if(is_sharp(src))
		. |= DAMAGE_FLAG_SHARP
		if (damtype == DAMAGE_BURN)
			. |= DAMAGE_FLAG_LASER

/obj/attackby(obj/item/O, mob/user)
	if(obj_flags & OBJ_FLAG_ANCHORABLE)
		if(isWrench(O))
			wrench_floor_bolts(user)
			update_icon()
			return
	return ..()

/obj/proc/wrench_floor_bolts(mob/user, delay=20)
	playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
	if(anchored)
		user.visible_message("\The [user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
	else
		user.visible_message("\The [user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")
	if(do_after(user, delay, src, DO_REPAIR_CONSTRUCT))
		if(!src) return
		to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured \the [src]!"))
		anchored = !anchored
	return 1

/obj/attack_hand(mob/living/user)
	if(Adjacent(user))
		add_fingerprint(user)
	..()

/obj/is_fluid_pushable(amt)
	return ..() && w_class <= round(amt/20)

/obj/proc/can_embed()
	return is_sharp(src)

/obj/AltClick(mob/user)
	if(obj_flags & OBJ_FLAG_ROTATABLE)
		rotate(user)
	..()

/obj/examine(mob/user)
	. = ..()
	if((obj_flags & OBJ_FLAG_ROTATABLE))
		to_chat(user, SPAN_SUBTLE("Can be rotated with alt-click."))

/obj/proc/rotate(mob/user)
	if(!CanPhysicallyInteract(user))
		to_chat(user, SPAN_NOTICE("You can't interact with \the [src] right now!"))
		return

	if(anchored)
		to_chat(user, SPAN_NOTICE("\The [src] is secured to the floor!"))
		return

	set_dir(turn(dir, 90))
	update_icon()

//For things to apply special effects after damaging an organ, called by organ's take_damage
/obj/proc/after_wounding(obj/item/organ/external/organ, datum/wound)

/**
 * Test for if stepping on a tile containing this obj is safe to do, used for things like landmines and cliffs.
 */
/obj/proc/is_safe_to_step(mob/living/L)
	return TRUE
