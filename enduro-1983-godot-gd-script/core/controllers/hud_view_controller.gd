## =================================================
## CLASS: HudViewController
## DESCRIPTION: Displays the bottom HUD bar — faithful
## to the Enduro 1983 Atari original.
##
## Layout:
## ┌─────────────────────────────────────┐
## │  [laranja] 00970 [odometer] 🏆      │
## │  days_completed  🚗 cars_remaining  │
## └─────────────────────────────────────┘
##
## Listens to SignalBus signals pushed by other systems
## (scoring, DayManager, EnemyPoolManager) in future
## episodes. The odometer advances automatically via
## OdometerTimer — in future episodes the interval will
## be proportional to the car's current speed.
## Pure presentation — no game logic here.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name HudViewController
extends CanvasLayer

const CLASS_NAME_LOG: String = "HudViewController"

var model: HUDModel = null

@onready var distance_label: Label = %DistanceLabel
@onready var days_complete_label: Label = %DaysCompleteLabel
@onready var cars_remaining_label: Label = %CarsRemainingLabel

## Cena filha que encapsula o AnimatedSprite2D do odômetro
## (dígito rolante 0→9). Toda a lógica de animação fica
## em OdometerViewController — aqui só chamamos advance()
@onready var odometer_view: OdometerViewController = %OdometerView

## Timer que dispara o avanço do odômetro periodicamente.
## wait_time fixo por enquanto — em episódios futuros será
## proporcional à velocidade real do carro via SignalBus
@onready var odometer_timer: Timer = %OdometerTimer

## 📌
func _ready() -> void:
	model = HUDModel.new()
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		"_ready()")

	SignalBus.HudViewControllerSignal_distance_changed.connect(
		_on_distance_changed)
	SignalBus.HudViewControllerSignal_cars_remaining_changed.connect(
		_on_cars_remaining_changed)
	SignalBus.HudViewControllerSignal_days_completed_changed.connect(
		_on_days_completed_changed)

	_update_distance_label()
	_update_days_completed_label()
	_update_cars_remaining_label()

	odometer_timer.timeout.connect(_on_odometer_timer_timeout)
	odometer_timer.start()

## 📌
## Recebe a distância percorrida via SignalBus.
## Emitir: SignalBus.HudViewControllerSignal_distance_changed.emit(value)
func _on_distance_changed(new_distance: int) -> void:
	model.distance = new_distance
	_update_distance_label()

## 📌
## Recebe o contador de carros restantes via SignalBus.
## Emitir: SignalBus.HudViewControllerSignal_cars_remaining_changed.emit(value)
func _on_cars_remaining_changed(new_count: int) -> void:
	model.cars_remaining = new_count
	_update_cars_remaining_label()

## 📌
## Recebe os dias completados via SignalBus.
## Emitir: SignalBus.HudViewControllerSignal_days_completed_changed.emit(value)
func _on_days_completed_changed(new_days: int) -> void:
	model.days_completed = new_days
	_update_days_completed_label()

## 📌
## Formata a distância como odômetro zero-padded (ex: 970 → "00970")
func _update_distance_label() -> void:
	distance_label.text = "%05d" % model.distance

## 📌
## Exibe os dias completados (ex: "6")
func _update_days_completed_label() -> void:
	days_complete_label.text = str(model.days_completed)

## 📌
## Exibe o contador decrescente de carros restantes (ex: "208")
func _update_cars_remaining_label() -> void:
	cars_remaining_label.text = "%d" % model.cars_remaining

## 📌
## Dispara o avanço do odômetro a cada tick do OdometerTimer
func _on_odometer_timer_timeout() -> void:
	advance_odometer()

## 📌
## Avança o odômetro um dígito via OdometerViewController.
## Quando o ciclo completa (9→0), incrementa model.distance
## e atualiza o DistanceLabel
func advance_odometer() -> void:
	var completed: bool = odometer_view.advance()
	if completed:
		model.distance += 1
		_update_distance_label()
