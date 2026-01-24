extends UnitData

func _init(p_atlas_coords: Vector2i) -> void:
	super._init(p_atlas_coords)
	unit_name = "Rifle Squad"
	vision_range = 20 # How many tiles away this unit can see
	weapon_range = 20

	# Stats for Combat
	manpower = 100.0
	max_manpower = 100.0
	attack_power = 15.0
	supressive_power = 5.0
	speed = 10.0
	
	
