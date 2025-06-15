extends CanvasLayer

@onready var confirm: Button = $confirm
@onready var discard: Button = $discard

@onready var name_entry: LineEdit = $"name entry"

@onready var project: CheckButton = $project
@onready var month: CheckButton = $month
@onready var date: CheckButton = $date
@onready var time: CheckButton = $time

@onready var override: CheckBox = $override
@onready var subfolder: CheckBox = $subfolder

@onready var error: Label = $error
@onready var display: Label = $display

# check button bools
var seperate_by_project_name : bool
var seperate_by_month : bool
var insert_date : bool
var insert_time : bool
var use_subfolders : bool

# label default texts
const DEFAULT_DISPLAY = ".../"
const DEFAULT_ERROR = ""
var project_name : String = ProjectSettings.get_setting("application/config/name")
var accidental_overwrite : bool

# match based on OS
var INVALID_CHARACTERS : Array = ["/",'\\',":","?","*","\"","<",">","|",]

#region init

func _ready() -> void:
	error.text = DEFAULT_ERROR
	create_reload_buttons()
	set_buttons()
	set_label_text()
	signals()

var count : int = 0
func create_reload_button(backed_up_project_name : String, project_path : String) -> void:
	var reload_button : Button = UM.inst(Button, self)
	var OFFSET : Vector2 = Vector2(0, 200)
	var SPACING : Vector2 = Vector2(0, 50)
	reload_button.text = backed_up_project_name
	reload_button.pressed.connect(lood_backup.bind(project_path))
	reload_button.position += SPACING * count + OFFSET
	count += 1

func lood_backup(project_path : String) -> void:
	var godot_exe : String = OS.get_executable_path()
	OS.execute(godot_exe, [project_path])

func create_reload_buttons() -> void:
	find_projects()

func set_buttons() -> void:
	project.button_pressed = get_parent().SAVE_FILE[project_name]["project"]
	month.button_pressed = get_parent().SAVE_FILE[project_name]["month"]
	date.button_pressed = get_parent().SAVE_FILE[project_name]["date"]
	time.button_pressed = get_parent().SAVE_FILE[project_name]["time"]
	
	seperate_by_project_name = get_parent().SAVE_FILE[project_name]["project"]
	seperate_by_month = get_parent().SAVE_FILE[project_name]["month"]
	insert_date = get_parent().SAVE_FILE[project_name]["date"]
	insert_time = get_parent().SAVE_FILE[project_name]["time"]

	
func signals() -> void:
	# buttons
	confirm.pressed.connect(create_backup)
	discard.pressed.connect(discard_backup)
	# line edit
	name_entry.text_submitted.connect(create_backup)
	name_entry.text_changed.connect(on_text_changed)
	# check buttons
	project.toggled.connect(toggle_project)
	month.toggled.connect(toggle_month)
	date.toggled.connect(toggle_date)
	time.toggled.connect(toggle_time)
	subfolder.toggled.connect(toggle_subfolders)
	# override
	override.toggled.connect(overwrite_override)

#endregion

#func _process(delta: float) -> void:
	#set_label_text()


func toggle() -> void:
	self.visible = !self.visible
	name_entry.grab_focus()

func create_backup(_new_text : String = "") -> void:
	if accidental_overwrite:
		return
	# values
	var FOLDER_NAME : String = get_folder_name()
	var BACKUP_DIR : String = get_parent().BACKUP_DIR + FOLDER_NAME
	print(":::::::::::::::::")
	print(FOLDER_NAME)
	print(get_parent().BACKUP_DIR)
	print(BACKUP_DIR)
	backup_dir(BACKUP_DIR)
	set_label_text()

	# backup lib
	name_entry.text = ""
	self.visible = false

func discard_backup() -> void:
	name_entry.text = ""
	self.visible = false


#region file funcs

func verify_dir(FOLDER_PATH : String) -> void:
	# if the directory doesn't exist; create it
	if !DirAccess.dir_exists_absolute(FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(FOLDER_PATH)
	else:
		pass


func backup_dir(BACKUP_PATH : String) -> void:
	# makes sure the directory exists
	verify_dir(BACKUP_PATH)
	# backup dir
	var absolute_res_path : String = ProjectSettings.globalize_path("res://")
	search_dir(absolute_res_path, BACKUP_PATH)



func search_dir(PATH : String, BACKUP_PATH : String) -> void:
	var dir : DirAccess = DirAccess.open(PATH)
	var directories : PackedStringArray = dir.get_directories()
	for directory in directories:
		# make folders at backup location
		var NEW_BACKUP_PATH : String = BACKUP_PATH + directory + "/"
		verify_dir(NEW_BACKUP_PATH)
		# copy all files at current location
		copy_dir(PATH, BACKUP_PATH)
		# search additional folders
		var NEW_PATH : String = PATH + directory + "/"
		copy_dir(NEW_PATH, BACKUP_PATH)
		search_dir(NEW_PATH, NEW_BACKUP_PATH)
	if directories.is_empty():
		copy_dir(PATH, BACKUP_PATH)

func copy_dir(PATH : String, BACKUP_PATH : String) -> void:
	var dir : DirAccess = DirAccess.open(PATH)
	var files : PackedStringArray = dir.get_files()
	for file : String in files:
		var FILE_PATH : String = PATH + file
		var NEW_BACKUP_PATH : String = BACKUP_PATH + file
		DirAccess.copy_absolute(FILE_PATH, NEW_BACKUP_PATH)


#endregion

#region signal funcs
func on_text_changed(new_text : String) -> void:
	if valid(new_text):
		set_label_text()

func valid(new_text : String) -> bool:
	for CHARACTER : String in INVALID_CHARACTERS:
		if new_text.contains(CHARACTER):
			print("check")
			var invalid_character : String = new_text.right(1)
			name_entry.text = new_text.left(-1)
			error.text = "Invalid character for file naming: " + invalid_character
			return false
	return true

func toggle_project(toggled_on : bool) -> void:
	seperate_by_project_name = toggled_on
	get_parent().SAVE_FILE[project_name]["project"] = project.button_pressed
	set_label_text()
	get_parent().save()

func toggle_month(toggled_on : bool) -> void:
	seperate_by_month = toggled_on
	get_parent().SAVE_FILE[project_name]["month"] = month.button_pressed
	set_label_text()
	get_parent().save()

func toggle_date(toggled_on : bool) -> void:
	insert_date = toggled_on
	get_parent().SAVE_FILE[project_name]["date"] = date.button_pressed
	set_label_text()
	get_parent().save()

func toggle_time(toggled_on : bool) -> void:
	insert_time = toggled_on
	get_parent().SAVE_FILE[project_name]["time"] = time.button_pressed
	set_label_text()
	get_parent().save()

func toggle_subfolders(toggled_on : bool) -> void:
	use_subfolders = toggled_on
	get_parent().SAVE_FILE[project_name]["subfolder"] = subfolder.button_pressed
	set_label_text()
	get_parent().save()



func set_label_text() -> void:
	display.text = DEFAULT_DISPLAY + get_folder_name()
	check_for_overwrite()

func check_for_overwrite() -> void:
	var thing : String = get_parent().BACKUP_DIR
	var FOLDER_PATH : String = thing + get_folder_name()
	# if the directory exists; warn of overwrite
	if DirAccess.dir_exists_absolute(FOLDER_PATH):
		overwrite_warning(true)
	else:
		overwrite_warning(false)
		

func overwrite_warning(toggled_on : bool) -> void:
	override.visible = toggled_on
	confirm.disabled = toggled_on
	error.text = "Folder at location with same name"
	error.visible = toggled_on
	accidental_overwrite = toggled_on

func overwrite_override(toggled_on : bool) -> void:
	if accidental_overwrite and toggled_on:
		confirm.disabled = false
	

#endregion 

func get_folder_name() -> String:
	var FOLDER_NAME : String = ""
	
	if seperate_by_project_name:
		FOLDER_NAME += project_name + "/"
	if seperate_by_month:
		var date_string : String = Time.get_date_string_from_system()
		date_string = date_string.left(-3)
		FOLDER_NAME += date_string + "/"
	if insert_date:
		var date_string : String = Time.get_date_string_from_system()
		date_string = date_string.right(-5)
		FOLDER_NAME += date_string + "/"
	if insert_time:
		FOLDER_NAME += Time.get_time_string_from_system() + "/"
		FOLDER_NAME = FOLDER_NAME.replace(":", "-")
	if use_subfolders:
		FOLDER_NAME = FOLDER_NAME.left(-1)
		FOLDER_NAME += " "
	
	if name_entry.text.is_empty():
		print("empty? ", FOLDER_NAME)
		return FOLDER_NAME
	else:
		FOLDER_NAME += name_entry.text + "/"
		print("entry? ", FOLDER_NAME)
		return FOLDER_NAME

#region todo

# reload old backups
# OS.shell_open

# close current game
# close current engine process

# create subfolder or append

## else

# save states
# creating / deleting saves


#endregion 

#region notes

func find_projects() -> void:
	var BACKUP_PATH : String = get_parent().BACKUP_DIR
	# makes sure the directory exists
	verify_dir(BACKUP_PATH)
	# backup dir
	search_backups(BACKUP_PATH)



func search_backups(BACKUP_PATH : String) -> void:
	var dir : DirAccess = DirAccess.open(BACKUP_PATH)
	var directories : PackedStringArray = dir.get_directories()
	for directory in directories:
		# make folders at backup location
		var NEW_BACKUP_PATH : String = BACKUP_PATH + directory + "/"
		# copy all files at current location
		var project_found : bool = search_dir_for_project_file(BACKUP_PATH)
		
		# /rw turn off deep searches if project is found?
		if project_found:
			var project_path : String = BACKUP_PATH + "project.godot"
			create_reload_button(project_path, project_path)
			break
			
			#search_backups(NEW_BACKUP_PATH)
			#continue
			
		# search additional folders if project not found
		else:
			search_backups(NEW_BACKUP_PATH)
	
	if directories.is_empty():
		var _project_found : bool = search_dir_for_project_file(BACKUP_PATH)


func search_dir_for_project_file(BACKUP_PATH : String) -> bool:
	var dir : DirAccess = DirAccess.open(BACKUP_PATH)
	var files : PackedStringArray = dir.get_files()
	if "project.godot" in files:
		var FILE_PATH : String = BACKUP_PATH
		print("FOUND PROJECT AT : ", FILE_PATH)
		
		return true
	else:
		return false

#endregion 
