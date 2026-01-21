extends TileMapLayer
@onready var terrain_map: TileMapLayer = $"../TerrainLayer"
@onready var unit_map: TileMapLayer = self
var routes: Array[Array] = []
var accumulator: float = 0.0

func _ready():
	await get_tree().process_frame 
	spawn_soldiers()


func _process(delta: float) -> void:
	accumulator += delta
	# How long in between unit "hops"
	if (accumulator < 1.0): 
		return
	accumulator = 0.0
	
	for route: Array in routes:
		# We check for >= 2 because we need a 'current' and a 'next'
		if (route.size() >= 2):
			# 1. Identify where we are (0) and where we want to go (1)
			var current_pos = route[0]
			var next_step = route[1]
			
			# 2. Get the Data
			var my_data = UnitManager.get_unit_at_pos(current_pos)
			var target_data = UnitManager.get_unit_at_pos(next_step)
			
			# 3. COMBAT CHECK (Before moving!)
			if target_data != null and my_data != null:
				if target_data.atlas_coords != my_data.atlas_coords:
					print("Combat triggered at: ", next_step)
					var enemy_died = CombatResolver.resolve_combat(my_data, target_data)
					
					if enemy_died:
						erase_cell(next_step) # Clear the dead enemy
					else:
						route.clear() # Stop moving if enemy survived
						continue 

			# 4. ACTUAL MOVEMENT
			var unit_atlas = get_cell_atlas_coords(current_pos)
			set_cell(next_step, 0, unit_atlas)
			erase_cell(current_pos)
			
			# 5. UPDATE DATA
			if my_data:
				my_data.grid_pos = next_step
			
			# 6. NOW we remove the old step so we can move to the next one in the next tick
			route.pop_front()
	
	for routeInd in routes.size():
		var route = routes[routeInd]
		if (route.size() < 2):
			routes.remove_at(routeInd)

var map_height = 128
var water_coords = Vector2i(6, 0)

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
		
		# --- 1. Place the Leader ---
		unit_map.set_cell(safe_center, 0, group["leader"])
		# CREATE DATA FOR LEADER
		UnitManager.create_unit("Leader", safe_center, group["leader"])
		
		# --- 2. Place the 4 Units ---
		var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
		
		for j in range(group["units"].size()):
			var unit_tile = group["units"][j]
			var unit_pos = safe_center + offsets[j] # This is where 'unit_pos' is defined
			
			unit_map.set_cell(unit_pos, 0, unit_tile)
			# CREATE DATA FOR UNIT
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

var selected_tile_pos = Vector2i(0, 0)

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
			var path = bfs_to_destination(selected_tile_pos, mouse_grid_pos)
			print(path)
			routes.push_back(path)

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
	return terrain_map.get_cell_atlas_coords(tile) != Vector2i(6, 0) and get_cell_atlas_coords(tile) == Vector2i(-1,-1)

func create_route_from_tile_to_prev(start: Vector2i, destination: Vector2i, tile_to_prev: Dictionary) -> Array[Vector2i]:
	var current: Vector2i = destination
	var route: Array[Vector2i] = []
	while current != start:
		route.push_front(current)
		current = tile_to_prev[current]
	route.push_front(start)
	return route
