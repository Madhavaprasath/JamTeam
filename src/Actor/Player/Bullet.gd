extends Area2D
export (int)var speed
export (int)var lifetime
export (int) var damage 

var velocity=Vector2()


func start(_position,_direction):
	position=_position
	rotation=_direction.angle()
	velocity=_direction*speed

func _process(delta):
	position+=velocity*delta

func explode():
	queue_free()



func _on_life_time_timeout():
	explode()


func _on_Bullet_body_entered(body):
	explode()
