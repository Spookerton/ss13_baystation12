/obj/item/reagent_containers/food/snacks/old
	abstract_type = /obj/item/reagent_containers/food/snacks/old
	center_of_mass = "x=15;y=12"
	bitesize = 3
	filling_color = "#336b42"
	reagents = list(
		/datum/reagent/nutriment = list(10, list("rot" = 5, "mold" = 5))
	)


/obj/item/reagent_containers/food/snacks/old/Initialize()
	var/reagent = pick(list(
		/datum/reagent/fuel,
		/datum/reagent/toxin/amatoxin,
		/datum/reagent/toxin/carpotoxin,
		/datum/reagent/toxin/zombiepowder,
		/datum/reagent/drugs/cryptobiolin,
		/datum/reagent/drugs/psilocybin
	))
	reagents[reagent] = 5
	return ..()


/obj/item/reagent_containers/food/snacks/old/pizza
	name = "pizza"
	desc = "It's so stale you could probably cut something with the cheese."
	icon_state = "ancient_pizza"


/obj/item/reagent_containers/food/snacks/old/burger
	name = "giga burger"
	desc = "At some point in time this probably looked delicious."
	icon_state = "ancient_burger"


/obj/item/reagent_containers/food/snacks/old/hamburger
	name = "horse burger"
	desc = "Even if you were hungry enough to eat a horse, it'd be a bad idea to eat this."
	icon_state = "ancient_hburger"


/obj/item/reagent_containers/food/snacks/old/fries
	name = "space fries"
	desc = "The salt appears to have preserved these, still stale and gross."
	icon_state = "ancient_fries"


/obj/item/reagent_containers/food/snacks/old/hotdog
	name = "space dog"
	desc = "This one is probably only marginally less safe to eat than when it was first created.."
	icon_state = "ancient_hotdog"


/obj/item/reagent_containers/food/snacks/old/taco
	name = "taco"
	desc = "Interestingly, the shell has gone soft and the contents have gone stale."
	icon_state = "ancient_taco"
