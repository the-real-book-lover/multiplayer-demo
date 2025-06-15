extends Node

var hovered_screen : Node
var preview : Node2D
var item_id : int

func _ready() -> void:
	create_preview()


func create_preview() -> void:
	# init
	preview = UM.inst(Sprite2D, self)
	preview.modulate.a = 0.5
	preview.visible = false
	preview.z_index = 500



#region process

func _process(_delta: float) -> void:
	spawning()

func spawning() -> void:
	# if player is spawning objects
	if preview.visible:
		preview.global_position = GM.main.get_global_mouse_position()
		# left click; spawn object
		if Input.is_action_just_pressed("LMB"):
			spawn()
		# right click; cancel
		if Input.is_action_just_pressed("RMB"):
			stop_spawning()

#endregion


#region spawning
func spawn() -> void:
	# checks that a screen will spawn the item
	if spawning_box():
		GM.main.spawn(item_id)
	elif hovered_screen:
		hovered_screen.spawn(item_id)
	
	var currency_cost : int = GM.DB[item_id].cost
	GM.change_energy(currency_cost)

func spawning_box() -> bool:
	var type : String = GM.get_type(item_id)
	if type == "box":
		return true
	else:
		return false

func parent() -> Node:
	# sets the node where the item needs to be parented
	match GM.get_scene(item_id):
		Entity:
			return hovered_screen.clip
		Box:
			return GM.main
		Treadmill:
			return hovered_screen
	return GM.main

func get_thing_position() -> Vector2:
	# sets the node where the item needs to be parented
	match GM.get_item_name(item_id):
		"fly":
			return hovered_screen.global_position + hovered_screen.spawn_point
		"lizard":
			return hovered_screen.global_position + hovered_screen.spawn_point
		"screen":
			return preview.global_position
		"food":
			return hovered_screen.global_position + hovered_screen.spawn_point
		"treadmill":
			return hovered_screen.global_position + hovered_screen.spawn_point + Vector2(150, 200)
	return Vector2.ZERO


#endregion


#region preview

func show_preview(selected_id : int) -> void:
	item_id = selected_id
	GM.state = GM.STATE.SPAWN
	preview.texture = GM.get_sprite(item_id)
	preview.visible = true
	
	

func stop_spawning() -> void:
	GM.state = GM.STATE.NONE
	preview.visible = false
	print("??")

#endregion


# color red / green; placeability
# auto adjustment -^?
