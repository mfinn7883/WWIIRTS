extends Node

# This dictionary will store every unit. 
# The Key will be the Unit ID, the Value will be the UnitData object.
var active_units: Dictionary[int, UnitData] = {}
var next_id: int = 0

func get_units() -> Array[UnitData]:
	return (active_units.values() as Array[UnitData])

# Function to create a unit and track it
func create_unit(type: String, spawn_pos: Vector2i, atlas: Vector2i) -> UnitData:
	var new_unit = UnitData.new()
	
	new_unit.unit_id = next_id
	new_unit.unit_name = type
	new_unit.grid_pos = spawn_pos
	new_unit.atlas_coords = atlas
	
	# Add it to our "Big Book" of units
	active_units[next_id] = new_unit
	
	next_id += 1
	print("UnitManager: Created ", type, " with ID ", new_unit.unit_id)
	return new_unit

# Function to find a unit based on its grid position
func get_unit_at_pos(pos: Vector2i) -> UnitData:
	for unit in active_units.values():
		if unit.grid_pos == pos:
			return unit
	return null

func get_unit_with_id(unit_id: int) -> UnitData:
	return active_units[unit_id]
