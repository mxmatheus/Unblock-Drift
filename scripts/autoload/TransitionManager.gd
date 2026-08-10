extends Node

signal transition_started
signal transition_finished

var overlay_rect: ColorRect

func _ready() -> void:
	layer = 100
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	overlay_rect = ColorRect.new()
	overlay_rect.color = Color(0, 0, 0, 0)
	overlay_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(overlay_rect)

func start_transition_to_phase2() -> void:
	transition_started.emit()
	GameManager.change_phase(GameManager.GamePhase.TRANSITION)
	
	# Create fade-to-black tween
	var tween = create_tween()
	tween.tween_property(overlay_rect, "color:a", 1.0, 0.6)
	tween.tween_callback(Callable(self, "_on_fade_out_complete"))

func _on_fade_out_complete() -> void:
	GameManager.change_phase(GameManager.GamePhase.PHASE_2_DRIVING)
	get_tree().change_scene_to_file("res://scenes/phase2_driving/Phase2Driving.tscn")
	
	var tween = create_tween()
	tween.tween_property(overlay_rect, "color:a", 0.0, 0.6)
	tween.tween_callback(Callable(self, "_on_fade_in_complete"))

func _on_fade_in_complete() -> void:
	transition_finished.emit()
