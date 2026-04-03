extends Control

@onready var slot_grid: GridContainer = $Panel/VBoxContainer/SlotGrid

var inventory_visible: bool = false

func _ready():
	visible = false

func _input(event):
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_visible = !inventory_visible
		visible = inventory_visible
		if inventory_visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func refresh(inventory: Array):
	if slot_grid == null:
		return

	for child in slot_grid.get_children():
		child.queue_free()

	for item in inventory:
		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(64, 64)

		var vbox = VBoxContainer.new()
		slot.add_child(vbox)

		if item.get("icon") != null:
			var tex_rect = TextureRect.new()
			tex_rect.texture = item["icon"]
			tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(48, 48)
			vbox.add_child(tex_rect)

		var label = Label.new()
		label.text = item.get("name", "?")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		vbox.add_child(label)

		slot_grid.add_child(slot)
