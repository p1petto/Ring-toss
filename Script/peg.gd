extends CSGCylinder3D

enum MovementState {
	IDLE,
	HORIZONTAL,
	VERTICAL,
	SINE_WAVE,
	CIRCULAR,
	FIGURE_EIGHT
}

@export var speed: float = 1.0
@export var amplitude: float = 2.0
@export var current_state: MovementState = MovementState.IDLE
@export var auto_switch_states: bool = false
@export var state_duration: float = 3.0
@export var path_length: float = 10.0  # Длина пути для SINE_WAVE

var time: float = 0.0
var state_timer: float = 0.0
var initial_position: Vector3
var moving_forward: bool = true  # Направление движения для SINE_WAVE

func _ready():
	initial_position = position

func _process(delta: float):
	time += delta
	
	if auto_switch_states:
		state_timer += delta
		if state_timer >= state_duration:
			state_timer = 0
			current_state = (current_state + 1) % MovementState.size()
	
	match current_state:
		MovementState.IDLE:
			position = initial_position
		
		MovementState.HORIZONTAL:
			position.x = initial_position.x + amplitude * sin(time * speed)
			position.y = initial_position.y
			position.z = initial_position.z
		
		MovementState.VERTICAL:
			position.x = initial_position.x
			position.y = initial_position.y + amplitude * sin(time * speed)
			position.z = initial_position.z
		
		MovementState.SINE_WAVE:
			# Вычисляем прогресс движения
			var progress = time * speed
			
			# Определяем текущее положение по X
			var current_x = position.x - initial_position.x
			
			# Меняем направление при достижении границ
			if moving_forward and current_x >= path_length:
				moving_forward = false
			elif !moving_forward and current_x <= 0:
				moving_forward = true
			
			# Двигаем объект в нужном направлении
			var movement = delta * speed
			if !moving_forward:
				movement = -movement
			
			position.x += movement
			position.y = initial_position.y + amplitude * sin(current_x * 0.5)  # Используем текущую позицию X для синусоиды
			position.z = initial_position.z
		
		MovementState.CIRCULAR:
			position.x = initial_position.x + amplitude * cos(time * speed)
			position.z = initial_position.z + amplitude * sin(time * speed)
			position.y = initial_position.y
		
		MovementState.FIGURE_EIGHT:
			position.x = initial_position.x + amplitude * sin(time * speed)
			position.z = initial_position.z + amplitude * sin(time * speed * 2) * 0.5
			position.y = initial_position.y

func switch_state(new_state: MovementState):
	current_state = new_state
	time = 0
	position = initial_position
	moving_forward = true  # Сброс направления движения
