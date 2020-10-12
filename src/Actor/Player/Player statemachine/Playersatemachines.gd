extends Node

onready var player=get_parent()

var states ={
	"foot":{
		1:"Idle",
		2:"Run",
		3:"Jump",
		4:"Fall",
		5:"Shooting"
	},
	"jet_pack":{
		1:"jet_pack_idle",
		2:"Jet_pack_run",
		3:"Jet_pack_off"
		},
	"otherstates":{}
}
var current_state
var mode
func _ready():
	current_state=states["foot"][1]
	pass
func _physics_process(delta):
	state_logic(delta)
	var state=transition(delta)
	if state !=null:
		animation(state)
		current_state=state
func state_logic(delta):
	player.handle_input()
	player.apply_movement()
	player.apply_gravity(delta)
func transition(delta):
	match current_state:
		"Idle":
			if ! player.is_on_floor()&&player.foot==true:
				if player.velocity.y<0:
					return states["foot"][3]
				if player.velocity.y>0:
					return states["foot"][4]
			elif abs(player.velocity.x)>=1 &&player.foot==true:
					return states["foot"][2]
			elif player.foot==false:
				if abs(player.velocity.x)==0:
					return states["jet_pack"][1]
		"Run":
			if !player.is_on_floor()&&player.foot==true:
				if player.velocity.y<0:
					return states["foot"][3]
				if player.velocity.y>0:
					return states["foot"][4]
			elif abs(player.velocity.x)<=1 && player.foot==true:
				return states["foot"][1]
			elif player.foot==false:
				if player.velocity!=Vector2(0,0):
					return states["jet_pack"][2]
		"Jump":
			if player.velocity.y>0 and player.foot==true:
				return states["foot"][4]
			if player.is_on_floor() and player.foot==true:
				return states["foot"][1]
		"Fall":
			if player.velocity.y<0 and player.foot==true:
				return states["foot"][3]
			if player.is_on_floor() and player.foot==true:
				return states["foot"][1]
	return null
func animation(state):
	match state:
		"Idle":
			player.animation_player.play("Idle")
		"Run":
			player.animation_player.play("Run")
		"Fall":
			player.animation_player.play("Fall")
		"Jump":
			player.animation_player.play("Jump")


func _unhandled_input(event):
	if event.is_action_pressed("space"):
		player.foot = not player.foot
	if event.is_action_pressed("ui_up")&&player.is_on_floor():
		player.velocity.y=player.max_jump_velocity
		player.jumping=true
	if event.is_action_released("ui_up")&&player.velocity.y<player.min_jump_velocity:
		player.velocity.y=player.min_jump_velocity

