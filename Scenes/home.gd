extends StaticBody

var health = 3

func get_damage(var amount):
	health -= amount
	if (health <= 0):
		var node = get_parent()
		node.remove_child(self)
		if node.has_node(NodePath("death_gui")):
			node.get_tree().paused = true
			var death_node = node.get_node("death_gui")
			death_node.show()
			

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
