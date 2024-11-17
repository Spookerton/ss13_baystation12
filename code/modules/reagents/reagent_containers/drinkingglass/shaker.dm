
/obj/item/reagent_containers/food/drinks/glass2/fitnessflask
	name = "fitness shaker"
	base_name = "shaker"
	desc = "Big enough to contain enough protein to get perfectly swole. Don't mind the bits."
	icon_state = null
	base_icon = "fitness-cup"
	icon = 'icons/obj/food/drink_glasses/fitness.dmi'
	reagent_container_flags = REAGENT_CONTAINER_INIT_UPDATE_ICON
	reagents_volume = 100
	matter = list(MATERIAL_PLASTIC = 2000)
	filling_states = "10;20;30;40;50;60;70;80;90;100"
	possible_transfer_amounts = "5;10;15;25"
	rim_pos = null


/obj/item/reagent_containers/food/drinks/glass2/fitnessflask/on_update_icon()
	if (!icon_state)
		icon_state = "[base_icon]_[pick("black", "red", "blue")]"
	..()


/obj/item/reagent_containers/food/drinks/glass2/fitnessflask/proteinshake
	name = "protein shake"
	reagents = list(
		/datum/reagent/nutriment = 30,
		/datum/reagent/iron = 10,
		/datum/reagent/nutriment/protein = 15,
		/datum/reagent/water = 45
	)
