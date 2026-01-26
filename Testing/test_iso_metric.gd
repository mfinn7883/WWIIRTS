extends Node2D

var map_state_h1: Array[Vector2i] = []
var map_state_h2: Array[Vector2i] = []

@onready var h1 = $TileMapLayer
@onready var h2 = $TileMapLayer2

var reflection_60: Transform2D = Transform2D(1.0472, Vector2(0, 0))

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("test")):
		rotate_camera()

func rotate_camera() -> void:
	
	map_state_h1 = h1.get_used_cells()
	map_state_h2 = h2.get_used_cells()
	
	h1.clear()
	h2.clear()
	
	
	for cell: Vector2i in map_state_h1:
		var new_cell: Vector2i = reflect_cell(cell, h1)
		if (cell == Vector2i(0, 0)): print(cell, "-->", new_cell)
		h1.set_cell(new_cell, 0, Vector2i(0, 0))
	
	for cell: Vector2i in map_state_h2:
		var new_cell: Vector2i = reflect_cell(cell, h2)
		h2.set_cell(new_cell, 0, Vector2i(0, 0))

func reflect_cell(cell: Vector2i, tilemaplayer: TileMapLayer) -> Vector2i:
	var world_pos: Vector2 = tilemaplayer.map_to_local(cell) - Vector2(63.5, 55.0)
	if (cell == Vector2i(0, 0)): print(world_pos)
	var reflected = reflection_60 * world_pos + Vector2(63.5, 55.0)
	if (cell == Vector2i(0, 0)): print(reflected)
	return tilemaplayer.local_to_map(reflected)
