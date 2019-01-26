extends Spatial

func _ready():
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE) && !get_tree().is_paused():
		get_tree().paused = true
		$pause_gui.show()
	pass

func _on_resume_pressed(screen):
	get_tree().paused = false
	$pause_gui.hide()
	pass

func _on_restart_pressed(screen):
	get_tree().change_scene("res://Scenes/test.tscn")
	pass

func _on_main_menu_pressed(screen):
	get_tree().reload_current_scene()
	#get_tree().change_scene("res://TitleScreen/TitleScreen.tscn")
	pass