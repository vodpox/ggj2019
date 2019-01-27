extends KinematicBody

var health = 3

func _ready():
	pass

func _process(delta):
	var collision = move_and_collide(Vector3(0, 0, 0))
	if (collision != null):
		if (collision.collider.has_method("get_damage")):
			health -= 1
			collision.collider.get_damage(1)
		if health <= 0:
			get_parent().remove_child(self)