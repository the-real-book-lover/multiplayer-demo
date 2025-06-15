class_name Player
extends CharacterBody2D

@onready var player_name: Label = $"player name"
@onready var camera: Camera2D = $camera

var pname : String
var SPEED : float = 100
var speed : float = SPEED

var direction : Vector2

func _ready() -> void:
	if is_multiplayer_authority():
		GM.player = self
		player_name.text = pname
		camera.enabled = true


#enum ENTITY {
	#ZERO
#}
#var entityDB : Dictionary = {
	#ENTITY.ZERO : preload("res://player.tscn")
#}
#@rpc("any_peer", "call_local")
#func spawn_id(id : int):
	#var new_entity : PackedScene = entityDB[id]
	#UM.inst(new_entity, self)
#
#rpc("spawn_id", ENTITY.ZERO)

func _physics_process(delta: float) -> void:
	#if multiplayer.is_server():
	if GM.coop:
		if is_multiplayer_authority():
			rpc("player_position", position, multiplayer.get_unique_id())
			player_actions()
			
			#if Input.is_action_just_pressed("spawn guy"):
				#rpc("spawn_id", ENTITY.ZERO)
	else:
		player_actions()



#func plant_growth():
	#stage += 1

func player_actions():
	direction = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity = speed * direction
	
	
	move_and_slide()


@rpc("any_peer", "call_remote")
func player_position(pos : Vector2i, id : int):
	GM.player_nodes[id].position = pos

func rename(new_name : String):
	pname = new_name
	player_name.text = pname
