extends Control

@onready var button: Button = $button

func init(search_text : String):
	button.text = search_text



func _on_x_pressed() -> void:
	print("???")
	SM.debug_remove_search.emit(self.get_index())
	queue_free()


func _on_button_pressed() -> void:
	SM.debug_search.emit(button.text)
