tool
class_name NavMesh_Node
extends Node2D

export(Array, NodePath) var connected_node_paths = Array() setget set_connected_node_paths

onready var font = Control.new().get_font("res://Roboto.ttf")
var primary_color = Color(.28, .55, .75)
var connected_nodes = Array()

func set_connected_node_paths(new_connected_node_paths):
	connected_node_paths = new_connected_node_paths
	if Engine.editor_hint:
		if get_parent() != null:
			if get_parent().has_method("update_navmesh_nodes"):
				get_parent().update_navmesh_nodes()
			else:
				push_error("xxxNavMesh_Node '" + name + "' is not a child of a NavMesh Instance")

func _ready():
	if !get_parent().has_method("update_navmesh_nodes"):
		push_error("(_ready()) NavMesh_Node '" + name + "' is not a child of a NavMesh Instance")
		
func clear_connections():
	connected_nodes.clear()

func update_connections():
	for node_path in connected_node_paths:
		if !node_path.is_empty():
			var other = get_node(node_path)
			if other != null:
				if other.get_parent() != get_parent():
					push_error("Connected Navmesh_Nodes '" + other.name + "' and '" + name + "' do not share the same parent.")
					continue
					
				if !other.has_method("add_connection"):
					push_error("Node '" + other.name + "' connected to '" + name + "' is not a NavMesh_Node.")
					continue
					
				add_connection(other)
				other.add_connection(self)
			else:
				push_error("NodePath '" + node_path + "' connected to '" + name + "' could not be found.")

func _draw():
	if Engine.editor_hint or get_parent().show_in_game:
		for node in connected_nodes:
			draw_line(Vector2(0, 0), node.global_position - global_position, primary_color, 2)
			
		draw_line(Vector2(-12, 0), Vector2(12, 0), primary_color, 3)
		draw_line(Vector2(0, -12), Vector2(0, 12), primary_color, 3)
		draw_circle(Vector2(0,0), 4, primary_color)

func add_connection(other):
	for neighbor in connected_nodes:
		if other == neighbor:
			return
	connected_nodes.append(other)

func _process(dt):
	update()
