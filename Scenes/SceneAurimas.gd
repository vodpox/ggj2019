extends Spatial

func _ready():
	pass

func create_zombie():
	var zombie = load("res://Scenes/Enemy.tscn")
	var instance = zombie.instance()
	self.add_child(instance)
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE):
		create_zombie()
	pass