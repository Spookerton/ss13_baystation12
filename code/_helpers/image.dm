/proc/image_flags(icon, loc, icon_state, layer, dir, flags)
	var/image/image = image(icon, loc, icon_state, layer, dir)
	image.appearance_flags = flags
	return image
