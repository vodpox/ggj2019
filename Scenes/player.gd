extends KinematicBody

var walk_speed = 10
var magazine_size = 5
var magazine = magazine_size
var bullet_cooldown = false
var health = 1
var money = 0
var max_bullets = 99
var spikes_count = 5
var bullets = max_bullets
var reloading = false
var in_home = false
var home_in_range = false

const M4A4 = "m4a4"
const SPIKES = "spikes"
const weapons = [M4A4, SPIKES]
var selected_weapon = M4A4

var camera
var bullet_scene
var spikes_scene

var home
var money_ui
var health_ui
var ammo_ui
var home_ui
var weapon_ui

var gunshot_player
var reload_player

func get_damage(var amount):
	health -= amount
	if (health <= 0):
		var node = get_parent()
		node.remove_child(self)
		if node.has_node(NodePath("death_gui")):
			var death_node = node.get_node("death_gui")
			node.get_tree().paused = true
			death_node.show()

func _ready():
	move_and_collide(Vector3(0, -100, 0)) # to ground
	camera = get_node("../Camera")
	#camera = $Camera
	bullet_scene = load("res://Scenes/bullet.tscn")
	spikes_scene = load("res://Scenes/spikes.tscn")
	
	home = get_node("../Home")
	
	money_ui = get_node("../gui/score")
	health_ui = get_node("../gui/health")
	ammo_ui = get_node("../gui/ammo")
	home_ui = get_node("../gui/press_home")
	weapon_ui = get_node("../gui/weapon")
	
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
	change_gui()
	
	if Input.is_action_just_pressed("ui_accept") && selected_weapon == SPIKES && spikes_count > 0:
		var spikes = spikes_scene.instance()
		spikes.global_translate(get_translation())
		spikes.rotate(Vector3(0, 1, 0), get_rotation().y)
		get_node("..").call_deferred("add_child", spikes)
		spikes.translate(Vector3(0, 0, -6))
		spikes_count -= 1
	
	if (Input.is_action_pressed("ui_accept") && magazine > 0 && !bullet_cooldown && !in_home && !reloading) && selected_weapon == M4A4:
		
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
			
	
	if (Input.is_action_pressed("reload")) && selected_weapon == M4A4:
		reloading = true
		$ReloadTimer.start()
		reload_player.play()
	
	if (Input.is_action_just_pressed("ui_select") && home_in_range):
		in_home = !in_home
		visible = !visible
		$CollisionShape.disabled = !$CollisionShape.disabled
		if (in_home):
			$GetBulletTimer.start()

		var node = get_parent()
		if node.has_node(NodePath("shop_gui")):
			var shop_node = node.get_node("shop_gui")
			if $CollisionShape.disabled:
				shop_node.show()
			else:
				shop_node.hide()

func _input(event):
	var selected = false;
	if event is InputEventMouseButton && !selected && event.is_pressed():
		selected = true
		if event.button_index == BUTTON_WHEEL_UP:
			wheel_up()
		if event.button_index == BUTTON_WHEEL_DOWN:
			wheel_down()
		selected = false
	pass

func wheel_up():
	var index = 0
	for i in range(weapons.size()):
		if weapons[i] == selected_weapon && i != (weapons.size()-1):
			index = i+1
	selected_weapon = weapons[index]
	print(selected_weapon)
	return;

func wheel_down():
	var index = weapons.size()-1
	for i in range(weapons.size()):
		if weapons[i] == selected_weapon && i != 0:
			index = i-1
	selected_weapon = weapons[index]
	print(selected_weapon)
	return;

func change_gui():
	money_ui.text = str(money)
	money_ui.text = str(money) + "$"
	health_ui.text = str(home.health)
	
	if (home_in_range):
		if (in_home):
			home_ui.text = "Press SPACE to exit the house"
		else:
			home_ui.text = "Press SPACE to enter the house"
	else:
		home_ui.text = ""
	if selected_weapon == M4A4:
		weapon_ui.text = "weapon: M4A4"
		if (bullets + magazine == 0):
			ammo_ui.text = "OUT OF AMMO!"
		elif (reloading):
			ammo_ui.text = "(Reloading) " + str(magazine) + "/" + str(bullets)
		else:
			ammo_ui.text = str(magazine) + "/" + str(bullets)
	elif selected_weapon == SPIKES:
		weapon_ui.text = "weapon: SPIKES"
		ammo_ui.text = str(spikes_count)

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


func _on_buy_m4a4_ammo_pressed(screen):
	if money >= 5:
		money -= 5
		bullets += 5
	if bullets > max_bullets:
		bullets = max_bullets
	pass



func _on_buy_spikes_pressed(screen):
	if money >= 15:
		money -= 15
		spikes_count += 5
	pass
