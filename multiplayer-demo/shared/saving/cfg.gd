class_name Cfg
extends Node


static var file : Dictionary = {
	"keybinds" : {
		"current" : {
			"Default" : {
				"Keyboard" : {
					"Menu" : null,
					"Move Left" : null,
					"Move Right" : null,
					"Move Up" : null,
					"Move Down" : null,
					"charge" : null,
					"debug" : null,
					},
				"Mouse" : {
					# interact
					"LMB" : null,
					"RMB" : null,
					# Camera
					"Zoom In" : null,
					"Zoom Out" : null,
				}
			}
		},
		"default" : {
			"Default" : {
				"Keyboard" : {
					"Menu" : [KEY_ESCAPE],
					"Move Left" : [KEY_A],
					"Move Right" : [KEY_D],
					"Move Up" : [KEY_W],
					"Move Down" : [KEY_S],
					"charge" : [KEY_SPACE],
					"debug" : [KEY_F1],
					},
				"Mouse" : {
					# interact
					"LMB" : [MOUSE_BUTTON_LEFT],
					"RMB" : [MOUSE_BUTTON_RIGHT],
					# Camera
					"Zoom In" : [MOUSE_BUTTON_WHEEL_UP],
					"Zoom Out" : [MOUSE_BUTTON_WHEEL_DOWN],
					}
				}
			}
	},
	"preset" : "Default",
	"device" : "Keyboard",
	"device_int" : 0,
	"audio" : {
		"range" : Vector3(0, 1, .05),
		"master" : 1.0,
		"music" : 1.0,
		"sfx" : 1.0,
		"ambience" : 1.0,
		"movement" : 1.0,
	},
	"graphics" : {
		"resolution" : [10, Vector2(1248, 1000)],
		"window_mode" : Window.MODE_WINDOWED,
		"refresh_rate" : 3,
		"vsync" : false,
	}
}

# /f how do I get the user folder
const DIR : String = "C:/Users/ronst/Documents/godot/projects/fuck-art/user/"
const FILE_PATH : String = "C:/Users/ronst/Documents/godot/projects/fuck-art/user/cfg.json/"
const BACKUP_DIR : String = "C:/Users/ronst/Documents/godot/projects/fuck-art/user/backup/"


static func save() -> void:
	## /f do backups?
	#UM.backup_json(BACKUP_DIR, GM.cfg)
	UM.save_json(FILE_PATH, GM.cfg)


static func load_file() -> void:
	# create dir if none
	UM.verify_dir(DIR)
	# get file
	var loaded_file : Dictionary = UM.load_json(FILE_PATH)
	if loaded_file.is_empty():
		GM.cfg = file.duplicate(true)
	else:
		GM.cfg = UM.load_json(FILE_PATH)



# /o/ limit presets?
# /rw/ prevent duplicate names ( if renamable ); else Custom X += 1 
static func init(cfg_file : Dictionary) -> void:
	# /d/ not sure if this needs to be here but it does for now
	save()
	
	var keybinds : Dictionary = cfg_file["keybinds"]["default"]
	var default_keybinds : Dictionary = keybinds["Default"]
	var current_preset : String = cfg_file["preset"]
	
	
	# runs over each preset
	for preset : Dictionary in [keybinds]:
		# sets for control.gd to change presets
		GM.all_presets.append(preset)

	# generates the keybinds for all the devices
	for device : String in keybinds[current_preset]:
		# generates all actions on each device
		for action : String in keybinds[current_preset][device]:
			# adds the action; ( assumes first time init; will not crash but here as precaution )
			if !InputMap.has_action(action):
				InputMap.add_action(action)
			
			# if the keybind is already mapped;
			if keybinds[current_preset][device][action]:
				match device:
					"Mouse":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventMouseButton = InputEventMouseButton.new()
							# sets to pressed to activate
							keybind.pressed = true
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.button_index = key
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
					"Keyboard":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventKey = InputEventKey.new()
							# sets to pressed to activate
							keybind.pressed = true
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.keycode = key
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
					"Controller Button":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventJoypadButton = InputEventJoypadButton.new()
							# sets to pressed to activate
							keybind.pressed = true
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.button_index = key
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
					"Controller Stick":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventJoypadMotion = InputEventJoypadMotion.new()
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.axis = key
							# chooses the key that needs to be pressed to activate; based on KEY enums
							keybind.axis_value = get_axis_value(action)
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
			# if not; create
			else:
				match device:
					"Mouse":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in default_keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventMouseButton = InputEventMouseButton.new()
							# sets to pressed to activate
							keybind.pressed = true
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.button_index = key
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
					"Keyboard":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in default_keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventKey = InputEventKey.new()
							# sets to pressed to activate
							keybind.pressed = true
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.keycode = key
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
					"Controller Button":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in default_keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventJoypadButton = InputEventJoypadButton.new()
							# sets to pressed to activate
							keybind.pressed = true
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.button_index = key
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
					"Controller Stick":
						# will allow for multiple inputs per action; (menu, chat, scroll need)
						for key : int in default_keybinds[current_preset][device][action]:
							# creates new InputEventKey for keyboard inputs
							var keybind : InputEventJoypadMotion = InputEventJoypadMotion.new()
							# chooses the key that needs to be pressed to activate; based on KEY enums
							@warning_ignore("int_as_enum_without_cast")
							keybind.axis = key
							# chooses the key that needs to be pressed to activate; based on KEY enums
							keybind.axis_value = get_axis_value(action)
							# adds the keybind to the action
							InputMap.action_add_event(action, keybind)
							# adds the keybind to the official saved settings
							keybinds[current_preset][device][action] = [keybind]
	
	GM.preset = current_preset
	GM.preset_int = GM.all_presets.find(current_preset)
	
	#var actions : Array = InputMap.get_actions()
	#print(actions)
	#for i in actions:
		#var events : Array = InputMap.action_get_events(i)
		#print(i, events)
	
static func get_axis_value(action : String) -> int:
	if action.contains("Up") or action.contains("Left"):
		return -1
	else:
		return 1
