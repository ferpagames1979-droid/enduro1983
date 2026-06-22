## =================================================
## CLASS: CarIaPoolManager
## DESCRIPTION: Manages IA car spawning, pooling, and
## despawning. Uses an object pool to avoid instantiate/
## free overhead. Spawns IAs at the horizon with random
## lanes (LEFT/CENTER/RIGHT) and random relative speeds.
##
## Each spawned IA receives a reference to the track
## (_pista) so it can follow the road's current curve
## (CarIaViewController.setup() + _handle_movement()
## query PistaBaseViewController.get_center_x_at(t) every
## frame to stay aligned with curves, not just go straight
## down the screen).
##
## Listens to player speed via SignalBus — currently only
## stored, not yet used to adjust IA speeds dynamically
## (planned for a future episode).
##
## Added to AutoLoad as "CarIaPoolManager" — no class_name,
## since autoloads conflict with class_name in Godot 4.
## AUTHOR: Ferpa Games
## VERSION: 1.2.0
## =================================================
extends Node

const CLASS_NAME_LOG: String = "CarIaPoolManager"

## Cena da IA (car_ia_view.tscn) — arrastar no Inspector
@export var ia_scene: PackedScene

## Caminho até o nó da pista (PistaBaseViewController) na
## cena ativa — setado no Inspector ou via código externo
## (ex: GameViewController._ready() atribuindo _pista
## diretamente, já que autoload e game_view.tscn vivem em
## hierarquias separadas)
@export var pista_node_path: NodePath

## Referência resolvida à pista — usada por cada IA para
## seguir a curva atual via get_center_x_at(t)
var _pista: PistaBaseViewController = null

## Máximo de IAs simultâneas ativas na tela
const MAX_IA_CARS: int = 5

## Intervalo entre tentativas de spawn (segundos)
const SPAWN_INTERVAL: float = 2.0

## Posição X central da pista (referência legada — a posição
## real agora vem de _pista.get_center_x_at(), considerando curva)
const ROAD_CENTER_X: float = 576.0

## Meia largura da pista (referência legada — idem acima)
const ROAD_HALF_WIDTH: float = 400.0

## Velocidade relativa mínima sorteada para uma IA —
## IA bem mais lenta que o player, fácil de ultrapassar
const RELATIVE_SPEED_MIN: float = 30.0

## Velocidade relativa máxima sorteada para uma IA —
## IA quase tão rápida quanto o player
const RELATIVE_SPEED_MAX: float = 80.0

## IAs atualmente ativas e visíveis na pista
var _active_cars: Array[CarIaViewController] = []

## IAs inativas, prontas para reuso (object pool)
var _pool: Array[CarIaViewController] = []

## Acumulador de tempo desde o último spawn
var _spawn_timer: float = 0.0

## Velocidade atual do player — recebida via SignalBus
var _current_player_speed: float = 200.0

## Pré-popula o pool com MAX_IA_CARS instâncias inativas no
## início do jogo, evitando instantiate()/free() em runtime
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

## A cada frame: avança o timer de spawn e tenta spawnar uma
## nova IA quando o intervalo é atingido; também verifica e
## remove IAs que já passaram da base da pista
func _process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer >= SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_try_spawn()
	_update_active_cars()

## Tenta spawnar uma IA do pool, se houver espaço ativo e
## instâncias disponíveis. Sorteia uma lane (LEFT/CENTER/
## RIGHT) e uma velocidade relativa, e inicializa a IA
## passando a referência da pista para seguir a curva
func _try_spawn() -> void:
	if _active_cars.size() >= MAX_IA_CARS:
		return
	if _pool.is_empty():
		return

	var ia: CarIaViewController = _pool.pop_back()
	var lane: CarIaModel.Lane = [
		CarIaModel.Lane.LEFT,
		CarIaModel.Lane.CENTER,
		CarIaModel.Lane.RIGHT
	][randi() % 3]
	var relative_speed: float = randf_range(
		RELATIVE_SPEED_MIN, RELATIVE_SPEED_MAX)

	ia.setup(relative_speed, lane, _pista)
	ia.visible = true
	_active_cars.append(ia)

## Verifica todas as IAs ativas e despawna as que já
## ultrapassaram a base da pista (should_despawn() == true)
func _update_active_cars() -> void:
	var to_remove: Array[CarIaViewController] = []
	for ia in _active_cars:
		if ia.should_despawn():
			to_remove.append(ia)
	for ia in to_remove:
		_despawn(ia)

## Esconde a IA, reseta sua posição, e a devolve ao pool
## para reuso em um próximo spawn
func _despawn(ia: CarIaViewController) -> void:
	ia.visible = false
	ia.position = Vector2.ZERO
	_active_cars.erase(ia)
	_pool.append(ia)

## Recebe a velocidade atual do player via SignalBus.
## Armazenada para uso futuro (ajuste dinâmico da
## velocidade relativa das IAs conforme o player acelera)
func _on_player_speed_changed(speed: float) -> void:
	_current_player_speed = speed
