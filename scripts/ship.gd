# scripts/ship_rb.gd
extends RigidBody2D

@export var thrust_force: float = 900.0
@export var turn_speed: float = 3.5   # rad/s
@export var max_speed: float = 900.0

func _ready() -> void:
	# Un poco de amortiguación arcade
	linear_damp = 0.3
	angular_damp = 6.0
	gravity_scale = 0.0
	lock_rotation = false

func _physics_process(delta: float) -> void:
	# Rotación estilo Asteroids
	var turn := 0.0
	if Input.is_action_pressed("turn_left"):
		turn -= 1.0
	if Input.is_action_pressed("turn_right"):
		turn += 1.0
	angular_velocity = turn * turn_speed

	# Thrust hacia "delante" (eje X local)
	if Input.is_action_pressed("thrust"):
		var forward := transform.x.normalized()
		apply_central_force(forward * thrust_force)

	# Clamp de velocidad para evitar que se dispare por colisiones
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
