extends Node3D
@export var ray_length = 100
@export var item_offset: Vector3 = Vector3(-2, 1, 2.5) 
@onready var camera: XRCamera3D = $"../XRCamera3D"
@onready var raycaster: RayCast3D = $"../XRCamera3D/RayCast3D"
@onready var cursor: ColorRect = $"../XRCamera3D/ColorRect"
@onready var world = $"../../"

var hands_are_employed: bool = false

func _ready():
	camera.current = true
	#camera.add_child(raycaster)
	raycaster.target_position = Vector3(0, 0, -ray_length)

func get_looked_object() -> Node3D:
	if raycaster.is_colliding():
		return raycaster.get_collider()
	return null

func get_look_position() -> Vector3:
	return raycaster.get_collision_point()
	return Vector3.ZERO

func _input(event):
	if event.is_action_pressed("interact"):
		var looked_object = get_looked_object()
		if looked_object:
			print("Позиция:", get_look_position())
			if looked_object.is_in_group("Rings") and !hands_are_employed:
				take_item()
			elif hands_are_employed:
				drop_item()

func take_item():
	var item = get_looked_object()
	if item:
		print("Подобрал предмет:", item.name)
		
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
	# Ищем объект, который находится в руках (дочерний элемент камеры)
	for child in camera.get_children():
		if child.is_in_group("Rings"):  # Проверяем, что это предмет из группы "Rings"
			var item = child
			
			# Удаляем предмет из камеры
			camera.remove_child(item)
			
			# Возвращаем его в сцену (например, в корневую ноду или другую логическую родительскую ноду)
			world.add_child(item)
			
			# Устанавливаем его позицию перед камерой
			item.global_transform.origin = raycaster.get_collision_point() + Vector3(0, 1, 0)
			
			# Активируем физику (если это RigidBody3D)
			if item is RigidBody3D:
				item.process_mode = 1  # Снова включаем физику (в зависимости от вашего режима)
			
			# Включаем коллизии обратно
			var collision_shape = item.get_node("CollisionShape3D") if item.has_node("CollisionShape3D") else null
			if collision_shape:
				collision_shape.disabled = false
			
			# Устанавливаем, что руки больше не заняты
			hands_are_employed = false
			
			print("Выбросил предмет:", item.name)
			return
