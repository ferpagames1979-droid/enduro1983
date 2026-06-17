## OdometerViewController.gd
class_name OdometerViewController
extends Control

const CLASS_NAME_LOG = "OdometerViewController"
const DIGIT_HEIGHT: float = 50.0

@onready var odometer_strip: TextureRect = %OdometerStrip

var _current_digit: int = 0

## 📌
## Avança o odômetro um dígito — chamado pelo HudViewController
## Retorna true quando completa o ciclo (9→0), sinalizando
## que a distância deve ser incrementada
func advance() -> bool:
	_current_digit += 1
	var target_y: float = -_current_digit * DIGIT_HEIGHT
	var completed_cycle: bool = false

	var tween: Tween = create_tween()

	if _current_digit > 9:
		tween.tween_property(odometer_strip, "position:y",
			target_y, 0.1)
		tween.tween_callback(func():
			_current_digit = 0
			odometer_strip.position.y = 0.0)
		completed_cycle = true
	else:
		tween.tween_property(odometer_strip, "position:y",
			target_y, 0.1)

	return completed_cycle
