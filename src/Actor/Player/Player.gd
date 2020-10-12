extends KinematicBody2D

var velocity=Vector2()
onready var animation_player=get_node("Body/AnimationPlayer")
onready var body =get_node("Body")
var move_direction
var just_landed
var gravity
var jump_duration=0.5
var max_jump_height=3*Constants.TILE_SIZE
var min_jump_height=0.8*Constants.TILE_SIZE
var min_jump_velocity
var max_jump_velocity
var jumping=false
export (bool)var foot=true
func _ready():
	gravity=2*max_jump_height/pow(jump_duration,2)
	max_jump_velocity=-sqrt(2*gravity*max_jump_height)
	min_jump_velocity=-sqrt(2*gravity*min_jump_height)


func apply_gravity(delta):
	if foot==true:
		velocity.y+=gravity*delta
	else:
		velocity.y=20
func handle_input():
	move_direction=int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	if move_direction!=0:
		body.scale.x=move_direction
	velocity.x=lerp(velocity.x,Constants.MOVE_SPEED*move_direction,Friction())
func Friction():
	return 0.2 if is_on_floor() else 0.05

func apply_movement():
	if jumping==true&&velocity.y>0:
		jumping=false
	if foot==true:
		var snap_vector=Vector2(0,32) if !jumping else Vector2()
		velocity=move_and_slide_with_snap(velocity,snap_vector,Vector2.UP)
	elif foot==false:
		var jet_pack_vec=Vector2()
		jet_pack_vec.y=int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up"))
		jet_pack_vec.x=int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
		jet_pack_vec=jet_pack_vec.normalized()
		velocity.x=lerp(velocity.x,Constants.JET_PACK_SPEED*jet_pack_vec.x,0.01)
		velocity.y=lerp(velocity.y,Constants.JET_PACK_SPEED*4*jet_pack_vec.y,0.1)
		velocity=move_and_slide(velocity)
