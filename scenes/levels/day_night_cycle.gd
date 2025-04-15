extends CanvasModulate

const DAY_COLOR := Color(1, 1, 1, 1)
const NIGHT_COLOR := Color(0.2, 0.2, 0.5, 1)
const SUPER_MOON_COLOR := Color(0.25, 0.1, 0, 1)

var game_manager: Node = null

func _ready() -> void:
	game_manager = get_tree().root.get_node("GameManager")
	# Connect signals from GameManager
	game_manager.connect("time_of_day_changed", Callable(self, "_on_time_of_day_changed"))
	game_manager.connect("cycle_progress_changed", Callable(self, "_on_cycle_progress_changed"))
	# Immediately set initial time of day color
	_set_time_of_day(game_manager.time_of_day)

func _on_time_of_day_changed(new_time):
	_set_time_of_day(new_time)

func _on_cycle_progress_changed(progress: float):
	_update_color(progress)

func _set_time_of_day(time_of_day):
	match time_of_day:
		game_manager.TimeOfDay.DAY:
			self.color = DAY_COLOR
		game_manager.TimeOfDay.NIGHT:
			if game_manager.moon_phase == game_manager.MoonPhase.BLOOD_MOON:
				self.color = SUPER_MOON_COLOR
			else:
				self.color = NIGHT_COLOR

func _update_color(progress: float):
	var current_time = game_manager.time_of_day
	if current_time == game_manager.TimeOfDay.DAY:
		self.color = DAY_COLOR.lerp(NIGHT_COLOR, progress)
	else:
		if game_manager.moon_phase == game_manager.MoonPhase.BLOOD_MOON:
			var base_color: Color        = SUPER_MOON_COLOR
			var adjusted_progress: float = (progress - 0.5) * 2.0 if progress > 0.5 else 0.0
			self.color = base_color.lerp(DAY_COLOR, adjusted_progress)
		else:
			var adjusted_progress: float = (progress - 0.5) * 2.0 if progress > 0.5 else 0.0
			self.color = NIGHT_COLOR.lerp(DAY_COLOR, adjusted_progress)
