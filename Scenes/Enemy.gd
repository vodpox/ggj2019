extends KinematicBody

const WALK_SPEED = 2
const GRAVITY = -10

var health = 2

var player
var home

func get_damage(var amount):
	health -= amount
	if (health <= 0):
		get_parent().remove_child(self)

func _ready():
	player = get_node("../Player")
	home = get_node("../Home")

func _physics_process(delta):
	#var motion = Vector3(0, 0, 0)
	#motion += Vector3(0, GRAVITY, 0)
	#move_and_slide(motion)
	
	move_and_collide(get_transform().basis.z * delta * WALK_SPEED * -1)
	pass
	
func _process(delta):
	pass

func _on_AttackArea_body_entered(body):
	if (body.has_method("get_damage")):
		body.get_damage(1)
