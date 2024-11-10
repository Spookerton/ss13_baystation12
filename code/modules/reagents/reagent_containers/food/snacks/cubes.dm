/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_OPEN_CONTAINER
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#adac7f"
	center_of_mass = "x=16;y=14"
	var/wrapped = FALSE
	var/growing = FALSE
	var/monkey_type = /mob/living/carbon/human/monkey
	reagents = list(
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/monkeycube/attack_self(mob/living/user)
	if (wrapped)
		Unwrap(user)


/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	if(!growing)
		growing = TRUE
		src.visible_message(SPAN_NOTICE("\The [src] expands!"))
		var/mob/monkey = new monkey_type
		monkey.dropInto(src.loc)
		qdel(src)


/obj/item/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/living/user)
	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, SPAN_NOTICE("You unwrap \the [src]."))
	wrapped = FALSE
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	var/trash = new /obj/item/trash/cubewrapper(get_turf(user))
	user.put_in_hands(trash)


/obj/item/reagent_containers/food/snacks/monkeycube/OnConsume(mob/living/consumer, mob/living/feeder)
	set waitfor = FALSE
	..()
	if (ishuman(consumer))
		var/mob/living/carbon/human/human = consumer
		to_chat(human, FONT_LARGE(SPAN_DANGER("Something is very wrong ...")))
		var/obj/item/organ/external/organ = human.get_organ(BP_CHEST)
		sleep(3 SECONDS)
		organ.fracture()
		sleep(3 SECONDS)
		human.visible_message(
			SPAN_DANGER("A screeching creature bursts out of \the [human]'s chest!"),
			FONT_HUGE(SPAN_DANGER("Something claws its way out through your [organ]!"))
		)
		organ.take_external_damage(50, 0, EMPTY_BITFIELD, "Live animal escaping the body")
		organ.damage_internal_organs(50, 0, EMPTY_BITFIELD)
		human.AdjustWeakened(5)
		human.AdjustStunned(5)
	else
		consumer.kill_health()
	var/mob/monkey = new monkey_type
	monkey.dropInto(consumer.loc)


/obj/item/reagent_containers/food/snacks/monkeycube/on_reagent_change()
	if (reagents.has_reagent(/datum/reagent/water))
		Expand()


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	item_flags = 0
	obj_flags = 0
	wrapped = TRUE


/obj/item/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/human/farwa


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/human/farwa


/obj/item/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/human/stok


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/human/stok


/obj/item/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/human/neaera


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/human/neaera


/obj/item/reagent_containers/food/snacks/monkeycube/spidercube
	name = "spider cube"
	monkey_type = /obj/spider/spiderling


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/spidercube
	name = "spider cube"
	monkey_type = /obj/spider/spiderling


/obj/item/reagent_containers/food/snacks/monkeycube/pikecube
	name = "strange-looking monkey cube"
	monkey_type = /mob/living/simple_animal/hostile/carp/pike


/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/pikecube
	name = "strange-looking monkey cube"
	monkey_type = /mob/living/simple_animal/hostile/carp/pike


/obj/item/reagent_containers/food/snacks/corpse_cube
	name = "odd fleshy cube"
	desc = "A strangely large, veiny and deformed monkey cube that pulsates and writhes disturbingly"
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_OPEN_CONTAINER
	icon_state = "corpsecube"
	bitesize = 12
	filling_color = "#adac7f"
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment/protein = 20
	)

	var/wrapped = FALSE
	var/growing = FALSE
	var/spawn_type = /mob/living/carbon/human


/obj/item/reagent_containers/food/snacks/corpse_cube/OnConsume(mob/living/consumer, mob/living/feeder)
	set waitfor = FALSE
	..()
	if (ishuman(consumer))
		var/mob/living/carbon/human/human = consumer
		to_chat(human, FONT_LARGE(SPAN_DANGER("You feel something shifting and slithering throughout your body ...")))
		var/obj/item/organ/external/organ = human.get_organ(BP_CHEST)
		var/obj/item/organ/external/unluckylimb1 = human.get_organ(pick(BP_ALL_LIMBS))
		var/obj/item/organ/external/unluckylimb2 = human.get_organ(pick(BP_ALL_LIMBS))
		sleep(3 SECONDS)
		organ.add_pain(30)
		organ.fracture()
		sleep(3 SECONDS)
		unluckylimb1.add_pain(50)
		unluckylimb1.fracture()
		unluckylimb2.add_pain(50)
		unluckylimb2.fracture()
		organ.take_external_damage(50, 0, EMPTY_BITFIELD, "Agonizing pain")
		organ.damage_internal_organs(50, 0, EMPTY_BITFIELD)
		human.AdjustWeakened(5)
		human.AdjustStunned(5)
	else
		consumer.kill_health()


/obj/item/reagent_containers/food/snacks/corpse_cube/use_tool(obj/item/device/dna_sampler/sampler, mob/living/user)
	if (istype(sampler))
		if (sampler.loaded == TRUE)
			to_chat(user, "You inject the DNA sample into the cube.")
			CorpseExpand(sampler.src_dna, sampler.src_name, sampler.src_species, sampler.src_pronouns, sampler.src_faction, sampler.src_flavor)
			sampler.loaded = FALSE
			sampler.icon_state = "dnainjector0"
			sampler.src_dna = null
			sampler.src_pronouns = ""
			sampler.src_faction = ""
			sampler.src_name = ""
			sampler.src_species = ""
			sampler.src_flavor = ""
		else
			to_chat(user,"The cube doesn't so much as twitch without a DNA sample.")
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/corpse_cube/proc/CorpseExpand(source_DNA, source_name, source_species, source_pronouns, source_faction, source_flavor)
	if (!growing)
		growing = TRUE
		var/mob/living/carbon/human/human = new spawn_type
		human.dna = source_DNA
		playsound(loc, 'sound/effects/corpsecube.ogg', 60)
		human.faction = source_faction
		human.real_name = source_name
		human.SetName(source_name)
		human.dna.real_name = source_name
		human.pronouns = source_pronouns
		human.change_pronouns(source_pronouns)
		human.change_species(source_species)
		human.flavor_texts = source_flavor
		src.visible_message(SPAN_WARNING("[src] transforms, the dummy body's features twisting and cracking as it imitates the provided blood!"))
		human.dropInto(loc)
		human.setBrainLoss(200)
		human.adjustOxyLoss(human.maxHealth)
		domutcheck(human, null)
		human.UpdateAppearance()
		qdel(src)
