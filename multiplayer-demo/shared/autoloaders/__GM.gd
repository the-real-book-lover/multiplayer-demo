extends Node

## TROUBLESHOOTING
# host id may be 0
# port may be closed

# Codes - SDV STEAM API -> ( https://godotengine.org/asset-library/asset/1020 ) 
var Address = "127.0.0.1"
var port = 8910

# to get around load order errors; better method possible for sure
var host : bool = false
var coop : bool = false
var player_name : String

var player : Player
# some way to know all the current clients connected; Dictionary -> { id : "name" } 
var Players : Dictionary
# groups may be better; [PLAYERNODE,  PLAYERNODE,...] 
var player_nodes : Dictionary

var main : Node2D

func is_host():
	return multiplayer.get_unique_id() == 1



# v-- none of this mattesr --v
var file : Dictionary
var cfg : Dictionary

var all_presets : Array
var preset
var preset_int

func _ready() -> void:
	Data.load_file()
	Cfg.load_file()
	
	Cfg.init(cfg)
