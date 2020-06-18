extends Node2D
class_name NavMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	
func get_navigation_path(start_position, end_position, jump_height, move_speed):
	var start_node = null
	var end_node = null
	for node in get_children():
		if start_node == null or node.global_position.distance_to(start_position) < start_node.global_position.distance_to(start_position):
			start_node = node
		if end_node == null or node.global_position.distance_to(end_position) < end_node.global_position.distance_to(end_position):
			end_node = node
	
	start_node.draw_color = Color(0, 255, 0)
	end_node.draw_color = Color(0, 0, 255)
	
	var visited_nodes = []
	var frontier = [create_waypoint(start_node, null)]
	var current = null
	
	while frontier.empty() == false:
		
		current = frontier[0]
		for child_node in current.node.connected_nodes:
			if visited_nodes.has(child_node) == false:
				frontier.append(create_waypoint(child_node, current))
		frontier.erase(current)
		visited_nodes.append(current.node)
		if(current.node == end_node):
			var step = current
			var path = [step.node]
			while(step.parent != null):
				step = step.parent
				path.append(step.node)
			
			for i in range(len(path)):
				var val = (i+1)/len(path)
				path[i].draw_color = Color(0, 0, 0)
				path[i].update()
				
		


func create_waypoint(node, parent):
	return {
		'node' : node,
		'parent' : parent
	}
