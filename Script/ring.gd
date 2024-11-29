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

#func _physics_process(delta):
	#for body in get_tree().get_nodes_in_group("Rings"):
		#if body != self:  # Не проверяем себя
			#var distance = global_position.distance_to(body.global_position)
			## Проверяем, что кольцо находится над нами
			#if distance < 1.0 and body.global_position.y > global_position.y:
				#print(body.name)
#
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Rings"):
		print("Сверху ", body.name)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Rings"):
		print("Сняли ", body.name)
