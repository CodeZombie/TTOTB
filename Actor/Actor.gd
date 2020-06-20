extends KinematicBody2D
export var gravity = 800
export var walk_speed = 150
export var run_speed = 200
export var jump_speed = 350
export var friction = 30
onready var animated_sprite = get_node("AnimatedSprite")
onready var arm = get_node("Arm")
onready var fall_raycast = get_node("FallRaycast")
onready var collision_shape = get_node("CollisionShape")
var velocity = Vector2()
var arm_y_offset = 0
var path = []
var jumping = false

signal hold_trigger()
signal release_trigger()
signal drop_item()
signal equip_item(parent)

func _ready():
	arm_y_offset = arm.position.y
	set_physics_process(true)

func walking_a_path():
	return path.empty() == false
	
func set_path(path):
	print(path)
	self.path = path

func process_animation():
	var fall_raycast_x_distance = abs(fall_raycast.get_position().x)
	if(velocity.x > 0):
		animated_sprite.set_flip_h(false)
		fall_raycast.set_position(Vector2(fall_raycast_x_distance, 0))
	elif(velocity.x < 0):
		animated_sprite.set_flip_h(true)
		fall_raycast.set_position(Vector2(fall_raycast_x_distance * -1, 0))
		
	if(velocity.y > 0):
		animated_sprite.set_animation("falling")
	elif(velocity.y < 0):
		animated_sprite.set_animation("jumping")
	elif(velocity.x == 0):
		animated_sprite.set_animation("idle")
	else:
		animated_sprite.set_animation("walking")
		animated_sprite.speed_scale = abs(velocity.x)/150
		#animated_sprite.set_animation_speed("walking", velocity.x/20)
	
	if (animated_sprite.animation == "walking"):
		if(animated_sprite.frame == 0 or animated_sprite.frame == 2):
			arm.position.y = arm_y_offset + 1
		else:
			arm.position.y = arm_y_offset
	else:
		arm.position.y = arm_y_offset

func _process(delta):
	walk_path()	
	process_animation()
	
func _physics_process(delta):
	velocity.y += delta * gravity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if jumping and is_on_floor():
		jumping = false

func jump():
	if(is_on_floor()):
		velocity.y = -jump_speed
		jumping = true

func halt_jump():
	if velocity.y < 0:
		velocity.y = velocity.y/2
		
func walk(dir):
	velocity.x = dir * walk_speed
	
func run(dir):
	#if is_on_floor():
	velocity.x = dir * run_speed


func _draw():
	draw_rect(Rect2(Vector2(0,0), collision_shape.shape.extents), Color(0, 255, 0))
	
	#collision_shape.extents

func walk_path():
	if self.path == null or self.path.empty():
		return
	self.path[0].draw_color = Color(0, 255, 0)
	self.path[0].update()
	#get next node in path
	#move toward the node
	#	if your next move in that direction will cause you to fall:
	#		if your goal is above you: Jump and move in that direction
	#		if your goal is below you: Move forward enough to fall, and wait until you hit the ground.
	#Once you touch the target node, remove it from the path and Continue;
	#once at the last or second last node, start checking for path completion.
	#return the remaining path
	print(jumping)
	var x_direction = -1	#Move left
	if self.global_position.x < path[0].global_position.x:	#If the goal is to the right
		x_direction = 1	#Move right
	if not jumping:
		if fall_raycast.is_colliding() == false: #If our next move will cause us to fall:
				jump()
				x_direction = 0
	if abs(global_position.x - path[0].global_position.x) < 8:
		path.pop_front()
	if not path.empty():
		walk(x_direction)
	else:
		walk(0)
		
	return path
