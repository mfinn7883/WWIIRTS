class_name UnitData extends Resource

# Core Identity
@export var unit_id: int
@export var unit_name: String = "Infantry"
@export var atlas_coords: Vector2i # Keeps track of what the tile looks like

# Position on the 128x128 grid
@export var grid_pos: Vector2i
#Tiles it can see
@export var vision_range: int = 3 # How many tiles away this unit can see

# Stats for Combat
@export var strength: float = 100.0   # Current health/manpower
@export var max_strength: float = 100.0
@export var morale: float = 1.0       # 1.0 = 100% morale
@export var attack_power: float = 15.0

# Logistics
@export var supplies: float = 50.0
@export var officer_id: int = -1      # -1 means no officer assigned

# Route
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
