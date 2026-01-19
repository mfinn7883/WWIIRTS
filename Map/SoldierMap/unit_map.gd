extends TileMapLayer
# These should match the names in your Scene Tree
@onready var terrain_map: TileMapLayer = $"../TerrainLayer"
@onready var unit_map: TileMapLayer = self

func _ready():
	# We wait a tiny bit to make sure the terrain is finished generating
	await get_tree().process_frame 
	spawn_soldiers()
# Settings for your map	var map_width = 128
var map_height = 128
var water_coords = Vector2i(6, 0) # Your specific water tile	var soldier_coords = Vector2i(0, 0) # CHANGE THIS to your soldier's atlas position

func spawn_soldiers():
	# Define the Groups
	var group_blue = {"leader": Vector2i(0,0), "units": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1)]}
	var group_red = {"leader": Vector2i(1,0), "units": [Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)]}
	var group_green = {"leader": Vector2i(2,0), "units": [Vector2i(0,3), Vector2i(1,3), Vector2i(2,3), Vector2i(3,3)]}
	
	var all_groups = [group_blue, group_red, group_green]
	
	# Initial starting area (Middle Bottom)
	var start_x = 40 
	var spawn_y = 115
	var gap = 12 # Increased gap slightly to prevent overlapping searches

	for i in range(all_groups.size()):
		var group = all_groups[i]
		var preferred_center = Vector2i(start_x + (i * gap), spawn_y)
		
		# Find a center point where the WHOLE clump fits
		var safe_center = find_clump_land(preferred_center)
		
		# 3. Place the Leader
		unit_map.set_cell(safe_center, 0, group["leader"])
		
		# 4. Place the 4 Units around that safe center
		var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
		
		for j in range(group["units"].size()):
			var unit_tile = group["units"][j]
			var unit_pos = safe_center + offsets[j]
			unit_map.set_cell(unit_pos, 0, unit_tile)

# New helper: Searches for a spot where a 3x3 area is mostly dry
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
# --- Variables for Selection ---
var selected_tile_pos: Vector2i = Vector2i(-1, -1) # -1 means nothing is selected

func _input(event):
	# Only proceed if it's a mouse click (and not just moving the mouse)
	if not event is InputEventMouseButton or not event.pressed:
		return

	# Convert the mouse click position to a grid coordinate (e.g., 64, 110)
	var mouse_grid_pos = unit_map.local_to_map(get_local_mouse_position())

	# LEFT CLICK: Select a Unit
	if event.button_index == MOUSE_BUTTON_LEFT:
		var source_id = unit_map.get_cell_source_id(mouse_grid_pos)
		
		# If there is a tile here (source_id is not -1), select it
		if source_id != -1:
			selected_tile_pos = mouse_grid_pos
			print("Selected unit at: ", selected_tile_pos)
		else:
			# If you click empty ground, clear the selection
			selected_tile_pos = Vector2i(-1, -1)
			print("Deselected.")

	# RIGHT CLICK: Move the Selected Unit
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		# Only move if we actually have a unit selected
		if selected_tile_pos != Vector2i(-1, -1):
			print("Moving unit from ", selected_tile_pos, " to ", mouse_grid_pos)
			bfs_to_destination(selected_tile_pos, mouse_grid_pos)

func bfs_to_destination(start: Vector2i, destination: Vector2i) -> Array[Vector2i]:
	var current: Vector2i
	var queue: priority_queue = priority_queue.new()
	var tile_to_prev: Dictionary = {}
	var visited: Dictionary = {}
	var found: bool = false
	queue.insert_element(start, 0)
	visited[start] = 0
	while !queue.is_empty():
		current = queue.pop_back()
		if current == destination:
			found = true
			break
			for tile: Vector2i in get_surrounding_cells(current):
				var terrain_mult: int = 1
				var temp_dist: float =  map_to_local(current).distance_to(map_to_local(tile))
				var current_dist: float = visited[current] + (temp_dist / terrain_mult)
				if is_tile_traversable(tile) and !visited.has(tile):
					queue.insert_element(tile, current_dist)
					visited[tile] = current_dist
					tile_to_prev[tile] = current
	if found:
		return create_route_from_tile_to_prev(start, destination, tile_to_prev)
	else:
		return []

func is_tile_traversable(tile: Vector2i) -> bool:
	return tile != Vector2i(0, 6)

func create_route_from_tile_to_prev(start: Vector2i, destination: Vector2i, tile_to_prev: Dictionary) -> Array[Vector2i]:
	var current: Vector2i = destination
	var route: Array[Vector2i] = []
	while current != start:
		route.push_front(current)
		current = tile_to_prev[current]
	return route
