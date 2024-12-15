extends XRToolsPickable
class_name Ball

@onready var timer = $Timer
@onready var sound = $AudioStreamPlayer3D

signal ball_fell
signal ball_died

var picked = false
var flag = false
var previous_position: Vector3
var impact_velocity: float = 0.0

func _ready() -> void:
	previous_position = global_position

func _physics_process(delta: float) -> void:
	var velocity = (global_position - previous_position).length() / delta
	
	if global_position.y < previous_position.y:
		impact_velocity = velocity
		
	previous_position = global_position

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body.is_in_group("Box"):
		var base_velocity = 5.0
		var volume_multiplier = clamp(impact_velocity / base_velocity, 0.0, 1.0)
		volume_multiplier = pow(volume_multiplier, 2)  
		
		var min_volume_db = -40.0
		var max_volume_db = -20.0
		var volume = lerp(min_volume_db, max_volume_db, volume_multiplier)
		
		print("Impact velocity: ", impact_velocity)
		print("Volume multiplier: ", volume_multiplier)
		print("Volume: ", volume)
		
		sound.volume_db = volume
		timer.start()
		sound.playing = true
		if !flag:
			ball_fell.emit()

func _on_timer_timeout() -> void:
	queue_free()
	ball_died.emit()
	print("Die")

func _on_picked_up(pickable: Variant) -> void:
	var picked = true
	gravity_scale = 1
	impact_velocity = 0.0
	set_collision_mask_value(17, 1)
