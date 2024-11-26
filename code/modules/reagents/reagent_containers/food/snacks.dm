/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "Yummy!"
	icon = 'icons/obj/food/food.dmi'
	center_of_mass = "x=16;y=16"
	var/bitesize = 1
	var/bitecount = 0
	var/slice_path
	var/slices_num
	var/dried_type = null
	var/dry = 0
	var/list/eat_sound = 'sound/items/eatfood.ogg'
	var/obj/item/trash
	var/sushi_overlay
	var/can_use_cooker = TRUE


/obj/item/reagent_containers/food/snacks/Destroy()
	for(var/atom/movable/movable in contents)
		movable.dropInto(loc)
	if (trash && !ispath(trash))
		QDEL_NULL(trash)
	return ..()


/obj/item/reagent_containers/food/snacks/proc/OnConsume(mob/living/consumer, mob/living/feeder)
	if (reagents && reagents.total_volume)
		return
	if (consumer)
		consumer.visible_message(
			SPAN_ITALIC("\The [consumer] finishes eating \the [src]."),
			SPAN_ITALIC("You finish eating \the [src].")
		)
		consumer.update_personal_goal(/datum/goal/achievement/specific_object/food, type)
	if (feeder)
		feeder.drop_from_inventory(src, feeder.loc)
	if (loc && trash)
		if (ispath(trash))
			trash = new trash
		if (feeder)
			feeder.put_in_hands(trash)
		else
			trash.dropInto(loc)
		trash = null
	qdel(src)


/obj/item/reagent_containers/food/snacks/use_before(mob/M as mob, mob/user as mob)
	. = FALSE
	if (!istype(M, /mob/living/carbon))
		return FALSE
	if (!reagents || !reagents.total_volume)
		to_chat(user, SPAN_DANGER("None of [src] left!"))
		qdel(src)
		return TRUE
	if (!is_open_container())
		to_chat(user, SPAN_NOTICE("\The [src] isn't open!"))
		return TRUE
	var/mob/living/carbon/C = M
	var/fullness = C.get_fullness()
	if (C == user)
		if (istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if (!H.check_has_mouth())
				to_chat(user, "Where do you intend to put \the [src]? You don't have a mouth!")
				return TRUE
			var/obj/item/blocked = H.check_mouth_coverage()
			if (blocked)
				to_chat(user, SPAN_WARNING("\The [blocked] is in the way!"))
				return TRUE
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (fullness <= 50)
			to_chat(C, SPAN_DANGER("You hungrily chew out a piece of [src] and gobble it!"))
		if (fullness > 50 && fullness <= 150)
			to_chat(C, SPAN_NOTICE("You hungrily begin to eat [src]."))
		if (fullness > 150 && fullness <= 350)
			to_chat(C, SPAN_NOTICE("You take a bite of [src]."))
		if (fullness > 350 && fullness <= 550)
			to_chat(C, SPAN_NOTICE("You unwillingly chew a bit of [src]."))
		if (fullness > 550)
			to_chat(C, SPAN_DANGER("You cannot force any more of [src] to go down your throat."))
			return TRUE
	else
		if(!M.can_force_feed(user, src))
			return TRUE
		if (fullness <= 550)
			user.visible_message(SPAN_DANGER("[user] attempts to feed [M] [src]."))
		else
			user.visible_message(SPAN_DANGER("[user] cannot force anymore of [src] down [M]'s throat."))
			return TRUE
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (!do_after(user, 3 SECONDS, M, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
			return TRUE
		if (user.get_active_hand() != src)
			return TRUE
		var/contained = reagentlist()
		admin_attack_log(user, M, "Fed the victim with [name] (Reagents: [contained])", "Was fed [src] (Reagents: [contained])", "used [src] (Reagents: [contained]) to feed")
		user.visible_message(SPAN_DANGER("[user] feeds [M] [src]."))
	if (reagents)
		if (eat_sound)
			playsound(M, pick(eat_sound), rand(10, 50), 1)
		if (reagents.total_volume)
			if (reagents.total_volume > bitesize)
				reagents.trans_to_mob(M, bitesize, CHEM_INGEST)
			else
				reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
			bitecount++
			OnConsume(M, user)
	return TRUE


/obj/item/reagent_containers/food/snacks/examine(mob/user, distance)
	. = ..()
	if(distance > 1)
		return
	if (bitecount==0)
		return
	else if (bitecount==1)
		to_chat(user, SPAN_NOTICE("\The [src] was bitten by someone!"))
	else if (bitecount<=3)
		to_chat(user, SPAN_NOTICE("\The [src] was bitten [bitecount] time\s!"))
	else
		to_chat(user, SPAN_NOTICE("\The [src] was bitten multiple times!"))


/obj/item/reagent_containers/food/snacks/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(istype(item,/obj/item/storage))
		return ..()
	if(!is_open_container())
		to_chat(user, SPAN_WARNING("\The [src] isn't open!"))
		return TRUE
	// Eating with forks
	if(istype(item,/obj/item/material/utensil))
		var/obj/item/material/utensil/U = item
		if(U.scoop_food)
			if(!U.reagents)
				U.create_reagents(5)
			if (U.reagents.total_volume > 0)
				to_chat(user, SPAN_WARNING("You already have something on \the [U]."))
				return TRUE
			to_chat(user, SPAN_NOTICE("You scoop up some \the [src] with \the [U]!"))
			bitecount++
			U.ClearOverlays()
			U.loaded = "[src]"
			var/image/I = new(U.icon, "loadedfood")
			I.color = src.filling_color
			U.AddOverlays(I)
			if(!reagents)
				crash_with("A snack [type] failed to have a reagent holder when attacked with a [item.type]. It was [QDELETED(src) ? "" : "not"] being deleted.")
			else
				reagents.trans_to_obj(U, min(reagents.total_volume,5))
				if (reagents.total_volume <= 0)
					if (loc && trash)
						if (ispath(trash))
							trash = new trash
						trash.dropInto(loc)
						trash = null
					qdel(src)
			return TRUE
	if (slice_path)
		var/can_slice_here = isturf(src.loc) && ((locate(/obj/structure/table) in src.loc) || (locate(/obj/machinery/optable) in src.loc) || (locate(/obj/item/tray) in src.loc))
		var/hide_item = !has_edge(item) || !can_slice_here
		if (hide_item)
			if (item.w_class >= src.w_class || is_robot_module(item) || istype(item,/obj/item/reagent_containers/food/condiment))
				return ..()
			if(!user.unEquip(item, src))
				FEEDBACK_UNEQUIP_FAILURE(user, item)
				return TRUE
			to_chat(user, SPAN_WARNING("You slip \the [item] inside \the [src]."))
			item.forceMove(src)
			return TRUE
		if (has_edge(item))
			if (!can_slice_here)
				to_chat(user, SPAN_WARNING("You cannot slice \the [src] here! You need a table or at least a tray to do it."))
				return TRUE
			var/slices_lost = 0
			if (item.w_class > 3)
				user.visible_message(SPAN_NOTICE("\The [user] crudely slices \the [src] with [item]!"), SPAN_NOTICE("You crudely slice \the [src] with your [item]!"))
				slices_lost = rand(1,min(1,round(slices_num/2)))
			else
				user.visible_message(SPAN_NOTICE("\The [user] slices \the [src]!"), SPAN_NOTICE("You slice \the [src]!"))
			var/reagents_per_slice = reagents.total_volume/slices_num
			for(var/i=1 to (slices_num-slices_lost))
				var/obj/item/reagent_containers/food/snacks/S = new slice_path (loc, TRUE)
				reagents.trans_to_obj(S, reagents_per_slice)
				if(istype(src, /obj/item/reagent_containers/food/snacks/sliceable/variable))
					S.SetName("[name] slice")
					S.filling_color = filling_color
					var/image/I = image(S.icon, "[S.icon_state]_filling")
					I.color = filling_color
					S.AddOverlays(I)
			qdel(src)
			return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/use_after(obj/item/reagent_containers/food/drinks/glass2/glass, mob/user)
	if(!istype(glass))
		return FALSE
	if(w_class != ITEM_SIZE_TINY)
		to_chat(user, SPAN_NOTICE("\The [src] is too big to properly dip in \the [glass]."))
		return TRUE
	var/transfered = glass.reagents.trans_to_obj(src, reagents_volume)
	if(transfered)
		to_chat(user, SPAN_NOTICE("You dip \the [src] into \the [glass]."))
	else
		if(!glass.reagents.total_volume)
			to_chat(user, SPAN_NOTICE("\The [glass] is empty."))
		else
			to_chat(user, SPAN_NOTICE("\The [src] is full."))
	return TRUE


/obj/item/reagent_containers/food/snacks/attack_animal(mob/living/user)
	if(!isanimal(user) && !isalien(user))
		return
	user.visible_message("<b>[user]</b> nibbles away at \the [src].","You nibble away at \the [src].")
	bitecount++
	if(reagents && user.reagents)
		reagents.trans_to_mob(user, bitesize, CHEM_INGEST)
	spawn(5)
		if(!src && !user.client)
			user.custom_emote(1,"[pick("burps", "cries for more", "burps twice", "looks at the area where the food was")]")
			qdel(src)
	OnConsume(user, user)


/obj/item/reagent_containers/food/snacks/aesirsalad
	name = "aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#468c00"
	center_of_mass = "x=17;y=11"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(8, list("apples" = 3,"salad" = 5)),
		/datum/reagent/drink/doctor_delight = 8,
		/datum/reagent/tricordrazine = 8
	)


/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#fdffd1"
	reagents_volume = 10
	center_of_mass = "x=16;y=13"
	reagents = list(
		/datum/reagent/nutriment/protein/egg = 3
	)


/obj/item/reagent_containers/food/snacks/egg/use_after(obj/O, mob/living/user, click_parameters)
	if(istype(O,/obj/machinery/microwave))
		return FALSE
	if(!O.is_open_container())
		return TRUE
	to_chat(user, "You crack \the [src] into \the [O].")
	reagents.trans_to(O, reagents.total_volume)
	qdel(src)
	return TRUE


/obj/item/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	if (QDELETED(src))
		return
	new/obj/decal/cleanable/egg_smudge(src.loc)
	reagents.splash(hit_atom, reagents.total_volume)
	visible_message(SPAN_WARNING("\The [src] has been squashed!"),SPAN_WARNING("You hear a smack."))
	..()
	qdel(src)


/obj/item/reagent_containers/food/snacks/egg/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(istype(item, /obj/item/pen/crayon))
		var/obj/item/pen/crayon/C = item
		var/clr = C.colourName
		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, SPAN_NOTICE("The egg refuses to take on this color!"))
			return TRUE
		to_chat(usr, SPAN_NOTICE("You color \the [src] [clr]"))
		icon_state = "egg-[clr]"
		return TRUE
	else
		return ..()


/obj/item/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"


/obj/item/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"


/obj/item/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"


/obj/item/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"


/obj/item/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"


/obj/item/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"


/obj/item/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"


/obj/item/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"


/obj/item/reagent_containers/food/snacks/egg/lizard
	name = "unathi egg"
	desc = "Large, slightly elongated egg with a thick shell."
	icon_state = "lizard_egg"
	w_class = ITEM_SIZE_SMALL
	reagents = list(
		/datum/reagent/nutriment/protein/egg = 5
	)


/obj/item/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#ffdf78"
	center_of_mass = "x=16;y=14"
	bitesize = 1
	sushi_overlay = "egg"
	reagents = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1
	)


/obj/item/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#ffffff"
	reagents = list(
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/organ
	name = "organ"
	desc = "It's good for you."
	icon = 'icons/obj/organs.dmi'
	icon_state = "appendix"
	filling_color = "#e00d34"
	center_of_mass = "x=16;y=16"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/toxin = 1
	)


/obj/item/reagent_containers/food/snacks/tofu
	name = "tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=10"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/softtofu = 6
	)


/obj/item/reagent_containers/food/snacks/tofurkey
	name = "tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(12, list("turkey?" = 6))
	)


/obj/item/reagent_containers/food/snacks/stuffing
	name = "stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#c9ac83"
	center_of_mass = "x=16;y=10"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(3, list("dryness" = 2, "bread" = 2))
	)


/obj/item/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#ffdefe"
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	center_of_mass = "x=17;y=16"
	bitesize = 6
	reagents = list(
		/datum/reagent/nutriment = list(3, list("fleshy mushroom" = 2)),
		/datum/reagent/drugs/psilocybin = 3
	)


/obj/item/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	center_of_mass = "x=17;y=16"
	bitesize = 6
	reagents = list(
		/datum/reagent/nutriment = list(3, list("fleshy tomato" = 3))
	)


/obj/item/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=10"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = 12,
		/datum/reagent/hyperzine = 5
	)


/obj/item/reagent_containers/food/snacks/spider
	name = "giant spider leg"
	desc = "An economical replacement for crab. In space! Would probably be a lot nicer cooked."
	icon_state = "spiderleg"
	filling_color = "#d5f5dc"
	center_of_mass = "x=16;y=10"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = list(9, list("slimy protein" = 9))
	)


/obj/item/reagent_containers/food/snacks/spider/cooked
	name = "boiled spider meat"
	desc = "An economical replacement for crab. In space!"
	icon_state = "spiderleg_c"
	bitesize = 5


/obj/item/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of green meat. Smells like acid."
	icon_state = "xenomeat"
	filling_color = "#43de18"
	center_of_mass = "x=16;y=10"
	bitesize = 6
	reagents = list(
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/acid/polyacid = 6
	)


/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "sausage"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 6
	)


/obj/item/reagent_containers/food/snacks/fatsausage
	name = "fat sausage"
	desc = "A piece of mixed, long meat, with some bite to it."
	icon_state = "sausage"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 8
	)


/obj/item/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#f2b6ea"
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/alkysine = 6
	)


/obj/item/reagent_containers/food/snacks/ghostburger
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#fff2ff"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("buns" = 3, "spookiness" = 3))
	)


/obj/item/reagent_containers/food/snacks/humanburger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	filling_color = "#d63c3c"
	reagents = list(
		/datum/reagent/nutriment/protein = 6
	)


/obj/item/reagent_containers/food/snacks/human/burger/use_tool(obj/item/item, mob/living/user)
	if (istype(item, /obj/item/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/reagent_containers/food/snacks/cheeseburger (get_turf(src))
		to_chat(user, "You make a cheeseburger.")
		qdel(item)
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	center_of_mass = "x=16;y=11"
	reagents = list(
		/datum/reagent/nutriment = list(2, list("cheese" = 2, "bun" = 2)),
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/meatburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bun" = 2)),
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/plainburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bun" = 2)),
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/fishburger
	name = "fish sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#ffdefe"
	center_of_mass = "x=16;y=10"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bun" = 2)),
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/tofuburger
	name = "tofu burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("bun" = 2, "pseudo-soy meat" = 3))
	)


/obj/item/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = COLOR_GRAY80
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("bun" = 2, "metal" = 3))
	)


/obj/item/reagent_containers/food/snacks/roburger/Initialize()
	if (prob(5))
		reagents[/datum/reagent/nanites] = 2
	return ..()


/obj/item/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = COLOR_GRAY80
	reagents_volume = 100
	center_of_mass = "x=16;y=11"
	bitesize = 0.1
	reagents = list(
		/datum/reagent/nanites = 100
	)


/obj/item/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43de18"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bun" = 2)),
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/clownburger
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#ff00ff"
	center_of_mass = "x=17;y=12"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("bun" = 2, "clown shoe" = 3))
	)


/obj/item/reagent_containers/food/snacks/mimeburger
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#ffffff"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("bun" = 2, "mime paint" = 3))
	)


/obj/item/reagent_containers/food/snacks/omelette
	name = "cheese omelette"
	desc = "Omelette with cheese!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#fff9a8"
	center_of_mass = "x=16;y=13"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment/protein = 8
	)


/obj/item/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	filling_color = "#e0cf9b"
	center_of_mass = "x=17;y=4"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("sweetness" = 3, "muffin" = 3))
	)


/obj/item/reagent_containers/food/snacks/bananapie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#fbffb8"
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("pie" = 3, "cream" = 2)),
		/datum/reagent/drink/juice/banana = 5
	)


/obj/item/reagent_containers/food/snacks/bananapie/throw_impact(atom/hit_atom)
	..()
	new /obj/decal/cleanable/pie_smudge (loc)
	visible_message(
		SPAN_DANGER("\The [name] splats."),
		SPAN_DANGER("You hear a splat.")
	)
	qdel(src)


/obj/item/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("sweetness" = 2, "pie" = 3)),
		/datum/reagent/drink/juice/berry = 5
	)


/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#e6deb5"
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("waffle" = 8))
	)


/obj/item/reagent_containers/food/snacks/pancakesblu
	name = "blueberry pancakes"
	desc = "Pancakes with blueberries, delicious."
	icon_state = "pancakes_berry"
	trash = /obj/item/trash/plate
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("pancake" = 8))
	)


/obj/item/reagent_containers/food/snacks/pancakes
	name = "pancakes"
	desc = "Pancakes without blueberries, still delicious."
	icon_state = "pancakes"
	trash = /obj/item/trash/plate
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("pancake" = 8))
	)


/obj/item/reagent_containers/food/snacks/eggplantparm
	name = "eggplant parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4d2f5e"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("cheese" = 3, "eggplant" = 3))
	)


/obj/item/reagent_containers/food/snacks/soylentgreen
	name = "soylent green"
	desc = "Not made of people. Honest."
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#b8e6b5"
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/soylenviridians
	name = "soylen virdians"
	desc = "Not made of people. Honest."
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#e6fa61"
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("some sort of protein" = 10))
	)


/obj/item/reagent_containers/food/snacks/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	center_of_mass = "x=16;y=13"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=13"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("tofu" = 2, "pie" = 8))
	)


/obj/item/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#ffcccc"
	center_of_mass = "x=17;y=9"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(5, list("sweetness" = 3, "mushroom" = 3, "pie" = 2)),
		/datum/reagent/toxin/amatoxin = 3,
		/datum/reagent/drugs/psilocybin = 1
	)


/obj/item/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#b8279b"
	center_of_mass = "x=17;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("heartiness" = 2, "mushroom" = 3, "pie" = 3))
	)


/obj/item/reagent_containers/food/snacks/plump_pie/Initialize()
	if (prob(10))
		name = "exceptional plump pie"
		reagents[/datum/reagent/tricordrazine] = 5
	return ..()


/obj/item/reagent_containers/food/snacks/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43de18"
	center_of_mass = "x=16;y=13"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/meatkabob
	name = "meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/material/rods
	filling_color = "#a85340"
	center_of_mass = "x=17;y=15"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 8
	)


/obj/item/reagent_containers/food/snacks/tofukabob
	name = "tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/material/rods
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=15"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("tofu" = 3, "metal" = 1))
	)


/obj/item/reagent_containers/food/snacks/cubancarp
	name = "cuban carp"
	desc = "A sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#e9adff"
	center_of_mass = "x=12;y=5"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(3, list("toasted bread" = 3)),
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/capsaicin = 3
	)


/obj/item/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	filling_color = "#fffad4"
	center_of_mass = "x=16;y=8"
	bitesize = 0.1
	reagents = list(
		/datum/reagent/nutriment = list(2, list("popcorn" = 3))
	)


/obj/item/reagent_containers/food/snacks/loadedbakedpotato
	name = "loaded baked potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9c7a68"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("baked potato" = 3)),
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/fries
	name = "space fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("fresh fries" = 4))
	)


/obj/item/reagent_containers/food/snacks/onionrings
	name = "onion rings"
	desc = "Like circular fries but better."
	icon_state = "onionrings"
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("fried onions" = 5))
	)


/obj/item/reagent_containers/food/snacks/soydope
	name = "soy dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#c4bf76"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("slime" = 2, "soy" = 2))
	)


/obj/item/reagent_containers/food/snacks/spagetti
	name = "spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=16"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(1, list("noodles" = 2))
	)


/obj/item/reagent_containers/food/snacks/cheesyfries
	name = "cheesy fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("fresh fries" = 3, "cheese" = 3)),
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211f02"
	center_of_mass = "x=16;y=12"
	bitesize = 2
	reagents = list(
		/datum/reagent/toxin = 1,
		/datum/reagent/carbon = 3
	)


/obj/item/reagent_containers/food/snacks/plainsteak
	name = "plain steak"
	desc = "A piece of unseasoned cooked meat."
	icon_state = "meatsteak"
	slice_path = /obj/item/reagent_containers/food/snacks/cutlet
	slices_num = 3
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/meatsteak
	name = "meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = 4,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1
	)


/obj/item/reagent_containers/food/snacks/meatsteak/synthetic
	name = "meaty steak"
	desc = "A piece of hot spicy pseudo-meat."


/obj/item/reagent_containers/food/snacks/loadedsteak
	name = "loaded steak"
	desc = "A steak slathered in sauce with sauteed onions and mushrooms."
	icon_state = "meatsteak"
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("onion" = 2, "mushroom" = 2)),
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/nutriment/garlicsauce = 2
	)


/obj/item/reagent_containers/food/snacks/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42b873"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(6, list("mushroom" = 6)),
		/datum/reagent/drugs/psilocybin = 6
	)


/obj/item/reagent_containers/food/snacks/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ed0758"
	center_of_mass = "x=16;y=5"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(6, list("jelly" = 3, "mushroom" = 3)),
		/datum/reagent/toxin/amatoxin = 6,
		/datum/reagent/drugs/psilocybin = 3
	)


/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	filling_color = "#916e36"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("poppy seeds" = 2, "pretzel" = 3))
	)


/obj/item/reagent_containers/food/snacks/meatballsoup
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	center_of_mass = "x=16;y=8"
	bitesize = 5
	eat_sound = list('sound/items/eatfood.ogg', 'sound/items/drink.ogg')
	reagents = list(
		/datum/reagent/nutriment/protein = 8,
		/datum/reagent/water = 5
	)


/obj/item/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"//nonexistant?
	filling_color = "#c4dba0"
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/slimejelly = 5,
		/datum/reagent/water = 10
	)


/obj/item/reagent_containers/food/snacks/bloodsoup
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#ff0000"
	center_of_mass = "x=16;y=7"
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/blood = 10,
		/datum/reagent/water = 5
	)


/obj/item/reagent_containers/food/snacks/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#c4fbff"
	center_of_mass = "x=16;y=7"
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(4, list("salt" = 1, "the worst joke" = 3)),
		/datum/reagent/drink/juice/banana = 5,
		/datum/reagent/water = 10
	)


/obj/item/reagent_containers/food/snacks/onionsoup
	name = "onion soup"
	desc = "Best enjoyed with some bread and cheese."
	icon_state = "onionsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#af8e5a"
	center_of_mass = "x=16;y=8"
	bitesize = 5
	eat_sound = list('sound/items/eatfood.ogg', 'sound/items/drink.ogg')
	reagents = list(
		/datum/reagent/nutriment = list(8, list("onion" = 2)),
		/datum/reagent/water = 5
	)


/obj/item/reagent_containers/food/snacks/vegetablesoup
	name = "vegetable soup"
	desc = "A highly nutritious blend of vegetative goodness. Guaranteed to leave you with a, er, \"souped-up\" sense of wellbeing."
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	center_of_mass = "x=16;y=8"
	bitesize = 5
	eat_sound = list('sound/items/eatfood.ogg', 'sound/items/drink.ogg')
	reagents = list(
		/datum/reagent/nutriment = list(8, list("carrot" = 2, "corn" = 2, "eggplant" = 2, "potato" = 2)),
		/datum/reagent/water = 5
	)


/obj/item/reagent_containers/food/snacks/nettlesoup
	name = "nettle soup"
	desc = "A mean, green, calorically lean dish derived from a poisonous plant. It has a rather acidic bite to its taste."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	center_of_mass = "x=16;y=7"
	bitesize = 5
	eat_sound = list('sound/items/eatfood.ogg', 'sound/items/drink.ogg')
	reagents = list(
		/datum/reagent/nutriment = list(8, list("salad" = 4, "egg" = 2, "potato" = 2)),
		/datum/reagent/water = 5,
		/datum/reagent/tricordrazine = 5
	)


/obj/item/reagent_containers/food/snacks/mysterysoup
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f082ff"
	center_of_mass = "x=16;y=6"
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(1, list("backwash" = 1)),
	)


/obj/item/reagent_containers/food/snacks/mysterysoup/Initialize()
	var/list/datum/reagent/options = list(
		/datum/reagent/nutriment,
		/datum/reagent/carbon,
		/datum/reagent/capsaicin,
		/datum/reagent/frostoil,
		/datum/reagent/drink/juice/tomato,
		/datum/reagent/drink/juice/banana,
		/datum/reagent/tricordrazine,
		/datum/reagent/blood,
		/datum/reagent/imidazoline,
		/datum/reagent/toxin,
		/datum/reagent/slimejelly
	)
	for (var/i = 1 to rand(1, 4))
		var/reagent = pick_n_take(options)
		reagents[reagent] = rand(1, 4)
	return ..()


/obj/item/reagent_containers/food/snacks/wishsoup
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d1f4ff"
	center_of_mass = "x=16;y=11"
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/water = 10
	)


/obj/item/reagent_containers/food/snacks/wishsoup/Initialize()
	if (prob(25))
		desc = "A wish come true!"
		reagents[/datum/reagent/nutriment] = list(8, list("something good" = 8))
	return ..()


/obj/item/reagent_containers/food/snacks/hotchili
	name = "hot chili"
	desc = "A five alarm Texan chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ff3c00"
	center_of_mass = "x=15;y=9"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(3, list("chilli peppers" = 3)),
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/capsaicin = 3,
		/datum/reagent/drink/juice/tomato = 2
	)


/obj/item/reagent_containers/food/snacks/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2b00ff"
	center_of_mass = "x=15;y=9"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(3, list("chilli peppers" = 3)),
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/frostoil = 3,
		/datum/reagent/drink/juice/tomato = 2
	)


/obj/item/reagent_containers/food/snacks/spellburger
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#d505ff"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("magic" = 3, "buns" = 3))
	)


/obj/item/reagent_containers/food/snacks/bigbiteburger
	name = "big bite burger"
	desc = "Forget the Luna Burger! THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#e3d681"
	center_of_mass = "x=16;y=11"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("buns" = 3)),
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Space Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#a36a1f"
	center_of_mass = "x=16;y=13"
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment = list(2, list("tortilla" = 3, "corn" = 3)),
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/capsaicin = 6
	)


/obj/item/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5c3c11"
	center_of_mass = "x=16;y=13"
	bitesize = 6
	reagents = list(
		/datum/reagent/nutriment/protein = 10,
		/datum/reagent/drink/juice/banana = 5,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/sodiumchloride = 1
	)


/obj/item/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#e3d796"
	center_of_mass = "x=18;y=12"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(6, list("french bread" = 6)),
		/datum/reagent/blackpepper = 1,
		/datum/reagent/sodiumchloride = 1
	)


/obj/item/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#e3d796"
	center_of_mass = "x=16;y=16"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(3, list("salt" = 1, "chips" = 3)),
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bread" = 3, "cheese" = 2, "lettuce" = 1)),
		/datum/reagent/nutriment/protein = 3
	)


/obj/item/reagent_containers/food/snacks/toastedsandwich
	name = "toasted sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("toasted bread" = 3, "cheese" = 3)),
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/carbon = 2
	)


/obj/item/reagent_containers/food/snacks/grilledcheese
	name = "grilled cheese sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	filling_color = "#d9be29"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("toasted bread" = 3, "cheese" = 3)),
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/tomatosoup
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d92929"
	center_of_mass = "x=16;y=7"
	bitesize = 3
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(5, list("soup" = 5)),
		/datum/reagent/drink/juice/tomato = 10
	)


/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#ff00f7"
	center_of_mass = "x=15;y=11"
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment = list(8, list("waffle" = 7, "sweetness" = 1)),
		/datum/reagent/drugs/psilocybin = 8
	)


/obj/item/reagent_containers/food/snacks/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9e673a"
	center_of_mass = "x=16;y=5"
	bitesize = 10
	reagents = list(
		/datum/reagent/nutriment = list(6, list(
			"tomato" = 2,
			"potato" = 2,
			"carrot" = 2,
			"eggplant" = 2,
			"mushroom" = 2
		)),
		/datum/reagent/nutriment/protein = 4,
		/datum/reagent/drink/juice/tomato = 5,
		/datum/reagent/imidazoline = 5,
		/datum/reagent/water = 5
	)


/obj/item/reagent_containers/food/snacks/cherrytoast
	name = "jellied toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(1, list("toasted bread" = 2)),
		/datum/reagent/nutriment/cherryjelly = 5
	)


/obj/item/reagent_containers/food/snacks/slimetoast
	name = "jellied toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(1, list("toasted bread" = 2)),
		/datum/reagent/slimejelly = 5
	)


/obj/item/reagent_containers/food/snacks/pbtoast
	name = "peanut butter toast"
	desc = "A slice of bread covered with peanut butter."
	icon_state = "pbtoast"
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(1, list("toasted bread" = 2)),
		/datum/reagent/nutriment/peanutbutter = 5
	)


/obj/item/reagent_containers/food/snacks/ntella_bread
	name = "NTella bread slice"
	desc = "A slice of bread covered with delicious chocolate-nut spread."
	icon_state = "chocobread"
	filling_color = "#4b270f"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(1, list("toasted bread" = 2)),
		/datum/reagent/nutriment/choconutspread = 5
	)


/obj/item/reagent_containers/food/snacks/slimeburger
	name = "jelly burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("buns" = 5)),
		/datum/reagent/slimejelly = 5
	)


/obj/item/reagent_containers/food/snacks/cherryburger
	name = "jelly burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("buns" = 5)),
		/datum/reagent/nutriment/cherryjelly = 5
	)


/obj/item/reagent_containers/food/snacks/milosoup
	name = "milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	center_of_mass = "x=16;y=7"
	bitesize = 4
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(8, list("soy" = 8)),
		/datum/reagent/water = 5
	)


/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("soy" = 4, "tomato" = 4))
	)


/obj/item/reagent_containers/food/snacks/boiledspagetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#fcee81"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("noodles" = 2))
	)


/obj/item/reagent_containers/food/snacks/boiledrice
	name = "boiled rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/rice = 10
	)


/obj/item/reagent_containers/food/snacks/boiledrice/use_tool(obj/item/reagent_containers/food/snacks/snack, mob/living/user)
	if (istype(snack) && snack.sushi_overlay)
		new /obj/item/reagent_containers/food/snacks/sushi (get_turf(src), src, snack)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/chazuke
	name = "chazuke"
	desc = "An ancient way of using up day-old rice, this dish is composed of plain green tea poured over plain white rice. Hopefully you have something else to put in."
	icon_state = "chazuke"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/rice = 10,
		/datum/reagent/drink/tea/green = 5
	)


/obj/item/reagent_containers/food/snacks/katsucurry
	name = "katsu curry"
	desc = "An oriental curry dish made from apples, potatoes, and carrots. Served with rice and breaded chicken."
	icon_state = "katsu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#faa005"
	center_of_mass = "x=17;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list(
			"rice" = 2,
			"apple" = 2,
			"potato" = 2,
			"carrot" = 2,
			"bread" = 2
		))
	)


/obj/item/reagent_containers/food/snacks/ricepudding
	name = "rice pudding"
	desc = "Where's the jam?"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("milky rice" = 10))
	)


/obj/item/reagent_containers/food/snacks/pastatomato
	name = "spaghetti & tomato"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment = list(6, list("tomato" = 3, "noodles" = 3)),
		/datum/reagent/drink/juice/tomato = 10
	)


/obj/item/reagent_containers/food/snacks/nanopasta
	name = "nanopasta"
	desc = "Nanomachines, son!"
	icon_state = "nanopasta"
	trash = /obj/item/trash/plate
	filling_color = "#535e66"
	center_of_mass = "x=16;y=10"
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment = 6,
		/datum/reagent/nanites = 10
	)


/obj/item/reagent_containers/food/snacks/meatballspagetti
	name = "spaghetti & meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspagetti"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("noodles" = 3)),
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("noodles" = 3)),
		/datum/reagent/nutriment/protein = 8
	)


/obj/item/reagent_containers/food/snacks/carrotfries
	name = "carrot fries"
	desc = "Tasty fries from fresh carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#faa005"
	center_of_mass = "x=16;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("carrot" = 3, "salt" = 1)),
		/datum/reagent/imidazoline = 3
	)


/obj/item/reagent_containers/food/snacks/superbiteburger
	name = "super bite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#cca26a"
	center_of_mass = "x=16;y=3"
	bitesize = 10
	reagents = list(
		/datum/reagent/nutriment = list(25, list("buns" = 25)),
		/datum/reagent/nutriment/protein = 25
	)


/obj/item/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#f21873"
	center_of_mass = "x=15;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(3, list("apple" = 3, "caramel" = 3, "sweetness" = 2))
	)


/obj/item/reagent_containers/food/snacks/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#e0edc5"
	center_of_mass = "x=16;y=13"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("sweetness" = 2, "apple" = 2, "pie" = 2))
	)


/obj/item/reagent_containers/food/snacks/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#ff525a"
	center_of_mass = "x=16;y=11"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("sweetness" = 2, "cherry" = 2, "pie" = 2))
	)


/obj/item/reagent_containers/food/snacks/twobread
	name = "two bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#dbcc9a"
	center_of_mass = "x=15;y=12"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(2, list("sourness" = 2, "bread" = 2))
	)


/obj/item/reagent_containers/food/snacks/threebread
	name = "three bread"
	desc = "Is such a thing even possible?"
	icon_state = "threebread"
	filling_color = "#dbcc9a"
	center_of_mass = "x=15;y=12"
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment = list(3, list("sourness" = 2, "bread" = 2))
	)


/obj/item/reagent_containers/food/snacks/slimesandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9e3a78"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(2, list("bread" = 2)),
		/datum/reagent/slimejelly = 5
	)


/obj/item/reagent_containers/food/snacks/cherrysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9e3a78"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(2, list("bread" = 2)),
		/datum/reagent/nutriment/cherryjelly = 5
	)


/obj/item/reagent_containers/food/snacks/slimepbj
	name = "pbj sandwich"
	desc = "A staple classic lunch of gooey jelly and peanut butter."
	icon_state = "pbjsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#bb6a54"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(2, list("bread" = 2)),
		/datum/reagent/nutriment/peanutbutter = 5,
		/datum/reagent/slimejelly = 5
	)


/obj/item/reagent_containers/food/snacks/cherrypbj
	name = "pbj sandwich"
	desc = "A staple classic lunch of gooey jelly and peanut butter."
	icon_state = "pbjsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#bb6a54"
	center_of_mass = "x=16;y=8"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(2, list("bread" = 2)),
		/datum/reagent/nutriment/peanutbutter = 5,
		/datum/reagent/nutriment/cherryjelly = 5
	)


/obj/item/reagent_containers/food/snacks/boiledslimecore
	name = "boiled slime core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"//nonexistant?
	bitesize = 3
	reagents = list(
		/datum/reagent/slimejelly = 5
	)


/obj/item/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "A tasty after-dinner mint. It is only wafer thin."
	icon_state = "mint"
	filling_color = "#f2f2f2"
	center_of_mass = "x=16;y=14"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment/mint = 1
	)


/obj/item/reagent_containers/food/snacks/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#e386bf"
	center_of_mass = "x=17;y=10"
	bitesize = 3
	eat_sound = list('sound/items/eatfood.ogg', 'sound/items/drink.ogg')
	reagents = list(
		/datum/reagent/nutriment = list(8, list("mushroom" = 8, "milk" = 2))
	)


/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"
	center_of_mass = "x=16;y=13"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("mushroom" = 4))
	)


/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/Initialize()
	if (prob(10))
		name = "exceptional plump helmet biscuit"
		reagents[/datum/reagent/tricordrazine] = 5
	return ..()


/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f0f2e4"
	center_of_mass = "x=17;y=10"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment/protein = 5
	)


/obj/item/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fac9ff"
	center_of_mass = "x=15;y=8"
	bitesize = 2
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(8, list("tomato" = 4, "beet" = 4))
	)


/obj/item/reagent_containers/food/snacks/beetsoup/Initialize()
	. = ..()
	name = pick(list("borsch", "bortsch", "borstch", "borsh", "borshch", "borscht"))


/obj/item/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	center_of_mass = "x=17;y=11"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(8, list(
			"salad" = 2,
			"tomato" = 2,
			"carrot" = 2,
			"apple" = 2
		))
	)


/obj/item/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	center_of_mass = "x=17;y=11"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(6, list("100% real salad")),
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#ffff00"
	center_of_mass = "x=16;y=18"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(8, list("apple" = 8)),
		/datum/reagent/gold = 5
	)


/obj/item/reagent_containers/food/snacks/sliceable
	abstract_type = /obj/item/reagent_containers/food/snacks/sliceable
	w_class = ITEM_SIZE_NORMAL


/obj/item/reagent_containers/food/snacks/slice
	abstract_type = /obj/item/reagent_containers/food/snacks/slice


/obj/item/reagent_containers/food/snacks/slice/Initialize(mapload, from_parent)
	if (from_parent)
		reagents = null
	return ..()


/obj/item/reagent_containers/food/snacks/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/meatbread
	slices_num = 5
	filling_color = "#ff7575"
	center_of_mass = "x=19;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("bread" = 10)),
		/datum/reagent/nutriment/protein = 20
	)


/obj/item/reagent_containers/food/snacks/slice/meatbread
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	filling_color = "#ff7575"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("bread" = 10 / 5)),
		/datum/reagent/nutriment/protein = 20 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/xenomeatbread
	slices_num = 5
	filling_color = "#8aff75"
	center_of_mass = "x=16;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("bread" = 10)),
		/datum/reagent/nutriment/protein = 20
	)


/obj/item/reagent_containers/food/snacks/slice/xenomeatbread
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	filling_color = "#8aff75"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("bread" = 10 / 5)),
		/datum/reagent/nutriment/protein = 20 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/bananabread
	name = "banana bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/bananabread
	slices_num = 5
	filling_color = "#ede5ad"
	center_of_mass = "x=16;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("bread" = 10 / 5)),
		/datum/reagent/drink/juice/banana = 20
	)


/obj/item/reagent_containers/food/snacks/slice/bananabread
	name = "banana bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	filling_color = "#ede5ad"
	bitesize = 2
	center_of_mass = "x=16;y=8"
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("bread" = 10 / 5)),
		/datum/reagent/drink/juice/banana = 20 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/tofubread
	name = "tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/tofubread
	slices_num = 5
	filling_color = "#f7ffe0"
	center_of_mass = "x=16;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(20, list("tofu" = 10, "bread" = 10))
	)


/obj/item/reagent_containers/food/snacks/slice/tofubread
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	filling_color = "#f7ffe0"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("tofu" = 10 / 5, "bread" = 10 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/carrotcake
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/carrotcake
	slices_num = 5
	filling_color = "#ffd675"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(25, list("cake" = 10, "sweetness" = 10, "carrot" = 15)),
		/datum/reagent/imidazoline = 10
	)


/obj/item/reagent_containers/food/snacks/slice/carrotcake
	name = "carrot cake slice"
	desc = "Carrotty slice of carrot cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ffd675"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(25 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "carrot" = 15 / 5)),
		/datum/reagent/imidazoline = 10 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/braincake
	slices_num = 5
	filling_color = "#e6aedb"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("cake" = 10, "sweetness" = 10, "slime" = 15)),
		/datum/reagent/nutriment/protein = 25,
		/datum/reagent/alkysine = 10
	)


/obj/item/reagent_containers/food/snacks/slice/braincake
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#e6aedb"
	bitesize = 2
	center_of_mass = "x=16;y=12"
	reagents = list(
		/datum/reagent/nutriment = list(5 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "slime" = 15 / 5)),
		/datum/reagent/nutriment/protein = 25 / 5,
		/datum/reagent/alkysine = 10 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/cheesecake
	slices_num = 5
	filling_color = "#faf7af"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(10, list("cake" = 10, "cream" = 10, "cheese" = 15)),
		/datum/reagent/nutriment/protein = 15
	)


/obj/item/reagent_containers/food/snacks/slice/cheesecake
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#faf7af"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("cake" = 10 / 5, "cream" = 10 / 5, "cheese" = 15 / 5)),
		/datum/reagent/nutriment/protein = 15 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/ntella_cheesecake
	name = "NTella cheesecake"
	desc = "An elaborate layered cheesecake made with chocolate hazelnut spread. You gain calories just by looking at it for too long."
	icon_state = "NTellacheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/ntella_cheesecake
	slices_num = 5
	filling_color = "#331c03"
	center_of_mass = "x=16;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(20, list("hazelnut chocolate" = 15, "creamy cheese" = 10, "crunchy cookie base" = 5)),
		/datum/reagent/nutriment/choconutspread = 15
	)


/obj/item/reagent_containers/food/snacks/slice/ntella_cheesecake
	name = "NTella cheesecake slice"
	desc = "A slice of cake marrying the chocolate taste of NTella with the creamy smoothness of cheesecake, all on a cookie crumble base."
	icon_state = "NTellacheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#331c03"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("hazelnut chocolate" = 15 / 5, "creamy cheese" = 10 / 5, "crunchy cookie base" = 5 / 5)),
		/datum/reagent/nutriment/choconutspread = 15 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/plaincake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/plaincake
	slices_num = 5
	filling_color = "#f7edd5"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(20, list("cake" = 10, "sweetness" = 10, "vanilla" = 15))
	)


/obj/item/reagent_containers/food/snacks/slice/plaincake
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#f7edd5"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "vanilla" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/orangecake
	slices_num = 5
	filling_color = "#fada8e"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(20, list("cake" = 10, "sweetness" = 10, "orange" = 15))
	)


/obj/item/reagent_containers/food/snacks/slice/orangecake
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#fada8e"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "orange" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/limecake
	slices_num = 5
	filling_color = "#cbfa8e"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(20, list("cake" = 10, "sweetness" = 10, "lime" = 15))
	)


/obj/item/reagent_containers/food/snacks/slice/limecake
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#cbfa8e"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "lime" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/lemoncake
	slices_num = 5
	filling_color = "#fafa8e"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(20, list("cake" = 10, "sweetness" = 10, "lemon" = 15))
	)

/obj/item/reagent_containers/food/snacks/slice/lemoncake
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#fafa8e"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "lemon" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/chocolatecake
	slices_num = 5
	filling_color = "#805930"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(20, list("cake" = 10, "sweetness" = 10, "chocolate" = 15))
	)

/obj/item/reagent_containers/food/snacks/slice/chocolatecake
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "chocolate" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "birthday cake"
	desc = "Happy birthday!"
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/birthdaycake
	slices_num = 5
	filling_color = "#ffd6d6"
	center_of_mass = "x=16;y=10"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(20, list("cake" = 10, "sweetness" = 10)),
		/datum/reagent/nutriment/sprinkles = 10
	)


/obj/item/reagent_containers/food/snacks/slice/birthdaycake
	name = "birthday cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#ffd6d6"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(20 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5)),
		/datum/reagent/nutriment/sprinkles = 10 / 5
	)

/obj/item/reagent_containers/food/snacks/sliceable/bread
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/bread
	slices_num = 5
	filling_color = "#ffe396"
	center_of_mass = "x=16;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("bread" = 6))
	)

/obj/item/reagent_containers/food/snacks/slice/bread
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	filling_color = "#d27332"
	bitesize = 2
	center_of_mass = "x=16;y=4"
	reagents = list(
		/datum/reagent/nutriment = list(6 / 5, list("bread" = 6 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/creamcheesebread
	slices_num = 5
	filling_color = "#fff896"
	center_of_mass = "x=16;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("bread" = 6, "cream" = 3, "cheese" = 3)),
		/datum/reagent/nutriment/protein = 15
	)


/obj/item/reagent_containers/food/snacks/slice/creamcheesebread
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	filling_color = "#fff896"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(5 / 5, list("bread" = 6 / 5, "cream" = 3 / 5, "cheese" = 3 / 5)),
		/datum/reagent/nutriment/protein = 15 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/applecake
	name = "apple cake"
	desc = "A cake centred with apples."
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/applecake
	slices_num = 5
	filling_color = "#ebf5b8"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(15, list("cake" = 10, "sweetness" = 10, "apple" = 15))
	)


/obj/item/reagent_containers/food/snacks/slice/applecake
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#ebf5b8"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	reagents = list(
		/datum/reagent/nutriment = list(15 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "apple" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/pumpkinpie
	slices_num = 5
	filling_color = "#f5b951"
	center_of_mass = "x=16;y=10"
	reagents = list(
		/datum/reagent/nutriment = list(15, list("cake" = 10, "sweetness" = 10, "pumpkin" = 15))
	)


/obj/item/reagent_containers/food/snacks/slice/pumpkinpie
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#f5b951"
	bitesize = 2
	center_of_mass = "x=16;y=12"
	reagents = list(
		/datum/reagent/nutriment = list(15 / 5, list("cake" = 10 / 5, "sweetness" = 10 / 5, "pumpkin" = 15 / 5))
	)


/obj/item/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#f5deb8"
	center_of_mass = "x=17;y=6"
	w_class = ITEM_SIZE_TINY
	reagents_volume = 6
	reagents = list(
		/datum/reagent/nutriment = list(1, list("salt" = 1, "cracker" = 2))
	)


/obj/item/reagent_containers/food/snacks/dionaroast
	name = "roast diona"
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754b"
	center_of_mass = "x=16;y=7"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("a chorus of flavor" = 6)),
		/datum/reagent/radium = 2
	)


/obj/item/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#ff3867"
	bitesize = 2
	center_of_mass = "x=16;y=10"


/obj/item/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	filling_color = "#d6bca4"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(3, list("dough" = 3))
	)


/obj/item/reagent_containers/food/snacks/dough/use_tool(obj/item/item, mob/living/user, list/click_params)
	if (istype(item, /obj/item/material/rollingpin))
		new /obj/item/reagent_containers/food/snacks/sliceable/flatdough (src)
		to_chat(user, SPAN_NOTICE("You flatten the dough."))
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	filling_color = "#d6bca4"
	slice_path = /obj/item/reagent_containers/food/snacks/doughslice
	slices_num = 3
	center_of_mass = "x=16;y=16"
	reagents = list(
		/datum/reagent/nutriment/protein = 1,
		/datum/reagent/nutriment = 3
	)


/obj/item/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	filling_color = "#d6bca4"
	slice_path = /obj/item/reagent_containers/food/snacks/spagetti
	slices_num = 1
	bitesize = 2
	center_of_mass = "x=17;y=19"
	reagents = list(
		/datum/reagent/nutriment = list(1, list("dough" = 1))
	)


/obj/item/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "bun"
	filling_color = "#b8824c"
	bitesize = 2
	center_of_mass = "x=16;y=12"
	reagents = list(
		/datum/reagent/nutriment = list(4, list("bun" = 4))
	)


/obj/item/reagent_containers/food/snacks/customburger
	name = "custom burger"
	desc = "A tasty burger."
	icon = 'icons/obj/food/food_custom.dmi'
	icon_state = "customburger"
	filling_color = "#b8824c"
	center_of_mass = "x=16;y=12"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bun" = 3))
	)


/obj/item/reagent_containers/food/snacks/bun/use_tool(obj/item/item, mob/living/user)
	if (istype(item, /obj/item/reagent_containers/food/snacks/meatball) || istype(item, /obj/item/reagent_containers/food/snacks/cutlet))
		new /obj/item/reagent_containers/food/snacks/plainburger (src)
		to_chat(user, "You make a burger.")
		qdel(item)
		qdel(src)
		return TRUE
	else if (istype(item,/obj/item/reagent_containers/food/snacks/sausage))
		new /obj/item/reagent_containers/food/snacks/hotdog (src)
		to_chat(user, "You make a hotdog.")
		qdel(item)
		qdel(src)
		return TRUE
	else if (istype(item,/obj/item/reagent_containers/food/snacks/bun))
		new /obj/item/reagent_containers/food/snacks/bunbun (src)
		to_chat(user, "You make a bun bun.")
		qdel(item)
		qdel(src)
		return TRUE
	else if (istype(item, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/snack = item
		var/obj/item/reagent_containers/food/snacks/customburger/burger = new (src)
		burger.SetName("[snack.name]-burger")
		burger.filling_color = snack.filling_color
		var/image/image = image(burger.icon, "customburger_filling")
		image.color = snack.filling_color
		burger.AddOverlays(image)
		snack.reagents.trans_to_obj(burger, snack.reagents.total_volume)
		to_chat(user, "You make \a [burger].")
		qdel(item)
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/plainburger/use_tool(obj/item/item, mob/living/user)
	if (istype(item, /obj/item/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/reagent_containers/food/snacks/cheeseburger (src)
		to_chat(user, "You make a cheeseburger.")
		qdel(item)
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/boiledspagetti/use_tool(obj/item/item, mob/living/user)
	if (istype(item, /obj/item/reagent_containers/food/snacks/meatball))
		new /obj/item/reagent_containers/food/snacks/meatballspagetti (src)
		to_chat(user, "You add some meatballs to the spaghetti.")
		qdel(item)
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/meatballspagetti/use_tool(obj/item/item, mob/living/user)
	if (istype(item, /obj/item/reagent_containers/food/snacks/meatball))
		new /obj/item/reagent_containers/food/snacks/spesslaw (src)
		to_chat(user, "You add some more meatballs to the spaghetti.")
		qdel(item)
		qdel(src)
		return TRUE
	return ..()


/obj/item/reagent_containers/food/snacks/bunbun
	name = "bun bun"
	desc = "A small bread monkey fashioned from two burger buns."
	icon_state = "bunbun"
	filling_color = "#b8824c"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=8)
	reagents = list(
		/datum/reagent/nutriment = list(8, list("bun" = 8))
	)


/obj/item/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	filling_color = "#d63c3c"
	bitesize = 3
	center_of_mass = "x=21;y=12"
	reagents = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/nutriment = list(4, list("cheese" = 2,"taco shell" = 2))
	)


/obj/item/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawcutlet"
	filling_color = "#fb8258"
	slice_path = /obj/item/reagent_containers/food/snacks/rawbacon
	slices_num = 2
	bitesize = 1
	center_of_mass = "x=17;y=20"
	sushi_overlay = "meat"
	reagents = list(
		/datum/reagent/nutriment/protein = 1
	)


/obj/item/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "cutlet"
	filling_color = "#d75608"
	bitesize = 2
	center_of_mass = "x=17;y=20"
	sushi_overlay = "meat"
	reagents = list(
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/rawbacon
	name = "raw bacon"
	desc = "A raw, fatty strip of meat."
	icon_state = "rawbacon"
	filling_color = "#ffa7a3"
	bitesize = 1
	center_of_mass = "x=16;y=15"
	reagents = list(
		/datum/reagent/nutriment/protein = 1
	)


/obj/item/reagent_containers/food/snacks/bacon
	name = "bacon"
	desc = "A delicious, crispy strip of meat."
	icon_state = "bacon"
	filling_color = "#cb5d27"
	bitesize = 2
	center_of_mass = "x=16;y=15"
	reagents = list(
		/datum/reagent/nutriment/protein = 1
	)


/obj/item/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawmeatball"
	filling_color = "#ce3711"
	bitesize = 2
	center_of_mass = "x=16;y=15"
	reagents = list(
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	filling_color = "#ca5d16"
	bitesize = 2
	center_of_mass = "x=16;y=17"
	reagents = list(
		/datum/reagent/nutriment/protein = 6
	)


/obj/item/reagent_containers/food/snacks/classichotdog
	name = "classic hotdog"
	desc = "Going literal."
	icon_state = "hotcorgi"
	filling_color = "#ca5d16"
	bitesize = 6
	center_of_mass = "x=16;y=17"
	reagents = list(
		/datum/reagent/nutriment/protein = 16
	)


/obj/item/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flatbread"
	filling_color = "#c17f3e"
	bitesize = 2
	center_of_mass = "x=16;y=16"
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bread" = 3))
	)


/obj/item/reagent_containers/food/snacks/grown/potato/use_tool(obj/item/item, mob/living/user, list/click_params)
	if (istype(item,/obj/item/material/knife))
		to_chat(user, SPAN_NOTICE("You cut the potato."))
		new /obj/item/reagent_containers/food/snacks/rawsticks (get_turf(src))
		qdel(src)
		return TRUE
	else
		return ..()


/obj/item/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawsticks"
	filling_color = "#e4bf7e"
	bitesize = 2
	center_of_mass = "x=16;y=12"
	reagents = list(
		/datum/reagent/nutriment = list(3, list("raw potato" = 3))
	)


/obj/item/reagent_containers/food/snacks/canned
	abstract_type = /obj/item/reagent_containers/food/snacks/canned
	icon = 'icons/obj/food/food_canned.dmi'
	atom_flags = EMPTY_BITFIELD
	var/sealed = TRUE


/obj/item/reagent_containers/food/snacks/canned/Initialize()
	. = ..()
	if(!sealed)
		unseal()


/obj/item/reagent_containers/food/snacks/canned/examine(mob/user)
	. = ..()
	to_chat(user, "It is [sealed ? "" : "un"]sealed.")


/obj/item/reagent_containers/food/snacks/canned/attack_self(mob/user)
	if (sealed)
		playsound(loc,'sound/effects/canopen.ogg', rand(10, 50), TRUE)
		to_chat(user, SPAN_NOTICE("You unseal \the [src] with a crack of metal."))
		unseal()


/obj/item/reagent_containers/food/snacks/canned/on_update_icon()
	if (!sealed)
		icon_state = "[initial(icon_state)]-open"


/obj/item/reagent_containers/food/snacks/canned/proc/unseal()
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	sealed = FALSE
	update_icon()


/obj/item/reagent_containers/food/snacks/canned/beef
	name = "quadrangled beefium"
	icon_state = "beef"
	desc = "Proteins carefully cloned from extinct stock of holstein in the meat foundries of Mars."
	trash = /obj/item/trash/beef
	filling_color = "#663300"
	center_of_mass = "x=15;y=9"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = list(12, list("beef" = 12))
	)


/obj/item/reagent_containers/food/snacks/canned/beans
	name = "baked beans"
	icon_state = "beans"
	desc = "Luna Colony beans. Carefully synthethized from soy."
	trash = /obj/item/trash/beans
	filling_color = "#ff6633"
	center_of_mass = "x=15;y=9"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = list(12, list("beans" = 12))
	)


/obj/item/reagent_containers/food/snacks/canned/tomato
	name = "tomato soup"
	icon_state = "tomato"
	desc = "Plain old unseasoned tomato soup. This can predates the formation of the SCG."
	trash = /obj/item/trash/tomato
	filling_color = "#ae0000"
	center_of_mass = "x=15;y=9"
	bitesize = 3
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(6, list("tomato" = 6)),
		/datum/reagent/drink/juice/tomato = 6
	)


/obj/item/reagent_containers/food/snacks/canned/tomato/feed_sound(mob/user)
	playsound(user.loc, 'sound/items/drink.ogg', rand(10, 50), 1)


/obj/item/reagent_containers/food/snacks/canned/spinach
	name = "spinach"
	icon_state = "spinach"
	desc = "Wup-Az! Brand canned spinach. Notably has less iron in it than a watermelon."
	trash = /obj/item/trash/spinach
	filling_color = "#003300"
	center_of_mass = "x=15;y=9"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(6, list("soggy" = 1, "vegetable" = 1)),
		/datum/reagent/adrenaline = 2,
		/datum/reagent/hyperzine = 2,
		/datum/reagent/iron = 2
	)


/obj/item/reagent_containers/food/snacks/canned/berries
	name = "berries"
	icon_state = "berries"
	desc = "Berries preserved in syrup. Good enough for ancient Egypt."
	trash = /obj/item/trash/berries
	filling_color = "#801a39"
	center_of_mass = "x=15;y=9"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(6, list("soggy" = 1, "vegetable" = 1)),
		/datum/reagent/sugar = 3,
		/datum/reagent/drink/juice/berry = 3
	)


/obj/item/reagent_containers/food/snacks/canned/caviar
	name = "caviar"
	icon_state = "fisheggs"
	desc = "Terran caviar, or space carp eggs. Carefully faked using alginate, artificial flavoring and salt. Skrell approved!"
	trash = /obj/item/trash/fishegg
	filling_color = "#000000"
	center_of_mass = "x=15;y=9"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(6, list("fish" = 1, "salt" = 1))
	)


/obj/item/reagent_containers/food/snacks/canned/caviar/true
	name = "caviar"
	icon_state = "carpeggs"
	desc = "Terran caviar, or space carp eggs. Banned by the Sol Food Health Administration for exceeding the legally set amount of carpotoxins in foodstuffs."
	trash = /obj/item/trash/carpegg
	filling_color = "#330066"
	center_of_mass = "x=15;y=9"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(3, list("fish" = 1, "salt" = 1, "numbing sensation" = 1)),
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/toxin/carpotoxin = 0.5
	)


/obj/item/reagent_containers/food/snacks/syndicake
	name = "syndi-cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#ff5d05"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/syndi_cakes
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(4, list("sweetness" = 3, "cake" = 1)),
		/datum/reagent/drink/doctor_delight = 5
	)


/obj/item/reagent_containers/food/snacks/liquidfood
	name = "liquid-food MRE"
	desc = "A prepackaged grey slurry for all of the essential nutrients a soldier requires to survive. No expiration date is visible..."
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#a8a8a8"
	center_of_mass = "x=16;y=15"
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment = list(12, list("chalk" = 12)),
		/datum/reagent/sugar = 4,
		/datum/reagent/iron = 4
	)


/obj/item/reagent_containers/food/snacks/meatcube
	name = "cubed meat"
	desc = "Fried, salted lean meat compressed into a cube. Not very appetizing."
	icon_state = "meatcube"
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=16"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = 15
	)





/obj/item/reagent_containers/food/snacks/skrellsnacks
	name = "skrellsnax"
	desc = "Cured fungus shipped all the way from Jargon 4, almost like jerky! Almost."
	icon_state = "skrellsnacks"
	filling_color = "#a66829"
	center_of_mass = "x=15;y=12"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(10, list("mushroom" = 5, "salt" = 5))
	)


/obj/item/reagent_containers/food/snacks/candy/donor
	name = "donor candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(10, list("candy" = 10)),
		/datum/reagent/sugar = 3
	)


/obj/item/reagent_containers/food/snacks/proteinbar
	name = "protein bar"
	desc = "SwoleMAX brand protein bars, guaranteed to get you feeling perfectly overconfident."
	icon_state = "proteinbar"
	trash = /obj/item/trash/proteinbar
	bitesize = 6
	atom_flags = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_NO_REACT
	reagents = list(
		/datum/reagent/nutriment = 9,
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/proteinbar/Initialize()
	var/flavor_name = pick(GLOB.proteinbar_flavors)
	var/list/flavor_reagents = GLOB.proteinbar_flavors[flavor_name]
	var/count = length(flavor_reagents)
	if (count)
		count = round(4 / count, 0.1)
		for (var/type in flavor_reagents)
			reagents[type] = count
	else
		reagents[flavor_reagents] = 4
	name = "[flavor_name] [name]"
	return ..()


/obj/item/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#fffcb0"
	center_of_mass = "x=14;y=10"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("candy corn" = 4)),
		/datum/reagent/nutriment = 4,
		/datum/reagent/sugar = 2
	)


/obj/item/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7d5f46"
	center_of_mass = "x=16;y=13"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("chocolate" = 5)),
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 2
	)


/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	filling_color = "#b87b12"
	center_of_mass = "x=13;y=16"
	var/overlay_state = "box-donut1"


/obj/item/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment = list(3, list("sweetness", "donut")),
		/datum/reagent/nutriment/sprinkles = 1
	)


/obj/item/reagent_containers/food/snacks/donut/normal/Initialize()
	if (prob(30))
		icon_state = "donut2"
		filling_color = "#ff7fc1"
		SetName("frosted donut")
		reagents[/datum/reagent/nutriment/sprinkles] = 3
	return ..()


/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut_chaos"
	overlay_state = "box-donut_chaos"
	filling_color = "#b87b12"
	bitesize = 10
	reagents = list(
		/datum/reagent/nutriment = list(3, list("sweetness", "donut")),
		/datum/reagent/nutriment/sprinkles = 1
	)


/obj/item/reagent_containers/food/snacks/donut/chaos/Initialize()
	var/reagent = pick(list(
		/datum/reagent/capsaicin,
		/datum/reagent/frostoil,
		/datum/reagent/nutriment/sprinkles,
		/datum/reagent/toxin/phoron,
		/datum/reagent/nutriment/coco,
		/datum/reagent/slimejelly,
		/datum/reagent/drink/juice/banana,
		/datum/reagent/drink/juice/berry,
		/datum/reagent/fuel,
		/datum/reagent/tricordrazine
	))
	reagents[reagent] = 3
	return ..()


/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#b87b12"
	center_of_mass = "x=16;y=11"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(3, list("sweetness", "donut")),
		/datum/reagent/nutriment/sprinkles = 1,
		/datum/reagent/drink/juice/berry = 5
	)


/obj/item/reagent_containers/food/snacks/donut/jelly/Initialize()
	if (prob(30))
		icon_state = "jdonut2"
		filling_color = "#ff7fc1"
		SetName("frosted jelly donut")
		reagents[/datum/reagent/nutriment/sprinkles] = 3
	return ..()


/obj/item/reagent_containers/food/snacks/donut/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#b87b12"
	center_of_mass = "x=16;y=11"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(3, list("sweetness", "donut")),
		/datum/reagent/nutriment/sprinkles = 1,
		/datum/reagent/slimejelly = 5
	)


/obj/item/reagent_containers/food/snacks/donut/slimejelly/Initialize()
	if (prob(30))
		icon_state = "jdonut2"
		filling_color = "#ff7fc1"
		SetName("frosted jelly donut")
		reagents[/datum/reagent/nutriment/sprinkles] = 3
	return ..()


/obj/item/reagent_containers/food/snacks/donut/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#b87b12"
	center_of_mass = "x=16;y=11"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(3, list("sweetness", "donut")),
		/datum/reagent/nutriment/sprinkles = 1,
		/datum/reagent/nutriment/cherryjelly = 5
	)


/obj/item/reagent_containers/food/snacks/donut/cherryjelly/Initialize()
	if (prob(30))
		icon_state = "jdonut2"
		filling_color = "#ff7fc1"
		SetName("frosted jelly donut")
		reagents[/datum/reagent/nutriment/sprinkles] = 3
	return ..()


/obj/item/reagent_containers/food/snacks/clam_chowder
	name = "clam chowder"
	desc = "A delicious creamy chowder made with clam and potatoes."
	icon_state = "clam-chowder"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(5, list("clams" = 5)),
		/datum/reagent/drink/milk/cream = 5
	)


/obj/item/reagent_containers/food/snacks/bisque
	name = "bisque"
	desc = "A creamy soup garnished with lumps of crab meat. Bon appétit!"
	icon_state = "bisque"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	eat_sound = 'sound/items/drink.ogg'
	reagents = list(
		/datum/reagent/nutriment = list(5, list("crab" = 5)),
		/datum/reagent/drink/milk/cream = 5
	)


/obj/item/reagent_containers/food/snacks/stuffed_clam
	name = "stuffed clam"
	desc = "A clam minced with breadcrumbs and baked in the shell."
	icon_state = "stuffed-clam"
	trash = /obj/item/shell/clam
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(1, list("bread" = 1, "clam" = 1)),
		/datum/reagent/nutriment/protein = 1,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1
	)


/obj/item/reagent_containers/food/snacks/steamed_mussels
	name = "steamed mussels"
	desc = "A bowl of mussels steamed in a white wine broth. How opulent."
	icon_state = "steamed-mussels"
	trash = /obj/item/trash/snack_bowl
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment/protein = list(6, list("delicate broth" = 3, "mussels" = 3)),
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/ethanol/wine/premium = 2
	)


/obj/item/reagent_containers/food/snacks/oysters_rockefeller
	name = "oysters rockefeller"
	desc = "A plate of oysters baked with a decadent sauce of rich herbs, bread crumbs, and a garnish of bacon bits."
	icon_state = "oysters-rockefeller"
	trash = /obj/item/trash/plate
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = list(6, list("baked oyster" = 2, "parsley" = 2, "bread" = 1, "bacon" = 1))
	)


/obj/item/reagent_containers/food/snacks/crab_cakes
	name = "crab cakes"
	desc = "Fried crab cakes, topped with a dollop of tartar sauce."
	icon_state = "crab-cakes"
	trash = /obj/item/trash/usedplatter
	bitesize = 3
	reagents = list(
		/datum/reagent/nutriment/protein = list(4, list("fried crab" = 4)),
		/datum/reagent/nutriment/mayo = 1
	)


/obj/item/reagent_containers/food/snacks/crab_rangoon
	name = "crab rangoon"
	desc = "A creamy deep-fried wonton filled with crab meat and cream cheese."
	icon_state = "crab-rangoon"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment/protein = list(3, list("creamy crab meat" = 3)),
		/datum/reagent/drink/milk/cream = 1
	)


/obj/item/reagent_containers/food/snacks/crab_dinner
	name = "crab dinner"
	desc = "A large crab, boiled and served with a lemon wedge. Mind the pincers."
	icon_state = "crab-dinner"
	trash = /obj/item/trash/usedplatter
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = list(5, list("tender crab meat" = 4)),
		/datum/reagent/drink/juice/lemon = 2
	)


/obj/item/reagent_containers/food/snacks/shrimp_cocktail
	name = "shrimp cocktail"
	desc = "Shrimp served in a glass with cocktail sauce."
	icon_state = "shrimp-cocktail"
	trash = /obj/item/reagent_containers/food/drinks/glass2/cocktail
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment/protein = list(4, list("shrimp" = 2, "horseradish" = 2)),
		/datum/reagent/nutriment/ketchup = 1,
		/datum/reagent/nutriment/mayo = 1
	)


/obj/item/reagent_containers/food/snacks/shrimp_tempura
	name = "shrimp tempura"
	desc = "A large shrimp deep-fried in a coat of light, fluffy batter."
	icon_state = "shrimp-tempura"
	bitesize = 3
	sushi_overlay = "tempura"
	reagents = list(
		/datum/reagent/nutriment/protein = list(2, list("fried shrimp" = 2)),
		/datum/reagent/nutriment/batter = list(1, list("fried batter" = 1))
	)


/obj/item/reagent_containers/food/snacks/seafood_paella
	name = "seafood paella"
	desc = "A dish of rice and mixed seafood, sauted in a shallow pan with various herbs and spices. "
	icon_state = "seafood-paella"
	trash = /obj/item/trash/snack_bowl
	bitesize = 6
	reagents = list(
		/datum/reagent/nutriment/protein = list(4, list("seafood" = 3, "saffron" = 3)),
		/datum/reagent/nutriment/rice = 4,
		/datum/reagent/ethanol/wine/premium = 4
	)


/obj/item/reagent_containers/food/snacks/sliceable/unscottiloaf
	name = "loaf of unscotti"
	desc = "A loaf of unscotti, ready to be sliced into the iconic biscotti shape."
	icon_state = "unscottiloaf"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/unscotti
	slices_num = 4
	filling_color = "#ffe396"
	center_of_mass = "x=16;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(8, list("cookie" = 5, "almonds" = 3))
	)


/obj/item/reagent_containers/food/snacks/slice/unscotti
	name = "unscotti"
	desc = "An Italian cookie made with almonds. Typically baked again to make biscotti."
	icon_state = "unscotti"
	filling_color = "#d27332"
	bitesize = 4
	center_of_mass = "x=16;y=4"
	w_class = ITEM_SIZE_TINY
	reagents_volume = 7
	reagents = list(
		/datum/reagent/nutriment = list(8 / 4, list("cookie" = 5 / 4, "almonds" = 3 / 4))
	)

/obj/item/reagent_containers/food/snacks/biscotti
	name = "biscotti"
	desc = "A twice baked Italian cookie usually served before breakfast, after dinner, or with coffee. This one has almonds."
	icon_state = "biscotti"
	filling_color = "#dbc94f"
	center_of_mass = "x=17;y=18"
	w_class = ITEM_SIZE_TINY
	bitesize = 3
	reagents_volume = 9
	reagents = list(
		/datum/reagent/nutriment = list(4, list("sweetness" = 2, "crumbly cookie" = 2, "almonds" = 1))
	)
