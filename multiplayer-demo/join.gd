extends Control

@onready var join: Button = $join
@onready var host: Button = $host

const PLAYER = preload("res://player.tscn")

var player_count = 0
var spawn_locations : Array = [Vector2i(200, 200), Vector2i(210, 200), Vector2i(220, 200), Vector2i(230, 200)]



func _ready() -> void:
	join.pressed.connect(_on_drop_in_pressed)
	host.pressed.connect(_on_host_pressed)

func _on_drop_in_pressed() -> void:
	MM.new_peer()
	
	await get_tree().create_timer(.4).timeout
	
	## /rw - actual await needed
	
	join_game()
	
	MM.rpc_id(1, "save_call") 
	
	await get_tree().create_timer(.4).timeout

	if GM.coop:
		print("connected")
	else:
		print("not connected")
		MM.connection_failed()
	
	


func _on_host_pressed() -> void:
	MM.new_server()
	
	var currentPlayer = UM.inst(PLAYER, self)
	GM.player_nodes[1] = currentPlayer
	currentPlayer.rename("mario")
	
	# need or you will never rpc to the right node
	var id : int = multiplayer.get_unique_id()
	currentPlayer.name = str(id)
	
	MM.SendPlayerInformation(GM.player_name, multiplayer.get_unique_id())
	GM.coop = true
	
	print("connected")


func join_game():
	print("create check start")
	# tells the existing players that a new player is joining; creates new player node / data
	rpc("player_join", GM.player_name)
	
	# creates the other players on the newly joining client
	create_other_players()


@rpc("any_peer", "call_local")
func player_join(player_name : String):
	print("create check join")
	
	# fine
	var id : int = multiplayer.get_remote_sender_id()
	var currentPlayer = PLAYER.instantiate()
	# name chosen at character creation
	currentPlayer.name = str(id)
	currentPlayer.global_position = spawn_locations[player_count]
	currentPlayer.set_multiplayer_authority(id)
	
	
	GM.Players[id] = {"name" : {}}
	GM.Players[id]["name"] = player_name
	
	GM.player_nodes[id] = currentPlayer
	
	# fine
	add_child(currentPlayer)
	
	if not GM.is_host():
		GM.player.rename("luigi")

func create_other_players():
	print("create check end")
	
	# only create other players not the curernt clients player (id)
	for id in GM.Players:
		if GM.player.name != str(id):
			# fine
			var otherPlayer = PLAYER.instantiate()
			
			otherPlayer.name = str(id)
			
			GM.player_nodes[id] = otherPlayer
			# fine
			add_child(otherPlayer)


func player_leave(id : int):
	# fine
	GM.player_nodes[id].queue_free()
	player_count -= 1
	
