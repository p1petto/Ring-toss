extends Node3D

var rings: Array[Ring] = []
var base_rings: Array[Ring] = []  # Кольца, которые находятся на земле

func _ready() -> void:
	# Находим все кольца в сцене
	for child in get_children():
		if child is Ring:
			rings.append(child)
			
	# Подключаем сигналы от каждого кольца
	for ring in rings:
		ring.stack_updated.connect(_on_ring_stack_updated)

func _on_ring_stack_updated(_ring: Ring) -> void:
	_update_base_rings()
	_print_all_stacks()

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
