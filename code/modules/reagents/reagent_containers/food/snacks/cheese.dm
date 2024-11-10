/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	abstract_type = /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	bitesize = 10
	center_of_mass = "x=16;y=10"


/obj/item/reagent_containers/food/snacks/cheesewedge
	abstract_type = /obj/item/reagent_containers/food/snacks/cheesewedge
	bitesize = 2
	center_of_mass = "x=16;y=10"


/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel/fresh
	name = "fresh cheese wheel"
	desc = "A wheel of soft, fresh cheese."
	icon_state = "cheesewheel-fresh"
	filling_color = "#fffddd"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/fresh
	reagents = list(
		/datum/reagent/nutriment = list(10, list("mild cheese" = 10)),
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/cheesewedge/fresh
	name = "fresh cheese wedge"
	desc = "A wedge of soft, fresh cheese."
	icon_state = "cheesewedge-fresh"
	filling_color = "#fffddd"
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("mild cheese" = 10 / 5)),
		/datum/reagent/nutriment/protein = 10 / 5
	)


/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel/aged
	name = "aged cheese wheel"
	desc = "A wheel of firm, sharp cheese."
	icon_state = "cheesewheel"
	filling_color = "#fff700"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/aged
	scent_extension = /datum/extension/scent/cheese_aged
	reagents = list(
		/datum/reagent/nutriment = list(10, list("sharp cheese" = 10)),
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/cheesewedge/aged
	name = "aged cheese wedge"
	desc = "A wedge of firm, sharp cheese."
	icon_state = "cheesewedge"
	filling_color = "#fff700"
	scent_extension = /datum/extension/scent/cheese_aged
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("sharp cheese" = 10 / 5)),
		/datum/reagent/nutriment/protein = 10 / 5
	)


/datum/extension/scent/cheese_aged
	scent = "sharp cheese"
	intensity = /singleton/scent_intensity
	descriptor = SCENT_DESC_ODOR
	range = 2


/datum/microwave_recipe/cheesewheel_aged
	required_reagents = list(
		/datum/reagent/enzyme = 5,
		/datum/reagent/sodiumchloride = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel/aged


/datum/microwave_recipe/cheesewedge_aged
	required_reagents = list(
		/datum/reagent/enzyme = 1,
		/datum/reagent/sodiumchloride = 2
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result_path = /obj/item/reagent_containers/food/snacks/cheesewedge/aged


/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel/blue
	name = "blue cheese wheel"
	desc = "A wheel of intense blue cheese."
	icon_state = "cheesewheel-blue"
	filling_color = "#9eee86"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/blue
	scent_extension = /datum/extension/scent/cheese_blue
	reagents = list(
		/datum/reagent/nutriment = list(10, list("funky cheese" = 10)),
		/datum/reagent/nutriment/protein = 10
	)


/obj/item/reagent_containers/food/snacks/cheesewedge/blue
	name = "blue cheese wedge"
	desc = "A wedge of intense blue cheese."
	icon_state = "cheesewedge-blue"
	filling_color = "#9eee86"
	scent_extension = /datum/extension/scent/cheese_blue
	reagents = list(
		/datum/reagent/nutriment = list(10 / 5, list("funky cheese" = 10 / 5)),
		/datum/reagent/nutriment/protein = 10 / 5
	)


/datum/extension/scent/cheese_blue
	scent = "funky cheese"
	intensity = /singleton/scent_intensity/strong
	descriptor = SCENT_DESC_ODOR
	range = 3


/datum/microwave_recipe/cheesewheel_blue
	required_reagents = list(
		/datum/reagent/enzyme = 5,
		/datum/reagent/sodiumchloride = 5,
		/datum/reagent/drink/kefir = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel/blue


/datum/microwave_recipe/cheesewedge_blue
	required_reagents = list(
		/datum/reagent/enzyme = 1,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/drink/kefir = 1
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result_path = /obj/item/reagent_containers/food/snacks/cheesewedge/blue
