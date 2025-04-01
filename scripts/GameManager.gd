extends Node

enum TimeOfDay { DAY, NIGHT }

signal health_changed(health:int)
signal time_of_day_changed(new_time: TimeOfDay)
signal game_started
signal game_stopped
signal game_paused
signal game_unpaused
signal cycle_progress_changed(progress: float)

var player_health: int = 100
var time_of_day: TimeOfDay = TimeOfDay.DAY
var time_passed := 0.0
var cycle_duration_in_minutes := 3.0
var game_running   := false
var is_game_paused := false
var last_emitted_progress := -1.0
var start_timer: Timer

func _set_player_health(new_health: int) -> void:
	player_health = new_health
	emit_signal("health_changed", player_health)

func get_player_health() -> int:
	return player_health

func set_player_health(new_health: int) -> void:
	_set_player_health(new_health)

func get_time_passed() -> float:
	return time_passed

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
	if time_of_day == TimeOfDay.DAY:
		time_of_day = TimeOfDay.NIGHT
	else:
		time_of_day = TimeOfDay.DAY
	emit_signal("time_of_day_changed", time_of_day)
	
func get_cycle_progress() -> float:
	"""
	Returns a normalized value (0.0 to 1.0) representing how far
	along we are in the current day/night cycle.
	"""
	return time_passed / (cycle_duration_in_minutes * 60)
	
func start_game() -> void:
	if not game_running:
		game_running = true
		emit_signal("game_started")
		print("Game started")
		
func stop_game() -> void:
	if game_running:
		game_running = false
		emit_signal("game_stopped")
		print("Game stopped")
	
func pause_game() -> void:
	if game_running and not is_game_paused:
		is_game_paused = true
		emit_signal("game_paused")
		
func unpause_game() -> void:
	if game_running and is_game_paused:
		is_game_paused = false
		emit_signal("game_unpaused")
		
func _ready():
	# Set up timer to start game after 5 seconds
	start_timer = Timer.new()
	add_child(start_timer)
	start_timer.wait_time = 3.0
	start_timer.one_shot = true
	start_timer.timeout.connect(start_game)
	start_timer.start()
	print("Game will start in 3 seconds")
