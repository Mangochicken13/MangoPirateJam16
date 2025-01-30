extends Control
class_name Menu

@export var main_scene: MainUI
@export var settings_scene: SettingsUI
@export var player_customiser_scene: PlayerCustomiserUI
@export var scenes: Array[PanelContainer]

var current_scene: PanelContainer

signal start_game

func _ready() -> void:
	current_scene = main_scene
	scenes = [settings_scene, main_scene, player_customiser_scene]
	if main_scene:
		main_scene.settings_button.pressed.connect(transition_to_scene.bind(settings_scene))
		main_scene.settings_button.pressed.connect(settings_scene.load_config)
		main_scene.player_customiser_button.pressed.connect(transition_to_scene.bind(player_customiser_scene))
		main_scene.start_button.pressed.connect(_on_start_button_pressed)
	if settings_scene:
		settings_scene.return_to_main_scene.connect(transition_to_scene.bind(main_scene))
	if player_customiser_scene:
		player_customiser_scene.return_to_main_scene.connect(transition_to_scene.bind(main_scene))

func transition_to_scene(target: PanelContainer):
	var h_anchor_change = target.anchor_left
	for scene in scenes:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(scene, "anchor_left", scene.anchor_left - h_anchor_change, .8)
		tween.parallel().tween_property(scene, "anchor_right", scene.anchor_right - h_anchor_change, .8)
	

func _on_start_button_pressed():
	start_game.emit()
