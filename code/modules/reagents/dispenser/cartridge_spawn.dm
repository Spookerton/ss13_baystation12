/client/proc/spawn_chemdisp_cartridge(size in list("small", "medium", "large"))
	set name = "Spawn Chemical Dispenser Cartridge"
	set category = "Admin"
	var/datum/reagent/reagent
	reagent = select_subpath(/datum/reagent, /datum/reagent)
	if (!reagent)
		return
	var/obj/item/reagent_containers/chem_disp_cartridge/cartridge
	switch (size)
		if ("small")
			cartridge = new /obj/item/reagent_containers/chem_disp_cartridge/small (usr.loc)
		if ("medium")
			cartridge = new /obj/item/reagent_containers/chem_disp_cartridge/medium (usr.loc)
		if ("large")
			cartridge = new /obj/item/reagent_containers/chem_disp_cartridge (usr.loc)
	cartridge.reagents.add_reagent(reagent, cartridge.volume)
	cartridge.AddLabel(initial(reagent.name))
	log_and_message_admins("spawned a [size] reagent container containing [reagent]")
