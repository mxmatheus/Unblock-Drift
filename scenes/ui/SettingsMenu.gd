extends Control

@onready var sound_check: CheckButton = $VBoxContainer/SoundToggle/CheckButton
@onready var music_check: CheckButton = $VBoxContainer/MusicToggle/CheckButton
@onready var vibe_check: CheckButton = $VBoxContainer/VibeToggle/CheckButton
@onready var back_button: Button = $BackButton

func _ready() -> void:
	sound_check.button_pressed = SaveSystem.save_data.get("sound_enabled", true)
	music_check.button_pressed = SaveSystem.save_data.get("music_enabled", true)
	vibe_check.button_pressed = SaveSystem.save_data.get("vibration_enabled", true)
	
	sound_check.toggled.connect(_on_sound_toggled)
	music_check.toggled.connect(_on_music_toggled)
	vibe_check.toggled.connect(_on_vibe_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _on_sound_toggled(toggled: bool) -> void:
	SaveSystem.save_data["sound_enabled"] = toggled
	SaveSystem.save_to_disk()

func _on_music_toggled(toggled: bool) -> void:
	SaveSystem.save_data["music_enabled"] = toggled
	SaveSystem.save_to_disk()

func _on_vibe_toggled(toggled: bool) -> void:
	SaveSystem.save_data["vibration_enabled"] = toggled
	SaveSystem.save_to_disk()

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
