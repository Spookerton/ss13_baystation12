// PreventInteraction check flags.

/// This interaction test expects to have a subject atom. Also gates other subject tests, including distance.
var/const/INTERACTION_FLAG_HAS_SUBJECT = FLAG(0)

/// This interaction test expects its user (and subject if specified) to not have a null loc.
var/const/INTERACTION_FLAG_VALID_LOCS = FLAG(1)

/// This interaction test expects the user mob to be <user_type> or a subtype.
var/const/INTERACTION_FLAG_USER_TYPE = FLAG(2)

/// This interaction test expects the user to not be incapacitated according to <incapacitation_flags>.
var/const/INTERACTION_FLAG_INCAPACITATED = FLAG(3)

/// This interaction test expects the user and subject to share a parent atom.
var/const/INTERACTION_FLAG_SAME_LOC = FLAG(4)

/// This interaction test expects the user to be on the same z-level as the subject.
var/const/INTERACTION_FLAG_SAME_LEVEL = FLAG(5)

/// This interaction test expects the user to be within <range> distance of the subject, or Adjacent if < 2.
var/const/INTERACTION_FLAG_CHECK_RANGE = FLAG(6)

/// The set of INTERACTION_FLAG_* for common user-only interaction permission checks.
var/const/INTERACTION_MASK_USER_ONLY = INTERACTION_FLAG_VALID_LOCS | INTERACTION_FLAG_USER_TYPE | INTERACTION_FLAG_INCAPACITATED

/// The set of INTERACTION_FLAG_* for common user-subject interaction permission checks.
var/const/INTERACTION_MASK_DEFAULT = INTERACTION_MASK_USER_ONLY | INTERACTION_FLAG_HAS_SUBJECT | INTERACTION_FLAG_CHECK_RANGE


/*
* The test logic behind PreventInteraction. Is silent.
* Returns false or an INTERACTION_FLAG_* if continuing interaction should be prevented.
* user - The user that is interacting.
* subject - The atom the user is interacting with, if relevant.
* interaction_flags - Some combination of INTERACTION_FLAG_*. See INTERACTION_MASK_DEFAULT.
* user_type - If checking the user's mob type, the path to validate against.
* incapacitation_flags - If checking whether the user is incapacitated, the INCAPACITATION_* combination to check against.
* range - If checking range, the maximum allowed range. If less than 2, checks adjacency; otherwise consider also using INTERACTION_FLAG_SAME_LEVEL.
*/
/proc/PreventInteractionDetailed(mob/user, atom/subject, interaction_flags = INTERACTION_MASK_DEFAULT, user_type = /mob/living, incapacitation_flags = INCAPACITATION_DEFAULT, range = 1)
	if (QDELETED(user))
		return INTERACTION_FAIL_USER_DELETED
	if (interaction_flags & INTERACTION_FLAG_VALID_LOCS)
		if (!user.loc)
			return INTERACTION_FLAG_VALID_LOCS
	if (interaction_flags & INTERACTION_FLAG_HAS_SUBJECT)
		if (QDELETED(subject))
			return INTERACTION_FLAG_HAS_SUBJECT
		if (interaction_flags & INTERACTION_FLAG_VALID_LOCS)
			if (!subject.loc)
				return INTERACTION_FLAG_VALID_LOCS
	if (interaction_flags & INTERACTION_FLAG_USER_TYPE)
		if (!istype(user, user_type))
			return INTERACTION_FLAG_USER_TYPE
	if (interaction_flags & INTERACTION_FLAG_USER_INCAPACITATED)
		if (user.incapacitated(incapacitation_flags))
			return INTERACTION_FLAG_USER_INCAPACITATED
	if (interaction_flags & INTERACTION_FLAG_HAS_SUBJECT)
		if (interaction_flags & INTERACTION_FLAG_SAME_LOC)
			if (user.loc != subject.loc)
				return INTERACTION_FLAG_SAME_LOC
		else
			if (interaction_flags & INTERACTION_FLAG_SAME_Z)
				if (get_turf(user).z != get_turf(subject).z)
					return INTERACTION_FLAG_SAME_Z
			if (interaction_flags & INTERACTION_FLAG_CHECK_RANGE)
				if (range < 2)
					if (!subject.Adjacent(user))
						return INTERACTION_FLAG_CHECK_RANGE
				else if (get_dist(user, subject) > range)
					return INTERACTION_FLAG_CHECK_RANGE
	return FALSE


/// Check whether the current user interaction should be prevented, providing a stock message if so. See /proc/PreventInteractionDetailed.
/proc/PreventInteraction(mob/user, atom/subject, interaction_flags = INTERACTION_MASK_DEFAULT, user_type = /mob/living, incapacitation_flags = INCAPACITATION_DEFAULT, range = 1)
	var/outcome = PreventInteractionDetailed(user, subject, interaction_flags, user_type, incapacitation_flags)
	switch (outcome)
		if (INTERACTION_FLAG_HAS_SUBJECT, INTERACTION_FLAG_VALID_LOCS, INTERACTION_FLAG_SAME_LEVEL)
			to_chat(user, SPAN_WARNING("[subject ? "\The [subject]" : "That"] is gone."))
		if (INTERACTION_FLAG_USER_TYPE)
			to_chat(user, SPAN_WARNING("You don't have the right body to [subject ? "use \the [subject]" : "do that"]."))
		if (INTERACTION_FLAG_USER_INCAPACITATED)
			to_chat(user, SPAN_WARNING("You're in no condition to [subject ? "use \the [subject]" : "do that"]."))
		if (INTERACTION_FLAG_SAME_LOC, INTERACTION_FLAG_CHECK_RANGE)
			to_chat(user, SPAN_WARNING("You're too far away to [subject ? "use \the [subject]" : "do that"]."))
	return !!outcome
