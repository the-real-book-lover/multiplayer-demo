extends Node

var hovered : Node
var grabbed : Node
var offset : Vector2


func _process(_delta: float) -> void:
	# if node is hovered and mouse is clicked
	if hovered and Input.is_action_just_pressed("LMB"):
		print("GRABBED")
		grab()
	# if node is grabbed
	if grabbed:
		move()


func grab() -> void:
	# get the point clicked to offset
	offset = hovered.get_local_mouse_position()
	# set the node to grabbed
	grabbed = hovered


func move() -> void:
	# update to new position
	grabbed.position = get_new_position()
	# and mouse is unclicked
	if Input.is_action_just_released("LMB"):
		# drop
		grabbed = null


## Enable click to grab and drag.
func enable(hovered_node : Node) -> void:
	hovered_node.mouse_entered.connect(mouse_entered.bind(hovered_node))
	hovered_node.mouse_exited.connect(mouse_exited)

# sets node to hovered on hover
func mouse_entered(hovered_node : Node) -> void:
	hovered = hovered_node
func mouse_exited() -> void:
	hovered = null

# calculate new position
func get_new_position() -> Vector2:
	# if scale is changed
	if grabbed.scale != Vector2(1,1):
		# update the offset to the new scale
		offset = offset * grabbed.scale
	return grabbed.get_global_mouse_position() - offset

# documented

# pure code
