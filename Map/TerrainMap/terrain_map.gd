class_name TerrainMap extends TileMapLayer

# --- Configuration ---
@export var map_width: int = 128
@export var map_height: int = 128
@export var noise_seed: int = 5566789 # Change this for a new map

static var singleton_instance: TerrainMap = null

static func get_instance() -> TerrainMap:
	assert(singleton_instance != null, "The TerrainMap has not been created yet")
	return singleton_instance

# --- Noise Parameters ---
var noise = FastNoiseLite.new()

func _ready() -> void:
	assert(singleton_instance == null, "A terrain map has already been created, only 1 is allowed")
	singleton_instance = self
	generate_map()

func generate_map() -> void:
	# 1. Initialize Noise
	noise.seed = noise_seed if noise_seed != 0 else randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.03 # Higher = more "zoomed out" / chaotic
	
	# 2. Iterate through the grid
	for x in range(map_width):
		for y in range(map_height):
			# get_noise_2d returns a value between -1.0 and 1.0
			var noise_val = noise.get_noise_2d(x, y)
			
			# 3. Determine terrain based on thresholds
			place_terrain(x, y, noise_val)

func place_terrain(x: int, y: int, val: float) -> void:
	# Logic for mapping noise values to terrain
	if val < -0.3:
		# Water logic here
		set_cell(Vector2i(x,y), 1, Vector2i(6,0))
	elif val < -0.26:
		# Sand
		set_cell(Vector2i(x,y), 1, Vector2i(0,3))
	elif val < -0.18:
		#Marsh
		set_cell(Vector2i(x,y), 1, Vector2i(7,1))
	elif val < -0.15:
		if randi_range(0,2) != 0:
			set_cell(Vector2i(x,y), 1, Vector2i(0,0))
		else:
			#Grass
			set_cell(Vector2i(x,y), 1, Vector2i(4,0))
	elif val < 0.2:
		#Jungle
		if randi_range(0,3) != 0:
			set_cell(Vector2i(x,y), 1, Vector2i(0,4))
		else:
			#Grass
			set_cell(Vector2i(x,y), 1, Vector2i(0,0))
	elif val < 0.4:
		if randi_range(0,3) != 0:
			set_cell(Vector2i(x,y), 1, Vector2i(2,0))
		else:
			#Grass
			set_cell(Vector2i(x,y), 1, Vector2i(0,4))
	elif val < 0.5:
		#Forest Hill
		set_cell(Vector2i(x,y), 1, Vector2i(4,0))
	elif val < 0.6:
		#Hill
		set_cell(Vector2i(x,y), 1, Vector2i(3,0))
	else:
		# Mountain/Height logic here
		set_cell(Vector2i(x,y), 1, Vector2i(5,0))
