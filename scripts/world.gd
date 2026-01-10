# scripts/world.gd
extends Node2D

@onready var ship: RigidBody2D = $Ship
@onready var cam: Camera2D = $Camera2D

@onready var sld_thrust: HSlider = $UI/TuningPanel/VBox/HBoxThrust/HSliderThrust
@onready var lbl_thrust: Label = $UI/TuningPanel/VBox/HBoxThrust/LabelThrust

@onready var sld_damp: HSlider = $UI/TuningPanel/VBox/HBoxDamp/HSliderDamp
@onready var lbl_damp: Label = $UI/TuningPanel/VBox/HBoxDamp/LabelDamp

@onready var sld_turn: HSlider = $UI/TuningPanel/VBox/HBoxTurn/HSliderTurn
@onready var lbl_turn: Label = $UI/TuningPanel/VBox/HBoxTurn/LabelTurn

var AsteroidScene: PackedScene = preload("res://scenes/Asteroid.tscn")

func _ready() -> void:
	cam.global_position = ship.global_position
	_spawn_test_asteroids()

	# Inicializa UI
	_apply_tuning_from_sliders()

	# Conecta señales
	sld_thrust.value_changed.connect(_on_tuning_changed)
	sld_damp.value_changed.connect(_on_tuning_changed)
	sld_turn.value_changed.connect(_on_tuning_changed)


func _process(_delta: float) -> void:
	# Follow cámara (suave por smoothing)
	cam.global_position = ship.global_position

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("toggle_tuning"):
		$UI/TuningPanel.visible = not $UI/TuningPanel.visible

func _spawn_test_asteroids() -> void:
	# 5 asteroides estáticos para dar escala + referencia espacial
	var radii := [140.0, 90.0, 60.0, 40.0, 28.0]
	var positions := [
		Vector2(350, 0),
		Vector2(-250, 220),
		Vector2(120, -260),
		Vector2(-420, -180),
		Vector2(520, 260),
	]

	for i in range(radii.size()):
		var a := AsteroidScene.instantiate()
		a.radius = radii[i]
		a.frozen = true
		a.global_position = ship.global_position + positions[i]
		add_child(a)

func _on_tuning_changed(_v: float) -> void:
	_apply_tuning_from_sliders()

func _apply_tuning_from_sliders() -> void:
	var thrust := float(sld_thrust.value)
	var damp := float(sld_damp.value)
	var turn := float(sld_turn.value)

	# Ship script variables (asumiendo que el script está en el root Ship)
	ship.thrust_force = thrust
	ship.turn_speed = turn

	# Propiedad directa del RigidBody2D
	ship.linear_damp = damp

	lbl_thrust.text = "Thrust: %d" % int(thrust)
	lbl_damp.text = "Linear damp: %.2f" % damp
	lbl_turn.text = "Turn: %.1f" % turn
