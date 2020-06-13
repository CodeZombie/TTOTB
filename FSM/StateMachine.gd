extends Node
class_name StateMachine

export(NodePath) var active_state_nodepath
onready var active_state = get_node(active_state_nodepath)

func _process(delta):
	#for the active state node, run the on_update_method.
	self.active_state.on_update()
	#for each child in this state, check to see if a transition has occurred.
	var new_state = self.active_state.get_state_to_transition_to()
	if(new_state != null):
		self.active_state.on_exit()
		self.active_state = new_state
		self.active_state.on_enter()
