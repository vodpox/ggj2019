extends KinematicBody

var bullet_speed = 50

func _ready():
	pass

func _process(delta):
	var collision = move_and_collide(get_transform().basis.z * delta * bullet_speed * -1)
	if (collision != null):
		if (collision.collider.has_method("get_damage")):
			collision.collider.get_damage(1)
		get_parent().remove_child(self)