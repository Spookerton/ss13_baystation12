/obj/item/reagent_containers/food/snacks/pistachios
	name = "pistachios"
	icon_state = "pistachios"
	desc = "Pistachios. There is absolutely nothing remarkable about these."
	trash = /obj/item/trash/pistachios
	filling_color = "#825d26"
	center_of_mass = "x=15;y=9"
	bitesize = 0.5
	reagents = list(
		/datum/reagent/nutriment/almondmeal = 3
	)


/obj/item/reagent_containers/food/snacks/semki
	name = "semki"
	icon_state = "semki"
	desc = "Sunflower seeds. A favorite among both birds and gopniks."
	trash = /obj/item/trash/semki
	filling_color = "#68645d"
	center_of_mass = "x=15;y=9"
	bitesize = 0.5
	reagents = list(
		/datum/reagent/nutriment = list(6, list("sunflower seeds" = 1))
	)


/obj/item/reagent_containers/food/snacks/squid
	name = "calamari crisps"
	icon_state = "squid"
	desc = "Space squid tentacles, Carefully removed (from the squid) then dried into strips of delicious rubbery goodness!"
	trash = /obj/item/trash/squid
	filling_color = "#c0a9d7"
	center_of_mass = "x=15;y=9"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(2, list("fish" = 1, "salt" = 1)),
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/croutons
	name = "suhariki"
	icon_state = "croutons"
	desc = "Fried bread cubes."
	trash = /obj/item/trash/croutons
	filling_color = "#c6b17f"
	center_of_mass = "x=15;y=9"

	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(3, list("bread" = 1, "salt" = 1))
	)


/obj/item/reagent_containers/food/snacks/salo
	name = "salo"
	icon_state = "salo"
	desc = "Pig fat. Salted. Just as good as it sounds."
	trash = /obj/item/trash/salo
	filling_color = "#e0bcbc"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("fat" = 1, "salt" = 1)),
		/datum/reagent/nutriment/protein = 6
	)


/obj/item/reagent_containers/food/snacks/driedfish
	name = "vobla"
	icon_state = "driedfish"
	desc = "Dried salted beer snack fish."
	trash = /obj/item/trash/driedfish
	filling_color = "#c8a5bb"
	center_of_mass = "x=15;y=9"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(2, list("fish" = 1, "salt" = 1)),
		/datum/reagent/nutriment/protein = 4
	)
