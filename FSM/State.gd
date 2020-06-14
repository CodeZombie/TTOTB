extends Node
class_name State

export(NodePath) var target_nodepath
onready var target = get_node(target_nodepath)

export(String) var on_enter_method_name
var on_enter_method = null

export(String) var on_update_method_name
var on_update_method = null

export(String) var on_exit_method_name
var on_exit_method = null

func _ready():
	if target == null:
		push_error("State 'Target' cannot resolve to null")
	else:
		if not on_enter_method_name.empty():
			self.on_enter_method = funcref(self.target, self.on_enter_method_name)
			
		if not on_update_method_name.empty():
			self.on_update_method = funcref(self.target, self.on_update_method_name)
			
		if not on_exit_method_name.empty():
			self.on_exit_method = funcref(self.target, self.on_exit_method_name)
		
func on_enter():
	if not self.on_enter_method == null:
		self.on_enter_method.call_func()
	
func on_update():
	if not self.on_update_method == null:
		print(self.on_update_method)
		self.on_update_method.call_func()

func on_exit():
	if not self.on_exit_method == null:
		self.on_exit_method.call_func()
		
func get_state_to_transition_to():
	for transition in get_children():
		if transition.can_transition():
			return transition.to_state
	return null
