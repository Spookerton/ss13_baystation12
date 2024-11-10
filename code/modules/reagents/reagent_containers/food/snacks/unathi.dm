
/obj/item/reagent_containers/food/snacks/chilied_eggs
	name = "chilied eggs"
	desc = "Three deviled eggs floating in a bowl of spiced meat. A popular lunchtime meal on Moghes."
	icon_state = "chilied-eggs"
	trash = /obj/item/trash/snack_bowl
	bitesize = 6
	reagents = list(
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/capsaicin = 2,
		/datum/reagent/nutriment/protein/egg = 3
	)


/obj/item/reagent_containers/food/snacks/hatchling_surprise
	name = "hatchling surprise"
	desc = "A poached egg on top of several fried strips of meat, favoured by Unathi young and old alike. The real surprise is if you can feed it to your hatchling without losing a finger or two."
	icon_state = "hatchling-surprise"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/nutriment/protein/egg = 3
	)


/obj/item/reagent_containers/food/snacks/red_sun_special
	name = "red sun special"
	desc = "A single piece of sausage sitting on melted cheese curds. A cheap dish for Unathi working in human space."
	icon_state = "red-sun-special"
	trash = /obj/item/trash/snack_bowl
	bitesize = 4
	reagents = list(
		/datum/reagent/nutriment/protein = 2
	)


/obj/item/reagent_containers/food/snacks/sea_delight
	name = "\improper Rah'Zakeh delight"
	desc = "Three raw eggs floating in a sea of eye-watering gukhe broth. A mostly-authentic replication of a Yeosa delicacy."
	icon_state = "sea-delight"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment/protein/egg = 5,
		/datum/reagent/capsaicin = 2
	)


/obj/item/reagent_containers/food/snacks/stok_skewers
	name = "stok skewers"
	desc = "Two hearty skewers of seared meat, glazed in a tangy spice. A popular Mumbak street food - despite the name, it can be made with just about any meat."
	icon_state = "stok-skewers"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/capsaicin = 2,
		/datum/reagent/nutriment/vinegar = 3,
	)


/obj/item/reagent_containers/food/snacks/gukhe_fish
	name = "cured gukhe platter"
	desc = "A fish cutlet cured in a bitter gukhe rub, served with a tangy dipping sauce and a garnish of seaweed. A staple of Yeosa'Unathi cooking."
	icon_state = "gukhe-fish"
	bitesize = 5
	trash = /obj/item/trash/usedplatter
	reagents = list(
		/datum/reagent/nutriment/protein = list(8, list("tangy fish", "bitter gukhe")),
		/datum/reagent/capsaicin = 2,
		/datum/reagent/nutriment/vinegar = 3,
		/datum/reagent/sodiumchloride = 3
	)


/obj/item/reagent_containers/food/snacks/aghrassh_cake
	name = "aghrassh cake"
	desc = "A dense, calorie-packed puck of aghrassh paste, spices, and ground meat, usually eaten by desert-going Unathi. This one has an egg cracked over it to make it a bit more palatable."
	icon_state = "aghrassh-cake"
	bitesize = 5
	reagents = list(
		/datum/reagent/nutriment = list(4, list("aghrassh nuts", "mealy paste")),
		/datum/reagent/nutriment/protein = 8,
		/datum/reagent/nutriment/coco = 3,
		/datum/reagent/blackpepper = 3
	)
