extends Node

var active_units: Dictionary[int, UnitData] = {}
var tick_count = 0

var rifle_squad: Script = load("res://Map/MapObjects/Units/Actual_Units/rifle_squad.gd")

func get_units() -> Array[UnitData]:
	return (active_units.values() as Array[UnitData])

# Function to create a unit and track it
func create_unit(type: String, spawn_pos: Vector2i, atlas: Vector2i) -> UnitData:
	var new_unit = rifle_squad.new(atlas)
	
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
