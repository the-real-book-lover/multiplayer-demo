extends Control

@onready var img: Sprite2D = $img
@onready var timer: Timer = $Timer

@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var label_4: Label = $Label4
@onready var label_5: Label = $Label5
@onready var label_6: Label = $Label6
@onready var label_7: Label = $Label7
@onready var label_8: Label = $Label8
@onready var label_9: Label = $Label9


var tween : Tween

func init(id : int):
	# texture
	img.texture.region = Rect2(GM.ITEM_TEXTURE_SIZE * GM.item[id]["texture"].x, GM.ITEM_TEXTURE_SIZE * GM.item[id]["texture"].y, GM.ITEM_TEXTURE_SIZE, GM.ITEM_TEXTURE_SIZE)
	img.visible = true
	# info
	var index : int = 3
	
	
	
	for i in GM.item[id]:
		get_child(index).text = i + " : " + str(GM.item[id][i])
		get_child(index).position = Vector2(0, 36) * index
		
		index += 1
	
	tweenage_wasteland(0)

func _ready() -> void:
	timer.timeout.connect(reset)

func _on_clear_pressed() -> void:
	tweenage_wasteland(1)



func tweenage_wasteland(state : int):
	
	if tween and tween.is_running():
		tween.stop()
		tween.kill()
		tween = null
	if !tween or !tween.is_running():
		tween = create_tween()
	
	
	match state:
		0:
			tween.tween_property(self, "modulate:a", 1.0, 0.5)
		1:
			tween.tween_property(self, "modulate:a", 0.0, 0.5)
			timer.start(0.5)

func reset():
	# texture
	img.visible = false
	# label texts
	for i in get_children():
		if i is Label:
			i.text = ""
	
	SM.debug_open_comparison.emit(self.get_index())
	
