extends Area3D

var ball_on_up = false 
var ball_on_down = false
@onready var start_delay_timer = $StartDelayTimer
@onready var duration_timer = $DurationTimer
signal ball_collided

func _ready() -> void:
	pass


func _on_upper_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		ball_on_up = true

func _on_upper_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		ball_on_up = false

func _on_lower_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		ball_on_down = true
		if ball_on_up:
			ball_collided.emit()
			body.flag = true

func _on_lower_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		ball_on_down = false
