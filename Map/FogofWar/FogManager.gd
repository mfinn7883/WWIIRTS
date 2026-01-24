extends Node

var fog_data: Dictionary = {} # Vector2i: bool
var map_width: int = 128
var map_height: int = 128

func get_tile_vision_cost(_tile_pos: Vector2i) -> int:
	return 1 

func update_fog_vision(all_units: Array):
	for pos in fog_data.keys():
		fog_data[pos] = false
		
	for unit in all_units:
		_run_hex_bfs_vision(unit.grid_pos, unit.vision_range)

func _run_hex_bfs_vision(start_pos: Vector2i, max_range: int):
	var visited_costs: Dictionary = {}
	var queue: Array = [[start_pos, 0]]
	
	fog_data[start_pos] = true
	visited_costs[start_pos] = 0
	
	while queue.size() > 0:
		queue.sort_custom(func(a, b): return a[1] < b[1])
		var current = queue.pop_front()
		
		var current_pos = current[0]
		var current_cost = current[1]
		
		# --- ADJUSTED FOR 6 HEX NEIGHBORS ---
		# Note: These offsets vary if you use Offset (Odd/Even) vs Axial.
		# This set is the standard for Axial/Cubic coordinates:
		var neighbors = [
			current_pos + Vector2i(1, 0),   # East
			current_pos + Vector2i(1, -1),  # North-East
			current_pos + Vector2i(0, -1),  # North-West
			current_pos + Vector2i(-1, 0),  # West
			current_pos + Vector2i(-1, 1),  # South-West
			current_pos + Vector2i(0, 1)    # South-East
		]
		
		for neighbor in neighbors:
			if is_outside_map(neighbor):
				continue
				
			var total_cost = current_cost + get_tile_vision_cost(neighbor)
			
			if total_cost <= max_range:
				if not visited_costs.has(neighbor) or total_cost < visited_costs[neighbor]:
					visited_costs[neighbor] = total_cost
					fog_data[neighbor] = true
					queue.append([neighbor, total_cost])

func is_outside_map(pos: Vector2i) -> bool:
	return pos.x < 0 or pos.x >= map_width or pos.y < 0 or pos.y >= map_height
