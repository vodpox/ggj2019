extends KinematicBody

const gravity = 5;
var walk_speed = 10
var magazine_size = 5
var magazine = magazine_size
var bullet_cooldown = false
var health = 1
var score = 0
var max_bullets = 99
var bullets = max_bullets
var reloading = false
var in_home = false
var home_in_range = false

var camera
var bullet_scene

var home
var score_ui
var health_ui
var ammo_ui
var home_ui

var gunshot_player
var reload_player

func get_damage(var amount):
	health -= amount
	if (health <= 0):
		get_parent().remove_child(self)

func _ready():
	move_and_collide(Vector3(0, -100, 0)) # to ground
	camera = get_node("../Camera")
	#camera = $Camera
	bullet_scene = load("res://Scenes/bullet.tscn")
	
	home = get_node("../Home")
	
	score_ui = get_node("../gui/score")
	health_ui = get_node("../gui/health")
	ammo_ui = get_node("../gui/ammo")
	home_ui = get_node("../gui/press_home")
	
	gunshot_player = get_node("../Camera/Gunshot")
	reload_player = get_node("../Camera/Reload")

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
	
	dir -= Vector3(0, gravity, 0)
	move_and_slide(dir)
	
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
	
	score_ui.text = str(score)
	health_ui.text = str(home.health)
	if (bullets + magazine == 0):
		ammo_ui.text = "OUT OF AMMO!"
	elif (reloading):
		ammo_ui.text = "(Reloading) " + str(magazine) + "/" + str(bullets)
	else:
		ammo_ui.text = str(magazine) + "/" + str(bullets)
	if (home_in_range):
		if (in_home):
			home_ui.text = "Press SPACE to exit the house"
		else:
			home_ui.text = "Press SPACE to enter the house"
	else:
		home_ui.text = ""
	
	if (Input.is_action_pressed("ui_accept") && magazine > 0 && !bullet_cooldown && !in_home && !reloading):
		
		var bullet = bullet_scene.instance()
		bullet.global_translate(get_translation())
		bullet.rotate(Vector3(0, 1, 0), get_rotation().y)
		get_node("..").call_deferred("add_child", bullet)
		
		bullet_cooldown = true
		$BulletCooldown.start()
		magazine -= 1
		
		gunshot_player.play()
		
		if (magazine == 0):
			reloading = true
			$ReloadTimer.start()
			reload_player.play()
			
	
	if (Input.is_action_pressed("reload")):
		reloading = true
		$ReloadTimer.start()
		reload_player.play()
	
	if (Input.is_action_just_pressed("ui_select") && home_in_range):
		in_home = !in_home
		visible = !visible
		$CollisionShape.disabled = !$CollisionShape.disabled
		if (in_home):
			$GetBulletTimer.start()


func _on_BulletCooldown_timeout():
	bullet_cooldown = false
	gunshot_player.stop()


func _on_ReloadTimer_timeout():
	
	reloading = false
	
	var remaining = magazine_size - magazine
	
	if (bullets >= remaining):
		magazine += remaining
		bullets -= remaining
	else:
		magazine = bullets
		bullets = 0
	


func _on_HomeRange_area_entered(area):
	if (area.get_parent() == home):
		home_in_range = true


func _on_HomeRange_area_exited(area):
	if (area.get_parent() == home):
		home_in_range = false

func stop_gunshot():
	gunshot_player.stop()
	print("hi")


func _on_GetBulletTimer_timeout():
	
	if (in_home && bullets < max_bullets):
		bullets += 1
		$GetBulletTimer.start()
