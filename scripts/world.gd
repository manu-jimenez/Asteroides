# scripts/world.gd
extends Node2D

@onready var ship: RigidBody2D = $Ship
@onready var cam: Camera2D = $Camera2D

func _ready() -> void:
	cam.global_position = ship.global_position

func _process(_delta: float) -> void:
	# Follow cámara (suave por smoothing)
	cam.global_position = ship.global_position

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
