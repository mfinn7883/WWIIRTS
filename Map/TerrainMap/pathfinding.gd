class_name pathfinding extends Resource

static var e: float = 2.71828

static func bfs_to_destination(start: Vector2i, destination: Vector2i) -> Array[Vector2i]:
	var terrain_map = TerrainMap.get_instance()
	
	# Can't reach dest
	if (!is_tile_traversable(destination)):
		return []
	
	var current: Vector2i
	var queue: priority_queue = priority_queue.new()
	var tile_to_prev: Dictionary = {}
	var visited: Dictionary = {}
	var found: bool = false
	queue.insert_element(start, 0)
	visited[start] = 0
	const MAX_TRIES: int = 10000
	var tries: int = 0
	
	while !queue.is_empty():
		tries += 1
		if (tries >= MAX_TRIES):
			break
		current = queue.pop_back()
		if current == destination:
			found = true
			break
		for tile: Vector2i in terrain_map.get_surrounding_cells(current):
			var terrain_mult: int = 1
			var temp_dist: float =  terrain_map.map_to_local(current).distance_to(terrain_map.map_to_local(tile))
			var current_dist: float = visited[current] + (temp_dist / terrain_mult)
			if is_tile_traversable(tile) and !visited.has(tile):
				queue.insert_element(tile, current_dist)
				visited[tile] = current_dist
				tile_to_prev[tile] = current
	if found:
		return create_route_from_tile_to_prev(start, destination, tile_to_prev)
	else:
		return []

static func is_tile_traversable(tile: Vector2i) -> bool:
	var terrain_map = TerrainMap.get_instance()
	var atlas: Vector2i = terrain_map.get_cell_atlas_coords(tile)
	return atlas != Vector2i(6, 0) and atlas != Vector2i(7, 0) and atlas != Vector2i(-1, -1)

static func create_route_from_tile_to_prev(start: Vector2i, destination: Vector2i, tile_to_prev: Dictionary) -> Array[Vector2i]:
	var current: Vector2i = destination
	var route: Array[Vector2i] = []
	while current != start:
		route.push_front(current)
		current = tile_to_prev[current]
	return route

static func aStar(start: Vector2i, destination: Vector2i) -> Array[Vector2i]:
	var terrain_map = TerrainMap.get_instance()
	
	# Can't reach dest
	if (!is_tile_traversable(destination)):
		return []
	
	var current: Vector2i
	var queue: priority_queue = priority_queue.new()
	var tile_to_prev: Dictionary = {}
	var visited: Dictionary = {}
	var found: bool = false
	queue.insert_element(start, 0)
	visited[start] = 0
	const MAX_TRIES: int = 100000
	var tries: int = 0
	
	var get_h_cost = func(_pos: Vector2i) -> float:
		return 0 # TODO: FIX HEURISTIC
		#return terrain_map.map_to_local(pos).distance_to(terrain_map.map_to_local(destination))
	
	var get_tile_cost = func(s_tile: Vector2i, e_tile: Vector2i) -> float:
		var h1 = terrain_map.get_height_of_cell(s_tile)
		var h2 = terrain_map.get_height_of_cell(e_tile)
		
		return pow(e, h2 - h1)
	
	while !queue.is_empty():
		tries += 1
		if (tries >= MAX_TRIES):
			print("TOO")
			break
		current = queue.pop_back()
		if current == destination:
			found = true
			break
		for tile: Vector2i in terrain_map.get_surrounding_cells(current):
			var base_cost: float = visited[current] + get_tile_cost.call(current, tile)
			var h_cost: float = get_h_cost.call(tile)
			if is_tile_traversable(tile) and (!visited.has(tile) or visited[tile] > base_cost):
				queue.insert_element(tile, base_cost + h_cost)
				visited[tile] = base_cost
				tile_to_prev[tile] = current
	if found:
		return create_route_from_tile_to_prev(start, destination, tile_to_prev)
	else:
		return []
