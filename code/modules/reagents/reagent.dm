/datum/reagent
	var/datum/reagents/holder

	var/reagent_flags = EMPTY_BITFIELD

	var/volume = 0

	var/list/data

	var/name = "Reagent"

	var/description = "A non-descript chemical."

	var/taste_description = "old rotten bandaids"

	/// how this taste compares to others. Higher values means it is more noticable
	var/taste_mult = 1

	var/reagent_state = SOLID

	var/metabolism = REM

	var/ingest_met = 0

	var/touch_met = 0

	var/overdose = 0

	/// Whether the reagent can be detected by health analyzers
	var/scannable = 0

	var/color = "#000000"

	var/color_weight = 1

	/// If TRUE, this reagent affects the color of food items it's added to
	var/color_foods = FALSE

	/// What *percentage* of this is made of *animal* protein (1 is 100%). Used to calculate how it affects skrell
	var/protein_amount = 0

	/// What *percentage* of this is made of sugar
	var/sugar_amount

	/// Scalar 0..1 of how effectively the chem can be filtered (i.e. through sleeper dialysis)
	var/filter_mod = 1

	/// Whether this reagent causes its holder to take on its color, overriding whatever was previously there
	var/color_transfer = FALSE

	var/alpha = 255

	var/hidden_from_codex

	var/glass_icon = DRINK_ICON_DEFAULT

	var/glass_name = "something"

	var/glass_desc = "It's a glass of... what, exactly?"

	var/list/glass_special

	var/condiment_icon_state

	var/condiment_name

	var/condiment_desc

	var/gas_specific_heat = 20

	var/gas_molar_mass = 0.032

	var/gas_overlay_limit = 0.7

	var/gas_flags = EMPTY_BITFIELD

	var/gas_burn_product

	var/gas_overlay = "generic"

	var/chilling_point

	var/chilling_message = "crackles and freezes!"

	var/chilling_sound = 'sound/effects/bubbles.ogg'

	var/list/chilling_products

	var/list/heating_products

	var/heating_point

	var/heating_message = "begins to boil!"

	var/heating_sound = 'sound/effects/bubbles.ogg'

	var/temperature_multiplier = 1

	var/value = 1

	var/scent

	var/scent_intensity = /singleton/scent_intensity/normal

	var/scent_descriptor = SCENT_DESC_SMELL

	var/scent_range = 1

	var/should_admin_log = FALSE

	var/accelerant_quality = 0

	var/fire_colour


/datum/reagent/Destroy()
	holder = null
	return ..()


/datum/reagent/New(datum/reagents/holder, volume, data)
	if (!istype(holder))
		CRASH("Invalid reagents holder: [log_info_line(holder)]")
	src.holder = holder
	src.volume = volume
	initialize_data(data)


/datum/reagent/proc/remove_self(amount)
	if (QDELETED(src))
		return
	holder.remove_reagent(type, amount)


/datum/reagent/proc/on_leaving_metabolism(mob/parent, metabolism_class)
	return


// This doesn't apply to skin contact - this is for, e.g. extinguishers and sprays.
// The difference is that reagent is not directly on the mob's skin - it might just be on their clothing.
/datum/reagent/proc/touch_mob(mob/subject, amount = volume)
	return


// Acid melting, cleaner cleaning, etc
/datum/reagent/proc/touch_obj(obj/subject, amount = volume)
	return


// Cleaner cleaning, lube lubbing, etc, all go here
/datum/reagent/proc/touch_turf(turf/subject, amount = volume)
	return


/datum/reagent/proc/on_mob_life(mob/living/carbon/subject, location)
	if (QDELETED(src))
		return
	if (subject.stat == DEAD && ~reagent_flags & AFFECTS_DEAD)
		return
	if (overdose && location != CHEM_TOUCH)
		var/overdose_threshold = overdose * (reagent_flags & IGNORE_MOB_SIZE? 1 : MOB_MEDIUM / subject.mob_size)
		if (volume > overdose_threshold)
			overdose(subject)
	var/removed = metabolism
	if (ingest_met && location == CHEM_INGEST)
		removed = ingest_met
	if (touch_met && location == CHEM_TOUCH)
		removed = touch_met
	removed = subject.get_adjusted_metabolism(removed)
	removed = min(removed, volume)
	var/effective = removed
	if (location != CHEM_TOUCH && ~reagent_flags & IGNORE_MOB_SIZE)
		effective *= MOB_MEDIUM / subject.mob_size
	subject.chem_doses[type] = subject.chem_doses[type] + effective
	if (effective >= 0.1 || effective >= metabolism * 0.1)
		switch (location)
			if (CHEM_BLOOD)
				affect_blood(subject, effective)
			if (CHEM_INGEST)
				affect_ingest(subject, effective)
			if (CHEM_TOUCH)
				affect_touch(subject, effective)
	if (volume)
		remove_self(removed)


/datum/reagent/proc/affect_blood(mob/living/carbon/subject, removed)
	return


/datum/reagent/proc/affect_ingest(mob/living/carbon/subject, removed)
	if (IS_METABOLICALLY_INERT(subject))
		return
	if (protein_amount)
		handle_protein(subject, src)
	if (sugar_amount)
		handle_sugar(subject, src)
	affect_blood(subject, removed * 0.5)


/datum/reagent/proc/affect_touch(mob/living/carbon/subject, removed)
	return


/datum/reagent/proc/overdose(mob/living/carbon/subject)
	subject.add_chemical_effect(CE_TOXIN, 1)
	subject.adjustToxLoss(REM)
	return


/datum/reagent/proc/initialize_data(new_data)
	data = new_data


/datum/reagent/proc/mix_data(new_data, added_volume)
	return


/datum/reagent/proc/get_data()
	if (islist(data))
		return data.Copy()
	return data


/datum/reagent/proc/ex_act(obj/item/reagent_containers/holder, severity)
	return


/datum/reagent/proc/temperature_effects(temperature)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (custom_temperature_effects(temperature))
		return TRUE
	var/list/datum/reagent/replace_self_with
	var/replace_message
	var/replace_sound
	if (temperature <= chilling_point)
		if (length(chilling_products))
			replace_self_with = chilling_products
			replace_message = "\The [lowertext(name)] [chilling_message]"
			replace_sound = chilling_sound
	else if (temperature >= heating_point)
		if (length(heating_products))
			replace_self_with = heating_products
			replace_message = "\The [lowertext(name)] [heating_message]"
			replace_sound = heating_sound
	if (replace_self_with)
		var/replace_amount = volume / length(replace_self_with)
		var/list/reagent_list = holder.reagent_list
		var/atom/my_atom = holder.my_atom
		reagent_list -= src
		qdel(src)
		for (var/datum/reagent/product as anything in replace_self_with)
			reagent_list += new product (src, replace_amount)
		if (my_atom)
			if (replace_message)
				my_atom.visible_message(SPAN_NOTICE("[icon2html(my_atom, viewers(get_turf(my_atom)))] [replace_message]"))
			if (replace_sound)
				playsound(my_atom, replace_sound, 50, TRUE)
		return TRUE


/datum/reagent/proc/custom_temperature_effects(temperature)
	return
