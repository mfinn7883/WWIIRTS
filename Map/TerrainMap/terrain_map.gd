class_name TerrainMap extends Node2D

# --- Configuration ---
const WATER_CUTOFF: float = 3.0
@export var map_width: int = 128
@export var map_height: int = 128
@export var noise_seed: int = 5566789 # Change this for a new map
@export var max_height: int = 10

class TileInfo:
	var atlas: Vector2i
	var height: int
	
	func _init(p_atlas: Vector2i, p_height: int) -> void:
		atlas = p_atlas
		height = p_height
		
var terrain_grid: Dictionary[Vector2i, TileInfo] = {}
var terrain_layers: Array[TileMapLayer] = []

var tileset: TileSet = TileSet.new()

static var singleton_instance: TerrainMap = null

static func get_instance() -> TerrainMap:
	assert(singleton_instance != null, "The TerrainMap has not been created yet")
	return singleton_instance

# --- Noise Parameters ---
var noise = FastNoiseLite.new()
var height_noise = FastNoiseLite.new()

func _ready() -> void:
	assert(singleton_instance == null, "A terrain map has already been created, only 1 is allowed")
	tileset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tileset.tile_layout = TileSet.TILE_LAYOUT_STACKED
	tileset.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_VERTICAL
	tileset.tile_size = Vector2i(127, 110)
	
	var source = TileSetAtlasSource.new()
	source.texture = load("res://Resources/MapAtlasTextures/big_isometric_map.png")
	source.margins = Vector2i(0, 32)
	source.texture_region_size = Vector2i(128, 224)
	
	for i in range(0, 8):
		for j in range(0, 3):
			source.create_tile(Vector2i(i, j))
	source.create_tile(Vector2i(0, 3))
	tileset.add_source(source)
	
	var road_source = TileSetAtlasSource.new()
	road_source.texture = load("res://Resources/MapAtlasTextures/roads_atlas.png")
	road_source.texture_region_size = Vector2i(128, 256)
	
	for i in range(0, 20):
		for j in range(0, 3):
			road_source.create_tile(Vector2i(i, j))
	tileset.add_source(road_source)
	
	
	for i in range(0, max_height):
		var layer = TileMapLayer.new()
		layer.tile_set = tileset
		layer.z_index = 0
		terrain_layers.append(layer)
		#layer.position = Vector2i(1 * i, -33 * i)
		layer.position = Vector2i(1 * i, -66 * i)
		layer.y_sort_origin = 66 * i
		layer.y_sort_enabled = true
		add_child(layer)
	
	singleton_instance = self
	
	generate_map()
	var thread = Thread.new()
	thread.start(generate_roads.bind())

func get_layer(height: int) -> TileMapLayer:
	if (height < max_height): return terrain_layers[height]
	return null

func generate_map() -> void:
	# Higher value, bigger mountains
	const MOUNTAINNESS = 1.3
	# 1. Initialize Noise
	noise.seed = noise_seed if noise_seed != 0 else randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.03 # Higher = more "zoomed out" / chaotic
	
	height_noise.seed = noise_seed if noise_seed != 0 else randi()
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.frequency = 0.01
	
	# 2. Iterate through the grid
	for x in range(map_width):
		for y in range(map_height):
			# get_noise_2d returns a value between 0 and 2.0
			var noise_val = noise.get_noise_2d(x, y) + 1
			
			# redistribute values for height
			var h_val = pow(noise_val, MOUNTAINNESS)
			
			# 3. Determine terrain based on thresholds
			place_terrain(x, y, h_val)

func place_terrain(x: int, y: int, h_val: float) -> void:
	# TODO: MAKE SURE THAT HEIGHT IS abs(height - MAX(HEIGHT_OF_SURROUNDING_TILES)) <= 1
	
	# 0 - 10
	var height: float = (h_val) * 5.0
	
	# Useful when ratios are right but need to shift b/c of water
	const SHIFT_FACTOR: float = 0.75
	
	# Logic for mapping noise values to terrain
	if height < WATER_CUTOFF:
		# Water
		set_cell(Vector2i(x,y), Vector2i(6,0), int(WATER_CUTOFF))
	elif height < (4.2 - SHIFT_FACTOR):
		# Sand
		set_cell(Vector2i(x,y), Vector2i(0,2), floor(height))
	elif height < (4.8 - SHIFT_FACTOR):
		#Marsh
		set_cell(Vector2i(x,y), Vector2i(7,1), floor(height))
	elif height < (5.3 - SHIFT_FACTOR):
		if randi_range(0,25) != 0:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(0,0), floor(height))
		else:
			#Hill
			set_cell(Vector2i(x,y), Vector2i(4,0), floor(height))
	elif height < (8.0 - SHIFT_FACTOR):
		var rand_num = randi_range(0, 99)
		if rand_num < 4:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(0,0), floor(height))
		elif rand_num < 15:
			# Sparse Forest
			set_cell(Vector2i(x,y), Vector2i(1,0), floor(height))
		else:
			# Fores
			set_cell(Vector2i(x,y), Vector2i(2, 0), floor(height))
	else:
		if (randi_range(0, 5) == 0):
			#Forest Hill
			set_cell(Vector2i(x,y), Vector2i(4,0), floor(height))
		else:
			#Hill
			set_cell(Vector2i(x,y), Vector2i(3,0), floor(height))

func generate_roads() -> void:
	while !RoadMap.is_valid():
		OS.delay_msec(10)
	
	var randPt1: Vector2i = Vector2i(0, floor(map_height / 3.0 + 10))
	var randPt2: Vector2i = Vector2i(map_width - 1, floor(map_height / 3.0 + 10))
	
	place_road(randPt1, randPt2)
	
	randPt1 = Vector2i(0, floor(2.0 * map_height / 3.0))
	randPt2 = Vector2i(map_width - 1, floor(2.0 * map_height / 3.0))
	
	place_road(randPt1, randPt2)
	
	randPt1 = Vector2i(floor(map_height / 3.0), 0)
	randPt2 = Vector2i(floor(map_height / 3.0), map_width - 1)
	
	place_road(randPt1, randPt2)
	
	randPt1 = Vector2i(floor(2.0 * map_height / 3.0) + 10, 0)
	randPt2 = Vector2i(floor(2.0 * map_height / 3.0) + 10, map_width - 1)
	
	place_road(randPt1, randPt2)

func place_road(pt1: Vector2i, pt2: Vector2i) -> void:
	var road_path = pathfinding.aStar(pt1, pt2)
	for tile: Vector2i in road_path:
		RoadMap.get_instance().place_road(tile)

func set_cell(pos: Vector2i, atlas: Vector2i, height: int) -> void:
	terrain_grid[pos] = TileInfo.new(atlas, height)
	terrain_layers[height].set_cell(pos, 0, atlas)

func replace_cell(pos: Vector2i, atlas: Vector2i, source_id: int = 0) -> void:
	var height = get_height_of_cell(pos)
	terrain_grid[pos] = TileInfo.new(atlas, height)
	terrain_layers[height].set_cell(pos, source_id, atlas)

func get_surrounding_cells(pos: Vector2i) -> Array[Vector2i]:
	var toReturn: Array[Vector2i] = []
	
	for tile: Vector2i in get_layer(0).get_surrounding_cells(pos):
		toReturn.push_back(tile)
	return toReturn

func get_cell_atlas_coords(pos: Vector2i) -> Vector2i:
	if (!terrain_grid.has(pos)): return Vector2i(-1, -1)
	return terrain_grid[pos].atlas

func get_height_of_cell(pos: Vector2i) -> int:
	if (!terrain_grid.has(pos)): return -1
	return terrain_grid[pos].height

func map_to_local(pos: Vector2i) -> Vector2:
	# Use bottom layer for no offsets
	return get_layer(int(WATER_CUTOFF)).map_to_local(pos)

func local_to_map(local_pos: Vector2) -> Vector2i:
	# Use bottom layer for no offsets
	return get_layer(int(WATER_CUTOFF)).local_to_map(local_pos)

func get_cell_hovered() -> Vector2i:
	for h in range(max_height - 1, -1, -1):
		var layer = get_layer(h)
		var local_pos = layer.get_local_mouse_position()
		var cell = layer.local_to_map(local_pos)
		if (layer.get_cell_atlas_coords(cell) != Vector2i(-1, -1) or h == 0):
			return cell
	assert(false)
	return Vector2i(-1, -1)
