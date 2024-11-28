extends RigidBody3D

@onready var model = $model
@onready var collision_shape = $CollisionShape3D
@onready var area_shape = $Area3D/CollisionShape3D2
@export var ring_type: RingType

func _ready() -> void:
	# Материал
	var material = StandardMaterial3D.new()
	material.albedo_color = ring_type.color
	model.material = material
	
	# Модель
	model.radius = ring_type.radius
	
	# Дублируем формы для уникальных коллизий
	collision_shape.shape = collision_shape.shape.duplicate()
	area_shape.shape = area_shape.shape.duplicate()
	
	# Устанавливаем радиус для форм
	collision_shape.shape.radius = ring_type.radius
	area_shape.shape.radius = ring_type.radius

func _process(delta: float) -> void:
	pass
