extends Area2D
onready var ANIMATEDSPRITE = get_node("AnimatedSprite")
const SPEED = 5
var velocity = Vector2(0,0)

func _ready():
	pass # Replace with function body.

func set_direction(direction):
	if(direction > 0):
		direction = 1
	else:
		direction = -1
	velocity.x = direction * SPEED
	
func _process(_delta):
	if(velocity.x > 0):
		ANIMATEDSPRITE.set_flip_h(false)
	if(velocity.x < 0):
		ANIMATEDSPRITE.set_flip_h(true)
	
	position += velocity


func _on_Fireball_body_entered(body):
	if(body.is_in_group("player")):
		body.on_hurt()
		queue_free()
	elif(body is TileMap):
		queue_free()
	pass # Replace with function body.
