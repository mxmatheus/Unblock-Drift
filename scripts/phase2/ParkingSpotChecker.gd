class_name ParkingSpotChecker
extends Area2D

signal parking_evaluated(score: float, stars: int)

@export var target_angle_deg: float = 0.0
@export var speed_threshold: float = 25.0

var car_inside: PlayerCarController = null
var evaluation_done: bool = false
var low_speed_timer: float = 0.0

@onready var visual_box: ReferenceRect = $VisualBox

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if evaluation_done or car_inside == null:
		return
		
	var car_speed = car_inside.linear_velocity.length()
	if car_speed < speed_threshold:
		low_speed_timer += delta
		if low_speed_timer >= 0.8: # Sustained stop for 0.8 seconds
			evaluate_parking()
	else:
		low_speed_timer = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCarController:
		car_inside = body

func _on_body_exited(body: Node2D) -> void:
	if body == car_inside:
		car_inside = null
		low_speed_timer = 0.0

func evaluate_parking() -> void:
	if evaluation_done or car_inside == null:
		return
		
	evaluation_done = true
	car_inside.stop_vehicle()
	
	# Calculate Position/Overlap accuracy (70% weight)
	var distance = global_position.distance_to(car_inside.global_position)
	var max_dist = 120.0
	var pos_accuracy = clamp(1.0 - (distance / max_dist), 0.0, 1.0) * 100.0
	
	# Calculate Angle accuracy (30% weight)
	var target_rad = deg_to_rad(target_angle_deg)
	var car_rad = car_inside.rotation
	var angle_diff_rad = abs(angle_difference(car_rad, target_rad))
	var angle_accuracy = clamp(1.0 - (angle_diff_rad / (PI / 2.0)), 0.0, 1.0) * 100.0
	
	# Combined score
	var final_score = (pos_accuracy * 0.70) + (angle_accuracy * 0.30)
	
	var stars = 0
	if final_score >= 85.0:
		stars = 3
	elif final_score >= 60.0:
		stars = 2
	elif final_score >= 35.0:
		stars = 1
	else:
		stars = 0
		
	parking_evaluated.emit(final_score, stars)
	GameManager.complete_level(stars, final_score)
