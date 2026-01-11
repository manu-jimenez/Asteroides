# scripts/world.gd
extends Node2D

@onready var ship := $Ship
var cam: Camera2D

# Sliders parametros
@onready var sld_thrust: HSlider = $UI/TuningPanel/VBox/HBoxThrust/HSliderThrust
@onready var lbl_thrust: Label = $UI/TuningPanel/VBox/HBoxThrust/LabelThrust
@onready var sld_damp: HSlider = $UI/TuningPanel/VBox/HBoxDamp/HSliderDamp
@onready var lbl_damp: Label = $UI/TuningPanel/VBox/HBoxDamp/LabelDamp
@onready var sld_turn: HSlider = $UI/TuningPanel/VBox/HBoxTurn/HSliderTurn
@onready var lbl_turn: Label = $UI/TuningPanel/VBox/HBoxTurn/LabelTurn
@onready var sld_fuel_burn: HSlider = $UI/TuningPanel/VBox/HBoxFuelBurn/HSliderFuelBurn
@onready var lbl_fuel_burn: Label = $UI/TuningPanel/VBox/HBoxFuelBurn/LabelFuelBurn
@onready var sld_max_fuel: HSlider = $UI/TuningPanel/VBox/HBoxMaxFuel/HSliderMaxFuel
@onready var lbl_max_fuel: Label = $UI/TuningPanel/VBox/HBoxMaxFuel/LabelMaxFuel


var AsteroidScene: PackedScene = preload("res://scenes/Asteroid.tscn")

func _ready() -> void:
	_spawn_test_asteroids()

	# Inicializa UI
	_apply_tuning_from_sliders()

	# Conecta señales
	sld_thrust.value_changed.connect(_on_tuning_changed)
	sld_damp.value_changed.connect(_on_tuning_changed)
	sld_turn.value_changed.connect(_on_tuning_changed)
	sld_fuel_burn.value_changed.connect(_on_tuning_changed)
	sld_max_fuel.value_changed.connect(_on_tuning_changed)
	
	get_tree().paused = false
	print("World ready. paused =", get_tree().paused)
	
	cam = $Ship/Camera2D
	print("Camera enabled=", cam.enabled)
	cam.enabled = true
	print("Camera enabled=", cam.enabled)
	print("Active viewport cam =", get_viewport().get_camera_2d(), " my cam =", cam)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("toggle_tuning"):
		$UI/TuningPanel.visible = not $UI/TuningPanel.visible
		
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		print("PAUSED =", get_tree().paused)
	
func _on_tuning_changed(_v: float) -> void:
	_apply_tuning_from_sliders()

func _apply_tuning_from_sliders() -> void:
	var thrust := float(sld_thrust.value)
	var damp := float(sld_damp.value)
	var turn := float(sld_turn.value)
	var fuel_burn := float(sld_fuel_burn.value)
	var max_fuel := float(sld_max_fuel.value)

	# Ship script variables
	ship.thrust_force = thrust
	ship.turn_speed = turn
	ship.linear_damp = damp 	# Propiedad directa del RigidBody2D
	ship.fuel_burn_per_sec = fuel_burn
	ship.max_fuel = max_fuel

	lbl_thrust.text = "Thrust: %d" % int(thrust)
	lbl_damp.text = "Linear damp: %.2f" % damp
	lbl_turn.text = "Turn: %.1f" % turn
	lbl_fuel_burn.text = "Fuel burn: %.0f/s" % fuel_burn
	lbl_max_fuel.text = "Max fuel: %.0f" % max_fuel

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
