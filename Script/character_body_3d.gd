extends XROrigin3D

@onready var camera = $XRCamera3D
@onready var world = $"../"
@onready var ball = $"../PickableObject"
@onready var busket = $"../StaticBody3D2/Busket"
@onready var text_debug = $XRCamera3D/MeshInstance3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var is_zone_2 = false
var curent_score = 0
var best_score = 0

const BALL_SCENE = preload("res://Scenes/pickable_ball.tscn")

func _ready():
	ball.ball_died.connect(create_ball)
	ball.ball_fell.connect(clear_score)
	busket.ball_collided.connect(add_count)

func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
	pass
	
func create_ball():
	var ball_pos = position + Vector3(0, 1.5, -0.5)
	var ball = BALL_SCENE.instantiate() as Ball
	ball.position = ball_pos
	world.add_child(ball)
	ball.ball_died.connect(create_ball)
	ball.ball_fell.connect(clear_score)
	
func add_count():
	if is_zone_2:
		curent_score = curent_score + 2
	else:
		curent_score = curent_score + 3
	if curent_score > best_score:
		best_score = curent_score
	text_debug.mesh.text = str(curent_score)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("zone2"):
		is_zone_2 = true


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("zone2"):
		is_zone_2 = false
		
func clear_score():
	curent_score = 0
	text_debug.mesh.text = str(curent_score)
