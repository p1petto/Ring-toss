extends CharacterBody3D

@onready var camera = $XROrigin3D/XRCamera3D
@onready var world = $"../"
@onready var ball = $"../PickableObject"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var rings: Array[Ring] = []
var base_rings: Array[Ring] = []
var held_object = null

const BALL_SCENE = preload("res://Scenes/pickable_ball.tscn")

func _ready():
	ball.ball_died.connect(create_ball)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Обработка движения
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func create_ball():
	var ball_pos = position + Vector3(0, 1.5, -0.5)
	var ball = BALL_SCENE.instantiate() as Ball
	ball.position = ball_pos
	world.add_child(ball)
	ball.ball_died.connect(create_ball)
	
