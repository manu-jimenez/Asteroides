# scripts/ship.gd
extends RigidBody2D
class_name Ship

@export var thrust_force: float = 750.0
@export var turn_speed: float = 4.5   # rad/s
@export var max_speed: float = 900.0

@export var max_fuel: float = 500.0
@export var fuel: float = 500.0
@export var fuel_burn_per_sec: float = 5.0  # consumo mientras haces thrust

var _dbg_accum := 0.0

func _ready() -> void:
	print("Ship freeze=", freeze, " custom_integrator=", custom_integrator)

	# Un poco de amortiguación arcade
	linear_damp = 0.9
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
	# While paused, physics isn't running, so rotate visually here
	if get_tree().paused:
		rotation += _turn_input() * turn_speed * delta

func _physics_process(delta: float) -> void:	
	_dbg_accum += delta
	if _dbg_accum >= 0.33:
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
		#var t := _turn_input()
		#if t != 0.0:
		#	print("TURN input =", t, " paused=", get_tree().paused)

	if get_tree().paused:
		return
	
	# thrust + fuel aquí
	if Input.is_action_pressed("thrust") and fuel > 0.0:
		var forward := transform.x.normalized()
		apply_central_force(forward * thrust_force)
		fuel = max(0.0, fuel - fuel_burn_per_sec * delta)

	# Clamp de velocidad para evitar que se dispare por colisiones
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Prevent collision torque from spinning the ship:
	state.angular_velocity = 0.0

	# Apply player turning in the physics step (works at any speed)
	if not get_tree().paused:
		var t := _turn_input()
		if t != 0.0:
			var rot := state.transform.get_rotation() + t * turn_speed * state.step
			state.transform = Transform2D(rot, state.transform.origin)
	
func refuel_full() -> void:
	fuel = max_fuel

func has_fuel() -> bool:
	return fuel > 0.0
