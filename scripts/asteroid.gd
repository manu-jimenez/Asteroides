# scripts/asteroid.gd
extends RigidBody2D
class_name Asteroid

@export var radius: float = 48.0 : set = set_radius
@export var density: float = 1.0
@export var frozen: bool = true : set = set_frozen

@onready var collision: CollisionShape2D = $Collision
@onready var visual: Polygon2D = $Visual

var _pending_radius_apply: bool = false

func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = 0.2
	angular_damp = 0.2
	lock_rotation = true

	set_frozen(frozen)

	# Si radius se asignó antes de entrar al árbol, lo aplicamos ahora.
	if _pending_radius_apply:
		_apply_radius()
	else:
		# Asegura que al menos se aplica el valor por defecto
		_apply_radius()

func set_frozen(v: bool) -> void:
	frozen = v
	freeze = v
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC

func set_radius(r: float) -> void:
	radius = max(r, 6.0)

	# Si todavía no estamos en el árbol (o no están listos los onready), aplaza la aplicación.
	if not is_inside_tree():
		_pending_radius_apply = true
		return

	_apply_radius()

func _apply_radius() -> void:
	_pending_radius_apply = false

	# 1) Colisión: SIEMPRE shape nueva (evita shapes compartidos)
	var cs := CircleShape2D.new()
	cs.radius = radius
	collision.shape = cs

	# 2) Masa (2D)
	var area := PI * radius * radius
	mass = max(0.1, area * density)

	# 3) Visual
	visual.polygon = _make_circle_polygon(radius, 48)

func _make_circle_polygon(r: float, points: int) -> PackedVector2Array:
	var poly := PackedVector2Array()
	for i in range(points):
		var a := TAU * float(i) / float(points)
		poly.append(Vector2(cos(a), sin(a)) * r)
	return poly
