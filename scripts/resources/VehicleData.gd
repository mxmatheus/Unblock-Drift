class_name VehicleData
extends Resource

enum VehicleType {
	SEDAN,
	SPORTS,
	TAXI,
	POLICE,
	AMBULANCE,
	VAN,
	SUV,
	PICKUP,
	TRUCK,
	FIRE_TRUCK,
	BUS
}

@export var vehicle_id: String = ""
@export var type: VehicleType = VehicleType.SEDAN
@export var texture: Texture2D
@export var region_rect: Rect2 = Rect2(0, 0, 128, 256)
@export var grid_size: Vector2 = Vector2(1, 2)
@export var is_target: bool = false
