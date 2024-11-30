extends RigidBody3D
class_name Ring

signal stack_updated(ring: Ring)

@onready var model = $model
@onready var collision_shape = $CollisionShape3D
@onready var area_shape = $Area3D/CollisionShape3D2
@export var ring_type: RingType

var rings_above: Array[Ring] = []
var ring_below: Ring = null
var is_stacked := false

func _ready() -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = ring_type.color
	model.material = material
	
	model.radius = ring_type.radius
	collision_shape.shape = collision_shape.shape.duplicate()
	area_shape.shape = area_shape.shape.duplicate()
	
	collision_shape.shape.radius = ring_type.radius
	area_shape.shape.radius = ring_type.radius
	
	# Подключаем сигналы Area3D
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is Ring and body != self:
		var height_diff = body.global_position.y - global_position.y
		
		# Если кольцо выше текущего
		if height_diff > 0 and not rings_above.has(body):
			rings_above.append(body)
			body.ring_below = self
			body.is_stacked = true
			_update_stack_status()
			
		# Если кольцо ниже текущего
		elif height_diff < 0 and ring_below != body:
			ring_below = body
			body.rings_above.append(self)
			is_stacked = true
			_update_stack_status()

func _on_body_exited(body: Node3D) -> void:
	if body is Ring:
		# Удаляем кольцо из массива верхних колец
		if rings_above.has(body):
			rings_above.erase(body)
			body.ring_below = null
			body.is_stacked = false
			
		# Очищаем ссылку на нижнее кольцо
		if ring_below == body:
			ring_below = null
			is_stacked = false
			body.rings_above.erase(self)
		
		_update_stack_status()

func _update_stack_status() -> void:
	emit_signal("stack_updated", self)
	
	# Проверяем правильность порядка колец
	if ring_below and ring_type.radius > ring_below.ring_type.radius:
		print("Warning: Larger ring on top of smaller ring!")

func get_stack_height() -> int:
	var height := 1  # Текущее кольцо
	var current := self
	
	# Считаем кольца вверх
	while not current.rings_above.is_empty():
		height += 1
		current = current.rings_above[0]
	
	return height

func is_valid_stack() -> bool:
	# Проверяем, что кольца уложены по размеру (большие внизу)
	if ring_below and ring_type.radius > ring_below.ring_type.radius:
		return false
		
	for ring in rings_above:
		if ring.ring_type.radius >= ring_type.radius:
			return false
	
	return true
