extends KinematicBody2D
export var gravity = 800
export var walk_speed = 150
export var jump_speed = 350
export var friction = 30
onready var animated_sprite = get_node("AnimatedSprite")
onready var arm = get_node("Arm")
var velocity = Vector2()
var arm_y_offset = 0

signal hold_trigger()
signal release_trigger()

func _ready():
	arm_y_offset = arm.position.y
	set_physics_process(true)

func process_animation():
	if(velocity.x > 0):
		animated_sprite.set_flip_h(false)
	elif(velocity.x < 0):
		animated_sprite.set_flip_h(true)
		
	if(velocity.y > 0):
		animated_sprite.set_animation("falling")
	elif(velocity.y < 0):
		animated_sprite.set_animation("jumping")
	elif(velocity.x == 0):
		animated_sprite.set_animation("idle")
	else:
		animated_sprite.set_animation("walking")
	
	if (animated_sprite.animation == "walking"):
		if(animated_sprite.frame == 0 or animated_sprite.frame == 2):
			arm.position.y = arm_y_offset + 1
		else:
			arm.position.y = arm_y_offset
	else:
		arm.position.y = arm_y_offset

func _process(delta):
	process_animation()
	
func _physics_process(delta):
	velocity.y += delta * gravity
	velocity = move_and_slide(velocity, Vector2(0, -1))

func jump():
	if(is_on_floor()):
		velocity.y = -jump_speed
		
func walk(dir):
	velocity.x = dir * walk_speed