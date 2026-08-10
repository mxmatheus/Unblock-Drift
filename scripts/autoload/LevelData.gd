extends Node

# Stores predefined level data structures
var levels_database: Dictionary = {}

func _ready() -> void:
	setup_default_levels()

func setup_default_levels() -> void:
	# Level 1: Tutorial (4x4 grid, 2 vehicles)
	levels_database[1] = {
		"grid_width": 4,
		"grid_height": 5,
		"moves_allowed": 10,
		"target_vehicle_id": "red_sports",
		"exit_cell": Vector2(3, 2), # Right edge exit
		"exit_direction": Vector2(1, 0),
		"vehicles": [
			{"id": "red_sports", "type": "SPORTS", "cell": Vector2(1, 2), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": true},
			{"id": "blue_sedan", "type": "SEDAN", "cell": Vector2(2, 0), "size": Vector2(1, 2), "orientation": "VERTICAL", "is_target": false},
			{"id": "yellow_taxi", "type": "TAXI", "cell": Vector2(0, 3), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": false}
		],
		"phase2_config": {
			"spot_position": Vector2(360, 400),
			"spot_size": Vector2(140, 220),
			"target_angle_deg": 90.0,
			"target_speed": 400.0,
			"spawn_position": Vector2(100, 1100),
			"spawn_angle_deg": 0.0
		}
	}

	# Level 2: Easy (5x5 grid, 4 vehicles)
	levels_database[2] = {
		"grid_width": 5,
		"grid_height": 6,
		"moves_allowed": 12,
		"target_vehicle_id": "red_sports",
		"exit_cell": Vector2(4, 2),
		"exit_direction": Vector2(1, 0),
		"vehicles": [
			{"id": "red_sports", "type": "SPORTS", "cell": Vector2(1, 2), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": true},
			{"id": "blue_sedan", "type": "SEDAN", "cell": Vector2(3, 1), "size": Vector2(1, 2), "orientation": "VERTICAL", "is_target": false},
			{"id": "white_van", "type": "VAN", "cell": Vector2(0, 0), "size": Vector2(1, 3), "orientation": "VERTICAL", "is_target": false},
			{"id": "green_suv", "type": "SUV", "cell": Vector2(1, 4), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": false}
		],
		"phase2_config": {
			"spot_position": Vector2(500, 350),
			"spot_size": Vector2(130, 210),
			"target_angle_deg": 0.0,
			"target_speed": 450.0,
			"spawn_position": Vector2(150, 1050),
			"spawn_angle_deg": -30.0
		}
	}

	# Level 3: Easy (5x5 grid, 5 vehicles)
	levels_database[3] = {
		"grid_width": 5,
		"grid_height": 6,
		"moves_allowed": 15,
		"target_vehicle_id": "red_sports",
		"exit_cell": Vector2(4, 2),
		"exit_direction": Vector2(1, 0),
		"vehicles": [
			{"id": "red_sports", "type": "SPORTS", "cell": Vector2(0, 2), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": true},
			{"id": "police", "type": "POLICE", "cell": Vector2(2, 1), "size": Vector2(1, 2), "orientation": "VERTICAL", "is_target": false},
			{"id": "yellow_taxi", "type": "TAXI", "cell": Vector2(3, 2), "size": Vector2(1, 2), "orientation": "VERTICAL", "is_target": false},
			{"id": "black_truck", "type": "TRUCK", "cell": Vector2(0, 4), "size": Vector2(3, 1), "orientation": "HORIZONTAL", "is_target": false},
			{"id": "white_van", "type": "VAN", "cell": Vector2(4, 0), "size": Vector2(1, 2), "orientation": "VERTICAL", "is_target": false}
		],
		"phase2_config": {
			"spot_position": Vector2(360, 300),
			"spot_size": Vector2(130, 210),
			"target_angle_deg": 180.0,
			"target_speed": 480.0,
			"spawn_position": Vector2(360, 1100),
			"spawn_angle_deg": 0.0
		}
	}

	# Level 4: Medium (6x6 grid, 6 vehicles)
	levels_database[4] = {
		"grid_width": 6,
		"grid_height": 6,
		"moves_allowed": 16,
		"target_vehicle_id": "red_sports",
		"exit_cell": Vector2(5, 2),
		"exit_direction": Vector2(1, 0),
		"vehicles": [
			{"id": "red_sports", "type": "SPORTS", "cell": Vector2(1, 2), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": true},
			{"id": "fire_truck", "type": "FIRE_TRUCK", "cell": Vector2(3, 0), "size": Vector2(1, 3), "orientation": "VERTICAL", "is_target": false},
			{"id": "ambulance", "type": "AMBULANCE", "cell": Vector2(0, 0), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": false},
			{"id": "bus", "type": "BUS", "cell": Vector2(4, 2), "size": Vector2(1, 3), "orientation": "VERTICAL", "is_target": false},
			{"id": "blue_sedan", "type": "SEDAN", "cell": Vector2(1, 3), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": false},
			{"id": "green_suv", "type": "SUV", "cell": Vector2(0, 5), "size": Vector2(3, 1), "orientation": "HORIZONTAL", "is_target": false}
		],
		"phase2_config": {
			"spot_position": Vector2(250, 280),
			"spot_size": Vector2(125, 200),
			"target_angle_deg": 45.0,
			"target_speed": 500.0,
			"spawn_position": Vector2(600, 1100),
			"spawn_angle_deg": -45.0
		}
	}

	# Level 5 to 10: Parametric level creation
	for idx in range(5, 11):
		levels_database[idx] = generate_level_config(idx)

func generate_level_config(idx: int) -> Dictionary:
	var width = 6
	var height = 7
	var moves = 18 - (idx - 5)
	
	return {
		"grid_width": width,
		"grid_height": height,
		"moves_allowed": max(8, moves),
		"target_vehicle_id": "red_sports",
		"exit_cell": Vector2(width - 1, 2),
		"exit_direction": Vector2(1, 0),
		"vehicles": [
			{"id": "red_sports", "type": "SPORTS", "cell": Vector2(0, 2), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": true},
			{"id": "truck_1", "type": "TRUCK", "cell": Vector2(2, 0), "size": Vector2(1, 3), "orientation": "VERTICAL", "is_target": false},
			{"id": "bus_1", "type": "BUS", "cell": Vector2(4, 1), "size": Vector2(1, 3), "orientation": "VERTICAL", "is_target": false},
			{"id": "van_1", "type": "VAN", "cell": Vector2(0, 4), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": false},
			{"id": "taxi_1", "type": "TAXI", "cell": Vector2(3, 4), "size": Vector2(1, 2), "orientation": "VERTICAL", "is_target": false},
			{"id": "sedan_1", "type": "SEDAN", "cell": Vector2(1, 5), "size": Vector2(2, 1), "orientation": "HORIZONTAL", "is_target": false}
		],
		"phase2_config": {
			"spot_position": Vector2(360 + (idx % 2) * 100, 300 + (idx % 3) * 50),
			"spot_size": Vector2(120, 195),
			"target_angle_deg": float(idx * 30 % 360),
			"target_speed": 480.0 + idx * 20,
			"spawn_position": Vector2(200 + (idx % 3) * 150, 1100),
			"spawn_angle_deg": 0.0
		}
	}

func get_level(level_idx: int) -> Dictionary:
	if levels_database.has(level_idx):
		return levels_database[level_idx]
	return levels_database[1]
