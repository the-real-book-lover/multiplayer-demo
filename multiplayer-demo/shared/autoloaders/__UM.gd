extends Node

## call func pass self as default w/o ref? v--- :> self?
func inst(object : Variant, parent : Node , data : Variant = null) -> Object:
	var new : Node
	
	# takes packed scene
	if object is PackedScene:
		# checks for init data
		if data:
			# creates and adds to scene 
			new = object.instantiate()
			parent.add_child(new)
			# runs .init
			new.init(data)
		else:
			# creates and adds to scene 
			new = object.instantiate()
			parent.add_child(new)
	# takes class object
	elif object is Object:
		# checks for init data
		if data:
			# runs .init with data
			new = object.new(data) 
			parent.add_child(new)
		else:
			# runs .init
			new = object.new()
			parent.add_child(new)
	# return new scene to parent
	return new


#region json loading



func verify_dir(FOLDER_PATH : String) -> void:
	# if the directory doesn't exist; create it
	if !DirAccess.dir_exists_absolute(FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(FOLDER_PATH)
	# /D
	#if DirAccess.dir_exists_absolute(FOLDER_PATH):
		#print("VALID : ", FOLDER_PATH)

func verify_file(FILE_PATH : String) -> FileAccess:
	# if the directory doesn't exist; create it
	if !FileAccess.file_exists(FILE_PATH):
		# access file
		var init_file : FileAccess = FileAccess.open(FILE_PATH, FileAccess.WRITE)
		# close file
		init_file.close()
	
	var file : FileAccess = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	# return file for use
	return file

func write_file(FILE_PATH : String, data : Variant) -> void:
	# access file
	var file : FileAccess = verify_file(FILE_PATH)
	# write data
	if data is String:
		file.store_string(data)
	else:
		file.store_var(data)
	# close file
	file.close()

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
		print("ERR: ", parsed_json)
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



func backup_json(BACKUP_DIR : String, file : Dictionary) -> void:
	# will be used to limit the amount of current backups at a given location; -1 is unlimited
	var _backup_folder_size : int = 10
	# makes sure the directory exists
	UM.verify_dir(BACKUP_DIR)
	# label cache with backup time
	var time : String = Time.get_datetime_string_from_system()
	# ":" is not a valid file name in windows
	time = time.replace(":", "-")
	# save backup to path
	var FILE_PATH : String = BACKUP_DIR + "/" + time + ".json"
	save_json(FILE_PATH, file)

func backup_dir(DIR : String, BACKUP_DIR : String) -> void:
	# makes sure the directory exists
	UM.verify_dir(DIR)
	UM.verify_dir(BACKUP_DIR)
	# backup dir
	var files : PackedStringArray = DirAccess.get_files_at(DIR)
	for file : String in files:
		# label cache with backup time
		var time : String = Time.get_datetime_string_from_system()
		# ":" is not a valid file name in windows
		time = time.replace(":", "-")
		var FILE_PATH : String = DIR + file
		var BACKUP_PATH : String = BACKUP_DIR + file + time
		DirAccess.copy_absolute(FILE_PATH, BACKUP_PATH)


#endregion


#region init

func always_on_top() -> void:
	# adds new action to InputMap
	var action : StringName = "toggle_always_on_top"
	InputMap.add_action(action)
	# creates new InputEventKey for keyboard inputs
	var keybind : InputEventKey = InputEventKey.new()
	# sets to pressed to activate
	keybind.pressed = true
	# chooses the key that needs to be pressed to activate; based on KEY enums
	keybind.keycode = KEY_F3
	# adds the keybind to the action
	InputMap.action_add_event(action, keybind)
	
	print("INTIN: ", InputMap.event_is_action(keybind, action, true))
	toggling_always_on_top = true
	ProjectSettings.set_restart_if_changed("display/window/size/always_on_top", false)
	ProjectSettings.save()
	


#endregion 


#region process

#func _process(_delta: float) -> void:
	#if toggling_always_on_top:
		#if Input.is_action_just_pressed("toggle_always_on_top"):
			#toggle_always_on_top()

var toggling_always_on_top : bool = false
func toggle_always_on_top() -> void:
	var current_value : bool = ProjectSettings.get_setting("display/window/size/always_on_top")
	print(current_value)
	ProjectSettings.set_setting("display/window/size/always_on_top", !current_value)
	print(current_value)
	ProjectSettings.save()
	
	
#endregion 

	
	
	
	
