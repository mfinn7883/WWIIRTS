extends Node

var active_units: Dictionary[int, UnitData] = {}
var tick_count = 0

func run_tick():
	var player_units = []
	for unit in active_units.values():
		if unit.atlas_coords.y == 1: # Assuming Blue (y=1) is the player team
			player_units.append(unit)
	
	FogManager.update_fog(player_units)


func get_units() -> Array[UnitData]:
	return (active_units.values() as Array[UnitData])

# Function to create a unit and track it
func create_unit(type: String, spawn_pos: Vector2i, atlas: Vector2i) -> UnitData:
	var new_unit = UnitData.new(atlas)
	
	new_unit.unit_name = type
	new_unit.grid_pos = spawn_pos
	new_unit.atlas_coords = atlas
	
	# Add it to our "Big Book" of units
	active_units[new_unit.get_id()] = new_unit
	
	return new_unit

# Function to find a unit based on its grid position
func get_unit_at_pos(pos: Vector2i) -> UnitData:
	for unit in active_units.values():
		if unit.grid_pos == pos:
			return unit
	return null

func get_unit_with_id(unit_id: int) -> UnitData:
	return active_units[unit_id]
