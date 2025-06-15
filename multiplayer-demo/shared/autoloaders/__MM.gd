extends Node

var peer : ENetMultiplayerPeer

func _ready() -> void:
	multiplayer.peer_connected.connect(PlayerConnected)
	multiplayer.peer_disconnected.connect(PlayerDisconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


# called on server and all clients
func PlayerConnected(_id : int):
	if GM.is_host():
		MM.rpc("SendPlayerInformation", GM.player_name, 1)

# called on server and all clients
func PlayerDisconnected(id : int):
	print("player disconnected: ", id, "  ", multiplayer.get_peers(), "  ", multiplayer.is_server())
	GM.Players.erase(id)
	#GM.player_nodes[id].queue_free()

# called only from clients
func connected_to_server():
	MM.rpc("SendPlayerInformation", "luigi", multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print("con fail")
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface())
	print("multiplayer.get_unique_id(): ", multiplayer.get_unique_id())



@rpc("any_peer", "call_remote")
func disconnect_server():
	var id : int = multiplayer.get_remote_sender_id()
	print(id)
	multiplayer.disconnect_peer(id)

func new_server():
	# create new peer
	peer = ENetMultiplayerPeer.new()
	# create new server; (port, max peers)
	peer.create_server(GM.port, 4)
	multiplayer.set_multiplayer_peer(peer)
	print("multi.is_server() ", multiplayer.is_server())
	


func new_peer():
	# create new peer
	peer = ENetMultiplayerPeer.new()
	# connect to server; (address, port)
	peer.create_client(GM.Address, GM.port)
	multiplayer.set_multiplayer_peer(peer)
	print("new peer: ", multiplayer.get_unique_id())




@rpc("any_peer", "call_remote")
func SendPlayerInformation(new_player_name : String, id : int):
	if !GM.Players.has(id):
		GM.Players[id] = {
			"name" : new_player_name,
			"id" : id,
			
			# id : name
		}
	if multiplayer.is_server():
		for i in GM.Players:
			SendPlayerInformation.rpc(GM.Players[i].name, multiplayer.get_unique_id())


@rpc("any_peer", "call_remote")
func save_call():
	rpc_id(multiplayer.get_remote_sender_id(), "send_file")


@rpc("any_peer", "call_remote")
func send_file():
	print("running?")
	GM.player_name = "luigi"
	GM.coop = true

	
func client_leave(): 
	GM.host = false
	# /d/ checks for debug new game reloads
	if GM.game_state != GM.GAME_STATE.RESET:
		GM.game_state = GM.GAME_STATE.TITLE
	
	GM.save_state = GM.SAVE_STATE.LOADING
	
	GM.Players.clear()
	GM.player = null
	GM.coop = false
	
	if GM.coop:
		# shuts down peer connect
		peer.close()
		# reset server host status
		get_tree().set_multiplayer(MultiplayerAPI.create_default_interface())
	
	



@rpc("any_peer", "call_local")
func coop_game_load(file : Dictionary):
	
	GM.save.file = file.duplicate(true)
	
	
	
	
	GM.inv = GM.save.file["player_data"][GM.player_name]["player_inv"].duplicate(true)
	print("ran: ", multiplayer.get_unique_id(), " coop?: ", GM.coop)


#endregion
