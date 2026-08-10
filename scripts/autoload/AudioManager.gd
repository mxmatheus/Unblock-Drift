extends Node

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	music_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	add_child(music_player)

func play_sfx(_sound_name: String) -> void:
	if not SaveSystem.save_data.get("sound_enabled", true):
		return
	# Audio stream placeholder trigger logic

func play_music(_music_name: String) -> void:
	if not SaveSystem.save_data.get("music_enabled", true):
		return
	# Audio stream placeholder trigger logic

func trigger_haptic() -> void:
	if SaveSystem.save_data.get("vibration_enabled", true):
		Input.vibrate_handheld(50)
