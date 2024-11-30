extends CharacterBody3D

@onready var plane = $"../Plane"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sensitivity = 0.002
var rings: Array[Ring] = []
var base_rings: Array[Ring] = []  # Кольца, которые находятся на земле

signal ring_is_taken



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#ring_is_taken.connect(move_to_hand())
	for child in $"../".get_children():
		if child is Ring:
			rings.append(child)
			
	# Подключаем сигналы от каждого кольца
	for ring in rings:
		ring.stack_updated.connect(_on_ring_stack_updated)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func move_to_hand():
	pass
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$XRCamera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$XRCamera3D.rotation.x = clampf($XRCamera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
			
func _on_ring_stack_updated(_ring: Ring) -> void:
	_update_base_rings()
	_print_all_stacks()
	_check_win()

func _update_base_rings() -> void:
	base_rings.clear()
	
	# Находим кольца без нижних колец (стоящие на земле)
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
				# Здесь можно добавить дополнительные действия при победе
				# Например, показать UI, остановить игру и т.д.
				_show_win_message()
				return
	
	# Если мы дошли до этой точки, значит правильный стек не найден
	# print("Продолжайте собирать стек...")

func _show_win_message() -> void:
	# Можно добавить показ UI с сообщением о победе
	print("======================")
	print("🎉 Поздравляем! 🎉")
	print("Вы успешно собрали пирамиду!")
	print("======================")
	
	# Дополнительные действия при победе
	# Например, можно освободить мышь
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Можно добавить паузу или другие игровые эффекты
	# get_tree().paused = true
