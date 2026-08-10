class_name VehicleController
extends Area2D

signal drag_completed

@export var vehicle_id: String = "vehicle"
@export var grid_size: Vector2 = Vector2(2, 1)
@export var orientation: String = "HORIZONTAL" # "HORIZONTAL" or "VERTICAL"
@export var is_target: bool = false
@export var cell_position: Vector2i = Vector2i(0, 0)

var grid_system: GridSystem
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_start_vehicle_pos: Vector2 = Vector2.ZERO
var slide_bounds: Dictionary = {"min": 0, "max": 0}

@onready var sprite: Sprite2D = $Sprite2D
@onready var glow_outline: Sprite2D = $GlowOutline

func _ready() -> void:
	input_event.connect(_on_input_event)

func setup(p_id: String, p_size: Vector2, p_orientation: String, p_cell: Vector2i, p_is_target: bool, p_grid: GridSystem) -> void:
	vehicle_id = p_id
	grid_size = p_size
	orientation = p_orientation
	cell_position = p_cell
	is_target = p_is_target
	grid_system = p_grid
	
	position = grid_system.grid_to_world(cell_position)
	setup_visuals()

func setup_visuals() -> void:
	if glow_outline:
		glow_outline.visible = is_target

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if GameManager.current_phase != GameManager.GamePhase.PHASE_1_PUZZLE:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drag(event.global_position)
		elif is_dragging:
			end_drag()
			
	elif event is InputEventScreenTouch:
		if event.pressed:
			start_drag(event.position)
		elif is_dragging:
			end_drag()

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return
		
	if event is InputEventMouseMotion:
		update_drag(event.global_position)
	elif event is InputEventScreenDrag:
		update_drag(event.position)
	elif (event is InputEventMouseButton and not event.pressed) or (event is InputEventScreenTouch and not event.pressed):
		end_drag()

func start_drag(global_touch_pos: Vector2) -> void:
	is_dragging = true
	drag_start_mouse_pos = global_touch_pos
	drag_start_vehicle_pos = position
	slide_bounds = grid_system.calculate_slide_bounds(self)
	
	# Scale bounce visual feedback
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func update_drag(global_touch_pos: Vector2) -> void:
	var delta_pos = global_touch_pos - drag_start_mouse_pos
	var cell_px = grid_system.cell_size
	
	if orientation == "HORIZONTAL":
		var new_x = drag_start_vehicle_pos.x + delta_pos.x
		var min_x = slide_bounds["min"] * cell_px.x
		var max_x = slide_bounds["max"] * cell_px.x
		position.x = clamp(new_x, min_x, max_x)
	else:
		var new_y = drag_start_vehicle_pos.y + delta_pos.y
		var min_y = slide_bounds["min"] * cell_px.y
		var max_y = slide_bounds["max"] * cell_px.y
		position.y = clamp(new_y, min_y, max_y)

func end_drag() -> void:
	is_dragging = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Calculate target cell to snap
	var cell_px = grid_system.cell_size
	var target_cell: Vector2i = cell_position
	
	if orientation == "HORIZONTAL":
		target_cell.x = int(round(position.x / cell_px.x))
	else:
		target_cell.y = int(round(position.y / cell_px.y))
		
	var moved = (target_cell != cell_position)
	cell_position = target_cell
	grid_system.update_vehicle_occupancy(self)
	
	# Smooth snap animation
	var snap_pos = grid_system.grid_to_world(cell_position)
	var snap_tween = create_tween()
	snap_tween.tween_property(self, "position", snap_pos, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if moved:
		GameManager.use_move()
		AudioManager.trigger_haptic()
		AudioManager.play_sfx("click")
		drag_completed.emit()
		
	# Check exit condition
	if is_target:
		if (orientation == "HORIZONTAL" and cell_position.x >= grid_system.grid_size.x - 1) or \
		   (orientation == "VERTICAL" and cell_position.y >= grid_system.grid_size.y - 1):
			trigger_exit_sequence()

func trigger_exit_sequence() -> void:
	# Slide out animation
	var exit_dir = Vector2(1, 0) if orientation == "HORIZONTAL" else Vector2(0, 1)
	var exit_target_pos = position + exit_dir * 300.0
	
	var tween = create_tween()
	tween.tween_property(self, "position", exit_target_pos, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	GameManager.complete_phase1(global_position, exit_dir, vehicle_id)
