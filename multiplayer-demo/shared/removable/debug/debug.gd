extends CanvasLayer

var DB : Dictionary

var FOUND_DATA : Color = Color.GREEN
var NULL_DATA : Color = Color.RED

const DEBUG_SPAWNER = preload("res://shared/removable/debug/debug_spawner.tscn")
var debug_spawner : Control

func _init() -> void:
	pass


func _ready() -> void:
	debug_spawner = UM.inst(DEBUG_SPAWNER, self)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		debug_spawner.visible = !debug_spawner.visible

#func highlight(node : Node) -> void:
	#var panel : Panel = UM.inst(Panel, node)
	#panel.size = node.size
	#panel.modulate = Color.YELLOW
	#panel.modulate.a = 0.5
	

func view(data : Variant, title : String) -> void:
	var SPACE : Vector2 = Vector2(0, 50)
	var new : Label = Label.new()
	add_child(new)
	new.text = str(data)
	new.position = SPACE * get_child_count()
	DB[title] = new
	
	if data is int or data is float:
		var new2 : HSlider = HSlider.new()
		new.add_child(new2)
		var n : int = step_decimals(data)
		var bridge : float = pow(10, n)
		new2.step = 1 / bridge
		
		new2.min_value = 1 / bridge * -50
		new2.max_value = 1 / bridge * 50
	
	#Drag.enable(self)

func update(data : Variant, title : String) -> void:
	
	DB[title].text = title + ": " + str(data)
	
	if data:
		DB[title].modulate = FOUND_DATA
	else:
		DB[title].modulate = NULL_DATA
