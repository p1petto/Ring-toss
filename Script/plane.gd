extends MeshInstance3D

@export var texture: Texture2D
@export var rings: Array[Color]

func _ready() -> void:
	if texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = texture
		material_override = material  # или self.material_override = material
