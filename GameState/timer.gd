extends Timer

signal minute_tick
signal hour_tick
signal day_tick

var game_speed: float = 1.0
var accumulator: float = 0.0

var minute: int = 1
var hour: int = 1
var day: int = 1
var month: int = 1

func _on_timeout() -> void:
	accumulator += (0.05 * game_speed)
	if (accumulator >= 1):
		accumulator = 0.0
		update_minute()
		

func update_minute() -> void:
	minute += 1
	minute_tick.emit()
	if (minute > 60):
		minute = 1
		hour += 1
		update_hour()

func update_hour() -> void:
	hour += 1
	hour_tick.emit()
	if (hour > 24):
		hour = 1
		day += 1
		update_day()

func update_day() -> void:
	day += 1
	day_tick.emit()
	if (day > 30):
		day = 1
		month += 1
