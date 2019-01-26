extends KinematicBody

var bullet_speed = 15

func _ready():
	pass

func _process(delta):
	move_and_collide(get_transform().basis.z * delta * bullet_speed * -1)