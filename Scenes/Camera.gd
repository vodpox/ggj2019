extends Camera

var player

func _ready():
	player = get_node("../Player")
	pass

func _process(delta):
	translation = player.translation + Vector3(0, 10, 10)
	pass