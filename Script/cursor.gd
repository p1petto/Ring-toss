extends Node3D

@export var ray_length = 100
@export var item_offset: Vector3 = Vector3(-2, 1, 2.5)
@export var gaze_threshold: float = 0.1  # Максимальное допустимое отклонение курсора
@export var gaze_time: float = 1.5  # Время удержания взгляда в секундах

@onready var camera: XRCamera3D = $"../"
@onready var raycaster: RayCast3D = $"../RayCast3D"
@onready var progress_bar = $TextureProgressBar
@onready var world = $"../../../"
@onready var timer = $Timer

var hands_are_employed: bool = false
var last_gaze_position: Vector3 = Vector3.ZERO
var current_gazed_object: Node3D = null

func _ready():
	camera.current = true
	raycaster.target_position = Vector3(0, 0, -ray_length)
	
	# Настройка таймера
	timer.wait_time = gaze_time
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_gaze_timer_timeout"))
	progress_bar.value = 0
	progress_bar.max_value = 100

func _process(delta):
	var looked_object = get_looked_object()
	var look_position = get_look_position()
	
	# Обновление прогресс бара
	if timer.time_left > 0:
		var progress = ((gaze_time - timer.time_left) / gaze_time) * 100
		progress_bar.value = progress
	else:
		progress_bar.value = 0
	
	# Если держим предмет, проверяем любую поверхность
	if hands_are_employed:
		if looked_object:
			if current_gazed_object != looked_object or \
			   last_gaze_position.distance_to(look_position) > gaze_threshold:
				current_gazed_object = looked_object
				last_gaze_position = look_position
				timer.start()
				progress_bar.value = 0
		else:
			current_gazed_object = null
			timer.stop()
			progress_bar.value = 0
	# Если не держим предмет, проверяем только Rings
	else:
		if looked_object and looked_object.is_in_group("Rings"):
			if current_gazed_object != looked_object or \
			   last_gaze_position.distance_to(look_position) > gaze_threshold:
				current_gazed_object = looked_object
				last_gaze_position = look_position
				timer.start()
				progress_bar.value = 0
		else:
			current_gazed_object = null
			timer.stop()
			progress_bar.value = 0

func _on_gaze_timer_timeout():
	if current_gazed_object:
		if !hands_are_employed and current_gazed_object.is_in_group("Rings"):
			take_item()
		elif hands_are_employed:
			drop_item()
	progress_bar.value = 0

func get_looked_object() -> Node3D:
	if raycaster.is_colliding():
		return raycaster.get_collider()
	return null

func get_look_position() -> Vector3:
	if raycaster.is_colliding():
		return raycaster.get_collision_point()
	return Vector3.ZERO

func take_item():
	var item = current_gazed_object
	if item:
		item.get_parent().remove_child(item)
		camera.add_child(item)
		hands_are_employed = true
		item.transform.origin = camera.transform.origin - item_offset
		
		if item is RigidBody3D:
			item.process_mode = 4
		
		var collision_shape = item.get_node("CollisionShape3D") if item.has_node("CollisionShape3D") else null
		if collision_shape:
			collision_shape.disabled = true

func drop_item():
	for child in camera.get_children():
		if child.is_in_group("Rings"):
			var item = child
			camera.remove_child(item)
			world.add_child(item)
			item.global_transform.origin = raycaster.get_collision_point() + Vector3(0, 1, 0)
			
			if item is RigidBody3D:
				item.process_mode = 1
			
			var collision_shape = item.get_node("CollisionShape3D") if item.has_node("CollisionShape3D") else null
			if collision_shape:
				collision_shape.disabled = false
			
			hands_are_employed = false
			return
