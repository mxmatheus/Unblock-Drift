class_name PlayerCarController
extends RigidBody2D

@export var max_engine_force: float = 800.0
@export var max_speed: float = 500.0
@export var steering_torque: float = 12000.0
@export var normal_linear_damp: float = 3.0
@export var handbrake_linear_damp: float = 0.8
@export var normal_angular_damp: float = 6.0
@export var handbrake_angular_damp: float = 1.2

var is_handbrake_active: bool = false
var steering_input: float = 0.0 # -1.0 (left) to 1.0 (right)
var is_stopped: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var skid_particles: GPUParticles2D = $SkidParticles

func _ready() -> void:
	linear_damp = normal_linear_damp
	angular_damp = normal_angular_damp

func _physics_process(delta: float) -> void:
	if GameManager.current_phase != GameManager.GamePhase.PHASE_2_DRIVING or is_stopped:
		return
		
	# Constant forward movement combined with steering
	var forward_dir = Vector2.UP.rotated(rotation)
	var current_speed = linear_velocity.length()
	
	if current_speed < max_speed:
		apply_central_force(forward_dir * max_engine_force)
		
	# Apply steering torque
	if steering_input != 0.0:
		apply_torque(steering_input * steering_torque * delta)

	# Skid effect visibility when handbrake or high lateral drift occurs
	if is_handbrake_active and skid_particles:
		skid_particles.emitting = true
	elif skid_particles:
		skid_particles.emitting = false

func set_handbrake(active: bool) -> void:
	is_handbrake_active = active
	if active:
		linear_damp = handbrake_linear_damp
		angular_damp = handbrake_angular_damp
		AudioManager.trigger_haptic()
	else:
		linear_damp = normal_linear_damp
		angular_damp = normal_angular_damp

func set_steering(dir: float) -> void:
	steering_input = clamp(dir, -1.0, 1.0)

func stop_vehicle() -> void:
	is_stopped = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	if skid_particles:
		skid_particles.emitting = false
