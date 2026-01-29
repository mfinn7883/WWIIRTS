class_name RoadMap extends Resource

static var singleton_instance: RoadMap = null

func _init() -> void:
	assert(singleton_instance == null, "Road map is already set")
	singleton_instance = self

static func is_valid() -> bool:
	return singleton_instance != null

static func get_instance() -> RoadMap:
	assert(singleton_instance != null, "Road map has not been created yet")
	return singleton_instance

# TODO
var road_dictionary: Dictionary[Vector2i, int] = {}

func place_tile(tile_pos: Vector2i, atlas: Vector2i) -> void:
	TerrainMap.get_instance().replace_cell(tile_pos, atlas, 1)

func place_road(tile_pos: Vector2i) -> void:
	road_dictionary[tile_pos] = 1
	fix_tile(tile_pos, true)

func get_road_value(tile_pos: Vector2i) -> int:
	if !road_dictionary.has(tile_pos): return 0
	return road_dictionary[tile_pos]

func nCr(n: int, r: int) -> int:
	if r > n:
		return 0
	return factorial(n) / (factorial(r) * factorial(n - r))

func factorial(n: int) -> int:
		if (n == 0 || n == 1): return 1;
		var result: int = 1
		for i: int in range(2, n + 1):
			result *= i
		return result

func fix_tile(center: Vector2i, repeating: bool):
	var tiles: Array = TerrainMap.get_instance().get_surrounding_cells(center) # Starts at 2
	var offset: int = 4
	var y: int = -1 #Also is 1 less than the number of connections
	var connections: Array = []
	for i: int in range(0, tiles.size()):
		var tile: Vector2i = tiles[(i + offset) % tiles.size()]
		var val: int = get_road_value(tile)
		if (val > 0):
			if (repeating): fix_tile(tile, false)
			y += 1
			connections.push_back(true)
		else:
			connections.push_back(false)
		
	
	#if (get_cell_atlas_coords(center) == Vector2i(1, 5)): 
		#return
	

	if (y == -1):
		place_tile(center, Vector2i(6, 0)) #Just dot
		return
	elif (y == 5):
		place_tile(center, Vector2i(0, 5)) #5 tile
		return
	

	var uncounted_connections: int = y
	var index: int = 0
	var current: int = 0
	for val: bool in connections:
		if (val):
			uncounted_connections -= 1;
			if (uncounted_connections == -1): break
		else:
			index += nCr(5 - current, uncounted_connections)
		
		current += 1
	
	if (!pathfinding.is_tile_traversable(center)):
		place_tile(center, Vector2i(index, y));
	else:
		place_tile(center, Vector2i(index, y));
	
