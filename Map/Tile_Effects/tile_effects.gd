class_name TileEffects extends Node

static var singleton_instance: TileEffects = null

static func get_instance() -> TileEffects:
	assert(singleton_instance != null, "AAAAAAAAAAAAAA")
	return singleton_instance

func _ready() -> void:
	singleton_instance = self

#Tile Effects
func highlight_cell(coords: Vector2i) -> void:
	var highlight: Sprite2D = Sprite2D.new()
	highlight.texture = load("res://Map/Tile_Effects/selected.png")
	add_child(highlight)
	highlight.name = "highlight"
	highlight.position = TerrainMap.get_instance().map_to_local(coords)
	highlight.z_index = 5
	print(highlight.position)

func clear_highlights() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
