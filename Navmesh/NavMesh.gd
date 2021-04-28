tool
extends Node2D
class_name NavMesh
#TODO:
#  - Implement jump_height functionality in the get_navigation_path method
#  - Set up an "autofill" method for the navmesh based on tiles
#  - Create a draw_path(path) method that draws an array of connected points.
#		This will be helpful for debugging, as the Actor method can call 
#			NavMesh.draw_path(my_path) in its draw method
#		Maybe make it so that the NavMesh automatically draws ALL paths it generates, and just
#			fade them out over time



export var show_in_game = false
export(Color, RGB) var waypoint_color = Color(.28, .55, .75) setget set_waypoint_color

var last_path = Array()

func _ready():
	update_navmesh_nodes()

func set_waypoint_color(new_color):
	waypoint_color = new_color
	for node in get_children():
		if node.has_method("clear_connections"):
			node.primary_color = waypoint_color
			
func update_navmesh_nodes():
	for node in get_children():
		if node.has_method("clear_connections"):
			node.primary_color = waypoint_color
			node.clear_connections()
			
	for node in get_children() :
		if node.has_method("update_connections"):
			node.update_connections()
	
func get_navigation_path(start_position, end_position, jump_height, move_speed):
	#todo: Have starting and ending positions exist between nodes.
	var start_node = null
	var end_node = null
	for node in get_children():
		if node.has_method("update_connections"):		#ensure node is a navmesh_node
			if start_node == null or node.global_position.distance_to(start_position) < start_node.global_position.distance_to(start_position):
				start_node = node
			if end_node == null or node.global_position.distance_to(end_position) < end_node.global_position.distance_to(end_position):
				end_node = node
	
	var visited_nodes = []
	var frontier = [create_waypoint(start_node, null)]
	var current = null
	
	while frontier.empty() == false:
		current = frontier[0]
		for child_node in current.node.connected_nodes:
			if visited_nodes.has(child_node) == false:
				if child_node.global_position.y > current.node.global_position.y - jump_height :
					frontier.append(create_waypoint(child_node, current))
				
		frontier.erase(current)
		visited_nodes.append(current.node)
		
		if(current.node == end_node):
			var step = current
			var path = [step.node.global_position]
			while(step.parent != null):
				step = step.parent
				path.append(step.node.global_position)
			path.invert()
			
			#remove first waypoint if its behind the start_position
			
#			if path.size() > 1:
#				if path[1].x > path[0].x:
#					if start_position.x > path[0].x:
#						path.pop_front()
#						#path.push_front(start_position)
#				elif path[1].x < path[0].x:
#					if start_position.x < path[0].x:
#						path.pop_front()
#						#path.push_front(start_position)
#				#remove last waypoint if its out of the way of the end_position
			if path.size() > 1:
				if path[-2].x > path[-1].x:
					if end_position.x > path[-1].x:
						path.pop_back()
				elif path[-2].x < path[-1].x:
					if end_position.x < path[-1].x:
						path.pop_back()
			#insert real end_position into the path
			path.push_back(end_position)
			
			if path.size() > 1:
				if path[1].x > path[0].x:
					if start_position.x > path[0].x:
						path.pop_front()
						#path.push_front(start_position)
				elif path[1].x < path[0].x:
					if start_position.x < path[0].x:
						path.pop_front()
			last_path = path
			return path

func create_waypoint(node, parent):
	return {
		'node' : node,
		'parent' : parent
	}


func _draw():
	for point in last_path:
		draw_circle(point, 8, Color(255,0,0))
	
func _process(dt):
	update()
