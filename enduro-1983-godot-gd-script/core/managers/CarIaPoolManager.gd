## =================================================
## CLASS: CarIaPoolManager
## DESCRIPTION: Manages IA car spawning, pooling, and
## despawning. Uses an object pool to avoid instantiate/
## free overhead.
##
## LANE SYSTEM (faithful to Enduro 1983):
## Each lane (LEFT/CENTER/RIGHT) has its own cooldown
## timer — a new IA can only spawn in a lane after
## LANE_COOLDOWN seconds, guaranteeing spacing between
## cars in the same lane (no overlapping). All IAs in
## the same lane share the same relative_speed, creating
## the "car queue" visual of the original game.
##
## VARIED SPAWN INTERVALS:
## After each spawn, the next interval is randomized
## within [CarIaModel.SPAWN_INTERVAL_MIN,
## CarIaModel.SPAWN_INTERVAL_MAX] — IAs don't arrive
## in regular waves.
##
## TRACK FOLLOWING:
## Each spawned IA receives a reference to the track
## (_pista) so it follows the road's current curve
## via PistaBaseViewController.get_center_x_at(t).
##
## OVERTAKE DETECTION:
## Every frame, each active IA is checked against the
## player's Y position. When ia.position.y >=
## player.position.y and the IA hasn't been hit,
## passed_player is set to true (once per lifecycle)
## and CarIaPoolManagerSignal_car_passed is emitted.
##
## Added to AutoLoad as "CarIaPoolManager".
## No class_name — autoloads conflict with class_name
## in Godot 4.
## AUTHOR: Ferpa Games
## VERSION: 1.4.0
## =================================================
extends Node

const CLASS_NAME_LOG: String = "CarIaPoolManager"

## Cena da IA (car_ia_view.tscn) — arrastar no Inspector
@export var ia_scene: PackedScene

## Máximo de IAs simultâneas ativas na tela
const MAX_IA_CARS: int = 5

## Tempo mínimo entre spawns na mesma lane — garante
## espaçamento entre IAs da mesma fila (evita sobreposição)
const LANE_COOLDOWN: float = 3.0

## Referência à pista — setada pelo GameViewController._ready().
## Usada por cada IA para seguir a curva via get_center_x_at(t)
var _pista: PistaBaseViewController = null

## Referência ao player — setada pelo GameViewController._ready().
## Usada para detectar ultrapassagem (ia.position.y >= player.position.y)
var _player_ref: CarPlayerViewController = null

## IAs atualmente ativas e visíveis na pista
var _active_cars: Array[CarIaViewController] = []

## IAs inativas, prontas para reuso (object pool)
var _pool: Array[CarIaViewController] = []

## Acumulador de tempo desde o último spawn
var _spawn_timer: float = 0.0

## Intervalo atual até o próximo spawn — randomizado após
## cada spawn dentro de [CarIaModel.SPAWN_INTERVAL_MIN,
## CarIaModel.SPAWN_INTERVAL_MAX] para evitar ondas regulares
var _next_spawn_interval: float = 2.0

## Velocidade atual do player — recebida via SignalBus
var _current_player_speed: float = 200.0

## Cooldown individual por lane — conta o tempo desde o
## último spawn nessa lane. Spawn só ocorre quando o valor
## atingir LANE_COOLDOWN (lane "resfriou")
var _lane_timers: Dictionary = {
	CarIaModel.Lane.LEFT: LANE_COOLDOWN,
	CarIaModel.Lane.CENTER: LANE_COOLDOWN,
	CarIaModel.Lane.RIGHT: LANE_COOLDOWN
}

## Velocidade atual de cada lane — sorteada no momento do
## spawn e compartilhada por todas as IAs dessa lane.
## Cria o visual de "fila de carros" do Enduro original:
## carros da mesma lane andam juntos, sem se ultrapassar
var _lane_speeds: Dictionary = {
	CarIaModel.Lane.LEFT: 50.0,
	CarIaModel.Lane.CENTER: 50.0,
	CarIaModel.Lane.RIGHT: 50.0
}

## 📌
func _ready() -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		"_ready()")
	SignalBus.CarPlayerViewControllerSignal_speed_changed.connect(
		_on_player_speed_changed)
	_pre_populate_pool()

## Instancia MAX_IA_CARS cópias da cena de IA, deixa todas
## invisíveis e as adiciona como filhas deste autoload
func _pre_populate_pool() -> void:
	for i in MAX_IA_CARS:
		var ia: CarIaViewController = ia_scene.instantiate()
		ia.visible = false
		add_child(ia)
		_pool.append(ia)

## A cada frame: avança os cooldowns de lane, avança o timer
## de spawn, tenta spawnar quando o intervalo é atingido,
## e verifica ultrapassagens + despawns
func _process(delta: float) -> void:
	## Avança cooldown de cada lane — trava em LANE_COOLDOWN
	for lane in _lane_timers:
		_lane_timers[lane] = minf(
			_lane_timers[lane] + delta, LANE_COOLDOWN)

	_spawn_timer += delta
	if _spawn_timer >= _next_spawn_interval:
		_spawn_timer = 0.0
		_try_spawn()

	_update_active_cars()

## Tenta spawnar uma IA do pool. Só spawna em lanes cujo
## cooldown está completo (>= LANE_COOLDOWN). Sorteia entre
## as lanes disponíveis, define a velocidade da lane e
## reseta seu cooldown. Randomiza o próximo intervalo de spawn.
func _try_spawn() -> void:
	if _active_cars.size() >= MAX_IA_CARS:
		return
	if _pool.is_empty():
		return

	## Coleta lanes disponíveis (cooldown completo)
	var available_lanes: Array = []
	for lane in _lane_timers:
		if _lane_timers[lane] >= LANE_COOLDOWN:
			available_lanes.append(lane)

	## Nenhuma lane disponível — aguarda próximo tick
	if available_lanes.is_empty():
		return

	## Sorteia entre as lanes disponíveis
	var lane: CarIaModel.Lane = available_lanes[
		randi() % available_lanes.size()]

	## Nova velocidade para esta lane — compartilhada por
	## todas as IAs que spawnarem nessa lane até o próximo reset
	_lane_speeds[lane] = randf_range(
		CarIaModel.RELATIVE_SPEED_MIN,
		CarIaModel.RELATIVE_SPEED_MAX)

	## Reseta o cooldown da lane escolhida
	_lane_timers[lane] = 0.0

	var ia: CarIaViewController = _pool.pop_back()
	ia.setup(_lane_speeds[lane], lane, _pista)
	ia.visible = true
	_active_cars.append(ia)

	## Próximo spawn em intervalo aleatório
	_next_spawn_interval = randf_range(
		CarIaModel.SPAWN_INTERVAL_MIN,
		CarIaModel.SPAWN_INTERVAL_MAX)

	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		"spawned — lane=%d speed=%.1f next_interval=%.2fs" % [
			lane, _lane_speeds[lane], _next_spawn_interval])

## Verifica todas as IAs ativas:
## - Detecta ultrapassagem (ia.position.y >= player.position.y,
##   não colidida, não contada ainda) → emite signal
## - Despawna as que saíram da tela ou foram atingidas
func _update_active_cars() -> void:
	var to_remove: Array[CarIaViewController] = []

	for ia in _active_cars:
		## Detecta ultrapassagem — só conta uma vez por IA,
		## e apenas se não foi uma colisão (was_hit = false)
		if _player_ref != null \
		and not ia.ia_model.passed_player \
		and not ia.ia_model.was_hit \
		and ia.position.y >= _player_ref.position.y:
			ia.ia_model.passed_player = true
			SignalBus.CarIaPoolManagerSignal_car_passed.emit()
			PrintLogManager.printlog(CLASS_NAME_LOG,
				PrintLogManager.LogType.INFO,
				"car passed ok — signal emitted")

		if ia.should_despawn() or ia.ia_model.was_hit:
			to_remove.append(ia)

	for ia in to_remove:
		_despawn(ia)

## Esconde a IA, reseta posição e flags, e devolve ao pool
func _despawn(ia: CarIaViewController) -> void:
	ia.visible = false
	ia.position = Vector2.ZERO
	_active_cars.erase(ia)
	_pool.append(ia)

## Recebe a velocidade atual do player via SignalBus.
## Armazenada para uso futuro no sistema de dias (EP06)
func _on_player_speed_changed(speed: float) -> void:
	_current_player_speed = speed
