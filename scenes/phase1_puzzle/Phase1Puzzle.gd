extends Node2D

@onready var grid_system: GridSystem = $GridSystem
@onready var hud: CanvasLayer = $HUD
@onready var move_label: Label = $HUD/TopBar/MoveLabel
@onready var level_label: Label = $HUD/TopBar/LevelLabel
@onready var restart_button: Button = $HUD/TopBar/RestartButton
@onready var out_of_moves_dialog: Control = $HUD/OutOfMovesDialog
@onready var watch_ad_button: Button = $HUD/OutOfMovesDialog/VBox/WatchAdButton

var vehicle_scene = preload("res://scenes/phase1_puzzle/Vehicle.tscn")

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	if watch_ad_button:
		watch_ad_button.pressed.connect(_on_watch_ad_pressed)
		
	GameManager.moves_updated.connect(_on_moves_updated)
	setup_level(GameManager.current_level_index)

func setup_level(level_idx: int) -> void:
	var level_config = LevelData.get_level(level_idx)
	level_label.text = "LEVEL %d" % level_idx
	_on_moves_updated(GameManager.moves_remaining)
	
	var width = level_config.get("grid_width", 6)
	var height = level_config.get("grid_height", 6)
	var exit_cell = level_config.get("exit_cell", Vector2(width - 1, 2))
	
	grid_system.initialize_grid(width, height, exit_cell)
	
	# Center the grid on viewport
	var grid_total_width = width * grid_system.cell_size.x
	var grid_total_height = height * grid_system.cell_size.y
	grid_system.position = Vector2((720 - grid_total_width) / 2.0, (1280 - grid_total_height) / 2.0 + 40)
	
	# Spawn vehicles
	var vehicles_data = level_config.get("vehicles", [])
	for vdata in vehicles_data:
		var vehicle_inst = vehicle_scene.instantiate()
		grid_system.add_child(vehicle_inst)
		
		var v_id = vdata.get("id", "car")
		var size = vdata.get("size", Vector2(2, 1))
		var orientation = vdata.get("orientation", "HORIZONTAL")
		var cell = Vector2i(vdata.get("cell", Vector2.ZERO))
		var is_target = vdata.get("is_target", false)
		
		vehicle_inst.setup(v_id, size, orientation, cell, is_target, grid_system)
		grid_system.register_vehicle(vehicle_inst)

func _on_moves_updated(remaining: int) -> void:
	move_label.text = "MOVES: %d" % remaining
	if remaining <= 0 and GameManager.current_phase == GameManager.GamePhase.PHASE_1_PUZZLE:
		out_of_moves_dialog.visible = true

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.restart_current_level()

func _on_watch_ad_pressed() -> void:
	AudioManager.play_sfx("click")
	AdManager.show_rewarded_ad("bonus_moves")
	out_of_moves_dialog.visible = false
