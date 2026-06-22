## =================================================
## CLASS: CarIaModel
## DESCRIPTION: Holds IA car data — relative speed,
## spawn position, and screen Y boundaries.
## Extends CarModel adding IA-specific fields.
## Pure data class — no logic, no scene references.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name CarIaModel
extends CarModel

const CLASS_NAME_LOG_CHILD: String = "CarIaModel"

enum Lane { LEFT, CENTER, RIGHT }

## Faixa que a IA ocupa — relativa ao centro da pista,
## recalculada a cada frame considerando a curva atual
var lane: Lane = Lane.CENTER

## Fração da meia-largura usada para left/right (0.0=centro,
## 1.0=na borda). 0.5 = no meio entre centro e a borda
const LANE_OFFSET_RATIO: float = 0.5

## Velocidade relativa ao player — determina o quão rápido
## a IA "se aproxima" (desce na tela) por frame
var relative_speed: float = 0.0

## Posição Y atual na tela — horizon_y (spawn) até base_y (despawn)
var screen_y: float = 0.0

var horizon_y: float = 300.0
var base_y: float = 600.0

var scale_min: float = 0.1
var scale_max: float = 1.0

var passed_player: bool = false

var was_hit: bool = false
