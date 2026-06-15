extends Node2D

const ROAD_LINES: int = 80

@export var horizon_y: float = 80.0
@export var base_y: float = 648.0
@export var center_x: float = 576.0

@export var road_width_horizon: float = 40.0
@export var road_width_base: float = 800.0

@export var tick_interval: float = 0.03

@export var curve_acceleration: float = 0.20
@export var curve_friction: float = 0.98

@export var min_offset: float = -300.0
@export var max_offset: float = 300.0

var offsets: Array[float] = []

var curve_queue: Array[int] = []

var tick_timer: float = 0.0

var current_curve: int = 0

var curve_velocity: float = 0.0
var curve_position: float = 0.0


func _ready() -> void:
	randomize()

	_setup_offsets()
	_fill_curve_queue()

	queue_redraw()


func _process(delta: float) -> void:

	tick_timer += delta

	while tick_timer >= tick_interval:
		tick_timer -= tick_interval
		_do_tick()

	queue_redraw()


func _draw() -> void:

	for i in range(ROAD_LINES):

		var t: float = float(i) / float(ROAD_LINES - 1)

		var perspective: float = t * t

		var y: float = lerp(
			horizon_y,
			base_y,
			t
		)

		var width: float = lerp(
			road_width_horizon,
			road_width_base,
			perspective
		)

		var offset: float = offsets[i]

		var left_x: float = center_x - width * 0.5 + offset
		var right_x: float = center_x + width * 0.5 + offset

		draw_line(
			Vector2(left_x, y),
			Vector2(right_x, y),
			Color(0.25, 0.25, 0.25),
			4.0
		)

		if i % 12 < 6:

			var middle_x: float = (left_x + right_x) * 0.5

			draw_line(
				Vector2(middle_x, y),
				Vector2(middle_x, y + 4.0),
				Color.WHITE,
				2.0
			)

		draw_circle(
			Vector2(left_x, y),
			2.0,
			Color.WHITE
		)

		draw_circle(
			Vector2(right_x, y),
			2.0,
			Color.WHITE
		)


func _setup_offsets() -> void:

	offsets.clear()

	for i in range(ROAD_LINES):
		offsets.append(0.0)


func _fill_curve_queue() -> void:

	for i in range(15):

		var curve: int = randi_range(-1, 1)

		var duration: int = randi_range(40, 120)

		for j in range(duration):
			curve_queue.append(curve)


func _do_tick() -> void:

	if curve_queue.is_empty():
		_fill_curve_queue()

	current_curve = curve_queue[0]

	curve_velocity += float(current_curve) * curve_acceleration

	curve_velocity *= curve_friction

	curve_position += curve_velocity

	curve_position = clamp(
		curve_position,
		min_offset,
		max_offset
	)

	offsets.pop_back()
	offsets.insert(0, curve_position)

	curve_queue.pop_front()
