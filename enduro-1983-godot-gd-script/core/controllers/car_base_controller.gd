## =================================================
## CLASS: CarBaseController
## DESCRIPTION: Base class for all cars (player and IA).
## Handles shared initialization (model, clamp limits,
## sprite setup, headlights) and defines abstract methods
## _on_ready() and _handle_movement() to be overridden
## by child classes.
##
## _process() always calls _handle_movement() — each
## child is responsible for checking model.is_crashed
## internally (e.g. CarPlayerViewController blocks input
## and counts down crash_timer while crashed).
## AUTHOR: Ferpa Games
## VERSION: 1.1.0
## =================================================
class_name CarBaseController
extends AnimatedSprite2D

const CLASS_NAME_LOG: String = "CarBaseController"

enum CarType { PLAYER, IA }

var car_type: CarType = CarType.PLAYER
var model: CarModel

@onready var head_lights: Sprite2D = %HeadLights

## 📌
func _ready() -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		" _ready()")
	model = CarModel.new()

	const ROAD_BOTTOM_HALF_WIDTH: float = 400.0
	const ROAD_CENTER_X: float = 576.0

	var car_half_width: float = (sprite_frames.get_frame_texture("default", 0)
		.get_width() * scale.x) / 2.0

	model.min_x = (ROAD_CENTER_X - ROAD_BOTTOM_HALF_WIDTH) + car_half_width
	model.max_x = (ROAD_CENTER_X + ROAD_BOTTOM_HALF_WIDTH) - car_half_width

	position.x = model.lane_x
	head_lights.visible = false
	play("default")
	_on_ready()

## 📌
func _on_ready() -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.WARNING,
		"ABSTRACT METHOD _on_ready()")

## 📌
## NOTA: não há mais early-return em is_crashed aqui —
## cada child decide o que fazer quando crashado dentro
## do seu próprio _handle_movement() (ver CarPlayerViewController)
func _process(delta: float) -> void:
	_handle_movement(delta)
	_clamp_position()

## 📌
func _handle_movement(_delta: float) -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.WARNING,
		"ABSTRACT METHOD _handle_movement")

## 📌
func _clamp_position() -> void:
	position.x = clamp(position.x, model.min_x, model.max_x)
	model.lane_x = position.x

## 📌
func set_car_color(car_color: Color) -> void:
	self_modulate = car_color

## 📌
func set_night_mode(is_night: bool) -> void:
	head_lights.visible = is_night
