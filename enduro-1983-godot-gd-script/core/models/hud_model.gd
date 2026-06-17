## =================================================
## CLASS: HUDModel
## DESCRIPTION: Holds HUD state — distance traveled,
## days completed (trophy multiplier), cars remaining
## to overtake in the current day, and the current
## odometer digit (0-9) used by OdometerViewController.
##
## Layout fiel ao Enduro 1983 Atari:
## Linha 1: [fundo laranja] distancia(4 digitos) + odometro + 🏆
## Linha 2: days_completed + 🚗 + cars_remaining
##
## Pure data class — no logic, no scene references.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name HUDModel
extends Resource

const CLASS_NAME_LOG: String = "HUDModel"

## Distância percorrida (4 dígitos principais) — sobe
## continuamente conforme o odômetro completa ciclos (9→0).
## Exibida como zero-padded (ex: 970 → "0970")
var distance: int = 0

## Dias completados — exibido à esquerda na linha 2
## (ex: "6"). Incrementa quando cars_remaining chega a 0
var days_completed: int = 0

## Carros restantes para ultrapassar no dia atual —
## decrescente, começa em 200 e vai até 0.
## Quando chega a 0, days_completed incrementa e reseta para 200
var cars_remaining: int = 200

## Dígito atual do odômetro (0 a 9) — controla a posição
## vertical da OdometerStrip no OdometerViewController.
## Quando ultrapassa 9, reseta para 0 e distance += 1
var odometer_digit: int = 0
