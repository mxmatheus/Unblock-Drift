extends Node2D

@onready var player_car: PlayerCarController = $PlayerCar
@onready var parking_spot: ParkingSpotChecker = $ParkingSpot
@onready var left_btn: Button = $CanvasLayer/Controls/LeftBtn
@onready var right_btn: Button = $CanvasLayer/Controls/RightBtn
@onready var handbrake_btn: Button = $CanvasLayer/Controls/HandbrakeBtn
@onready var complete_dialog: Control = $CanvasLayer/LevelCompleteDialog
@onready var score_label: Label = $CanvasLayer/LevelCompleteDialog/VBox/ScoreLabel
@onready var star_label: Label = $CanvasLayer/LevelCompleteDialog/VBox/StarLabel
@onready var next_btn: Button = $CanvasLayer/LevelCompleteDialog/VBox/NextBtn
@onready var retry_btn: Button = $CanvasLayer/LevelCompleteDialog/VBox/RetryBtn

func _ready() -> void:
	parking_spot.parking_evaluated.connect(_on_parking_evaluated)
	
	next_btn.pressed.connect(_on_next_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	
	setup_driving_phase()

func setup_driving_phase() -> void:
	var level_config = LevelData.get_level(GameManager.current_level_index)
	var p2_config = level_config.get("phase2_config", {})
	
	var spawn_pos = p2_config.get("spawn_position", Vector2(360, 1100))
	var spawn_angle = p2_config.get("spawn_angle_deg", 0.0)
	
	player_car.global_position = spawn_pos
	player_car.rotation = deg_to_rad(spawn_angle)
	
	var spot_pos = p2_config.get("spot_position", Vector2(360, 300))
	var spot_angle = p2_config.get("target_angle_deg", 0.0)
	
	parking_spot.global_position = spot_pos
	parking_spot.rotation = deg_to_rad(spot_angle)
	parking_spot.target_angle_deg = spot_angle

func _process(_delta: float) -> void:
	if GameManager.current_phase != GameManager.GamePhase.PHASE_2_DRIVING:
		return
		
	var steer = 0.0
	if left_btn.is_pressed():
		steer -= 1.0
	if right_btn.is_pressed():
		steer += 1.0
		
	player_car.set_steering(steer)
	player_car.set_handbrake(handbrake_btn.is_pressed())

func _on_parking_evaluated(score: float, stars: int) -> void:
	score_label.text = "PARK SCORE: %.1f%%" % score
	
	var star_str = ""
	for i in range(stars):
		star_str += "★"
	for i in range(3 - stars):
		star_str += "☆"
	star_label.text = star_str
	
	complete_dialog.visible = true
	AudioManager.play_sfx("success")

func _on_next_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.next_level()

func _on_retry_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.restart_current_level()
