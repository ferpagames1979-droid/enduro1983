## =================================================
## CLASS: CarPlayerViewController
## DESCRIPTION: Handles player car input and physics —
## acceleration (↑), brake (↓), lateral movement (←/→).
## Inherits from CarBaseController.
##
## Crash mechanic: when PlayerArea detects an IaArea
## (area_entered), trigger_crash() sets is_crashed=true,
## forces min_speed, and starts crash_timer counting down
## from crash_penalty_duration (3s). While crashed,
## _handle_movement() ignores all input and holds
## min_speed — IAs the player had overtaken naturally
## catch up and pass, exactly like the original Enduro.
##
## Emits CarPlayerViewControllerSignal_speed_changed every
## frame — consumed by PistaBaseViewController and
## HudViewController.
## AUTHOR: Ferpa Games
## VERSION: 1.1.0
## =================================================
class_name CarPlayerViewController
extends CarBaseController

const CLASS_NAME_LOG_CHILD: String = "CarPlayerViewController"

@onready var area_2d: Area2D = %Area2D

## 📌
func _on_ready() -> void:
	car_type = CarType.PLAYER
	set_car_color(Color.WHITE)
	area_2d.area_entered.connect(_on_area_entered)
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD,
		PrintLogManager.LogType.INFO,
		"_on_ready")
	SignalBus.WeatherViewControllerSignal_weather_changed.connect(_on_weather_changed)

## 📌
## Quando is_crashed=true: ignora input, mantém min_speed,
## decrementa crash_timer até liberar o controle novamente.
## Quando não crashado: processa input normal de movimento
## lateral, aceleração, freio e desaceleração natural.
## Emite a velocidade atual via SignalBus a cada frame.
func _handle_movement(delta: float) -> void:
	if model.is_crashed:
		model.current_speed = model.min_speed
		model.crash_timer -= delta
		if model.crash_timer <= 0.0:
			model.is_crashed = false
			model.crash_timer = 0.0
		SignalBus.CarPlayerViewControllerSignal_speed_changed.emit(
			model.current_speed)
		return

	# Movimento lateral
	if Input.is_action_pressed("ui_right"):
		position.x += model.lateral_speed * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= model.lateral_speed * delta

	# Aceleração / freio / desaceleração natural
	if Input.is_action_pressed("ui_up"):
		model.current_speed = min(
			model.current_speed + model.acceleration * delta * 60,
			model.max_speed)
		sprite_frames.set_animation_speed("default", 100)
	elif Input.is_action_pressed("ui_down"):
		model.current_speed = max(
			model.current_speed - model.brake_force * delta * 60,
			model.min_speed)
		sprite_frames.set_animation_speed("default", 3)
	else:
		model.current_speed = max(
			model.current_speed - model.deceleration * delta * 60,
			model.min_speed)
		sprite_frames.set_animation_speed("default", 8)

	SignalBus.CarPlayerViewControllerSignal_speed_changed.emit(
		model.current_speed)

## 📌
func set_night_mode(_is_night: bool) -> void:
	head_lights.visible = false

## 📌
## Detecta colisão com IA (PlayerArea.area_entered sempre
## envia a Area2D que entrou em contato — IaArea da IA atingida)
func _on_area_entered(area: Area2D) -> void:
	if model.is_crashed:
		return
	var ia: CarIaViewController = area.get_parent() as CarIaViewController
	if ia != null:
		ia.push_away(position.x)
	trigger_crash()
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD, 
							PrintLogManager.LogType.DEBUG, 
							"collision detected - crash triggered")
	
## 📌
## Ativa a penalidade de colisão — trava o player em
## min_speed por crash_penalty_duration segundos
func trigger_crash() -> void:
	model.is_crashed = true
	model.crash_timer = model.crash_penalty_duration
	model.current_speed = model.min_speed
	sprite_frames.set_animation_speed("default", 3)
	
func _on_weather_changed(weather: WeatherModel.Weather) -> void:
	match  weather:
		WeatherModel.Weather.SNOW:
			model.lateral_speed = model.lateral_speed_base * WeatherModel.SNOW_LATERAL_SPEED_MULTIPLIER
		_:
			model.lateral_speed = model.lateral_speed_base
			
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD, 
							PrintLogManager.LogType.INFO,
							"weather changed - lateral_speed: %.1f" % model.lateral_speed)
