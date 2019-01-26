extends Timer

var enemy_scene
var spawn_points
var spawn_count

var home

func _ready():
	enemy_scene = load("res://Scenes/Enemy.tscn")
	spawn_points = get_children()
	spawn_count = get_child_count()
	
	home = get_node("../Home")
	
	spawn()

func spawn():
	var chosen_spawner = spawn_points[randi() % spawn_count]
	var enemy = enemy_scene.instance()
	enemy.global_translate(chosen_spawner.get_translation())
	#add_child(enemy)
	var dir = home.translation
	dir.y = enemy.get_translation().y
	enemy.look_at(dir, Vector3(0, 1, 0))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Spawner_timeout():
	spawn()
