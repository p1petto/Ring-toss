extends CharacterBody3D

@onready var camera = $XROrigin3D/XRCamera3D
@onready var right_controller = $XROrigin3D/RightXRController3D
@onready var function_pointer = $XROrigin3D/RightXRController3D/FunctionPointer 
@onready var ray_cast = $XROrigin3D/RightXRController3D/FunctionPointer/RayCast
@onready var world = $"../"
@onready var plane = $"../Plane"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var rings: Array[Ring] = []
var base_rings: Array[Ring] = []
var held_object = null

func _ready():
	# Настраиваем RayCast
	if ray_cast:
		ray_cast.collision_mask = 1  # Установите нужную маску коллизий
		ray_cast.target_position = Vector3(0, 0, -10)  # Длина луча
		ray_cast.collide_with_bodies = true
		ray_cast.enabled = true
	
	# Собираем все кольца на сцене
	for child in $"../".get_children():
		if child is Ring:
			rings.append(child)
			
	# Подключаем сигналы от колец
	for ring in rings:
		ring.stack_updated.connect(_on_ring_stack_updated)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Обработка движения
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Обновляем позицию удерживаемого объекта
	#if held_object:
		#var controller_pos = right_controller.global_transform.origin
		#var controller_forward = -right_controller.global_transform.basis.z
		#held_object.global_transform.origin = controller_pos + controller_forward * 0.3
#
#func try_grab_object() -> void:
	#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "1:Entering try_grab_object"
	#
	#if not ray_cast:
		#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "2:ray_cast is null"
		#return
		#
	#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "3:Getting collider"
	#
	## Проверяем, есть ли столкновение
	#if ray_cast.is_colliding():
		#var collider = ray_cast.get_collider()
		#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "4:Collider=" + str(collider.name)
		#
		#if collider.is_in_group("Rings"):
			##$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "5:Is in Rings group"
			#grab_object(collider)
		#else:
			#pass
			##$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "6:Not in Rings group"
	#else:
		#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "7:No collision detected"
#
#func grab_object(object: Node3D) -> void:
	#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = object.name
	#if object.get_parent():
		#object.get_parent().remove_child(object)
		#right_controller.add_child(object)
		#held_object = object
		#
		#if object is RigidBody3D:
			#object.process_mode = Node.PROCESS_MODE_DISABLED
		#
		#var collision_shape = object.get_node("CollisionShape3D")
		#if collision_shape:
			#collision_shape.disabled = true
#
#func drop_object() -> void:
	#if held_object:
		#right_controller.remove_child(held_object)
		#world.add_child(held_object)
		#
		#var drop_pos = right_controller.global_transform.origin
		#var forward = -right_controller.global_transform.basis.z
		#held_object.global_transform.origin = drop_pos + forward * 0.5
		#
		#if held_object is RigidBody3D:
			#held_object.process_mode = Node.PROCESS_MODE_INHERIT
		#
		#var collision_shape = held_object.get_node("CollisionShape3D")
		#if collision_shape:
			#collision_shape.disabled = false
			#
		#held_object = null

#func _on_right_xr_controller_3d_button_pressed(name: String) -> void:
	#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "_on_right_xr_controller_3d_button_pressed"
	#if name == "trigger_click":
		#if held_object:
			#drop_object()
		#else:
			#$XROrigin3D/XRCamera3D/MeshInstance3D.mesh.text = "click"
			#try_grab_object()
			
func _on_ring_stack_updated(_ring: Ring) -> void:
	_update_base_rings()
	_print_all_stacks()
	_check_win()

func _update_base_rings() -> void:
	base_rings.clear()
	for ring in rings:
		if not ring.ring_below:
			base_rings.append(ring)

func _print_all_stacks() -> void:
	print("\nCurrent Stacks Status:")
	for base_ring in base_rings:
		var stack = _get_stack_from_base(base_ring)
		print("Stack starting with ", base_ring.name, ":")
		_print_stack(stack)
	print("------------------------")

func _get_stack_from_base(base_ring: Ring) -> Array[Ring]:
	var stack: Array[Ring] = []
	var current_ring := base_ring
	
	while current_ring != null:
		stack.append(current_ring)
		if current_ring.rings_above.is_empty():
			break
		current_ring = current_ring.rings_above[0]
	
	return stack

func _print_stack(stack: Array[Ring]) -> void:
	var indent := "\t"
	for i in stack.size():
		var ring := stack[i]
		print(indent.repeat(i), "└─ ", ring.name, 
			" (radius: ", ring.ring_type.radius, ")")

func _check_win() -> void:
	# Проверяем каждый базовый стек
	for base_ring in base_rings:
		var stack = _get_stack_from_base(base_ring)
		
		# Проверяем, совпадает ли длина стека с требуемой
		if stack.size() == plane.rings.size():
			var is_correct = true
			
			# Сравниваем типы колец
			for i in stack.size():
				if stack[i].ring_type != plane.rings[i]:
					is_correct = false
					break
			
			# Если нашли правильный стек
			if is_correct:
				print("Победа! Стек собран правильно!")
				_show_win_message()
				return

func _show_win_message() -> void:
	print("======================")
	print("🎉 Поздравляем! 🎉")
	print("Вы успешно собрали пирамиду!")
	print("======================")
