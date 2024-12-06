extends XRToolsPickable

class_name Ball

#@onready var collision_shape = $CollisionShape3D
#@onready var mesh = $MeshInstance3D
@onready var timer = $Timer

signal ball_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#collision_shape.shape.radius = mesh.mesh.radius
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	timer.start()
	


func _on_timer_timeout() -> void:
	
	queue_free()
	ball_died.emit()
	print("Die")


func _on_picked_up(pickable: Variant) -> void:
	gravity_scale = 1
