extends Control

@onready var bg: Panel = $bg

var save : Dictionary
var SAVE : Dictionary = {
	"test" : "."
}


const DIR : String = "C:/Users/ronst/Documents/godot/projects/blockpet/shared/removable/debug/"
const FILE_PATH : String = "C:/Users/ronst/Documents/godot/projects/blockpet/shared/removable/debug/debug_save.json/"
#const BACKUP_DIR : String = "C:/Users/ronst/Documents/godot/projects/blockpet/shared/removable/debug/backup/"



func _ready() -> void:
	var row : int = 0
	var col : int = 0
	for item_id : int in GM.DB:
		# spawn node
		var item_button : TextureButton = UM.inst(TextureButton, self)
		# texture
		var texture : CompressedTexture2D = GM.get_sprite(item_id)
		item_button.texture_normal = texture
		item_button.scale = Vector2(64,64) / item_button.texture_normal.get_size()
		item_button.pressed.connect(spawn.bind(item_id))
		item_button.mouse_entered.connect(highlight_on.bind(item_button))
		item_button.mouse_exited.connect(highlight_off.bind(item_button))
		# position
		var x : float = 64 * col
		var y : float = 64 * row
		var SPACING : Vector2 = Vector2(x, y)
		item_button.position += SPACING
		# position values
		col += 1
		if col == 9:
			col = 0
			row += 1
	
	# position
	var xB : float = 64 * 9
	var yB : float = 64 * (row + 1)
	var SPACING_B : Vector2 = Vector2(xB, yB)
	bg.size = SPACING_B
	
func spawn(item_id : int) -> void:
	Spawn.show_preview(item_id)

func highlight_on(item_button : TextureButton) -> void:
	item_button.modulate = Color.YELLOW

func highlight_off(item_button : TextureButton) -> void:
	item_button.modulate = Color.WHITE
	


func save_debug() -> void:
	## /f do backups?
	#UM.backup_json(BACKUP_DIR, GM.cfg)
	UM.save_json(FILE_PATH, save)


func load_debug() -> void:
	# create dir if none
	UM.verify_dir(DIR)
	# get file
	var loaded_file : Dictionary = UM.load_json(FILE_PATH)
	if loaded_file.is_empty():
		save = SAVE.duplicate(true)
	else:
		save = UM.load_json(FILE_PATH)
