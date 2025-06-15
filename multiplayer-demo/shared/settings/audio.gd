extends Control


func _ready() -> void:
	var SIZE : Vector2 = Vector2(100, 32)
	var OFFSET : Vector2 = Vector2(0, 50)
	var SPACING : Vector2 = Vector2(0, 50)
	for idx in AudioServer.get_bus_count():
		var slider_name : String = AudioServer.get_bus_name(idx)
		var volume_slider : HSlider = UM.inst(HSlider, self)
		volume_slider.position += SPACING * idx + OFFSET
		volume_slider.size = SIZE
		
		
		var label : Label = UM.inst(Label, volume_slider)
		label.text = slider_name
		label.position -= SPACING / 2
