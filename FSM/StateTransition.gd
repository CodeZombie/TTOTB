extends Node
class_name StateTransition

export(NodePath) var target_nodepath
onready var target = get_node(target_nodepath)

export(NodePath) var to_state_nodepath
onready var to_state = get_node(to_state_nodepath)

export(String) var condition_method_name = null
onready var condition_method = funcref(self.target, self.condition_method_name)

func can_transition():
	return self.condition_method.call_func()
