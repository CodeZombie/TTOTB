tool
extends Node2D
class_name NavMesh_Node
export(NodePath) var connected_to_1
export(NodePath) var connected_to_2

# The problem is calling <navmesh_node>.connected_nodes from a different node ALWAYS returns an empty array.
var draw_color = Color(255, 0, 0)
var connected_nodes = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	if connected_to_1.is_empty() == false:
		var con_1 = get_node(connected_to_1)
		add_neighbor(con_1)
		con_1.add_neighbor(self)
		
	if connected_to_2.is_empty() == false:
		var con_2 = get_node(connected_to_2)
		add_neighbor(con_2)
		con_2.add_neighbor(self)

func _draw():
	
	if Engine.is_editor_hint():
		draw_line(Vector2(-16, 0), Vector2(16, 0), draw_color, 3)
		draw_line(Vector2(0, -16), Vector2(0, 16), draw_color, 3)
		for other in connected_nodes:
			draw_line(Vector2(0, 0), other.position - global_position, Color(255, 0, 0, .2), 1)

func add_neighbor(other):
	for neighbor in connected_nodes:
		if other == neighbor:
			return
	connected_nodes.append(other)

func _update(delta):
	_draw()
