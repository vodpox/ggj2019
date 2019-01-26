extends KinematicBody

const WALK_SPEED = 5
const GRAVITY = -10

func _ready():
	pass

func _physics_process(delta):
	var motion = Vector3(0, 0, 0)
	motion += Vector3(0, GRAVITY, 0)
	move_and_slide(motion)
	
	move_and_collide(get_transform().basis.z * delta * WALK_SPEED * -1)
	pass
	
func _process(delta):
	pass