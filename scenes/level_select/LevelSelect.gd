extends Control

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	populate_levels()

func populate_levels() -> void:
	# Clear existing
	for child in grid_container.get_children():
		child.queue_free()
		
	for lvl in range(1, 11):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(120, 120)
		
		var unlocked = SaveSystem.is_level_unlocked(lvl)
		var stars = SaveSystem.get_level_stars(lvl)
		
		if unlocked:
			var star_str = ""
			for i in range(stars):
				star_str += "★"
			for i in range(3 - stars):
				star_str += "☆"
				
			btn.text = "LEVEL %d\n%s" % [lvl, star_str]
			btn.disabled = false
			btn.pressed.connect(Callable(self, "_on_level_selected").bind(lvl))
		else:
			btn.text = "LOCKED\n🔒"
			btn.disabled = true
			
		grid_container.add_child(btn)

func _on_level_selected(level_idx: int) -> void:
	AudioManager.play_sfx("click")
	GameManager.load_level(level_idx)

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
