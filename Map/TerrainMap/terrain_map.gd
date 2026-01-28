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
	source.texture = load("res://Resources/MapAtlasTextures/big_isometric_map.png")
	source.margins = Vector2i(0, 32)
	source.texture_region_size = Vector2i(128, 224)
	
	for i in range(0, 8):
		for j in range(0, 3):
			source.create_tile(Vector2i(i, j))
	
	source.create_tile(Vector2i(0, 3))
	
	tileset.add_source(source)
	
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
	# 0 - 10
	var height: float = (h_val) * 5.0
	
	const WATER_CUTOFF: float = 3.0
	# Useful when ratios are right but need to shift b/c of water
	const SHIFT_FACTOR: float = 0.75
	
	# Logic for mapping noise values to terrain
	if height < WATER_CUTOFF:
		# Water
		set_cell(Vector2i(x,y), Vector2i(6,0), int(WATER_CUTOFF))
	elif height < (4.4 - SHIFT_FACTOR):
		# Sand
		set_cell(Vector2i(x,y), Vector2i(0,2), floor(height))
	elif height < (5.0 - SHIFT_FACTOR):
		#Marsh
		set_cell(Vector2i(x,y), Vector2i(7,1), floor(height))
	elif height < (6.0 - SHIFT_FACTOR):
		if randi_range(0,10) != 0:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(0,0), floor(height))
		else:
			#Hill
			set_cell(Vector2i(x,y), Vector2i(4,0), floor(height))
	elif height < (7.0 - SHIFT_FACTOR):
		if randi_range(0,3) != 0:
			#Jungle
			set_cell(Vector2i(x,y), Vector2i(0,3), floor(height))
		else:
			#Grass
			set_cell(Vector2i(x,y), Vector2i(0,0), floor(height))
	elif height < (7.5 - SHIFT_FACTOR):
		if randi_range(0,3) != 0:
			# Sparse Forest
			set_cell(Vector2i(x,y), Vector2i(2,0), floor(height))
		else:
			# Jungle
			set_cell(Vector2i(x,y), Vector2i(0,3), floor(height))
	elif height < (8.0 - SHIFT_FACTOR):
		#Forest Hill
		set_cell(Vector2i(x,y), Vector2i(4,0), floor(height))
	elif height < (8.7 - SHIFT_FACTOR):
		#Hill
		set_cell(Vector2i(x,y), Vector2i(3,0), floor(height))
	else:
		# Mountain/Height logic here
		set_cell(Vector2i(x,y), Vector2i(5,0), floor(height))
	
	
	
	#if val < -0.3:
		## Water logic here
		#set_cell(Vector2i(x,y), Vector2i(6,0), height)
	#elif val < -0.26:
		## Sand
		#set_cell(Vector2i(x,y), Vector2i(0,3), height)
	#elif val < -0.18:
		##Marsh
		#set_cell(Vector2i(x,y), Vector2i(7,1), height)
	#elif val < -0.15:
		#if randi_range(0,2) != 0:
			#set_cell(Vector2i(x,y), Vector2i(0,0), height)
		#else:
			##Grass
			#set_cell(Vector2i(x,y), Vector2i(4,0), height)
	#elif val < 0.2:
		##Jungle
		#if randi_range(0,3) != 0:
			#set_cell(Vector2i(x,y), Vector2i(0,4), height)
		#else:
			##Grass
			#set_cell(Vector2i(x,y), Vector2i(0,0), height)
	#elif val < 0.4:
		#if randi_range(0,3) != 0:
			#set_cell(Vector2i(x,y), Vector2i(2,0), height)
		#else:
			##Grass
			#set_cell(Vector2i(x,y), Vector2i(0,4), height)
	#elif val < 0.5:
		##Forest Hill
		#set_cell(Vector2i(x,y), Vector2i(4,0), height)
	#elif val < 0.6:
		##Hill
		#set_cell(Vector2i(x,y), Vector2i(3,0), height)
	#else:
		## Mountain/Height logic here
		#set_cell(Vector2i(x,y), Vector2i(5,0), height)

func set_cell(pos: Vector2i, atlas: Vector2i, height: int) -> void:
	terrain_grid[pos] = atlas
	terrain_layers[height].set_cell(pos, 0, atlas)
