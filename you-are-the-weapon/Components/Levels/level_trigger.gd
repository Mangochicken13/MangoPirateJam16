extends Area3D
class_name LevelTrigger

# Empty for now, may need special logic?

@export var untriggered_color: Color = Color(Color.DARK_ORANGE, 128.0/255)
@export var triggered_color: Color = Color(Color.LIME_GREEN, 128.0/255) 

func _ready() -> void:
	$MeshInstance3D.mesh.albedo_color = untriggered_color
	body_entered.connect(_tween_color)

func _tween_color():
	var tween = get_tree().create_tween()
	tween.EaseType = Tween.EASE_IN_OUT
	tween.tween_property($MeshInstance3D.mesh, "albedo_color", triggered_color, 1)
