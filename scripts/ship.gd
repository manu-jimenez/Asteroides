# scripts/ship.gd
extends RigidBody2D
class_name Ship

@export var thrust_force: float = 900.0
@export var turn_speed: float = 3.5   # rad/s
@export var max_speed: float = 900.0

@export var max_fuel: float = 500.0
@export var fuel: float = 500.0
@export var fuel_burn_per_sec: float = 18.0  # consumo mientras haces thrust

var _dbg_accum := 0.0

func _ready() -> void:
	print("Ship freeze=", freeze, " custom_integrator=", custom_integrator)

	# Un poco de amortiguación arcade
	linear_damp = 0.3
	angular_damp = 6.0
	gravity_scale = 0.0

	lock_rotation = true
	angular_velocity = 0.0

func _turn_input() -> float:
	var t := 0.0
	if Input.is_action_pressed("turn_left"):
		t -= 1.0
	if Input.is_action_pressed("turn_right"):
		t += 1.0
	return t

func _process(delta: float) -> void:
	if not get_tree().paused:
		return
	rotation += _turn_input() * turn_speed * delta

func _physics_process(delta: float) -> void:	
	_dbg_accum += delta
	if _dbg_accum >= 0.25:
		_dbg_accum = 0.0
		if Input.is_action_pressed("thrust"):
			print("THRUST pressed | paused=", get_tree().paused,
				" freeze=", freeze,
				" custom_integrator=", custom_integrator,
				" fuel=", fuel,
				" thrust_force=", thrust_force,
				" pos=", global_position,
				" lin_vel=", linear_velocity,
				" paused=", get_tree().paused)

	if get_tree().paused:
		return

	rotation += _turn_input() * turn_speed * delta
	
	# thrust + fuel aquí
	if Input.is_action_pressed("thrust") and fuel > 0.0:
		var forward := transform.x.normalized()
		apply_central_force(forward * thrust_force)
		fuel = max(0.0, fuel - fuel_burn_per_sec * delta)

	# Clamp de velocidad para evitar que se dispare por colisiones
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	
func refuel_full() -> void:
	fuel = max_fuel

func has_fuel() -> bool:
	return fuel > 0.0
