extends Node
class_name FiniteStateMachine

var states = []
var current_state = 0

func register_state(object, state_name, update_function_name = null, enter_state_function_name = null, leave_state_function_name = null):
	#error checking...
	if(object == null):
		push_error("Error registering state in FiniteStateManager: Object is null")
		return
		
	if (get_state_id(state_name) != -1):
		push_error("Error registering state in FiniteStateManager with name %s: state already exists" % state_name)
		return 
		
	var update_function = null
	if(update_function_name != null):
		update_function = funcref(object, update_function_name)
		
		
	var enter_state_function = null
	if(enter_state_function_name != null):
		enter_state_function = funcref(object, enter_state_function_name)
	
	
	
	var leave_state_function = null
	if(leave_state_function_name != null):
		leave_state_function = funcref(object, leave_state_function_name)
	
	var new_state = {
			"state_name": state_name,
			"update_function": update_function,
			"enter_state_function": enter_state_function,
			"leave_state_function": leave_state_function,
			"transitions": []
		}
	states.append(new_state)
	
func register_transition(object, from_state_name, to_state_name, condition_function_name):
	if(object == null):
		push_error("Error registering state in FiniteStateManager: Object is null")
		return
	
	var condition_function = funcref(object, condition_function_name)
	if(condition_function == null):
		push_error("Error registering transition in FiniteStateManager: %s is not a valid function" % condition_function_name)
	
	var from_state_id = get_state_id(from_state_name)
	if(from_state_id == -1):
		push_error("Error registering transition in FiniteStateManager: From state with name %s is not registered." % from_state_name)
		return
	
	var to_state_id = get_state_id(to_state_name)
	if(to_state_id == -1):
		push_error("Error registering transition in FiniteStateManager: To state with name %s is not registered." % from_state_name)
		return
	
	states[from_state_id].transitions.append({
		"to_state_id": to_state_id,
		"condition_function": condition_function
	})

func update():
	if(states.empty()):
		return
	if(states[current_state].update_function != null):
		states[current_state].update_function.call_func()
	for transition in states[current_state].transitions:
		if(transition.condition_function.call_func() == true):
			
			if(states[current_state].leave_state_function != null):
				states[current_state].leave_state_function.call_func()
				
			current_state = transition.to_state_id
			
			if(states[current_state].enter_state_function != null):
				states[current_state].enter_state_function.call_func()
			break
	
func get_state_id(state_name):
	for i in range(0, states.size()):
		if(states[i].state_name == state_name):
			return i
	return -1

func set_default_state(state_name):
	var default_state_id = get_state_id(state_name)
	if(default_state_id == -1):
		push_error("Error setting default state in FiniteStateManager: State with name %s is not registered" % state_name)
		return
	current_state = default_state_id
