extends CharacterBody3D

@export var speed: float = 10.0
@export var sprint_speed: float = 16.0
@export var crouch_speed: float = 4.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3

@export var crouch_height: float = 0.5       # CollisionShape scale Y when crouching
@export var stand_height: float = 1.0        # CollisionShape scale Y when standing
@export var crouch_head_y: float = 0.2       # Head Y position when crouching
@export var stand_head_y: float = 0.94527245 # Head Y position when standing (dari scene asli)
@export var crouch_transition_speed: float = 8.0

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var inventory_ui = $InventoryUI  

var camera_x_rotation: float = 0.0
var is_crouching: bool = false
var is_sprinting: bool = false

var inventory: Array = []       
const MAX_INVENTORY_SLOTS = 8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

func _physics_process(delta):
	_handle_crouch(delta)
	_handle_movement(delta)

func _handle_crouch(delta):
	# Toggle crouch dengan input "crouch"
	is_crouching = Input.is_action_pressed("crouch")

	var target_head_y = crouch_head_y if is_crouching else stand_head_y
	head.position.y = lerp(head.position.y, target_head_y, crouch_transition_speed * delta)

	if collision_shape and collision_shape.shape is CapsuleShape3D:
		var target_height = crouch_height if is_crouching else stand_height
		collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_transition_speed * delta)

func _handle_movement(delta):
	var movement_vector = Vector3.ZERO

	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x

	movement_vector = movement_vector.normalized()

	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching
	var current_speed: float
	if is_crouching:
		current_speed = crouch_speed
	elif is_sprinting:
		current_speed = sprint_speed
	else:
		current_speed = speed

	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_power

	move_and_slide()

func add_item(item_data: Dictionary) -> bool:
	if inventory.size() >= MAX_INVENTORY_SLOTS:
		print("Inventory penuh!")
		return false
	inventory.append(item_data)
	print("Item ditambahkan: ", item_data.get("name", "Unknown"))
	if inventory_ui and inventory_ui.has_method("refresh"):
		inventory_ui.refresh(inventory)
	return true

func remove_item(index: int) -> Dictionary:
	if index < 0 or index >= inventory.size():
		return {}
	var item = inventory[index]
	inventory.remove_at(index)
	if inventory_ui and inventory_ui.has_method("refresh"):
		inventory_ui.refresh(inventory)
	return item

func has_item(item_name: String) -> bool:
	for item in inventory:
		if item.get("name", "") == item_name:
			return true
	return false
