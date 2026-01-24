class_name UnitData extends Resource

static var NUMBER_OF_UNITS: int = 0

# Core Identity
var id: int
var unit_name: String = "Infantry"
var atlas_coords: Vector2i # Keeps track of what the tile looks like

# Position on the 128x128 grid
var grid_pos: Vector2i
var vision_range: int = 3 # How many tiles away this unit can see

# Stats for Combat
var strength: float = 100.0 		# 0 - 100
var max_strength: float = 100.0 	# 0 - 100
var morale: float = 100.0       	# 0 - 100
var attack_power: float = 15.0

# Logistics
var supplies: float = 50.0
var officer_id: int = -1      		# -1 means no officer assigned


# Unit Creation
func _init(p_atlas_coords: Vector2i) -> void:
	id = NUMBER_OF_UNITS
	NUMBER_OF_UNITS += 1
	atlas_coords = p_atlas_coords


func get_id() -> int:
	return id


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
