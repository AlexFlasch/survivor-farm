extends Node

enum TimeOfDay { DAY, NIGHT }
enum MoonPhase { FULL, WANING_GIBBOUS, WANING_CRESCENT, NEW, WAXING_CRESCENT, WAXING_GIBBOUS }

signal health_changed(health:int)
signal max_health_changed(max_health:int)
signal time_of_day_changed(new_time: TimeOfDay)
signal game_started
signal game_stopped
signal game_paused
signal game_unpaused
signal game_reset
signal cycle_progress_changed(progress: float)
signal player_died
signal moon_phase_changed(moon_phase: MoonPhase)

var player_health: int = 100
var player_max_health: int = 100
var time_of_day: TimeOfDay = TimeOfDay.DAY
var time_passed := 0.0

@export var day_duration_in_minutes: float = 3.0
@export var night_duration_in_minutes: float = 2.0

var cycle_duration_in_minutes := day_duration_in_minutes
var game_running   := false
var is_game_paused := false
var last_emitted_progress := -1.0
var start_timer: Timer
var current_level: int = 1
var current_sprite: SpriteFrames
var player = null
var moon_phase: MoonPhase = MoonPhase.FULL

func _set_player_health(new_health: int) -> void:
	player_health = new_health
	emit_signal("health_changed", player_health)

func get_player_health() -> int:
	return player_health

func set_player_health(new_health: int) -> void:
	_set_player_health(new_health)
	
func get_player_max_health() -> int:
	return player_max_health
	
func set_player_max_health(new_max_health: int) -> void:
	player_max_health = new_max_health
	%HealthBar.max_value = player_max_health
	emit_signal("max_health_changed", player_max_health)

func get_time_passed() -> float:
	return time_passed

func get_current_level() -> int:
	return current_level

func set_current_level(level: int) -> void:
	current_level = level

func set_player(p: Node2D) -> void:
	player = p

func is_game_active() -> bool:
	return game_running and not is_game_paused

func _process(delta) -> void:
	if not game_running or is_game_paused:
		return
		
	time_passed += delta
	
	# Emit progress signal (rounded to nearest percent to avoid excessive emissions)
	var current_progress: float = get_cycle_progress()
	var progress_percent        = floor(current_progress * 100)
	if progress_percent != last_emitted_progress:
		last_emitted_progress = progress_percent
		emit_signal("cycle_progress_changed", current_progress)
	
	if time_passed >= cycle_duration_in_minutes * 60:
		time_passed = 0
		last_emitted_progress = 0
		_toggle_time_of_day()

func _toggle_time_of_day():
	# Reset cycle progress
	time_passed = 0
	last_emitted_progress = 0
	if time_of_day == TimeOfDay.DAY:
		time_of_day = TimeOfDay.NIGHT
		# Update duration to night duration.
		cycle_duration_in_minutes = night_duration_in_minutes
		# Cycle moon phase: FULL -> WANING_GIBBOUS -> WANING_CRESCENT -> NEW -> WAXING_CRESCENT -> WAXING_GIBBOUS -> FULL
		match moon_phase:
			MoonPhase.FULL:
				moon_phase = MoonPhase.WANING_GIBBOUS
			MoonPhase.WANING_GIBBOUS:
				moon_phase = MoonPhase.WANING_CRESCENT
			MoonPhase.WANING_CRESCENT:
				moon_phase = MoonPhase.NEW
			MoonPhase.NEW:
				moon_phase = MoonPhase.WAXING_CRESCENT
			MoonPhase.WAXING_CRESCENT:
				moon_phase = MoonPhase.WAXING_GIBBOUS
			MoonPhase.WAXING_GIBBOUS:
				moon_phase = MoonPhase.FULL
		emit_signal("moon_phase_changed", moon_phase)  # Emit signal when moon phase changes
		emit_signal("time_of_day_changed", time_of_day)
		print("Announcement: Day has ended, night has begun. Moon phase is now %s." % str(moon_phase))
	else:
		time_of_day = TimeOfDay.DAY
		current_level += 1  # Increment level when night turns into day
		cycle_duration_in_minutes = day_duration_in_minutes
		emit_signal("time_of_day_changed", time_of_day)
		print("Announcement: Night has ended, day has started.")
		print("Announcement: Level increased to %d" % current_level)
	
func get_cycle_progress() -> float:
	"""
	Returns a normalized value (0.0 to 1.0) representing how far
	along we are in the current day/night cycle.
	"""
	return time_passed / (cycle_duration_in_minutes * 60)
	
func start_game() -> void:
	if not game_running:
		game_running = true
		is_game_paused = false  # Ensure the game starts unpaused
		emit_signal("game_started")
		print("Game started")
		
func stop_game() -> void:
	if game_running:
		game_running = false
		emit_signal("game_stopped")
		print("Game stopped")
	
func pause_game() -> void:
	if game_running and not is_game_paused:
		get_tree().paused = true
		is_game_paused = true
		emit_signal("game_paused")
		
func unpause_game() -> void:
	if game_running and is_game_paused:
		get_tree().paused = false
		is_game_paused = false
		emit_signal("game_unpaused")

func handle_player_death() -> void:
	emit_signal("player_died")  # Emit signal that player died
	stop_game()  # Then stop the game

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
	if event is InputEventKey and event.is_action_pressed("ui_right"):
		 # Only advance time manually when running in the editor.
		if Engine.is_editor_hint:
			_toggle_time_of_day()
		# else: ignore manual toggling during runtime.

func _toggle_pause() -> void:
	if is_game_paused:
		unpause_game()
	else:
		pause_game()

func _ready() -> void:
	start_game()

func reset_game() -> void:
	# Reset game variables to initial states
	time_passed = 0.0
	last_emitted_progress = -1.0
	time_of_day = TimeOfDay.DAY
	cycle_duration_in_minutes = day_duration_in_minutes
	current_level = 1
	player_health = 100
	player_max_health = 100
	is_game_paused = false
	game_running = true
	moon_phase = MoonPhase.FULL
	emit_signal("game_reset")
	# --- Added: reset player position ---
	if player and player.has_method("reset_position"):
		player.reset_position()
