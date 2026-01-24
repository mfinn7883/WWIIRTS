extends TileMapLayer

var terrain_map: TileMapLayer = null

var map_height = 128
var water_coords = Vector2i(6, 0)
var pathfinding = load("res://Map/TerrainMap/pathfinding.gd")

func _ready():
	await get_tree().process_frame 
	terrain_map = get_parent().get_node("UnitMap")
	spawn_soldiers()
	GlobalTimer.connect("minute_tick", minute_tick)


func _input(event):
	# Only proceed if it's a mouse click (and not just moving the mouse)
	if not event is InputEventMouseButton or not event.pressed:
		return

	# Convert the mouse click position to a grid coordinate (e.g., 64, 110)
	var mouse_grid_pos = local_to_map(get_local_mouse_position())
	
	# LEFT CLICK: Select a Unit
	if event.button_index == MOUSE_BUTTON_LEFT:
		var source_id = get_cell_source_id(mouse_grid_pos)
		
		# If there is a tile here (source_id is not -1), select it
		if source_id != -1:
			selected_unit_id = UnitManager.get_unit_at_pos(mouse_grid_pos).get_id()
			print("Selected unit with id: ", selected_unit_id)
		else:
			# If you click empty ground, clear the selection
			selected_unit_id = -1
			print("Deselected.")

	# RIGHT CLICK: Move the Selected Unit
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		# Only move if we actually have a unit selected
		if selected_unit_id != -1:
			print("Moving unit with id: ", selected_unit_id, " to ", mouse_grid_pos)
			var unit: UnitData = UnitManager.get_unit_with_id(selected_unit_id)
			var path = pathfinding.bfs_to_destination(unit.grid_pos, mouse_grid_pos)
			print(path)
			unit.set_route(path)

func minute_tick() -> void:
	for unit: UnitData in UnitManager.get_units():
		simulate_unit_minute_tick(unit)

func simulate_unit_minute_tick(unit: UnitData) -> void:
	if (unit.has_route()):
		var next_step = unit.get_next_step()
		var target_data = UnitManager.get_unit_at_pos(next_step)
		
		# COMBAT CHECK (Before moving!)
		if target_data != null:
			if target_data.atlas_coords != unit.atlas_coords:
				print("Combat triggered at: ", next_step)
				unit.erase_route()
				return
		
		var unit_atlas = get_cell_atlas_coords(unit.grid_pos)
		set_cell(next_step, 0, unit_atlas)
		erase_cell(unit.grid_pos)
		
		unit.grid_pos = next_step
		
		unit.pop_step()
		
		temp(unit)

func temp(unit: UnitData) -> void:
	TileEffects.get_instance().clear_highlights()
	for tile: Vector2i in unit.get_tiles_in_sight():
		TileEffects.get_instance().highlight_cell(tile)

func spawn_soldiers():
	# Define the Groups
	var group_blue = {"leader": Vector2i(0,0), "units": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1)]}
	var group_red = {"leader": Vector2i(1,0), "units": [Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)]}
	var group_green = {"leader": Vector2i(2,0), "units": [Vector2i(0,3), Vector2i(1,3), Vector2i(2,3), Vector2i(3,3)]}
	
	var all_groups = [group_blue, group_red, group_green]
	
	var start_x = 40 
	var spawn_y = 115
	var gap = 12

	for i in range(all_groups.size()):
		var group = all_groups[i]
		var preferred_center = Vector2i(start_x + (i * gap), spawn_y)
		
		var safe_center = find_clump_land(preferred_center)
		
		set_cell(safe_center, 0, group["leader"])
		# CREATE DATA FOR LEADER
		UnitManager.create_unit("Leader", safe_center, group["leader"])
		
		# --- 2. Place the 4 Units ---
		var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
		
		for j in range(group["units"].size()):
			var unit_tile = group["units"][j]
			var unit_pos = safe_center + offsets[j] # This is where 'unit_pos' is defined
			
			set_cell(unit_pos, 0, unit_tile)
			UnitManager.create_unit("Soldier", unit_pos, unit_tile)

func find_clump_land(start_pos: Vector2i) -> Vector2i:
	var max_search_radius = 20 
	
	for radius in range(0, max_search_radius + 1):
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				if radius == 0 or abs(x) == radius or abs(y) == radius:
					var test_center = start_pos + Vector2i(x, y)
					
					# Check if the center AND its 4 neighbors are land
					if is_area_dry(test_center):
						return test_center
						
	return start_pos # Fallback

# Check if the "Plus" shape is entirely on land
func is_area_dry(center: Vector2i) -> bool:
	var points_to_check = [
		center,
		center + Vector2i(-1, 0),
		center + Vector2i(1, 0),
		center + Vector2i(0, -1),
		center + Vector2i(0, 1)
	]
	
	for p in points_to_check:
		# (6, 0) is water. If ANY point is water, the whole area is invalid.
		if terrain_map.get_cell_atlas_coords(p) == Vector2i(6, 0):
			return false
	return true

var selected_unit_id: int = -1
