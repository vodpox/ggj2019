extends AudioStreamPlayer3D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	print("2")
	connect("finished", get_node("../../Player"), "stop_gunshot")
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Gunshot_finished():
	stop()
	print("aaa")
