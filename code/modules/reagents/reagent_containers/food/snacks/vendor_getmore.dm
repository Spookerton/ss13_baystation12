/obj/item/reagent_containers/food/snacks/sosjerky
	name = "beef jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment/protein = 4
	)


/obj/item/reagent_containers/food/snacks/no_raisin
	name = "raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#343834"
	center_of_mass = "x=15;y=4"
	reagents = list(
		/datum/reagent/nutriment = list(4, list("raisins" = 4))
	)


/obj/item/reagent_containers/food/snacks/spacetwinkie
	name = "space eclair"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#ffe591"
	center_of_mass = "x=15;y=11"
	bitesize = 2
	reagents = list(
		/datum/reagent/sugar = 4
	)


/obj/item/reagent_containers/food/snacks/cheesiehonkers
	name = "cheesie honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#ffa305"
	center_of_mass = "x=15;y=9"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("cheese" = 5, "chips" = 2))
	)


/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#e8c31e"
	center_of_mass = "x=15;y=15"
	bitesize = 1
	reagents = list(
		/datum/reagent/nutriment = list(3, list("salt" = 1, "chips" = 2))
	)


/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "cookie"
	filling_color = "#dbc94f"
	center_of_mass = "x=17;y=18"
	w_class = ITEM_SIZE_TINY
	reagents_volume = 10
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("sweetness" = 3, "cookie" = 2))
	)


/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7d5f46"
	center_of_mass = "x=15;y=15"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("chocolate" = 5)),
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 2
	)


/obj/item/reagent_containers/food/snacks/tastybread
	name = "bread tube"
	desc = "Bread in a tube. Chewy... and surprisingly tasty."
	icon_state = "tastybread"
	trash = /obj/item/trash/tastybread
	filling_color = "#a66829"
	center_of_mass = "x=17;y=16"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(6, list("bread" = 3, "sweetness" = 3))
	)


/obj/item/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat, love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7d5f46"
	center_of_mass = "x=15;y=15"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(1, list("candy" = 1)),
		/datum/reagent/sugar = 3
	)
