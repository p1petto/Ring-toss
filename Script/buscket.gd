extends Area3D

var ball_on_up = false 
var ball_on_down = false
var can_emit = true
@onready var particles = $Particles3D
@onready var start_delay_timer = $StartDelayTimer
@onready var duration_timer = $DurationTimer
signal ball_collided

func _ready() -> void:
	print("Scene ready")
	# Настраиваем таймеры
	start_delay_timer.one_shot = true  # Важно!
	duration_timer.one_shot = true     # Важно!
	start_delay_timer.wait_time = 0.5
	duration_timer.wait_time = 3.0
	particles.emitting = false
	print("Particles node exists: ", particles != null)
	print("Start timer exists: ", start_delay_timer != null)
	print("Duration timer exists: ", duration_timer != null)

func _on_upper_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("Ball entered upper area")
		ball_on_up = true
		check_conditions()

func _on_upper_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("Ball exited upper area")
		ball_on_up = false

func _on_lower_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("Ball entered lower area")
		ball_on_down = true
		check_conditions()

func _on_lower_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("Ball exited lower area")
		ball_on_down = false

func check_conditions() -> void:
	print("Checking conditions: up=", ball_on_up, " down=", ball_on_down, " can_emit=", can_emit)
	if ball_on_up and ball_on_down and can_emit:
		print("Starting particle sequence")
		can_emit = false
		particles.emitting = false  
		#start_delay_timer.stop()    
		start_delay_timer.start()   
		ball_collided.emit()

func _on_start_delay_timer_timeout() -> void:
	print("Start delay timer timeout - starting particles")
	start_delay_timer.stop()
	particles.emitting = true
	duration_timer.start()

func _on_duration_timer_timeout() -> void:
	print("Duration timer timeout - stopping particles")
	duration_timer.stop()
	particles.emitting = false
	can_emit = true
