extends Camera2D

# --- Variables ---
var is_panning: bool = false
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 5.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed
		
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(zoom_speed)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(-zoom_speed)

	if event is InputEventMouseMotion and is_panning:
		# We multiply by zoom so that panning feels consistent 
		# regardless of how far zoomed in/out you are.
		position -= event.relative * 1.0/zoom

func zoom_camera(delta: float) -> void:
	var new_zoom = clamp(zoom.x + delta, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
