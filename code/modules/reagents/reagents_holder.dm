GLOBAL_DATUM_INIT(temp_reagents_holder, /obj, new)


/datum/reagents
	var/atom/my_atom
	var/list/datum/reagent/reagent_list = list()
	var/metabolism_class //one of: null, CHEM_TOUCH, CHEM_INGEST, CHEM_BLOOD
	var/maximum_volume = 120
	var/total_volume = 0
	var/del_info


/datum/reagents/Destroy()
	del_info = "[my_atom]([length(reagent_list)||"_"]):[my_atom?.x||"_"],[my_atom?.y||"_"],[my_atom?.z||"_"]"
	SSchemistry.active_reagents -= src
	QDEL_NULL_LIST(reagent_list)
	if (my_atom)
		my_atom.reagents = null
		my_atom = null
	return ..()


/datum/reagents/New(maximum_volume = 120, atom/my_atom, metabolism_class)
	if (!istype(my_atom))
		CRASH("Invalid reagents holder: [log_info_line(my_atom)]")
	src.my_atom = my_atom
	src.maximum_volume = maximum_volume
	if (metabolism_class)
		if (!iscarbon(my_atom))
			CRASH("Invalid metabolism reagents atom [my_atom]")
		src.metabolism_class = metabolism_class


/// Destroys all reagents in the container and zeroes its total_volume
/datum/reagents/proc/clear_reagents()
	QDEL_NULL_LIST(reagent_list)
	reagent_list = list()
	total_volume = 0


/// Returns the container's maximum volume
/datum/reagents/proc/maximum_volume()
	return max(0, maximum_volume)


/// Returns the container's occupied volume
/datum/reagents/proc/occupied_volume()
	return clamp(total_volume, 0, maximum_volume)


/// Returns the container's occupied volume as a 0..1 scalar
/datum/reagents/proc/occupied_volume_scale(to_precision)
	if (to_precision)
		return round(clamp(total_volume / maximum_volume, 0, 1), to_precision)
	return clamp(total_volume / maximum_volume, 0, 1)


/// Returns the difference between the container's maximum and occupied volume
/datum/reagents/proc/free_volume()
	return clamp(maximum_volume - total_volume, 0, maximum_volume)


/// Returns whether the container has free volume left
/datum/reagents/proc/has_free_volume()
	return total_volume < maximum_volume


/// Returns the held reagent with the largest volume, if any
/datum/reagents/proc/get_master_reagent()
	var/volume = 0
	var/datum/reagent/reagent
	for (var/datum/reagent/entry as anything in reagent_list)
		if (entry.volume > volume)
			volume = entry.volume
			reagent = entry
	return reagent


/// Returns the name of the held reagent with the largest volume, if any
/datum/reagents/proc/get_master_reagent_name()
	var/datum/reagent/reagent = get_master_reagent()
	return reagent?.name


/// Returns the type of the held reagent with the largest volume, if any
/datum/reagents/proc/get_master_reagent_type()
	var/datum/reagent/reagent = get_master_reagent()
	return reagent?.type


/// Updates the container's total_volume, culling reagents below MINIMUM_CHEMICAL_VOLUME
/datum/reagents/proc/update_total()
	total_volume = 0
	var/list/datum/reagent/new_reagent_list = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		if (entry.volume < MINIMUM_CHEMICAL_VOLUME)
			qdel(entry)
			continue
		total_volume += entry.volume
		new_reagent_list += entry
	reagent_list = new_reagent_list


/**
* Remove amount of type from the reagent list, updating the container's total_volume and
* culling reagents below MINIMUM_CHEMICAL_VOLUME. If amount is not specified, removes all
* of the reagent.
* **Parameters**:
* - `type` - The /datum/reagent/X to remove
* - `amount` - null to remove all, or a >0 volume to try to remove
* - `skip_reacting` - When falsy (ie, the default), the container will be queued to handle
* reactions if the remove was meaningful. If truthy, it is expected that the caller will
* control queueing.
*/
/datum/reagents/proc/remove_reagent(datum/reagent/type, amount, skip_reacting)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] remove_reagent invalid type '[type]' ([usr])")
		return
	if (isnum(amount))
		if (amount <= 0)
			warning("[log_info_line(my_atom)] remove_reagent invalid amount '[amount]' ([usr])")
			return
	else if (!isnull(amount))
		warning("[log_info_line(my_atom)] remove_reagent invalid amount '[amount]' ([usr])")
		return
	var/discovered
	total_volume = 0
	var/list/datum/reagent/new_reagent_list = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		if (entry.type == type)
			discovered = TRUE
			if (amount)
				entry.volume -= amount
			else
				entry.volume = 0
		if (entry.volume < MINIMUM_CHEMICAL_VOLUME)
			if (metabolism_class)
				entry.on_leaving_metabolism(my_atom, metabolism_class)
			qdel(entry)
			continue
		total_volume += entry.volume
		new_reagent_list += entry
	reagent_list = new_reagent_list
	if (discovered && !skip_reacting)
		QUEUE_REAGENT_REACTION(src)
	if (my_atom)
		my_atom.on_reagent_change()


/**
* Add the type to the reagent list, updating the container's total_volume and
* culling reagents below MINIMUM_CHEMICAL_VOLUME. The container's maximum_volume
* is respected
* **Parameters**:
* - `type` - The /datum/reagent/X to add
* - `amount` - A >0 scalar amount to try to add
* - `data` - Arbitrary data to pass to the new reagent, or mix with the existing instance
* - `skip_reacting` - When falsy, the container will be queued to handle reactions if the
* add was meaningful. If truthy, it is expected that the caller will control queueing.
*/
/datum/reagents/proc/add_reagent(datum/reagent/type, amount, data, skip_reacting)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] add_reagent invalid type '[type]' ([usr])")
		return
	if (!isnum(amount) || amount < MINIMUM_CHEMICAL_VOLUME)
		warning("[log_info_line(my_atom)] add_reagent invalid amount '[amount]' ([usr])")
		return
	total_volume = 0
	var/datum/reagent/reagent
	var/list/datum/reagent/new_reagent_list = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		if (entry.type == type)
			reagent = entry
		else if (entry.volume < MINIMUM_CHEMICAL_VOLUME)
			qdel(entry)
			continue
		total_volume += entry.volume
		new_reagent_list += entry
	reagent_list = new_reagent_list
	amount = min(amount, free_volume())
	if (amount < MINIMUM_CHEMICAL_VOLUME)
		return
	total_volume += amount
	if (!reagent)
		reagent = new type (src)
		reagent.volume = amount
		if (!isnull(data))
			reagent.initialize_data(data)
		reagent_list += reagent
	else
		reagent.volume += amount
		if (!isnull(data))
			reagent.mix_data(data, amount)
	if (!skip_reacting)
		QUEUE_REAGENT_REACTION(src)
	if (my_atom)
		my_atom.on_reagent_change()


/**
* Tests whether type is present in the container
* **Parameters**:
* - `type` - The /datum/reagent/X to test
* - `amount` - Optional, a minimum amount required
*/
/datum/reagents/proc/has_reagent(datum/reagent/type, amount)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] has_reagent invalid type '[type]' ([usr])")
		return FALSE
	if (isnum(amount))
		if (amount <= 0)
			warning("[log_info_line(my_atom)] has_reagent invalid amount '[amount]' ([usr])")
			return FALSE
	else if (!isnull(amount))
		warning("[log_info_line(my_atom)] has_reagent invalid amount '[amount]' ([usr])")
		return FALSE
	var/datum/reagent/instance = locate(type) in reagent_list
	if (!instance)
		return FALSE
	if (!isnull(amount) && instance.volume < amount)
		return FALSE
	return TRUE


/**
* Tests whether any type in types is present in the container
* **Parameters**:
* - `types` - A map of (/datum/reagent/X = minimum amount, ...)
*/
/datum/reagents/proc/has_any_reagent(list/datum/reagent/types)
	var/datum/reagent/instance
	for (var/datum/reagent/type as anything in types)
		instance = locate(type) in reagent_list
		if (!instance)
			continue
		if (instance.volume < types[type])
			continue
		return TRUE
	return FALSE


/**
* Tests whether all types in types are present in the container
* **Parameters**:
* - `types` - A map of (/datum/reagent/X = minimum amount, ...)
*/
/datum/reagents/proc/has_all_reagents(list/datum/reagent/types)
	var/datum/reagent/instance
	for (var/datum/reagent/type as anything in types)
		instance = locate (type) in reagent_list
		if (!instance)
			return FALSE
		if (instance.volume < types[type])
			return FALSE
	return TRUE


/**
* Tests whether a type *not* in types is present in the container
* **Parameters**:
* - `types` - A list of (/datum/reagent/X, ...)
*/
/datum/reagents/proc/has_other_reagent(list/datum/reagent/types)
	for (var/datum/reagent/entry as anything in reagent_list)
		if (entry.type in types)
			continue
		return TRUE
	return FALSE


/**
* Returns the instance of type in the container if it exists
* **Parameters**:
* - `type` - The /datum/reagent/X to test
*/
/datum/reagents/proc/get_reagent(datum/reagent/type)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] get_reagent invalid type '[type]' ([usr])")
		return
	return locate(type) in reagent_list


/**
* Returns the volume of type in the container if any, optionally allowing
* subtypes to contribute
* **Parameters**:
* - `type` - The /datum/reagent/X to fetch a volume for
* - `include_subtypes` - Whether to also count /datum/reagent/X/...
*/
/datum/reagents/proc/get_reagent_amount(datum/reagent/type, include_subtypes)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] get_reagent_amount invalid type '[type]' ([usr])")
		return 0
	if (include_subtypes)
		var/volume = 0
		for (var/datum/reagent/entry as anything in reagent_list)
			if (istype(entry, type))
				volume += entry.volume
		return volume
	var/datum/reagent/instance = locate(type) in reagent_list
	return instance?.volume || 0


/**
* Returns the volume of type and its subtypes in the container as a map of (type = volume, ...)
* **Parameters**:
* - `type` - The /datum/reagent/X/... to fetch volume(s) for
*/
/datum/reagents/proc/get_reagent_amount_list(datum/reagent/type)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] get_reagent_amount_list invalid type '[type]' ([usr])")
		return list()
	var/list/result = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		if (istype(entry, type))
			result[entry.type] = entry.volume
	return result


/**
* Returns the get_data() result for type if present in the container
* **Parameters**:
* - `type` - The /datum/reagent/X to fetch data from
*/
/datum/reagents/proc/get_data(datum/reagent/type)
	if (!ispath(type, /datum/reagent))
		warning("[log_info_line(my_atom)] get_data invalid type '[type]' ([usr])")
		return
	var/datum/reagent/instance = locate(type) in reagent_list
	return instance?.get_data()


/**
* Returns an english formatted list of reagents in the container
* **Parameters**:
* - `scannable_only` - If set, skips entries with scannable not set. For health analyzers
* - `precision` - A scalar precision to round each reported volume to, eg 1 or 0.1
*/
/datum/reagents/proc/get_reagent_display_list(scannable_only, precision)

	var/list/sections = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		if (!entry.scannable && scannable_only)
			continue
		var/volume = entry.volume
		if (precision)
			volume = round(volume, precision)
		if (volume)
			sections += "[entry.name] ([volume])"
	return english_list(sections, "EMPTY", ", ", ", ", ", ")


/**
* Remove amount from the entries of reagent_list, updating the container's total_volume
* and culling reagents below MINIMUM_CHEMICAL_VOLUME
* **Parameters**:
* - `amount` - A >0 scalar amount to try to add
* - `skip_reacting` - When falsy, the container will be queued to handle reactions if the
* remove was meaningful. If truthy, it is expected that the caller will control queueing.
* Meaningful means that some amount was removed.
*/
/datum/reagents/proc/remove_any(amount = 1, skip_reacting)
	if (!isnum(amount) || amount < 0)
		return
	amount = min(amount, total_volume)
	if (!amount)
		return
	amount /= total_volume
	var/list/datum/reagent/new_reagent_list = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		entry.volume -= entry.volume *= amount
		if (entry.volume < MINIMUM_CHEMICAL_VOLUME)
			qdel(entry)
			continue
		new_reagent_list += entry
	reagent_list = new_reagent_list
	if (!skip_reacting)
		QUEUE_REAGENT_REACTION(src)
	if (my_atom)
		my_atom.on_reagent_change()


/**
* Handle reagent reactions in this container. Typically run by queueing to SSChemistry
*/
/datum/reagents/proc/process_reactions()
	if (!my_atom)
		return FALSE
	if (!my_atom.loc)
		return FALSE
	if (my_atom.atom_flags & ATOM_FLAG_NO_REACT)
		return FALSE
	var/reaction_occurred = FALSE
	var/list/eligible_reactions = list()
	var/temperature = my_atom?.temperature || T20C
	for (var/datum/reagent/reagent as anything in reagent_list)
		if (reagent.temperature_effects(temperature, src))
			reaction_occurred = TRUE
			continue
		eligible_reactions |= SSchemistry.id_reactions_map[reagent.type]
	var/list/active_reactions = list()
	for (var/singleton/reaction/reaction as anything in eligible_reactions)
		if (reaction.can_happen(src))
			active_reactions[reaction] = 1
			reaction_occurred = TRUE
	if (!length(active_reactions))
		return reaction_occurred
	var/list/used_reagents = list()
	for (var/singleton/reaction/reaction as anything in active_reactions)
		var/list/reaction_reagents = reaction.get_used_reagents()
		for (var/datum/reagent/reagent as anything in reaction_reagents)
			LAZYADD(used_reagents[reagent], reaction)
	for (var/datum/reagent/reagent as anything in used_reagents)
		var/reaction_list = used_reagents[reagent]
		var/reaction_count = length(reaction_list)
		if (reaction_count < 2)
			break
		for (var/singleton/reaction/reaction as anything in reaction_list)
			active_reactions[reaction] = max(reaction_count, active_reactions[reaction])
			--reaction_count
	for (var/singleton/reaction/reaction as anything in active_reactions)
		reaction.process(src, active_reactions[reaction])
	for (var/singleton/reaction/reaction as anything in active_reactions)
		reaction.post_reaction(src)
	update_total()
	if (reaction_occurred)
		QUEUE_REAGENT_REACTION(src)
	return reaction_occurred


/datum/reagents/proc/metabolize()
	if (metabolism_class && length(reagent_list))
		for (var/datum/reagent/entry as anything in reagent_list)
			entry.on_mob_life(my_atom, metabolism_class)
		update_total()


/**
* Proportionally move reagents from this reagent container to the target, respecting the
* target's maximum volume.
* **Parameters**:
*/
/datum/reagents/proc/trans_to_holder(datum/reagents/target, amount, skip_reacting, clone)
	if (!istype(target))
		warning("[src] trans_to_holder '[target]' target not a reagents holder")
		return 0
	if (!isnum(amount) || amount <= 0)
		warning("[src] trans_to_holder '[target]' invalid amount [amount]")
		return 0
	amount = clamp(amount, 0, target.free_volume())
	if (amount <= 0)
		return 0
	var/transfer_multiplier = amount / total_volume
	var/list/datum/reagent/new_reagent_list = list()
	for (var/datum/reagent/entry as anything in reagent_list)
		var/transfer_amount = entry.volume * transfer_multiplier
		target.add_reagent(entry.type, transfer_amount, entry.get_data(), TRUE)
		if (clone)
			continue
		entry.volume -= transfer_amount
		if (entry.volume < MINIMUM_CHEMICAL_VOLUME)
			qdel(entry)
			continue
		total_volume += entry.volume
		new_reagent_list += entry
	if (!clone)
		reagent_list = new_reagent_list
		QUEUE_REAGENT_REACTION(src)
	if (!skip_reacting)
		QUEUE_REAGENT_REACTION(target)
	return amount


/**
* Touch effects happen on "contact" - that is, they don't transfer reagents to the target.
* For example, splashing a burning person with water will wet and extinguish them.
* **Parameters**:
*/
/datum/reagents/proc/touch(atom/target)
	if (!istom(target) || !target.simulated)
		warning("datum/reagents touch '[target]' fail; invalid target")
		return 0
	else if (ismob(target))
		touch_mob(target)
		return 1
	else if (isturf(target))
		touch_turf(target)
		return 2
	else if (isobj(target))
		touch_obj(target)
		return 3


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/touch_mob(mob/target)
	PRIVATE_PROC(TRUE)
	for (var/datum/reagent/reagent as anything in reagent_list)
		reagent.touch_mob(target)
	update_total()


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/touch_turf(turf/target)
	PRIVATE_PROC(TRUE)
	for (var/datum/reagent/reagent as anything in reagent_list)
		reagent.touch_turf(target)
	update_total()


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/touch_obj(obj/target)
	PRIVATE_PROC(TRUE)
	for (var/datum/reagent/reagent as anything in reagent_list)
		reagent.touch_obj(target)
	update_total()


//The general proc for applying reagents to things. This proc assumes the reagents are being applied externally,
//not directly injected into the contents. It first calls touch, then the appropriate trans_to_*() or splash_mob().
//If for some reason touch effects are bypassed (e.g. injecting stuff directly into a reagent container or person),
//call the appropriate trans_to_*() proc.
/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/trans_to(atom/target, amount, clone)
	if (!istom(target))
		warning("trans_to '[target]' fail; invalid target")
		return
	if (!isnum(amount) || amount <= 0)
		warning("trans_to '[target]' fail; invalid amount [amount]")
		return
	if (total_volume <= 0)
		return
	if (!target.simulated)
		return
	switch (touch(target))
		if (1)
			return splash_mob(target, amount, clone)
		if (2)
			return trans_to_turf(target, amount, clone)
		if (3)
			if (target.is_open_container())
				return trans_to_obj(target, amount, clone)


//Splashing reagents is messier than trans_to, the target's loc gets some of the reagents as well.
/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/splash(atom/target, amount, clone, min_spill = 0, max_spill = 0.6)
	if (!istom(target) || !target.simulated)
		warning("trans_to '[target]' fail; invalid target")
		return
	if (!isnum(amount) || amount <= 0)
		warning("trans_to '[target]' fail; invalid amount \"[amount]\"")
		return
	if (!isturf(target) && target.loc)
		max_spill = clamp(max_spill, 0, 1)
		min_spill = clamp(min_spill, 0, max_spill)
		var/spill = amount * Frand(min_spill, max_spill)
		if (spill)
			splash(target.loc, spill, clone, min_spill, max_spill)
		amount -= spill
	if (amount)
		trans_to(target, amount, clone)


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/trans_type_to(atom/target, type, amount, clone)
	if (!istom(target) || !target.simulated || !target.reagents)
		warning("trans_to '[target]' fail; invalid target")

	if (!target || !target.reagents || !target.simulated)
		return
	amount = min(amount, get_reagent_amount(type))
	if(!amount)
		return
	var/datum/reagents/F = new (amount, GLOB.temp_reagents_holder)
	var/tmpdata = get_data(type)
	F.add_reagent(type, amount, tmpdata)
	remove_reagent(type, amount)
	. = F.trans_to(target, amount)
	qdel(F)


// Attempts to place a reagent on the mob's skin.
// Reagents are not guaranteed to transfer to the target.
// Do not call this directly, call trans_to() instead.
/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/splash_mob(mob/target, amount = 1, copy = 0)
	var/perm = 1
	if(isliving(target)) //will we ever even need to tranfer reagents to non-living mobs?
		var/mob/living/L = target
		perm = L.reagent_permeability()
	return trans_to_mob(target, amount * perm, CHEM_TOUCH, 1, copy)


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/trans_to_mob(mob/target, amount, clone, type = CHEM_BLOOD)
	PRIVATE_PROC(TRUE)
	if(!target || !istype(target) || !target.simulated)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(type == CHEM_BLOOD)
			var/datum/reagents/R = C.reagents
			return trans_to_holder(R, amount, multiplier, copy)
		if(type == CHEM_INGEST)
			var/datum/reagents/R = C.get_ingested_reagents()
			return C.ingest(src, R, amount, multiplier, copy) //perhaps this is a bit of a hack, but currently there's no common proc for eating reagents
		if(type == CHEM_TOUCH)
			var/datum/reagents/R = C.touching
			return trans_to_holder(R, amount, multiplier, copy)
	else
		var/datum/reagents/R = new (amount, GLOB.temp_reagents_holder)
		. = trans_to_holder(R, amount, multiplier, copy, 1)
		R.touch_mob(target)
		qdel(R)


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/trans_to_turf(turf/target, amount = 1, multiplier = 1, copy = 0) // Turfs don't have any reagents (at least, for now). Just touch it.
	PRIVATE_PROC(TRUE)
	if(!target || !target.simulated)
		return
	var/datum/reagents/R = new  (amount * multiplier, GLOB.temp_reagents_holder)
	. = trans_to_holder(R, amount, multiplier, copy, 1)
	R.touch_turf(target)
	qdel(R)
	return


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/trans_to_obj(obj/target, amount = 1, multiplier = 1, copy = 0) // Objects may or may not; if they do, it's probably a beaker or something and we need to transfer properly; otherwise, just touch.
	PRIVATE_PROC(TRUE)
	if(!target || !target.simulated)
		return
	if(!target.reagents)
		var/datum/reagents/R = new (amount * multiplier, GLOB.temp_reagents_holder)
		. = trans_to_holder(R, amount, multiplier, copy, 1)
		R.touch_obj(target)
		qdel(R)
		return
	return trans_to_holder(target.reagents, amount, multiplier, copy)


///
/datum/reagents/proc/should_admin_log()
	for (var/datum/reagent/reagent as anything in reagent_list)
		if (reagent.should_admin_log)
			return TRUE
	return FALSE


/**
*
* **Parameters**:
*
*/
/datum/reagents/proc/Resize(new_volume = maximum_volume)
	maximum_volume = max(1, new_volume)
	var/over_volume = total_volume - maximum_volume
	if (over_volume <= 0)
		return
	over_volume /= length(reagent_list)
	total_volume = 0
	var/list/removed = list()
	for (var/datum/reagent/reagent as anything in reagent_list)
		reagent.volume -= over_volume
		if (reagent.volume >= MINIMUM_CHEMICAL_VOLUME)
			total_volume += reagent.volume
		else
			removed += reagent
	reagent_list -= removed
	QDEL_NULL_LIST(removed)


/datum/reagents/proc/get_color()
	if (!reagent_list || !length(reagent_list))
		return "#ffffffff"
	if (length(reagent_list) == 1) // It's pretty common and saves a lot of work
		var/datum/reagent/R = reagent_list[1]
		return R.color + num2hex(R.alpha)
	var/list/colors = list(0, 0, 0, 0)
	var/tot_w = 0
	for (var/datum/reagent/R in reagent_list)
		var/hex = uppertext(R.color) + num2hex(R.alpha)
		colors[1] += hex2num(copytext(hex, 2, 4)) * R.volume * R.color_weight
		colors[2] += hex2num(copytext(hex, 4, 6)) * R.volume * R.color_weight
		colors[3] += hex2num(copytext(hex, 6, 8)) * R.volume * R.color_weight
		colors[4] += hex2num(copytext(hex, 8, 10)) * R.volume * R.color_weight
		tot_w += R.volume * R.color_weight
	return rgb(colors[1] / tot_w, colors[2] / tot_w, colors[3] / tot_w, colors[4] / tot_w)



/**
* Creates a reagent holder for the atom. This shouldn't be used if a reagents holder already exists.
*
* **Parameters**:
* - `maximum_volume` integer - The maximum volume of the new reagents holder.
* - `initial_reagents` list - If set, a list of reagents to immediately add to the new reagents holder.
*
* Returns instance of `/datum/reagents`. The newly created reagents holder or, if the atom already had a holder, the
* pre-existing holder.
*/
/atom/proc/create_reagents(maximum_volume, list/initial_reagents)
	if (reagents)
		log_debug("Attempted to create a new reagents holder when already referencing one: [log_info_line(src)]")
		return reagents
	reagents = new (maximum_volume, src)
	if (!initial_reagents)
		return reagents
	if (ispath(initial_reagents))
		reagents.add_reagent(initial_reagents, maximum_volume)
		return reagents
	var/list/details
	for (var/reagent in initial_reagents)
		details = initial_reagents[reagent]
		if (islist(details))
			reagents.add_reagent(reagent, details[1], details[2], skip_reacting = TRUE)
		else
			reagents.add_reagent(reagent, details, skip_reacting = TRUE)
	QUEUE_REAGENT_REACTION(src)
	return reagents
