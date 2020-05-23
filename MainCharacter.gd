extends KinematicBody2D

const GRAVITY = 800
const WALK_SPEED = 150
const JUMP_SPEED = 350
const FRICTION = 30
onready var animated_sprite = get_node("AnimatedSprite")
onready var arm = get_node("Arm")


###########
#  var collision_info = move_and_collide(direction.normalized() * speed * delta)
# 	do not multiply by delta tho, it does this interallly
########################

var velocity = Vector2()

func _ready():
	set_physics_process(true)
	
func handle_animation():
	if(velocity.x > 0):
		animated_sprite.set_flip_h(false)
	elif(velocity.x < 0):
		animated_sprite.set_flip_h(true)
		
	if(velocity.y > 0): #falling
		animated_sprite.set_animation("falling")
	elif(velocity.y < 0): #jumping
		animated_sprite.set_animation("jumping")
	elif(velocity.x == 0):
		animated_sprite.set_animation("idle")
	else:
		animated_sprite.set_animation("walk")
	
	if (animated_sprite.animation == "walk"):
		if(animated_sprite.frame == 0 or animated_sprite.frame == 2):
			arm.position.y = 2
		else:
			arm.position.y = 0
	else:
		arm.position.y = 0


func _physics_process(delta):
	arm.look_at(get_global_mouse_position())
	
	velocity.y += delta * GRAVITY

	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0

	velocity = move_and_slide(velocity, Vector2(0, -1))
	handle_animation()
	
	if Input.is_action_just_pressed("ui_up"):
		if(is_on_floor()):
			velocity.y = -JUMP_SPEED
	elif is_on_floor():
		velocity.y = 0
	
func on_hurt():
	print("PLAYER HURT")
