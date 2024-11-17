
/obj/item/reagent_containers/injector/hypo
	name = "hypospray"
	item_state = "autoinjector"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients. Uses a replacable 30u vial."
	possible_transfer_amounts = "1;2;5;10;15;20;30"
	amount_per_transfer_from_this = 5
	reagents_volume = 0
	time = 7
	single_use = FALSE
	slot_flags = SLOT_BELT | SLOT_HOLSTER

	var/obj/item/reagent_containers/glass/beaker/vial/loaded_vial


/obj/item/reagent_containers/injector/hypo/Initialize()
	. = ..()
	loaded_vial = new (src)
	reagents_volume = loaded_vial.reagents_volume
	reagents.maximum_volume = loaded_vial.reagents.maximum_volume


/obj/item/reagent_containers/injector/hypo/proc/remove_vial(mob/user, swap_mode)
	if (!loaded_vial)
		return
	reagents.trans_to_holder(loaded_vial.reagents, reagents_volume)
	reagents.maximum_volume = 0
	loaded_vial.update_icon()
	user.put_in_hands(loaded_vial)
	loaded_vial = null
	if (swap_mode != "swap")
		to_chat(user, "You remove the vial from the [src].")

/obj/item/reagent_containers/injector/hypo/attack_hand(mob/user)
	if (user.get_inactive_hand() == src)
		if (!loaded_vial)
			to_chat(user, SPAN_NOTICE("There is no vial loaded in the [src]."))
			return
		remove_vial(user)
		update_icon()
		playsound(loc, 'sound/weapons/flipblade.ogg', 50, TRUE)
		return
	return ..()


/obj/item/reagent_containers/injector/hypo/use_tool(obj/item/item, mob/living/user, list/click_params)
	var/usermessage = ""
	if (istype(item, /obj/item/reagent_containers/glass/beaker/vial))
		if (!do_after(user, 1 SECOND, src, DO_PUBLIC_UNIQUE) || !(item in user))
			return TRUE
		if (!user.unEquip(item, src))
			FEEDBACK_UNEQUIP_FAILURE(user, item)
			return TRUE
		if (loaded_vial)
			remove_vial(user, "swap")
			usermessage = "You load \the [item] into \the [src] as you remove the old one."
		else
			usermessage = "You load \the [item] into \the [src]."
		if (item.is_open_container())
			item.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
			item.update_icon()
		loaded_vial = item
		reagents.maximum_volume = loaded_vial.reagents.maximum_volume
		loaded_vial.reagents.trans_to_holder(reagents, reagents_volume)
		user.visible_message(SPAN_NOTICE("[user] has loaded [item] into \the [src]."),SPAN_NOTICE("[usermessage]"))
		update_icon()
		playsound(src, 'sound/weapons/empty.ogg', 50, TRUE)
		return TRUE
	return ..()


/obj/item/reagent_containers/injector/hypo/use_after(obj/target, mob/living/user, click_parameters)
	if (!reagents.total_volume && istype(target, /obj/item/reagent_containers/glass))
		var/good_target = is_type_in_list(target, list(
			/obj/item/reagent_containers/glass/beaker,
			/obj/item/reagent_containers/glass/bottle
		))
		if (!good_target)
			return
		if (!target.is_open_container())
			to_chat(user, SPAN_ITALIC("\The [target] is closed."))
			return TRUE
		if (!target.reagents?.total_volume)
			to_chat(user, SPAN_ITALIC("\The [target] is empty."))
			return TRUE
		var/trans = target.reagents.trans_to_obj(src, amount_per_transfer_from_this)
		to_chat(user, SPAN_NOTICE("You fill \the [src] with [trans] units of the solution."))
		return TRUE
	else
		standard_pour_into(user, target)
		return TRUE
