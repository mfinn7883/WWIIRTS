extends Node2D

var map_state_h1: Array[Vector2i] = []
var map_state_h2: Array[Vector2i] = []

@onready var h1 = $TerrainLayer
@onready var h2 = $TerrainLayer2

var reflection_60: Transform2D = Transform2D(1.0472, Vector2(0, 0))

var rot: int = 0

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
		h1.set_cell(new_cell, 1, Vector2i(0, 0))
	
	for cell: Vector2i in map_state_h2:
		var new_cell: Vector2i = reflect_cell(cell, h2)
		h2.set_cell(new_cell, 1, Vector2i(0, 0))


func reflect_cell(cell: Vector2i, tilemaplayer: TileMapLayer) -> Vector2i:
	var world_pos = tilemaplayer.map_to_local(cell)
	var reflected = reflection_60 * world_pos
	return tilemaplayer.local_to_map(reflected)
