extends Node3D

@export var ray_length = 100

@onready var camera: XRCamera3D = $"../XRCamera3D"
@onready var raycaster: RayCast3D = $"../XRCamera3D/RayCast3D"



func _ready():
	camera.current = true
	camera.add_child(raycaster)
	raycaster.target_position = Vector3(0, 0, -ray_length)


func get_look_position() -> Vector3:
	if raycaster.is_colliding():
		return raycaster.get_collision_point()
	return Vector3.ZERO
