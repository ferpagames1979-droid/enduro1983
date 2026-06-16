## =================================================
## CLASS: HUDModel
## DESCRIPTION: Holds HUD state data — score, remaining
## cars to overtake, current weather/period, and number
## of days completed (trophy multiplier).
##
## Pure data class — no logic, no scene references.
## All values are updated via SignalBus signals received
## by HUDViewController.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name HUDModel
extends Resource

const CLASS_NAME_LOG: String = "HUDModel"

## Pontuação/distância percorrida — sobe continuamente,
## exibida como odômetro (zero-padded, ex: "0118")
var score: int = 0

## Carros restantes para ultrapassar no dia atual —
## decrescente, exibido com ícone de carrinho ao lado
var cars_remaining: int = 200

## Período/clima atual — usado para escolher o ícone
## (DAY, NIGHT, SNOW, FOG)
enum WeatherPeriod { DAY, NIGHT, SNOW, FOG }
var weather_period: WeatherPeriod = WeatherPeriod.DAY

## Dias completados — exibido como "🏆 x{days_completed}"
var days_completed: int = 0
