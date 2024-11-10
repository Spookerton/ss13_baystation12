/obj/item/reagent_containers/food/snacks/sliceable/margherita
	name = "margherita"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/margherita
	slices_num = 6
	center_of_mass = "x=16;y=11"
	filling_color = "#baa14c"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(30, list(
			"pizza crust" = 10,
			"tomato" = 10,
			"cheese" = 10
		)),
		/datum/reagent/nutriment/protein = 5,
		/datum/reagent/drink/juice/tomato = 6
	)


/obj/item/reagent_containers/food/snacks/slice/margherita
	name = "margherita slice"
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"
	filling_color = "#baa14c"
	bitesize = 2
	center_of_mass = "x=18;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(30 / 6, list(
			"pizza crust" = 10 / 6,
			"tomato" = 10 / 6,
			"cheese" = 10 / 6
		)),
		/datum/reagent/nutriment/protein = 5 / 6,
		/datum/reagent/drink/juice/tomato = 6 / 6
	)


/obj/item/reagent_containers/food/snacks/sliceable/meatpizza
	name = "meatpizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/meatpizza
	slices_num = 6
	center_of_mass = "x=16;y=11"
	filling_color = "#baa14c"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(15, list(
			"pizza crust" = 10,
			"tomato" = 10,
			"cheese" = 10
		)),
		/datum/reagent/nutriment/protein = 20,
		/datum/reagent/drink/juice/tomato = 6
	)


/obj/item/reagent_containers/food/snacks/slice/meatpizza
	name = "meatpizza slice"
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"
	filling_color = "#baa14c"
	bitesize = 2
	center_of_mass = "x=18;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(15 / 6, list(
			"pizza crust" = 10 / 6,
			"tomato" = 10 / 6,
			"cheese" = 10 / 6
		)),
		/datum/reagent/nutriment/protein = 20 / 6,
		/datum/reagent/drink/juice/tomato = 6 / 6
	)


/obj/item/reagent_containers/food/snacks/sliceable/mushroompizza
	name = "mushroompizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/mushroompizza
	slices_num = 6
	center_of_mass = "x=16;y=11"
	filling_color = "#baa14c"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(30, list("pizza crust" = 10, "cheese" = 10)),
		/datum/reagent/nutriment/protein = 5,
		/datum/reagent/drink/juice/tomato = 6
	)


/obj/item/reagent_containers/food/snacks/slice/mushroompizza
	name = "mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#baa14c"
	bitesize = 2
	center_of_mass = "x=18;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(30 / 6, list("pizza crust" = 10 / 6, "cheese" = 10 / 6)),
		/datum/reagent/nutriment/protein = 5 / 6,
		/datum/reagent/drink/juice/tomato = 6 / 6
	)


/obj/item/reagent_containers/food/snacks/sliceable/vegetablepizza
	name = "vegetable pizza"
	desc = "No one of Tomato Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/vegetablepizza
	slices_num = 6
	center_of_mass = "x=16;y=11"
	filling_color = "#baa14c"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(25, list(
			"pizza crust" = 10,
			"tomato" = 10,
			"cheese" = 5,
			"eggplant" = 5,
			"carrot" = 5,
			"corn" = 5
		)),
		/datum/reagent/nutriment/protein = 5,
		/datum/reagent/drink/juice/tomato = 6,
		/datum/reagent/imidazoline = 12
	)


/obj/item/reagent_containers/food/snacks/slice/vegetablepizza
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	filling_color = "#baa14c"
	bitesize = 2
	center_of_mass = "x=18;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(25 / 6, list(
			"pizza crust" = 10 / 6,
			"tomato" = 10 / 6,
			"cheese" = 5 / 6,
			"eggplant" = 5 / 6,
			"carrot" = 5 / 6,
			"corn" = 5 / 6
		)),
		/datum/reagent/nutriment/protein = 5 / 6,
		/datum/reagent/drink/juice/tomato = 6 / 6,
		/datum/reagent/imidazoline = 12 / 6
	)


/obj/item/reagent_containers/food/snacks/sliceable/fruitpizza
	name = "fruit pizza"
	desc = "Cream and mixed fruit on a pizza crust. Is it even legal?"
	icon_state = "fruitpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/fruitpizza
	slices_num = 6
	center_of_mass = "x=16;y=11"
	filling_color = "#baa14c"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(15, list(
			"pizza crust" = 10,
			"cream" = 10,
			"pineapple" = 5,
			"banana" = 5,
			"blueberry" = 5,
			"sugar" = 5
		)),
		/datum/reagent/drink/juice/banana = 5,
		/datum/reagent/drink/juice/berry = 5,
		/datum/reagent/drink/juice/pineapple = 5
	)


/obj/item/reagent_containers/food/snacks/slice/fruitpizza
	name = "fruit pizza slice"
	desc = "A slice of cream, fruit, and crust. How strange."
	icon_state = "fruitpizzaslice"
	filling_color = "#baa14c"
	bitesize = 2
	center_of_mass = "x=18;y=13"
	reagents = list(
		/datum/reagent/nutriment = list(15 / 6, list(
			"pizza crust" = 10 / 6,
			"cream" = 10 / 6,
			"pineapple" = 5 / 6,
			"banana" = 5 / 6,
			"blueberry" = 5 / 6,
			"sugar" = 5 / 6
		)),
		/datum/reagent/drink/juice/banana = 5 / 6,
		/datum/reagent/drink/juice/berry = 5 / 6,
		/datum/reagent/drink/juice/pineapple = 5 / 6
	)


/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/food_storage.dmi'
	icon_state = "pizzabox1"

	/// Whether the pizza box is open or not
	var/open

	/// Whether the lid icon should be messy or not
	var/messy_lid

	/// The contained pizza, if any
	var/obj/item/reagent_containers/food/snacks/sliceable/pizza

	/// If this box is a stack of boxes, the member boxes
	var/list/obj/item/pizzabox/boxes

	/// The pizza name written on the box, if any
	var/boxtag


/obj/item/pizzabox/Initialize()
	. = ..()
	if (pizza)
		pizza = new pizza (src)
		queue_icon_update()


/obj/item/pizzabox/on_update_icon()
	ClearOverlays()
	if (open && pizza)
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if(length(boxes) > 0)
		desc = "A pile of boxes suited for pizzas. There appears to be [length(boxes) + 1] boxes in the pile."
		var/obj/item/pizzabox/topbox = boxes[length(boxes)]
		var/toptag = topbox.boxtag
		if(toptag != "")
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."
		if(boxtag != "")
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."
	if(open) // Icon states and overlays
		if(messy_lid)
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"
		if(pizza)
			var/image/pizzaimg = image(pizza.icon, icon_state = pizza.icon_state)
			if (istype(pizza, /obj/item/reagent_containers/food/snacks/sliceable/variable/pizza))
				var/image/filling = image("food_custom.dmi", icon_state = "pizza_filling")
				filling.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
				filling.color = pizza.filling_color
				pizzaimg.AddOverlays(filling)
			pizzaimg.pixel_y = -3
			AddOverlays(pizzaimg)
		return
	else // Stupid code because byondcode sucks
		var/doimgtag = 0
		if(length(boxes) > 0)
			var/obj/item/pizzabox/topbox = boxes[length(boxes)]
			if(topbox.boxtag != "")
				doimgtag = 1
		else
			if(boxtag != "")
				doimgtag = 1
		if(doimgtag)
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = length(boxes) * 3
			AddOverlays(tagimg)
	icon_state = "pizzabox[length(boxes)+1]"


/obj/item/pizzabox/attack_hand(mob/living/user)
	if (open && pizza)
		user.put_in_hands(pizza)
		pizza = null
		to_chat(user, SPAN_WARNING("You take \the [pizza] out of \the [src]."))
		update_icon()
		return
	if (length(boxes) > 0)
		if (user.get_inactive_hand() != src)
			..()
			return
		var/obj/item/pizzabox/box = boxes[length(boxes)]
		boxes -= box
		user.put_in_hands(box)
		to_chat(user, SPAN_WARNING("You remove the topmost [src] from your hand."))
		box.update_icon()
		update_icon()
		return
	..()


/obj/item/pizzabox/attack_self(mob/living/user)
	if(length(boxes) > 0)
		return
	open = !open
	if (open && pizza)
		messy_lid = TRUE
	update_icon()


/obj/item/pizzabox/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(istype(item, /obj/item/pizzabox))
		var/obj/item/pizzabox/box = item
		if(!box.open && !open)
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i
			if((length(boxes)+1) + length(boxestoadd) <= 5)
				if(!user.unEquip(box, src))
					FEEDBACK_UNEQUIP_FAILURE(user, box)
					return TRUE
				box.boxes = list()
				boxes.Add(boxestoadd)
				box.update_icon()
				update_icon()
				to_chat(user, SPAN_WARNING("You put \the [box] ontop of \the [src]!"))
			else
				to_chat(user, SPAN_WARNING("The stack is too high!"))
		else
			to_chat(user, SPAN_WARNING("Close \the [box] first!"))
		return TRUE
	var/list/pizza_types = list(
		/obj/item/reagent_containers/food/snacks/sliceable/margherita,
		/obj/item/reagent_containers/food/snacks/sliceable/vegetablepizza,
		/obj/item/reagent_containers/food/snacks/sliceable/mushroompizza,
		/obj/item/reagent_containers/food/snacks/sliceable/meatpizza,
		/obj/item/reagent_containers/food/snacks/sliceable/fruitpizza,
		/obj/item/reagent_containers/food/snacks/sliceable/chocopizza,
		/obj/item/reagent_containers/food/snacks/sliceable/variable/pizza
	)
	if (is_type_in_list(item, pizza_types))
		if (open)
			if (!pizza)
				if(!user.unEquip(item, src))
					FEEDBACK_UNEQUIP_FAILURE(user, item)
					return TRUE
				pizza = item
				update_icon()
				to_chat(user, SPAN_WARNING("You put \the [item] in \the [src]!"))
			else
				to_chat(user, SPAN_WARNING("There is already \a [pizza] in \the [src]!"))
		else
			to_chat(user, SPAN_WARNING("You try to push \the [item] through the lid but it doesn't work!"))
		return TRUE
	if (istype(item, /obj/item/pen))
		if (open)
			USE_FEEDBACK_FAILURE("You need to close \the [src].")
			return TRUE
		var/t = sanitize(input("Enter what you want to add to the tag:", "Write", null, null) as text, 30)
		var/obj/item/pizzabox/boxtotagto = src
		if( length(boxes) > 0 )
			boxtotagto = boxes[length(boxes)]
		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)
		update_icon()
		return TRUE
	return ..()


/obj/item/pizzabox/margherita
	boxtag = "Margherita Deluxe"
	pizza = /obj/item/reagent_containers/food/snacks/sliceable/margherita


/obj/item/pizzabox/vegetable
	boxtag = "Gourmet Vegatable"
	pizza = /obj/item/reagent_containers/food/snacks/sliceable/vegetablepizza


/obj/item/pizzabox/mushroom
	boxtag = "Mushroom Special"
	pizza = /obj/item/reagent_containers/food/snacks/sliceable/mushroompizza


/obj/item/pizzabox/meat
	boxtag = "Meatlover's Supreme"
	pizza = /obj/item/reagent_containers/food/snacks/sliceable/meatpizza


/obj/item/pizzabox/fruit
	boxtag = "Fruit Fanatic"
	pizza = /obj/item/reagent_containers/food/snacks/sliceable/fruitpizza
