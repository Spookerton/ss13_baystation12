/obj/item/reagent_containers/food/snacks/ricecake
	name = "rice cake"
	icon_state = "ricecake"
	desc = "Ancient earth snack food made from balled up rice."
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(4, list("rice" = 4, "sweet?" = 1)),
		/datum/reagent/sugar = 1
	)


/obj/item/reagent_containers/food/snacks/pokey
	name = "pokeys"
	icon_state = "pokeys"
	desc = "A bundle of chocolate coated bisquit sticks."
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("chocolate" = 4, "bisquit" = 1))
	)


/obj/item/reagent_containers/food/snacks/weebonuts
	name = "red alert nuts"
	icon_state = "weebonuts"
	trash = /obj/item/trash/weebonuts
	desc = "A bag of Red Alert! brand spicy nuts. Goes well with your beer!"
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(2, list("spicy!" = 1)),
		/datum/reagent/nutriment/groundpeanuts = 4,
		/datum/reagent/capsaicin = 1
	)


/obj/item/reagent_containers/food/snacks/chocobanana
	name = "choco banang"
	icon_state = "chocobanana"
	trash = /obj/item/trash/stick
	desc = "A chocolate and sprinkles coated banana. On a stick."
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("chocolate" = 4, "wax?" = 1)),
		/datum/reagent/nutriment/sprinkles = 10
	)


/obj/item/reagent_containers/food/snacks/dango
	name = "dango"
	icon_state = "dango"
	trash = /obj/item/trash/stick
	desc = "Food dyed rice dumplings on a stick."
	bitesize = 2
	reagents = list(
		/datum/reagent/nutriment = list(5, list("rice" = 4, "topping?" = 1))
	)
