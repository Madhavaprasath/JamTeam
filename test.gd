extends Node2D

onready var player=get_node("Player")
func _ready():
	player.connect("shoot",self,"on_player_shoot")
	
func on_player_shoot(_bullet,_position,_direction):
	var b=_bullet.instance()
	add_child(b)
	b.start(_position,_direction)


