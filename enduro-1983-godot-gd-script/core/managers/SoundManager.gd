## =================================================
## CLASS: SoundManager
## DESCRIPTION: Manages all audio for Enduro 1983.
## Handles background music (day/night variants),
## engine sound (pitch proportional to speed),
## and SFX (crash, overtake, day completed, weather).
##
## Engine sound uses a dedicated looping AudioStreamPlayer
## with pitch_scale animated proportional to car speed —
## higher speed = higher pitch, idle speed = low pitch.
##
## Music switches automatically between day and night
## themes via DayViewControllerSignal_period_changed.
##
## Autoload — persists across scenes.
## No class_name — autoloads conflict with class_name
## in Godot 4.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
extends Node

const CLASS_NAME_LOG: String = "SoundManager"

## Audio toggle controls
var music_enabled: bool = true
var sfx_enabled: bool = true

## SFX paths
var sfx: Dictionary = {
	"car_acelerate": 	"res://assets/sounds/sfx/car_acelerate.mp3",
	"crash":         "res://assets/sounds/sfx/car_crash.mp3",
	"overtake":      "res://assets/sounds/sfx/car_pass.mp3",
	"day_completed": "res://assets/sounds/sfx/claps.mp3",
	"brake":         "res://assets/sounds/sfx/car_break.mp3",
}

## Music paths — day and night variants
const MUSIC_DAY   = "res://assets/sounds/music/game_theme.mp3"
const MUSIC_NIGHT = "res://assets/sounds/music/night_music.mp3"

## Engine pitch range — proportional to car speed
## CarModel.min_speed(80) → PITCH_MIN | CarModel.max_speed(600) → PITCH_MAX
const PITCH_MIN: float = 0.6
const PITCH_MAX: float = 1.8
const SPEED_MIN: float = 80.0
const SPEED_MAX: float = 600.0

## Velocidade atual do carro — recebida via SignalBus
var _current_speed: float = 80.0

## Flag para saber se estamos no período de noite —
## usado para não trocar música desnecessariamente
var _is_night: bool = false

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var engine_player: AudioStreamPlayer = AudioStreamPlayer.new()

## 📌
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	add_child(engine_player)

	_setup_engine_player()
	_connect_signals()
	play_music(MUSIC_DAY)

	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		CLASS_NAME_LOG + " _ready()")

## 📌
## Configura o AudioStreamPlayer do motor — loop contínuo,
## pitch animado em _process() proporcional à velocidade
func _setup_engine_player() -> void:
	engine_player.stream = load("res://assets/sounds/sfx/car_acelerate.mp3")
	engine_player.volume_db = -10.0
	engine_player.pitch_scale = PITCH_MIN
	engine_player.play()

## 📌
## Anima o pitch do motor proporcional à velocidade atual.
## Mapeia CarModel.min_speed→max_speed para PITCH_MIN→PITCH_MAX
func _process(_delta: float) -> void:
	if not sfx_enabled:
		engine_player.volume_db = -80.0
		return
	var speed_ratio: float = clamp(
		(_current_speed - SPEED_MIN) / (SPEED_MAX - SPEED_MIN), 0.0, 1.0)
	engine_player.pitch_scale = lerp(PITCH_MIN, PITCH_MAX, speed_ratio)
	engine_player.volume_db = -10.0

## 📌
## Conecta todos os signals do SignalBus automaticamente.
## Cada signal dispara o SFX correspondente via play_sfx()
func _connect_signals() -> void:
	## Velocidade do player — anima o pitch do motor
	SignalBus.CarPlayerViewControllerSignal_speed_changed.connect(
		func(speed: float): _current_speed = speed)

	## Colisão — toca crash SFX
	## O signal já existe pois CarPlayerViewController emite via push_away
	SignalBus.CarPlayerViewControllerSignal_crashed.connect(
	func(): play_sfx("crash"))

	## Ultrapassagem — beep curto ao passar uma IA
	SignalBus.CarIaPoolManagerSignal_car_passed.connect(
		func(): play_sfx("overtake"))

	## Dia completado — fanfarra curta
	SignalBus.HudViewControllerSignal_day_completed.connect(
		func(_day: int): play_sfx("day_completed"))

	

	## Período do dia — troca música entre day/night
	SignalBus.DayViewControllerSignal_period_changed.connect(
		func(period: DayModel.DayPeriod): _on_period_changed(period))

## 📌
## Troca a música conforme o período do dia.
## Noite = MUSIC_NIGHT | qualquer outro período = MUSIC_DAY
func _on_period_changed(period: DayModel.DayPeriod) -> void:
	var is_night: bool = period == DayModel.DayPeriod.NIGHT
	if is_night == _is_night:
		return
	_is_night = is_night
	play_music(MUSIC_NIGHT if is_night else MUSIC_DAY)

## 📌
## Toca música em loop — troca suavemente se já estiver tocando
func play_music(path: String) -> void:
	if not music_enabled:
		return
	music_player.stream = load(path)
	music_player.volume_db = -15.0
	music_player.play()
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		"music → %s" % path.get_file())

## 📌
## Para a música
func stop_music() -> void:
	music_player.stop()

## 📌
## Toca um SFX por nome — cria um AudioStreamPlayer temporário
## e o libera automaticamente quando terminar (queue_free)
func play_sfx(sfx_name: String) -> void:
	if not sfx_enabled:
		return
	if not sfx.has(sfx_name):
		PrintLogManager.printlog(CLASS_NAME_LOG,
			PrintLogManager.LogType.WARNING,
			"SFX not found: " + sfx_name)
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.stream = load(sfx[sfx_name])
	player.volume_db = -5.0
	player.play()
	player.finished.connect(player.queue_free)
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		"sfx → %s" % sfx_name)

## 📌
func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if not music_enabled:
		stop_music()
	else:
		play_music(MUSIC_NIGHT if _is_night else MUSIC_DAY)

## 📌
func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
