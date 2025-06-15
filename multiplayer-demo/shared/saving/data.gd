extends Node

class_name Data

static var file : Dictionary = {
	"test" : 1,
}

# /f how do I get the user folder
const DIR : String = "C:/Users/ronst/Documents/godot/projects/fuck-art/user/"
const FILE_PATH : String = "C:/Users/ronst/Documents/godot/projects/fuck-art/user/data.json/"
const BACKUP_DIR : String = "C:/Users/ronst/Documents/godot/projects/fuck-art/user/backup/"

static func save() -> void:
	## /f do backups?
	#UM.backup_json(BACKUP_DIR, GM.file)
	UM.save_json(FILE_PATH, GM.file)

static func load_file() -> void:
	# create dir if none
	UM.verify_dir(DIR)
	# get file
	var loaded_file : Dictionary = UM.load_json(FILE_PATH)
	if loaded_file.is_empty():
		GM.file = file.duplicate(true)
	else:
		GM.file = UM.load_json(FILE_PATH)
