class_name UnitData extends Resource

static var NUMBER_OF_UNITS: int = 0

enum ACTION_STATES {
	MOVE_NORMAL,
	MOVE_FAST,
	MOVE_SLOW,
	
	MOVE_RECON,
	
	COMBAT,
	
	STAGGERED_WITHDRAWL,
	PANICKED_RETREAT,
}

# Core Identity
var id: int
var unit_name: String = "Infantry"
var atlas_coords: Vector2i # Keeps track of what the tile looks like

var weapon_range: int = 0 # How many tiles away this unit can shot affectively
var vision_range: int = 0 # How many tiles away this unit can see

# Stats for Combat
var manpower: float
var max_manpower: float
var morale: float = 100.0       		# 0 - 100
var exhaustion: float = 100.0			# 0 - 100
var attack_power: float
var supressive_power: float
var speed: float

# Mutable stats
var grid_pos: Vector2i
var entrenchment: float = 0.0
var concealment: float = 0.0

# Logistics
var officer_id: int = -1      		# -1 means no officer assigned
var ammo: float = 100.0
var food: float = 100.0

# Constants
static var FOOD_CONSUMPTION_RATE: float = 1 # Per X amount of manpower

# Unit Creation
func _init(p_atlas_coords: Vector2i) -> void:
	id = NUMBER_OF_UNITS
	NUMBER_OF_UNITS += 1
	atlas_coords = p_atlas_coords

func get_id() -> int:
	return id

# Pathfinding
var route: Array = []

func set_route(new_route: Array):
	route = new_route

func has_route() -> bool:
	return !route.is_empty()

func get_next_step() -> Vector2i:
	return route[0]

func pop_step():
	if (!route.is_empty()): 
		route.pop_front()

func erase_route():
	route.clear()

# Attacking / Defending

func take_damage(damage: float) -> void:
	manpower -= damage

func get_manpower() -> float:
	return manpower

var tile_costs: Dictionary[Vector2i, float] = {
	Vector2i(-1, -1): 100000,
	Vector2(6, 0): 0.05,
	Vector2(0, 3): 0.05,
	Vector2(0, 0): 0.05,
	Vector2i(1, 0): 7, # Lightly Forested
	Vector2i(2, 0): 12, # Heavily Forested
	Vector2i(0, 4): 12, # Jungle Forested
}

const TILE_COST_SCALING_RATE: float = 1.0 / 100000.0

func get_tiles_in_sight() -> Array[Vector2i]:
	var terrain_map: TerrainMap = TerrainMap.get_instance()
	var sight_tiles: Dictionary[Vector2i, float] = {}
	var dist_tiles: Dictionary[Vector2i, int] = {}
	var queue: Array[Vector2i] = [grid_pos]
	dist_tiles[grid_pos] = 0
	sight_tiles[grid_pos] = 0.0
	
	while (!queue.is_empty()):
		var tile: Vector2i = queue.pop_front()
		if (dist_tiles[tile] > vision_range):
			continue
		
		for other: Vector2i in terrain_map.get_surrounding_cells(tile):
			if (!dist_tiles.has(other)):
				if (sight_tiles.has(tile)):
					var cost = sight_tiles[tile] + get_cost_to_see(terrain_map.get_cell_atlas_coords(other), other)
					if (ceil(cost) <= vision_range):
						sight_tiles[other] = cost
				dist_tiles[other] = dist_tiles[tile] + 1
				queue.append(other)
	
	return sight_tiles.keys()

func distance_to(tile1: Vector2i, tile2: Vector2i) -> float:
	var terrain_map: TerrainMap = TerrainMap.get_instance()
	var dist: float = terrain_map.map_to_local(tile1).distance_to(terrain_map.map_to_local(tile2))
	
	return dist

func get_cost_to_see(atlas: Vector2i, current_tile: Vector2i) -> float:
	return (tile_costs[atlas] if tile_costs.has(atlas) else 1.0) * pow(distance_to(grid_pos, current_tile), 2) * TILE_COST_SCALING_RATE
