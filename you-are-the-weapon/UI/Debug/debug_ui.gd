extends Control
class_name DebugUI

@export var frame_rate_label: Label
@export var camera_spring_label: Label
@export var player: Ball

func _process(delta: float) -> void:
	
	frame_rate_label.text = str(Engine.get_frames_per_second())
	camera_spring_label.text = "%.2f" % player.ball_cam.get_spring_length()
