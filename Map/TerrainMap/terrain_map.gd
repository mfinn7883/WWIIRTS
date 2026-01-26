class_name TerrainMap extends Node2D

# --- Configuration ---
@export var map_width: int = 128
@export var map_height: int = 128
@export var noise_seed: int = 5566789 # Change this for a new map
@export var max_height: int = 10

var terrain_grid: Dictionary[Vector2i, Vector2i] = {}
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
	source.texture = load("res://Resources/MapAtlasTextures/big_isometric.png")
	source.margins = Vector2i(0, 34)
	source.texture_region_size = Vector2i(128, 192)
	
	for i in range(0, 8):
		for j in range(0, 2):
			source.create_tile(Vector2i(i, j))
	
	for i in range(0, 8):
		source.create_tile(Vector2i(i, 3))
	
	source.create_tile(Vector2i(0, 4))
	
	tileset.add_source(source)
	
	for i in range(0, max_height):
		var layer = TileMapLayer.new()
		layer.tile_set = tileset
		terrain_layers.append(layer)
		#layer.position = Vector2i(1 * i, -33 * i)
		layer.position = Vector2i(1 * i, -66 * i)
		layer.y_sort_enabled = true
		add_child(layer)
	
	singleton_instance = self
	
	generate_map()

func generate_map() -> void:
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
			# get_noise_2d returns a value between -1.0 and 1.0
			var noise_val = noise.get_noise_2d(x, y)
			var height_noise_val = height_noise.get_noise_2d(x, y)
			
			# 3. Determine terrain based on thresholds
			place_terrain(x, y, noise_val, height_noise_val)

func place_terrain(x: int, y: int, val: float, h_val: float) -> void:
	var height = (h_val + 1) * 5
	# Logic for mapping noise values to terrain
	if val < -0.3:
		# Water logic here
		set_cell(Vector2i(x,y), Vector2i(6,0), height)
	elif val < -0.26:
		# Sand
		set_cell(Vector2i(x,y), Vector2i(0,3), height)
	elif val < -0.18:
		#Marsh
		set_cell(Vector2i(x,y), Vector2i(7,1), height)
	elif val < -0.15:
		if randi_range(0,2) != 0:
			set_cell(Vector2i(x,y), Vector2i(0,0), height)
		else:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(4,0), height)
	elif val < 0.2:
		#Jungle
		if randi_range(0,3) != 0:
			set_cell(Vector2i(x,y), Vector2i(0,4), height)
		else:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(0,0), height)
	elif val < 0.4:
		if randi_range(0,3) != 0:
			set_cell(Vector2i(x,y), Vector2i(2,0), height)
		else:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(0,4), height)
	elif val < 0.5:
		#Forest Hill
		set_cell(Vector2i(x,y), Vector2i(4,0), height)
	elif val < 0.6:
		#Hill
		set_cell(Vector2i(x,y), Vector2i(3,0), height)
	else:
		# Mountain/Height logic here
		set_cell(Vector2i(x,y), Vector2i(5,0), height)

func set_cell(pos: Vector2i, atlas: Vector2i, height: int) -> void:
	terrain_grid[pos] = atlas
	terrain_layers[height].set_cell(pos, 0, atlas)
