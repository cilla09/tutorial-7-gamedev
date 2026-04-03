extends RigidBody3D

class_name Pickable

@export var item_name: String = "Item"
@export var item_description: String = ""
@export var item_icon: Texture2D = null

func get_item_data() -> Dictionary:
	return {
		"name": item_name,
		"description": item_description,
		"icon": item_icon,
		"scene_path": scene_file_path
	}

func pickup(player: CharacterBody3D):
	var data = get_item_data()
	var added = player.add_item(data)
	if added:
		queue_free() 
