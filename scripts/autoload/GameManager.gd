extends Node

enum GamePhase {
	MAIN_MENU,
	LEVEL_SELECT,
	PHASE_1_PUZZLE,
	TRANSITION,
	PHASE_2_DRIVING,
	LEVEL_COMPLETE
}

signal phase_changed(new_phase: GamePhase)
signal moves_updated(moves_remaining: int)
signal level_completed(level_idx: int, stars: int, score: float)

var current_level_index: int = 1
var current_phase: GamePhase = GamePhase.MAIN_MENU
var moves_remaining: int = 10
var moves_used: int = 0
var total_levels: int = 10

# Data passed from Phase 1 to Phase 2
var phase1_exit_data: Dictionary = {
	"target_car_id": "player_car",
	"exit_position": Vector2(360, 200),
	"exit_direction": Vector2(0, -1),
	"car_type": "SPORTS"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_phase(new_phase: GamePhase) -> void:
	current_phase = new_phase
	phase_changed.emit(new_phase)

func load_level(level_idx: int) -> void:
	current_level_index = level_idx
	moves_used = 0
	var level_data = LevelData.get_level(level_idx)
	moves_remaining = level_data.get("moves_allowed", 15)
	change_phase(GamePhase.PHASE_1_PUZZLE)
	get_tree().change_scene_to_file("res://scenes/phase1_puzzle/Phase1Puzzle.tscn")

func use_move() -> bool:
	if moves_remaining > 0:
		moves_remaining -= 1
		moves_used += 1
		moves_updated.emit(moves_remaining)
		return true
	return false

func add_bonus_moves(count: int) -> void:
	moves_remaining += count
	moves_updated.emit(moves_remaining)

func complete_phase1(exit_pos: Vector2, exit_dir: Vector2, car_id: String = "player_car") -> void:
	phase1_exit_data["exit_position"] = exit_pos
	phase1_exit_data["exit_direction"] = exit_dir
	phase1_exit_data["target_car_id"] = car_id
	
	TransitionManager.start_transition_to_phase2()

func complete_level(stars: int, score: float) -> void:
	SaveSystem.save_level_result(current_level_index, stars, score)
	level_completed.emit(current_level_index, stars, score)
	change_phase(GamePhase.LEVEL_COMPLETE)

func restart_current_level() -> void:
	load_level(current_level_index)

func next_level() -> void:
	if current_level_index < total_levels:
		load_level(current_level_index + 1)
	else:
		get_tree().change_scene_to_file("res://scenes/level_select/LevelSelect.tscn")
