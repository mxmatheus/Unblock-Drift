class_name GridSystem
extends Node2D

@export var cell_size: Vector2 = Vector2(80, 80)
@export var grid_size: Vector2i = Vector2i(6, 6)

var occupancy_matrix: Array = []
var vehicles_list: Array = []
var exit_cell: Vector2i = Vector2i(5, 2)
var target_vehicle: Node2D = null

func initialize_grid(width: int, height: int, p_exit_cell: Vector2) -> void:
	grid_size = Vector2i(width, height)
	exit_cell = Vector2i(p_exit_cell.x, p_exit_cell.y)
	
	occupancy_matrix.clear()
	for y in range(grid_size.y):
		var row: Array = []
		for x in range(grid_size.x):
			row.append(null)
		occupancy_matrix.append(row)

func register_vehicle(vehicle: Node2D) -> void:
	vehicles_list.append(vehicle)
	update_vehicle_occupancy(vehicle)
	if vehicle.is_target:
		target_vehicle = vehicle

func update_vehicle_occupancy(vehicle: Node2D) -> void:
	# Clear previous vehicle references
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if occupancy_matrix[y][x] == vehicle:
				occupancy_matrix[y][x] = null
				
	# Occupy new cells
	var start_cell = vehicle.cell_position
	var size = vehicle.grid_size
	
	for dx in range(int(size.x)):
		for dy in range(int(size.y)):
			var cx = start_cell.x + dx
			var cy = start_cell.y + dy
			if cx >= 0 and cx < grid_size.x and cy >= 0 and cy < grid_size.y:
				occupancy_matrix[cy][cx] = vehicle

func calculate_slide_bounds(vehicle: Node2D) -> Dictionary:
	var start_cell = vehicle.cell_position
	var size = vehicle.grid_size
	var is_horizontal = vehicle.orientation == "HORIZONTAL"
	
	var min_bound: int = 0
	var max_bound: int = 0
	
	if is_horizontal:
		# Search left limit
		min_bound = start_cell.x
		for x in range(start_cell.x - 1, -1, -1):
			var blocked = false
			for dy in range(int(size.y)):
				if occupancy_matrix[start_cell.y + dy][x] != null and occupancy_matrix[start_cell.y + dy][x] != vehicle:
					blocked = true
					break
			if blocked:
				break
			min_bound = x
			
		# Search right limit
		max_bound = start_cell.x
		var right_edge = start_cell.x + int(size.x) - 1
		for x in range(right_edge + 1, grid_size.x):
			var blocked = false
			for dy in range(int(size.y)):
				if occupancy_matrix[start_cell.y + dy][x] != null and occupancy_matrix[start_cell.y + dy][x] != vehicle:
					blocked = true
					break
			if blocked:
				break
			max_bound = x - int(size.x) + 1
			
		# Check exit opening for target vehicle
		if vehicle.is_target and exit_cell.x == grid_size.x - 1:
			max_bound += 1
			
	else:
		# Search top limit
		min_bound = start_cell.y
		for y in range(start_cell.y - 1, -1, -1):
			var blocked = false
			for dx in range(int(size.x)):
				if occupancy_matrix[y][start_cell.x + dx] != null and occupancy_matrix[y][start_cell.x + dx] != vehicle:
					blocked = true
					break
			if blocked:
				break
			min_bound = y
			
		# Search bottom limit
		max_bound = start_cell.y
		var bottom_edge = start_cell.y + int(size.y) - 1
		for y in range(bottom_edge + 1, grid_size.y):
			var blocked = false
			for dx in range(int(size.x)):
				if occupancy_matrix[y][start_cell.x + dx] != null and occupancy_matrix[y][start_cell.x + dx] != vehicle:
					blocked = true
					break
			if blocked:
				break
			max_bound = y - int(size.y) + 1
			
	return {"min": min_bound, "max": max_bound}

func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size.x, cell.y * cell_size.y)

func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / cell_size.x), round(pos.y / cell_size.y))
