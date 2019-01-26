extends KinematicBody

var walk_speed = 10
var magazine_size = 5
var magazine = magazine_size
var bullet_cooldown = false

var camera
var bullet_scene

func _ready():
	camera = get_node("../Camera")
	bullet_scene = load("res://Scenes/bullet.tscn")

func _physics_process(delta):
	
	# movement
	
	var dir = Vector3()
	
	if (Input.is_action_pressed("ui_up")):
		dir -= Vector3(0, 0, 1)
	if (Input.is_action_pressed("ui_down")):
		dir += Vector3(0, 0, 1)
	if (Input.is_action_pressed("ui_left")):
		dir -= Vector3(1, 0, 0)
	if (Input.is_action_pressed("ui_right")):
		dir += Vector3(1, 0, 0)
	
	dir = dir.normalized() * delta * walk_speed
	
	move_and_collide(dir)
	
	
	# looking
	
	var mouse = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse)
	var to = from + camera.project_ray_normal(mouse) * 1000
	
	var space_state = get_world().direct_space_state
	var ray = space_state.intersect_ray(from, to)
	
	if (ray.has("position")):
		var look = ray["position"]
		look.y = get_translation().y
		look_at(look, Vector3(0, 1, 0))


func _process(delta):
	
	if (Input.is_action_pressed("ui_accept") && magazine > 0 && !bullet_cooldown):
		
		var bullet = bullet_scene.instance()
		bullet.global_translate(get_translation())
		bullet.rotate(Vector3(0, 1, 0), get_rotation().y)
		get_node("..").call_deferred("add_child", bullet)
		
		bullet_cooldown = true
		$BulletCooldown.start()
		magazine -= 1
		if (magazine == 0):
			$ReloadTimer.start()
	
	


func _on_BulletCooldown_timeout():
	bullet_cooldown = false


func _on_ReloadTimer_timeout():
	magazine = magazine_size
