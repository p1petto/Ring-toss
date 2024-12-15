extends XROrigin3D

@onready var camera = $XRCamera3D
@onready var world = $"../"
@onready var ball = $"../PickableObject"
@onready var busket = $"../StaticBody3D2/Busket"
@onready var text_debug = $XRCamera3D/MeshInstance3D

@onready var text_cur_score = $"../ScoreBox/CurScore"
@onready var text_best_score = $"../ScoreBox/BestScore"


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SPAWN_DISTANCE = 0.7  # Расстояние от камеры для создания мяча
var is_zone_2 = false
var curent_score = 0
var best_score = 0
var max_score = 10
const BALL_SCENE = preload("res://Scenes/pickable_ball.tscn")

func _ready():
	ball.ball_died.connect(create_ball)
	ball.ball_fell.connect(clear_score)
	busket.ball_collided.connect(add_count)

func _physics_process(delta: float) -> void:
	pass

func create_ball():
	# Получаем направление взгляда камеры
	var camera_forward = -camera.global_transform.basis.z.normalized()
	
	# Вычисляем позицию для создания мяча
	var spawn_position = camera.global_position + (camera_forward * SPAWN_DISTANCE)
	
	# Создаем новый мяч
	var ball = BALL_SCENE.instantiate() as Ball
	ball.position = spawn_position
	
	# Добавляем мяч в сцену
	world.add_child(ball)
	
	# Подключаем сигналы
	ball.ball_died.connect(create_ball)
	ball.ball_fell.connect(clear_score)

func add_count():
	if is_zone_2:
		curent_score = curent_score + 2
		text_debug.mesh.text = str(curent_score)
	else:
		curent_score = curent_score + 3
		text_debug.mesh.text = str(curent_score)
		
	if curent_score > best_score:
		best_score = curent_score
		
	if curent_score >= max_score:
		text_best_score.mesh.text = str(max_score)
		text_cur_score.mesh.text = str(max_score)
		text_debug.mesh.text = "WIN"
	else:
		text_best_score.mesh.text = str(best_score)
		text_cur_score.mesh.text = str(curent_score)
		
	
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("zone2"):
		is_zone_2 = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("zone2"):
		is_zone_2 = false

func clear_score():
	curent_score = 0
	text_debug.mesh.text = str(curent_score)
	text_cur_score.mesh.text = str(curent_score)
