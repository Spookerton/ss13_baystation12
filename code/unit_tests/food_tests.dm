/**
 *  Each slice origin items should cut into the same slice.
 *
 *  Each slice type defines an item from which it originates. Each sliceable
 *  item defines what item it cuts into. This test checks if the two defnitions
 *  are consistent between the two items.
 */
/datum/unit_test/food_slices_and_origin_items_should_be_consistent
	name = "FOOD: Each slice origin item should cut into the appropriate slice"

/datum/unit_test/food_slices_and_origin_items_should_be_consistent/start_test()
	var/any_failed = FALSE

	var/obj/item/reagent_containers/food/snacks/sliceable/sliceable
	for (sliceable as anything in subtypesof(/obj/item/reagent_containers/food/snacks/sliceable))
		if (is_abstract(sliceable))
			continue
		if (ispath(initial(sliceable.slice_path)))
			continue
		log_bad("[sliceable] does not define slice_path.")
		any_failed = TRUE

	if(any_failed)
		fail("Some slice types were incorrectly defined.")
	else
		pass("All slice types defined correctly.")

	return TRUE
