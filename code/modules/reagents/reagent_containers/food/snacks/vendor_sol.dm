/obj/item/reagent_containers/food/snacks/luna_cake
	name = "luna cake"
	icon_state = "lunacake_wrapped"
	desc = "Now with 20% less lawsuit enabling rhegolith!"
	trash = /obj/item/trash/cakewrap
	filling_color = "#ffffff"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("cake" = 3)),
		/datum/reagent/sugar = 3,
		/datum/reagent/drink/syrup_vanilla = 1
	)


/obj/item/reagent_containers/food/snacks/mochi_cake
	name = "mochi cake"
	icon_state = "mochicake_wrapped"
	desc = "Konnichiwa! Many go lucky rice cakes in future!"
	trash = /obj/item/trash/mochicakewrap
	filling_color = "#ffffff"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/rice = list(3, list("rice" = 3)),
		/datum/reagent/sugar = 3
	)


/obj/item/reagent_containers/food/snacks/choco_luna_cake
	name = "dark side luna cake"
	icon_state = "mooncake_wrapped"
	desc = "Explore the dark side! May contain trace amounts of reconstituted cocoa."
	trash = /obj/item/trash/mooncakewrap
	filling_color = "#000000"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("cake" = 3)),
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 1,
		/datum/reagent/drink/syrup_chocolate = 1
	)


/obj/item/reagent_containers/food/snacks/tide_gobs
	name = "tide gobs"
	icon_state = "tidegobs"
	desc = "Contains over 9000% of your daily recommended intake of salt."
	trash = /obj/item/trash/tidegobs
	filling_color = "#2556b0"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("salt" = 4, "seagull?" = 1))
	)


/obj/item/reagent_containers/food/snacks/saturnos
	name = "saturn-os"
	icon_state = "saturno"
	desc = "A day ration of salt, styrofoam and possibly sawdust."
	trash = /obj/item/trash/saturno
	filling_color = "#dca319"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(3, list("salt" = 4, "wood?" = 1)),
		/datum/reagent/nutriment/groundpeanuts = 3
	)


/obj/item/reagent_containers/food/snacks/jove_gello
	name = "jove gello"
	icon_state = "jupiter"
	desc = "By Joove! It's some kind of gel."
	trash = /obj/item/trash/jupiter
	filling_color = "#dc1919"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("sweet" = 4, "vanilla?" = 1))
	)


/obj/item/reagent_containers/food/snacks/pluto_rods
	name = "plutonian rods"
	icon_state = "pluto"
	desc = "Baseless tasteless nutrithick rods to get you through the day. Now even less rash inducing!"
	trash = /obj/item/trash/pluto
	filling_color = "#ffffff"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("chalk" = 4, "sad?" = 1))
	)


/obj/item/reagent_containers/food/snacks/frouka
	name = "frouka"
	icon_state = "mars"
	desc = "Celebrate founding day with a steaming self-heated bowl of sweet eggs and taters!"
	trash = /obj/item/trash/mars
	filling_color = "#d2c63f"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("potato" = 4, "mustard" = 2)),
		/datum/reagent/nutriment/protein = list(3, list("eggs" = 4))
	)


/obj/item/reagent_containers/food/snacks/venus_cakes
	name = "venusian hot cakes"
	icon_state = "venus"
	desc = "Hot takes on hot cakes, a timeless classic now finally fit for human consumption!"
	trash = /obj/item/trash/venus
	filling_color = "#d2c63f"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("heat" = 4, "burning!" = 1)),
		/datum/reagent/capsaicin = 5
	)


/obj/item/reagent_containers/food/snacks/oort_rocks
	name = "oort cloud rocks"
	icon_state = "oort"
	desc = "Pop rocks themed on the outer reaches of Sol, new formula guarantees fewer shrapnel induced oral injury."
	trash = /obj/item/trash/oort
	filling_color = "#3f7dd2"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("fizz" = 4, "sweet?" = 1)),
		/datum/reagent/frostoil = 5
	)
