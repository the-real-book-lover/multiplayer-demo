extends Node


## name the action and set the keys; 
# "ACTION_NAME";
const BACKUP : String = "BACKUP"
# input can be single or multiple; [KEY_G], [KEY_CTRL, KEY_P]
const BACKUP_INPUT_KEYS : Array = [KEY_L, KEY_CTRL]
# set the the tscn locations
const BACKUP_MENU = preload("res://shared/removable/backup/backup_menu.tscn")

# set a new backup folder location; default is the user data folder on your OS
var BACKUP_DIR : String # = "C:/Users/user_name/Documents/godot"
# set this to your desired backup folder name
var FOLDER_NAME : String = "/Godot Project Backups/"

var SAVE_FILE_PATH : String
var SAVE_FILE_NAME : String = ".backup_cfg.json"

var SAVE_FILE : Dictionary
var SETTINGS : Dictionary = {
	"project" : true,
	"month" : false,
	"date" : false,
	"time" : false,
}
var backup_menu : CanvasLayer


#region init

func _ready() -> void:
	# init
	add_backup_input()
	verify_backup_dir()
	load_file()
	create_window()

func create_window() -> void:
	# /rw to no tscn
	backup_menu = BACKUP_MENU.instantiate()
	self.add_child(backup_menu)

func add_backup_input() -> void:
	var count : int = 0
	# create an input event for each key for the backup menu hotkey
	for key : int in BACKUP_INPUT_KEYS:
		# creates new InputEventKey for keyboard inputs
		var keybind : InputEventKey = InputEventKey.new()
		# creates the action for each individual key; this could be mapped manually if you want
		var key_number : String = str(count)
		var ACTION_NAME : String = BACKUP + key_number
		# input manager stuff here
		if !InputMap.has_action(ACTION_NAME):
			InputMap.add_action(ACTION_NAME)
		# sets to pressed to activate
		keybind.pressed = true
		# chooses the key that needs to be pressed to activate; based on KEY enums
		@warning_ignore("int_as_enum_without_cast")
		keybind.keycode = key
		# add the action + keybind to the InputMap
		InputMap.action_add_event(ACTION_NAME, keybind)
		count += 1

#endregion


#region process + input checking

func _process(_delta: float) -> void:
	# checks for the input of the set hotkey; toggles the menu
	if new_input() and backup_keybind_pressed():
		backup_menu.toggle()

# hotkey input checker
func backup_keybind_pressed() -> bool:
	var count : int = 0
	# check all the keys;
	for i : int in BACKUP_INPUT_KEYS:
		# checks each key that was set in init
		var key_number : String = str(count)
		var ACTION_NAME : String = BACKUP + key_number
		# if input is pressed; check the next input key
		if Input.is_action_pressed(ACTION_NAME):
			count += 1
			continue
		# else break
		else:
			return false
	# if all are being pressed; run
	return true

# prevents the hotkey from rapid firing
func new_input() -> bool:
	var count : int = 0
	# check all the keys;
	for i : int in BACKUP_INPUT_KEYS:
		# checks each key that was set in init
		var key_number : String = str(count)
		var ACTION_NAME : String = BACKUP + key_number
		# if input is just pressed; allow a new backup input check
		if Input.is_action_just_pressed(ACTION_NAME):
			return true
		elif Input.is_action_just_released(ACTION_NAME):
			return true
		# if no new input found; continue
		else:
			continue
	# will not allow a new toggle menu input if no key press happens
	return false

#endregion


#region settings s/l

func save() -> void:
	print(SAVE_FILE_PATH)
	print(SAVE_FILE_PATH)
	save_json(SAVE_FILE_PATH, SAVE_FILE)

func load_file() -> void:
	# get file
	var save_file_path : String = get_save_file_path()
	var loaded_file : Dictionary = load_json(save_file_path)
	if loaded_file.is_empty():
		var project_name : String = ProjectSettings.get_setting("application/config/name")
		SAVE_FILE[project_name] = SETTINGS
		save()
	else:
		SAVE_FILE = load_json(save_file_path)


func get_save_file_path() -> String:
	var save_path : String = ""
	# if a manual save file path is set; use it
	if SAVE_FILE_PATH:
		save_path = SAVE_FILE_PATH + SAVE_FILE_NAME
		SAVE_FILE_PATH = save_path
	# otherwise default to where the backup path is on your OS
	else:
		save_path = BACKUP_DIR + SAVE_FILE_NAME
		SAVE_FILE_PATH = save_path
	return save_path


func verify_backup_dir() -> void:
	var new_dir : String = get_backup_dir()
	verify_dir(new_dir)

func get_backup_dir() -> String:
	var new_dir : String = ""
	# if a manual backup dir is set; use it
	if BACKUP_DIR:
		new_dir = BACKUP_DIR
	# otherwise default to the user data folder on your OS
	else:
		var USER_DIR  : String = OS.get_data_dir()
		new_dir = USER_DIR + FOLDER_NAME
		BACKUP_DIR = new_dir
	return new_dir

#endregion 


#region


func verify_dir(FOLDER_PATH : String) -> void:
	# if the directory doesn't exist; create it
	if !DirAccess.dir_exists_absolute(FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(FOLDER_PATH)
	else:
		pass

func load_json(PATH : String) -> Dictionary:
	# makes sure the json is init correctly
	var loaded_file : FileAccess = FileAccess.open(PATH, FileAccess.READ)
	if !loaded_file:
		loaded_file = create_json(PATH)
		
	# loads cache content
	var content : String = loaded_file.get_as_text()
	loaded_file.close()
	# reads the json data
	var json : JSON = JSON.new()
	var parsed_json : Error = json.parse(content)
	if parsed_json == OK:
		return json.data
	else:
		return {}

func create_json(PATH : String) -> FileAccess:
	var loaded_file : FileAccess = FileAccess.open(PATH, FileAccess.WRITE_READ)
	loaded_file.store_string("{}")
	return loaded_file


func save_json(FILE_PATH : String, file : Dictionary) -> void:
	# open / create json
	var json : FileAccess = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	# turn cache file into string
	var data : String = JSON.stringify(file)
	# store and close
	json.store_string(data)
	json.close()

#endregion
