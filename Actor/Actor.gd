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
	process_animation()
	
func _physics_process(delta):
	walk_path()	
	velocity.y += delta * gravity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	#if walking_a_path() and velocity == Vector2(0, 0):
	#	jump()
	if jumping and is_on_floor():
		jumping = false

func jump():
	if not jumping and is_on_floor():
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
	var node_trigger_distance = 8
	
	#If we're close to the next node...
	if global_position.distance_to(path[0].global_position) <= node_trigger_distance*2 and is_on_floor():
		path.pop_front()
		if path.empty():
			walk(0)
			return path
		

	var x_direction = velocity.normalized().x #Default direction is to just keep moving in the previous direction.
	if abs(self.global_position.x - path[0].global_position.x) >= node_trigger_distance:
		if self.global_position.x <= path[0].global_position.x:	#If the goal is to the right
			x_direction = 1	#Move right
			print("Right")
		else:
			print("Leftf")
			x_direction = -1 #Move left
	print(x_direction)
	#If we're not in the middle of jumping, and our next move will cause us to fall:
	if not jumping and fall_raycast.is_colliding() == false:
		jump()
		x_direction = 0
				
	#if the next node is above us, jump
	if path[0].global_position.y - global_position.y < -16:
		jump()
		
	if not path.empty():
		walk(x_direction)
	else:
		walk(0)
		
	return path
