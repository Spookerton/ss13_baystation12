/datum/map
	var/list/branch_types                         // list of branch datum paths for military branches available on this map
	var/list/spawn_branch_types                   // subset of above for branches a player can spawn in with

	var/list/species_to_branch_whitelist = list() // List of branches which are allowed, per species. Checked before the blacklist.
	var/list/species_to_branch_blacklist = list() // List of branches which are restricted, per species.

	var/list/species_to_rank_whitelist = list()   // List of ranks which are allowed, per branch and species. Checked before the blacklist.
	var/list/species_to_rank_blacklist = list()   // Lists of ranks which are restricted, per species.

// The white, and blacklist are type specific, any subtypes (of both species and jobs) have to be added explicitly
/datum/map/proc/is_species_branch_restricted(singleton/species/S, datum/mil_branch/MB)
	if(!istype(S) || !istype(MB))
		return TRUE

	var/list/whitelist = species_to_branch_whitelist[S.type]
	if(MB.type in whitelist)
		return FALSE

	var/list/blacklist = species_to_branch_blacklist[S.type]
	if(blacklist)
		return (MB.type in blacklist)

	return whitelist // not in the whitelist, no blacklist = bad, no whitelist or blacklist = fine

/datum/map/proc/is_species_rank_restricted(singleton/species/S, datum/mil_branch/MB, datum/mil_rank/MR)
	if(!istype(S) || !istype(MB) || !istype(MR))
		return TRUE

	var/list/whitelist_by_branch = species_to_rank_whitelist[S.type]
	var/list/whitelist
	if(whitelist_by_branch)
		whitelist = whitelist_by_branch[MB.type]
		if(MR.type in whitelist)
			return FALSE

	var/list/blacklist_by_branch = species_to_rank_blacklist[S.type]
	if(blacklist_by_branch)
		var/list/blacklist = blacklist_by_branch[MB.type]
		if(blacklist)
			return MR.type in blacklist

	return whitelist
