extends KinematicBody

var walk_speed = 10
var magazine_size = 5
var magazine = magazine_size
var bullet_cooldown = false

var in_home = false
var home_in_range = false

var camera
var bullet_scene

func _ready():
	camera = get_node("../Camera")
	#camera = $Camera
	bullet_scene = load("res://Scenes/bullet.tscn")

func _physics_process(delta):
	
	# movement
	
	var dir = Vector3()
	
	if (!in_home):
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
	
	if (Input.is_action_pressed("ui_accept") && magazine > 0 && !bullet_cooldown && !in_home):
		
		var bullet = bullet_scene.instance()
		bullet.global_translate(get_translation())
		bullet.rotate(Vector3(0, 1, 0), get_rotation().y)
		get_node("..").call_deferred("add_child", bullet)
		
		bullet_cooldown = true
		$BulletCooldown.start()
		magazine -= 1
		if (magazine == 0):
			$ReloadTimer.start()
	
	if (Input.is_action_just_pressed("ui_select") && home_in_range):
		in_home = !in_home
		visible = !visible
		$CollisionShape.disabled = !$CollisionShape.disabled


func _on_BulletCooldown_timeout():
	bullet_cooldown = false


func _on_ReloadTimer_timeout():
	magazine = magazine_size


func _on_HomeRange_area_entered(area):
	# todo check if this is home?
	home_in_range = true


func _on_HomeRange_area_exited(area):
	# todo check if this is home?
	home_in_range = false
