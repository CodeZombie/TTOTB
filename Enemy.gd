extends KinematicBody2D
class_name Enemy
signal hurt

onready var ai_fsm =  FiniteStateMachine.new()
onready var Fireball = preload("res://Fireball.tscn")
onready var vision = get_node("Vision")
var node_in_vision = null
var node_to_follow = null
const FOLLOW_DISTANCE = 256
const GRAVITY = 800
const WALK_SPEED = 100
const JUMP_SPEED = 250
var velocity = Vector2()
var wander_direction = 0 #0 = left, 1 = right
	
#my states! :)
func state_wander() -> void:
	if(randf() > 0.95):
		wander_direction = (randi() % 3) - 1
		if(randf() > 0.5):
			if(is_on_floor()):
				velocity.y = -JUMP_SPEED
	velocity.x = (wander_direction) * WALK_SPEED
	
func state_follow_player() -> void:
	if(abs(velocity.x) < 1):
		if(is_on_floor()):
			velocity.y = -JUMP_SPEED
			
	var mc = get_node("../MainCharacter")
	var dir_x = position.direction_to(mc.get_position()).x
	velocity.x = dir_x * WALK_SPEED

func state_move_to_players_height() -> void:
	pass

func state_attack_player() -> void:
	# always face the player
	var mc = get_node("../MainCharacter")
	var dir_x = position.direction_to(mc.get_position()).x
	velocity.x = dir_x * (WALK_SPEED/4)
	
	if(randf() > .99):
		var fireball = Fireball.instance()
		fireball.set_direction(velocity.x)
		fireball.position = position
		get_tree().get_root().get_node("Scene").add_child(fireball)

func condition_near_player() -> bool:
	if(node_in_vision != null):
		node_to_follow = node_in_vision
		return true
	return false

func condition_not_near_player() -> bool:
	if(node_to_follow != null):
		if(get_global_position().distance_to(node_to_follow.get_global_position()) >= FOLLOW_DISTANCE):
			node_to_follow = null
			return true
		return false
	else:
		return true
	#return not condition_near_player()

func condition_player_in_attack_range() -> bool:
	var mc = get_node("../MainCharacter")
	if(mc != null):
		var mc_pos = mc.get_position()
		var distance = mc_pos.distance_to(self.get_position())
		if(distance < 64):
			return true
	return false

func condition_player_not_in_attack_range() -> bool:
	return not condition_player_in_attack_range()
	
func _ready(): 
	set_physics_process(true)
	ai_fsm.register_state(self, "wander", "state_wander")
	ai_fsm.register_state(self, "follow_player", "state_follow_player")
	ai_fsm.register_state(self, "attack_player", "state_attack_player")
	ai_fsm.register_transition(self, "wander", "follow_player", "condition_near_player")
	ai_fsm.register_transition(self, "follow_player", "wander", "condition_not_near_player")
	ai_fsm.register_transition(self, "follow_player", "attack_player", "condition_player_in_attack_range")
	ai_fsm.register_transition(self, "attack_player", "follow_player", "condition_player_not_in_attack_range")
	ai_fsm.set_default_state("wander")
	
	#Signals
	connect("hurt", self, "hurt")

func hurt():
	print("I AM HURT")

func handle_animation():
	if(velocity.x > 0):
		get_node("AnimatedSprite").set_flip_h(false)
	if(velocity.x < 0):
		get_node("AnimatedSprite").set_flip_h(true)
		
func _process(delta):
	#print(" Near Body body?: %b", condition_near_player())
	velocity.y += delta * GRAVITY
	ai_fsm.update()
	velocity = move_and_slide(velocity, Vector2(0, -1))
	handle_animation()

func _on_Vision_body_entered(body):
	node_in_vision = body

func _on_Vision_body_exited(body):
	if(node_in_vision != null):
		if(body.get_instance_id() == node_in_vision.get_instance_id()):
			node_in_vision = null
