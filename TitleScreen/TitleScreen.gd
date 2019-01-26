extends Control

func _ready():
	pass

func _on_StartGame_pressed(screen):
	get_tree().change_scene("res://Scenes/test.tscn")
	pass 

func _on_Exit_pressed(screen):
	get_tree().quit()
	pass
