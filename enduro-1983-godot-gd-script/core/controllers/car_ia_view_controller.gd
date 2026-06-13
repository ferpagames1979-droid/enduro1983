## =================================================
## CLASS: CarIAViewController
## DESCRIPTION: IA car controller.
## Inherits from CarBaseController.
## Color set dynamically via self_modulate.
## Night mode hides car body, shows headlights.
## IA movement logic implemented in EP04.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name CarIAViewController
extends CarBaseController

const CLASS_NAME_LOG_CHILD: String = "CarIAViewController"

const IA_COLORS: Array[Color] = [
	Color(0.2, 0.6, 1.0),   # azul
	Color(0.2, 0.9, 0.3),   # verde
	Color(1.0, 0.4, 0.8),   # rosa
	Color(1.0, 0.7, 0.1),   # laranja
	Color(0.8, 0.2, 1.0),   # roxo
]

## 📌
func _on_ready() -> void:
	car_type = CarType.IA
	set_car_color(IA_COLORS[randi() % IA_COLORS.size()])
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD,
		PrintLogManager.LogType.INFO,
		CLASS_NAME_LOG + " _ready()")

## 📌
## Lógica de IA — implementada no EP 04
func _handle_movement(_delta: float) -> void:
	pass

## 📌
## À noite: esconde o carro, mostra só os faróis vermelhos
## Fiel ao Enduro original
func set_night_mode(is_night: bool) -> void:
	visible = not is_night
	head_lights.visible = is_night
