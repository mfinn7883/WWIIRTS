extends Resource
class_name UnitData

# Core Identity
@export var unit_id: int
@export var unit_name: String = "Infantry"
@export var atlas_coords: Vector2i # Keeps track of what the tile looks like

# Position on the 128x128 grid
@export var grid_pos: Vector2i

# Stats for Combat
@export var strength: float = 100.0   # Current health/manpower
@export var max_strength: float = 100.0
@export var morale: float = 1.0       # 1.0 = 100% morale
@export var attack_power: float = 15.0

# Logistics
@export var supplies: float = 50.0
@export var officer_id: int = -1      # -1 means no officer assigned
