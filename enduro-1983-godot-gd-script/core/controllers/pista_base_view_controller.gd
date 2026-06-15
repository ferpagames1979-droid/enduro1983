## =================================================
## CLASS: PistaBaseViewController
## DESCRIPTION: Controls the road curve conveyor-belt
## system combined with a smooth perspective trapezoid
## (thin at horizon, wide at base). The root node IS
## the climate background (ColorRect). Draws two Line2D
## (left/right edges) using a per-point offset array.
##
## v1.8: accumulated_offset changes by a FIXED rate
## (curve_rate) per tick during curves — independent of
## segment duration. This guarantees local_curvature
## (offsets[0] - offsets[N-1]) is always visible
## (~curve_rate * point_count), regardless of how long
## the curve segment lasts. During straights,
## accumulated_offset decays toward 0.
##
## Offsets are smoothed (double pass, wide window) before
## drawing to eliminate kinks/discontinuities.
## Sky (clouds) scrolls at constant speed via autoscroll;
## city reacts to the curve via scroll_offset.
## Emits the local curvature via SignalBus.
## AUTHOR: Ferpa Games
## VERSION: 1.8.0
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


func _ready() -> void:
	model = PistaBaseModel.new()
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		CLASS_NAME_LOG + " _ready()")
	SignalBus.CarPlayerViewControllerSignal_speed_changed.connect(
		_on_speed_changed)
	color = model.color_day

	randomize()  ## ← ADICIONAR — sem isso, randi_range pode repetir

	road_edge_left.width = 2.0
	road_edge_right.width = 2.0

	clouds.autoscroll = Vector2(-8.0, 0.0)

	_setup_offsets()
	_setup_road_points()
	_fill_curve_queue()
	
	var test_rolls: Array[int] = []
	for i in 30:
		test_rolls.append(randi_range(-1, 1))
	print("ROLLS: ", test_rolls)

## 📌
## Inicializa o array offsets com zeros — pista reta no início
func _setup_offsets() -> void:
	model.offsets.clear()
	for i in model.point_count:
		model.offsets.append(0.0)

## 📌
## Cria os pontos iniciais — TRAPÉZIO com perspectiva suave:
## largura cresce com t^1.5, fina no horizonte, larga na base
func _setup_road_points() -> void:
	road_edge_left.clear_points()
	road_edge_right.clear_points()

	for i in model.point_count:
		var t: float = float(i) / float(model.point_count - 1)
		var perspective: float = pow(t, 1.5)
		var y: float = lerp(model.horizon_y, model.base_y, t)
		var half_width: float = lerp(
			model.road_top_width / 2.0,
			model.road_bottom_width / 2.0,
			perspective)

		road_edge_left.add_point(Vector2(model.center_x - half_width, y))
		road_edge_right.add_point(Vector2(model.center_x + half_width, y))

## 📌
## Sorteia um lote de segmentos. RETAS (direção 0) são mais curtas
## (5-10s); CURVAS (direção ±1) são mais longas (30-60s) — fiel
## ao feeling de uma rodovia real (retas curtas, curvas longas).
func _fill_curve_queue() -> void:
	var directions: Array[int] = []

	# Garante pelo menos curve_batch_size/2 curvas
	var min_curves: int = model.curve_batch_size / 2
	for i in min_curves:
		directions.append(1 if randi() % 2 == 0 else -1)

	# Completa o restante aleatoriamente (pode ser reta ou curva)
	for i in (model.curve_batch_size - min_curves):
		directions.append(randi_range(-1, 1))

	directions.shuffle()

	for direction in directions:
		var duration: int
		if direction == 0:
			duration = randi_range(
				model.straight_duration_min,
				model.straight_duration_max)
		else:
			duration = randi_range(
				model.curve_duration_min,
				model.curve_duration_max)

		for j in duration:
			model.curve_queue.append(direction)

## 📌
func _process(delta: float) -> void:
	_advance_tick_timer(delta)
	_redraw_road_edges()
	_apply_curve_offset()

	var local_curvature: float = model.offsets[0] - model.offsets[model.point_count - 1]

	## 📌 DEBUG TEMPORÁRIO — remover depois
	if Engine.get_process_frames() % 30 == 0:
		print("accumulated=%.3f offsets[0]=%.3f offsets[79]=%.3f curvature=%.3f queue_dir=%d queue_size=%d" % [
			model.accumulated_offset,
			model.offsets[0],
			model.offsets[model.point_count - 1],
			local_curvature,
			model.curve_queue[0] if not model.curve_queue.is_empty() else -99,
			model.curve_queue.size()
		])

	SignalBus.PistaBaseViewControllerSignal_road_offset_changed.emit(
		local_curvature)

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
## Executa um "tick" da esteira:
## 1. Garante que há segmento na fila (sorteia lote se vazio)
## 2. CURVA: accumulated_offset += direção * curve_rate (incremento
##    FIXO por tick, independente da duração — garante que
##    local_curvature seja sempre visível, em curvas longas ou curtas)
##    RETA: accumulated_offset decai lentamente em direção a 0
## 3. Desloca o array offsets — novo valor entra no horizonte
func _do_tick() -> void:
	if model.curve_queue.is_empty():
		_fill_curve_queue()

	var current_direction: int = model.curve_queue[0]

	if current_direction != 0:
		model.accumulated_offset += float(current_direction) * model.curve_rate
		model.accumulated_offset = clamp(
			model.accumulated_offset,
			-model.accumulated_offset_limit,
			model.accumulated_offset_limit)
	else:
		model.accumulated_offset += (0.0 - model.accumulated_offset) \
			* model.straight_decay_rate

	model.offsets.pop_back()
	model.offsets.insert(0, model.accumulated_offset)

	model.curve_queue.pop_front()

## 📌
## Suaviza um array de offsets com média móvel — janela de 9
## (i-4 até i+4). Elimina ruído/quinas residuais no traçado.
func _smooth_array(source: Array[float]) -> Array[float]:
	var smoothed: Array[float] = []
	for i in source.size():
		var sum: float = 0.0
		var count: int = 0
		for j in range(-4, 5):  # janela de 9: i-4 até i+4
			var idx: int = i + j
			if idx >= 0 and idx < source.size():
				sum += source[idx]
				count += 1
		smoothed.append(sum / float(count))
	return smoothed

## 📌
## Redesenha as duas Line2D combinando TRAPÉZIO + ESTEIRA.
## A esteira passa por DUAS passadas de suavização (janela de 9)
## antes de ser usada. A BASE (último ponto) é a referência FIXA —
## subtraímos o offset da base de TODOS os pontos, garantindo que
## ela nunca se mova. A diferença entre horizonte e base (curvatura
## local) é o que cria a curva visível.
func _redraw_road_edges() -> void:
	var smoothed: Array[float] = _smooth_array(model.offsets)
	smoothed = _smooth_array(smoothed)  # segunda passada
	var base_offset: float = smoothed[model.point_count - 1]

	## 📌 DEBUG TEMPORÁRIO — remover depois
	if Engine.get_process_frames() % 30 == 0:
		var raw_curvature: float = model.offsets[0] - model.offsets[model.point_count - 1]
		var smoothed_curvature: float = smoothed[0] - base_offset
		print("RAW=%.3f SMOOTHED=%.3f | L0=%s R0=%s | L79=%s R79=%s" % [
			raw_curvature,
			smoothed_curvature,
			road_edge_left.get_point_position(0),
			road_edge_right.get_point_position(0),
			road_edge_left.get_point_position(model.point_count - 1),
			road_edge_right.get_point_position(model.point_count - 1)
		])

	for i in model.point_count:
		var t: float = float(i) / float(model.point_count - 1)
		var perspective: float = pow(t, 1.5)
		var y: float = lerp(model.horizon_y, model.base_y, t)
		var half_width: float = lerp(
			model.road_top_width / 2.0,
			model.road_bottom_width / 2.0,
			perspective)
		var offset: float = smoothed[i] - base_offset
		road_edge_left.set_point_position(i,
			Vector2(model.center_x - half_width + offset, y))
		road_edge_right.set_point_position(i,
			Vector2(model.center_x + half_width + offset, y))

## 📌
## Céu: movimento horizontal constante via autoscroll (configurado
## uma vez no _ready(), não precisa ser tocado aqui).
## Cidade: desloca conforme a curvatura local — usa scroll_offset
## do Parallax2D.
func _apply_curve_offset() -> void:
	var local_curvature: float = model.offsets[0] - model.offsets[model.point_count - 1]
	city.scroll_offset.x = local_curvature

## 📌
## Define a cor do fundo climático (dia, tarde, neblina, neve)
## Chamado pelo DayManager nos EP08/EP09
func set_climate_color(climate_color: Color) -> void:
	color = climate_color
