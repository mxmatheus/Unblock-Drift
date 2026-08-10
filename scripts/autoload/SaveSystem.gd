extends Node

const SAVE_PATH: String = "user://unblock_drift_save.json"

var save_data: Dictionary = {
	"unlocked_level": 1,
	"levels": {}, # level_idx (String): {"stars": int, "high_score": float, "completed": bool}
	"sound_enabled": true,
	"music_enabled": true,
	"vibration_enabled": true,
	"coins": 0
}

func _ready() -> void:
	load_data()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_to_disk()
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK and typeof(json.data) == TYPE_DICTIONARY:
			save_data = json.data

func save_to_disk() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

func is_level_unlocked(level_idx: int) -> bool:
	if level_idx == 1:
		return true
	var unlocked = save_data.get("unlocked_level", 1)
	return level_idx <= unlocked

func save_level_result(level_idx: int, stars: int, score: float) -> void:
	var key = str(level_idx)
	var existing = save_data["levels"].get(key, {"stars": 0, "high_score": 0.0, "completed": false})
	
	existing["completed"] = true
	existing["stars"] = max(existing["stars"], stars)
	existing["high_score"] = max(existing["high_score"], score)
	save_data["levels"][key] = existing
	
	if stars >= 1:
		var current_unlocked = save_data.get("unlocked_level", 1)
		save_data["unlocked_level"] = max(current_unlocked, level_idx + 1)
		
	save_to_disk()

func get_level_stars(level_idx: int) -> int:
	var key = str(level_idx)
	if save_data["levels"].has(key):
		return save_data["levels"][key].get("stars", 0)
	return 0

func get_level_score(level_idx: int) -> float:
	var key = str(level_idx)
	if save_data["levels"].has(key):
		return save_data["levels"][key].get("high_score", 0.0)
	return 0.0
