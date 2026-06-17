## =================================================
## CLASS: OdometerViewController
## DESCRIPTION: Displays the rolling odometer digit —
## faithful to the Enduro 1983 Atari original mechanical
## odometer effect. A TextureRect (OdometerStrip) contains
## all 10 digit frames (0-9) stacked vertically in a
## single spritesheet (50x500px). A clipping Control
## (this node, clip_contents=true, size=50x50) acts as
## a "window" showing only one digit at a time.
##
## advance() moves OdometerStrip.position.y upward via
## Tween (smooth roll effect), one digit per call.
## When the digit exceeds 9 (9→0), the strip resets to
## position.y=0 and returns true — signaling
## HudViewController to increment model.distance.
##
## Called by HudViewController.advance_odometer() via
## OdometerTimer (fixed interval for now — future
## episodes will make it proportional to car speed).
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name OdometerViewController
extends Control

const CLASS_NAME_LOG: String = "OdometerViewController"

## Altura de cada dígito na spritesheet (px).
## Spritesheet total: 50x500px — 10 dígitos de 50x50px cada
const DIGIT_HEIGHT: float = 50.0

## Spritesheet com os 10 dígitos (0-9) empilhados verticalmente.
## Movida em position.y via Tween para criar o efeito de rolagem.
## Fica dentro deste Control (clip_contents=true, size=50x50)
## que age como "janela" mostrando apenas 1 dígito por vez
@onready var odometer_strip: TextureRect = %OdometerStrip

## Dígito atualmente visível (0 a 9).
## Controla o target_y do Tween:
## position.y = -_current_digit * DIGIT_HEIGHT
var _current_digit: int = 0

## 📌
## Avança o odômetro um dígito com animação suave (Tween).
## Retorna true quando completa um ciclo (9→0), sinalizando
## ao HudViewController que model.distance deve ser incrementado.
func advance() -> bool:
	_current_digit += 1
	var target_y: float = -_current_digit * DIGIT_HEIGHT
	var completed_cycle: bool = false
	var tween: Tween = create_tween()

	if _current_digit > 9:
		## Completou ciclo: anima até a posição do "10" (fora do
		## sprite), depois reseta instantaneamente para 0 (dígito 0)
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
