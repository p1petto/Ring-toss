extends Area3D

var ball_on_up = false
var ball_on_down = false
signal ball_collided
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_upper_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("_on_upper_area_body_entered")
		ball_on_up = true


func _on_upper_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("_on_upper_area_body_exited")
		ball_on_up = false


func _on_lower_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("_on_lower_area_body_entered")
		ball_on_down = true
		if ball_on_down and ball_on_up:
			ball_collided.emit()


func _on_lower_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		print("_on_lower_area_body_exited")
		ball_on_down = false


func _on_ball_collided() -> void:
	print ("Ураа!")
