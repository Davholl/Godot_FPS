extends Spatial
	
func enable_gibs():
	for child in get_children():
		if child.has_method("init"):
			child.init();
		if "emitting" in child:
			child.emitting = true;
