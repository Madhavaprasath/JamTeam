extends KinematicBody2D

signal shoot

const BULLET=preload("res://src/Actor/Player/Bullet.tscn")

onready var animation_player:AnimationPlayer=get_node("Body/Playercontents/AnimationPlayer")
onready var piviot:Position2D=get_node("Body/Playercontents/position/Piviot")
onready var body:Node2D =get_node("Body")
onready var gun=get_node("Body/Playercontents/position/Piviot/Gun/AnimationPlayer")
onready var bullet_spawn:Position2D=get_node("Body/Playercontents/position/Piviot/Gun/Bullet_spawn")

export (bool)var foot=true


var move_direction=1
var velocity=Vector2()
var gravity
var jump_duration=0.5
var max_jump_height=3*Constants.TILE_SIZE
var min_jump_height=0.8*Constants.TILE_SIZE
var min_jump_velocity
var max_jump_velocity
var jumping=false
var facing=1
var can_shoot=true
var shooting
var being_attacked

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
	if move_direction==1:
		facing=1
	elif move_direction==-1:
		facing=-1
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
		jet_pack_vec.y=-int(Input.is_action_pressed("ui_up")) 
		jet_pack_vec.x=int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
		jet_pack_vec=jet_pack_vec.normalized()
		velocity.x=lerp(velocity.x,Constants.JET_PACK_SPEED*jet_pack_vec.x,0.01)
		velocity.y=lerp(velocity.y,Constants.JET_PACK_SPEED*4*jet_pack_vec.y,0.1)
		velocity=move_and_slide(velocity)


#shift the gun i mean rotating guns
func shifitng_guns():
	if Input.is_action_pressed("shift"):
		if piviot.rotation_degrees>=-30:
			piviot.rotation_degrees=lerp(piviot.rotation_degrees,piviot.rotation_degrees-10,0.1)
		elif piviot.rotation_degrees<-30:
			piviot.rotation_degrees=-30
	if Input.is_action_pressed("left_cntrl"):
		if piviot.rotation_degrees<=30:
			piviot.rotation_degrees=lerp(piviot.rotation_degrees,piviot.rotation_degrees+10,0.1)
		elif piviot.rotation_degrees>30:
			piviot.rotation_degrees=30
func shoot():
	if can_shoot:
		can_shoot=false
		shooting=true
		$"Reload timer".start()
		var dir=Vector2(1,0).rotated(piviot.global_rotation)
		emit_signal("shoot",BULLET,bullet_spawn.global_position,dir)
		gun.play("Fire")
		yield(gun,"animation_finished")
		shooting=false


func _on_Reload_timer_timeout():
	can_shoot=true
	shooting=false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="Fire":
		gun.play("Idle")
