extends KinematicBody2D
export var gravity = 800
export var walk_speed = 150
export var run_speed = 200

export var jump_height = 100
export var friction = 30

export(Texture) var gibsTexture

onready var animated_sprite = get_node("AnimatedSprite")
onready var arm = get_node("Arm")
onready var hand = get_node("Arm/Hand")
onready var fall_raycast = get_node("FallRaycast")
onready var collision_shape = get_node("CollisionShape")
onready var pickup_collider = get_node("PickupCollider")

const GibScene = preload("res://Actor/Gib.tscn")

var velocity = Vector2()
var arm_y_offset = 0
var path = []
var jumping = false
var equipped_item = false

var last_distance_to_next_node = -1

var health = 100

signal hold_trigger()
signal release_trigger()
signal drop_item()

func _ready():
	arm_y_offset = arm.position.y
	set_physics_process(true)

func walking_a_path():
	return path.empty() == false
	
func shot(sourcePosition):
	health -= 15
	if health <= 0:
		explode(2, 3, (global_position - sourcePosition).normalized())
	
func explode(hframes, vframes, direction):
	for n in vframes * hframes:
		var gib = GibScene.instance()
		gib.initialize(global_position, hframes, vframes, 2, n, animated_sprite.frames.animations[0].frames[0], direction, rand_range(200, 550), animated_sprite.flip_h)
		get_parent().add_child(gib)
		
	for n in 16:
		var gib = GibScene.instance()
		print(gibsTexture)
		gib.initialize(global_position, 4, 4, 1, n, gibsTexture, direction, rand_range(200, 550), false)
		get_parent().add_child(gib)

	get_parent().remove_child(self)
	pass
	
func set_path(path):
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
	
func get_pickupable_items():
	var pickupable = []
	for body in pickup_collider.get_overlapping_bodies():
		if body.is_in_group("pickupable"):
			if !body.is_equipped():
				pickupable.append(body)
	return pickupable

func equip(item):
	if item.is_in_group("pickupable"):
		item.equip(self, hand)
		equipped_item = true
		
func drop():
	if equipped_item:
		emit_signal("drop_item", self)
		equipped_item = false
	
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
		velocity.y = -sqrt(2.0 * gravity * jump_height)
		jumping = true

func halt_jump():
	if velocity.y < 0:
		velocity.y = velocity.y/2
		
func walk(dir):
	velocity.x = dir * walk_speed
	
func run(dir):
	#if is_on_floor():
	velocity.x = dir * run_speed


func will_land_on_point(point):
	var direction = 1
	if(global_position.x > point.x):
		direction = -1
		
	var trajectory_point = Vector2(0,0)
	var max_attempts = 256
	var attempts = 0

	while true:
		if attempts >= max_attempts:
			return false
			
		var x = trajectory_point.x + direction
		var t = (x+walk_speed) / walk_speed
		var y = -(t*t*((-gravity)*.5)) + (t*(-gravity)) + (gravity*.5)
		trajectory_point = Vector2(x,y)
		#see if this trajectory point has hit or missed the point:
		if direction == 1:
			if to_global(trajectory_point).x >= point.x: #if the trajectory has passed the point
				if to_global(trajectory_point).y <= point.y: #if we're at or above the Point
					return true
				else:
					return false
		else:
			if to_global(trajectory_point).x <= point.x:
				if to_global(trajectory_point).y <= point.y:
					return true
				else:
					return false
		attempts += 1
	return false

func walk_path():
	if self.path == null or self.path.empty():
		return
	
	#self.path[0].update()
	var node_trigger_distance = 32
	
	#If we're close to the next node...
	#if global_position.distance_to(path[0]) <= node_trigger_distance and is_on_floor():
	if abs(global_position.x - path[0].x) < 4.0 and abs(global_position.y - path[0].y) < node_trigger_distance and is_on_floor():
		print("We're close to the next node. Continue..." + String(path.size()))
		path.pop_front()
		last_distance_to_next_node = -1
		if path.empty():
			print("Path empty. Ending")
			walk(0)
			last_distance_to_next_node = -1
			return path
	
	if last_distance_to_next_node == -1 or last_distance_to_next_node > global_position.distance_to(path[0]):
		last_distance_to_next_node = global_position.distance_to(path[0])
		
	#this 16 should be replaced with jump_height when that becomes available.
	if last_distance_to_next_node - global_position.distance_to(path[0]) < -16 and not jumping:
		print("Path failed.")
		walk(0)
		last_distance_to_next_node = -1
		set_path(null)
		#if we are to do something on path fail, it should be here.
		return path

	var x_direction = velocity.normalized().x #Default direction is to just keep moving in the previous direction.
	if abs(self.global_position.x - path[0].x) > 4.0:
	#print(String(global_position.x) + " " + String(path[0].x) + " " + String(is_on_floor()))
		if self.global_position.x < path[0].x:	#If the goal is to the right
			x_direction = 1	#Move right
		else:
			x_direction = -1 #Move left
	else:
		x_direction = 0
		
	var will_land_on_next_node = will_land_on_point(path[0])
	
	#If we're not in the middle of jumping, and our next move will cause us to fall:
	if not jumping and not fall_raycast.is_colliding() and not will_land_on_next_node:
		print("We're about to fall. Jump.")
		jump()
		#x_direction = 0
				
	#if the next node is above us, jump
	if path[0].y - global_position.y < -16:
		print("Its above us. Jump")
		jump()
		
	if jumping:
		if will_land_on_next_node:
			halt_jump()
		
	if not path.empty():
		walk(x_direction)
	else:
		walk(0)
		
	return path
