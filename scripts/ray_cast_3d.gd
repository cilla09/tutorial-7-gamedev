extends RayCast3D

@onready var player = get_parent().get_parent().get_parent()  # Camera3D -> Head -> Player

var current_collider

func _ready():
	pass

func _process(delta):
	var collider = get_collider()
	current_collider = collider

	if is_colliding() and collider != null:
		if collider is Interactable:
			if Input.is_action_just_pressed("interact"):
				collider.interact()

		elif collider is Pickable:
			if Input.is_action_just_pressed("interact"):
				collider.pickup(player)
