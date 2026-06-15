## =================================================
## CLASS: PistaBaseViewController
## DESCRIPTION: Controls the road curve system with a
## perspective trapezoid (thin at horizon, wide at
## base). The root node IS the climate background
## (ColorRect). Draws two Line2D (left/right edges).
##
## v4.1 — CUBIC BEZIER CURVE: each edge is a single cubic
## Bezier curve (P0=horizon, P1, P2, P3=base). P0 and P3
## are always centered on center_x. P1 receives the full
## curve_amount * max_curve_offset; P2 receives an
## attenuated 0.3x offset — smooth across the whole
## extent, monotonic by construction (no crossing, no
## ripple, no kinks).
## curve_amount eases (lerp) toward a target defined by
## curve_queue (-1/0/1), with curves lasting 30-60s and
## straights 5-10s.
##
## Sky (clouds) scrolls at constant speed via autoscroll;
## city reacts to the curve via scroll_offset.
## Emits curve_amount via SignalBus.
## AUTHOR: Ferpa Games
## VERSION: 4.1.0
## =================================================
class_name PistaBaseViewController
extends ColorRect

const CLASS_NAME_LOG: String = "PistaBaseViewController"

var model: PistaBaseModel

@onready var road_edge_left: Line2D = %RoadEdgeLeft
@onready var road_edge_right: Line2D = %RoadEdgeRight
@onready var clouds: Parallax2D = %Clouds
@onready var city: Parallax2D = %City

var _current_speed: float = 200.0

## Direção do segmento atual (-1, 0, 1) — atualizada apenas
## quando um novo segmento é consumido da fila
var _current_segment_direction: int = 0

## 📌
func _ready() -> void:
	model = PistaBaseModel.new()
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		CLASS_NAME_LOG + " _ready()")
	SignalBus.CarPlayerViewControllerSignal_speed_changed.connect(
		_on_speed_changed)
	color = model.color_day

	randomize()

	# Espessura fina das linhas — fiel ao traço de 1px do Atari
	road_edge_left.width = 2.0
	road_edge_right.width = 2.0

	# Céu: movimento horizontal constante, independente da curva
	clouds.autoscroll = Vector2(-8.0, 0.0)

	_setup_road_points()
	_fill_curve_queue()

## 📌
## Cria os pontos iniciais — pista reta (curve_amount = 0).
## A geometria real é calculada em _redraw_road_edges() todo frame.
func _setup_road_points() -> void:
	road_edge_left.clear_points()
	road_edge_right.clear_points()

	for i in model.point_count:
		road_edge_left.add_point(Vector2.ZERO)
		road_edge_right.add_point(Vector2.ZERO)

## 📌
## Sorteia um lote de segmentos. RETAS (direção 0) são mais curtas
## (5-10s); CURVAS (direção ±1) são mais longas (30-60s) — fiel
## ao feeling de uma rodovia real (retas curtas, curvas longas).
## Garante pelo menos a metade dos segmentos sendo curva, para
## evitar longas sequências de retas por acaso estatístico.
func _fill_curve_queue() -> void:
	var directions: Array[int] = []

	var min_curves: int = model.curve_batch_size / 2
	for i in min_curves:
		directions.append(1 if randi() % 2 == 0 else -1)

	for i in (model.curve_batch_size - min_curves):
		directions.append(randi_range(-1, 1))

	directions.shuffle()

	for direction in directions:
		model.curve_queue.append(direction)

## 📌
func _process(delta: float) -> void:
	_advance_tick_timer(delta)
	_redraw_road_edges()
	_apply_curve_offset()

	SignalBus.PistaBaseViewControllerSignal_road_offset_changed.emit(
		model.curve_amount)

## 📌
## Recebe a velocidade atual do carro via SignalBus
func _on_speed_changed(speed: float) -> void:
	_current_speed = speed

## 📌
## Avança o timer do tick. Como tick_interval é bem pequeno (0.03s),
## usa um while para garantir que múltiplos ticks ocorram no mesmo
## frame se o delta for maior que o intervalo
func _advance_tick_timer(delta: float) -> void:
	var speed_bonus: float = _current_speed * model.speed_tick_factor
	model.tick_timer += delta * (1.0 + speed_bonus)

	while model.tick_timer >= model.tick_interval:
		model.tick_timer -= model.tick_interval
		_do_tick()

## 📌
## Executa um "tick":
## 1. Garante que há segmento na fila (sorteia lote se vazio)
## 2. Se o segmento atual acabou (ticks_remaining <= 0), consome
##    o próximo da fila, guarda sua direção e define a duração
## 3. curve_amount se aproxima suavemente (lerp) do alvo definido
##    pela direção do segmento atual (-1, 0, ou 1)
func _do_tick() -> void:
	if model.curve_queue.is_empty():
		_fill_curve_queue()

	if model.ticks_remaining <= 0:
		_current_segment_direction = model.curve_queue[0]
		if _current_segment_direction == 0:
			model.ticks_remaining = randi_range(
				model.straight_duration_min,
				model.straight_duration_max)
		else:
			model.ticks_remaining = randi_range(
				model.curve_duration_min,
				model.curve_duration_max)
		model.curve_queue.pop_front()

	var target: float = float(_current_segment_direction)
	model.curve_amount += (target - model.curve_amount) * model.curve_amount_lerp_speed

	model.ticks_remaining -= 1

## 📌
## Redesenha as duas Line2D usando BEZIER CÚBICA (4 pontos de
## controle por borda) — uma única curva suave de t=0 (horizonte)
## a t=1 (base), sem junções internas, sem quinas. P0 e P3 sempre
## centrados em center_x. P1 recebe o offset completo de
## curve_amount; P2 recebe offset reduzido (30%) para evitar
## overshoot perto da base — garante monotonicidade (left sempre
## decresce, right sempre cresce, sem cruzamento, sem ondulação).
func _redraw_road_edges() -> void:
	var half_top: float = model.road_top_width / 2.0
	var half_bottom: float = model.road_bottom_width / 2.0
	var mid_offset: float = model.curve_amount * model.max_curve_offset

	var p0_left: float = model.center_x - half_top
	var p3_left: float = model.center_x - half_bottom
	var p1_left: float = p0_left + (p3_left - p0_left) * 0.33 + mid_offset
	var p2_left: float = p0_left + (p3_left - p0_left) * 0.67 + mid_offset * 0.3

	var p0_right: float = model.center_x + half_top
	var p3_right: float = model.center_x + half_bottom
	var p1_right: float = p0_right + (p3_right - p0_right) * 0.33 + mid_offset
	var p2_right: float = p0_right + (p3_right - p0_right) * 0.67 + mid_offset * 0.3

	for i in model.point_count:
		var t: float = float(i) / float(model.point_count - 1)
		var y: float = lerp(model.horizon_y, model.base_y, t)

		var left_x: float = _bezier(p0_left, p1_left, p2_left, p3_left, t)
		var right_x: float = _bezier(p0_right, p1_right, p2_right, p3_right, t)

		road_edge_left.set_point_position(i, Vector2(left_x, y))
		road_edge_right.set_point_position(i, Vector2(right_x, y))

## 📌
## Bezier cúbica: B(t) = (1-t)³P0 + 3(1-t)²t·P1 + 3(1-t)t²·P2 + t³P3
func _bezier(p0: float, p1: float, p2: float, p3: float, t: float) -> float:
	var u: float = 1.0 - t
	return u*u*u*p0 + 3.0*u*u*t*p1 + 3.0*u*t*t*p2 + t*t*t*p3

## 📌
## Céu: movimento horizontal constante via autoscroll (configurado
## uma vez no _ready(), não precisa ser tocado aqui).
## Cidade: desloca conforme curve_amount — usa scroll_offset do Parallax2D.
func _apply_curve_offset() -> void:
	city.scroll_offset.x = model.curve_amount * model.max_curve_offset * 0.5

## 📌
## Define a cor do fundo climático (dia, tarde, neblina, neve)
## Chamado pelo DayManager nos EP08/EP09
func set_climate_color(climate_color: Color) -> void:
	color = climate_color
