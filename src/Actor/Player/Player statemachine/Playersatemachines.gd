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
		1:"jet_pack_idle"
		},
	"otherstates":{
		1:"knock_back"
	}
}
var current_state
var mode
func _ready():
	current_state=states["foot"][1]
	pass
func _physics_process(delta):
	self.check_for_attack()
	player.shifitng_guns()
	state_logic(delta)
	var state=transition(delta)
	if state !=null:
		animation(state)
		current_state=state
func state_logic(delta):
	player.handle_input()
	player.apply_movement()
	player.apply_gravity(delta)
	if current_state=="Shoot":
		player.shoot()
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
				return states["jet_pack"][1]
			elif player.shooting==true:
				return states["foot"][5]
			elif player.being_attacked==true:
				return states["otherstates"][1]
		"Run":
			if !player.is_on_floor()&&player.foot==true:
				if player.velocity.y<0:
					return states["foot"][3]
				if player.velocity.y>0:
					return states["foot"][4]
			elif abs(player.velocity.x)<=1 && player.foot==true:
				return states["foot"][1]
			elif player.foot==false:
				return states["jet_pack"][1]
			elif player.shooting==true:
				return states["foot"][5]
			elif player.being_attacked==true:
				return states["otherstates"][1]
		"Jump":
			if player.velocity.y>0 and player.foot==true:
				return states["foot"][4]
			elif player.is_on_floor() and player.foot==true:
				return states["foot"][1]
			elif player.foot==false:
				return states["jet_pack"][1]
			elif player.shooting==true:
				return states["foot"][5]
			elif player.being_attacked==true:
				return states["otherstates"][1]
		"Fall":
			if player.velocity.y<0 and player.foot==true:
				return states["foot"][3]
			elif player.is_on_floor() and player.foot==true:
				return states["foot"][1]
			elif player.foot==false:
				return states["jet_pack"][1]
			elif player.shooting==true:
				return states["foot"][5]
			elif player.being_attacked==true:
				return states["otherstates"][1]
		"jet_pack_idle":
			if player.foot==true:
				return states["foot"][1]
			elif player.being_attacked==true:
				return states["otherstates"][1]
		"Shooting":
			if player.shooting==false:
				return states["foot"][1]
			elif player.being_attacked==true:
				return states["otherstates"][1]
		"knock_back":
			if player.being_attacked==false:
				if player.foot==true&&player.is_on_floor():
					return states["foot"][1]
				elif player.foot==true:
					if player.velocity.y<0:
						return["foot"][3]
					else:
						return["foot"][4]
			else:
				return states["jet_pack"][1]
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
		"jet_pack_idle":
			player.animation_player.play("Jet_pack")
		"knock_back":
			pass

func _unhandled_input(event):
	if event.is_action_pressed("space"):
		player.foot = not player.foot
	if event.is_action_pressed("ui_up")&&player.is_on_floor():
		player.velocity.y=player.max_jump_velocity
		player.jumping=true
	if event.is_action_released("ui_up")&&player.velocity.y<player.min_jump_velocity:
		player.velocity.y=player.min_jump_velocity
	if event.is_action_pressed("left_click"):
		if current_state=="Idle"||current_state=="Run"||current_state=="Jump":
			player.shoot()
	if event.is_action_pressed("right_click"):
		player.being_attacked=true
func check_for_attack():
	if player.being_attacked==true:
		print(player.facing)
		player.velocity.x=-100*player.facing
		yield(get_tree().create_timer(0.4),"timeout")
		player.being_attacked=false
