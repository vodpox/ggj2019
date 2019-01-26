extends StaticBody

var health = 3

func get_damage(var amount):
	health -= amount
	if (health <= 0):
		get_parent().remove_child(self)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
