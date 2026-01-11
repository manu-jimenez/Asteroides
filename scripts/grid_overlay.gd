# scripts/grid_overlay.gd
extends Node2D

@export var grid_step: float = 64.0
@export var major_every: int = 5
@export var thickness: float = 1.0

var cam: Camera2D

func _ready() -> void:
	# Draw in screen space (not affected by world transforms)
	top_level = true
	print("GridOverlay cam=", cam)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	cam = get_viewport().get_camera_2d()
	if cam == null:
		return
	
	var vp := get_viewport_rect().size
	var half := vp * 0.5

	var center := cam.global_position
	var top_left := center - half / cam.zoom
	var bottom_right := center + half / cam.zoom

	var start_x: float = float(floor(top_left.x / grid_step)) * grid_step
	var end_x: float = float(ceil(bottom_right.x / grid_step)) * grid_step
	var start_y: float = float(floor(top_left.y / grid_step)) * grid_step
	var end_y: float = float(ceil(bottom_right.y / grid_step)) * grid_step


	# Vertical lines
	var i := 0
	var x := start_x
	while x <= end_x:
		var is_major := (i % major_every) == 0
		var color := Color(1, 1, 1, 0.22) if is_major else Color(1, 1, 1, 0.12)
		var width := thickness * 2.0 if is_major else thickness

		var a := Vector2((x - top_left.x) * cam.zoom.x, 0)
		var b := Vector2((x - top_left.x) * cam.zoom.x, vp.y)
		draw_line(a, b, color, width)

		x += grid_step
		i += 1

	# Horizontal lines
	i = 0
	var y := start_y
	while y <= end_y:
		var is_major := (i % major_every) == 0
		var color := Color(1, 1, 1, 0.22) if is_major else Color(1, 1, 1, 0.12)
		var width := thickness * 2.0 if is_major else thickness

		var a2 := Vector2(0, (y - top_left.y) * cam.zoom.y)
		var b2 := Vector2(vp.x, (y - top_left.y) * cam.zoom.y)
		draw_line(a2, b2, color, width)

		y += grid_step
		i += 1
