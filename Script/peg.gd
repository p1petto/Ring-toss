extends CSGCylinder3D

@export var speed: float = 1.0
@export var amplitude: float = 2.0
var time: float = 0.0


func _ready():
	pass

func _process(delta: float):
	time += delta
	
	# Движение по синусоиде по оси X
	var new_x = amplitude * sin(time * speed)
	position.x = new_x
	
