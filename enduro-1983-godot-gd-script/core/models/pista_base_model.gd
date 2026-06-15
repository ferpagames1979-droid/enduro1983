## =================================================
## CLASS: PistaBaseModel
## DESCRIPTION: Holds road geometry (perspective
## trapezoid with smooth widening) and the curve
## conveyor-belt system.
##
## NEW MODEL (v1.7): accumulated_offset represents the
## road's cumulative lateral position. During a curve
## segment, it increments steadily by curve_increment
## (direction * total_curve_offset / segment_duration).
## During a straight segment, it slowly decays toward 0.
## The DERIVATIVE (offsets[0] - offsets[N-1], i.e. the
## difference across the 80-point window) is what
## actually gets drawn — this represents the LOCAL
## curvature, regardless of the absolute accumulated
## value. This makes curves of any length visible,
## independent of the array size.
##
## Segment durations differ by type: straights are
## shorter (10-30s), curves are longer (30-60s) —
## like a real highway.
## Pure data class — no logic, no scene references.
## AUTHOR: Ferpa Games
## VERSION: 1.7.0
## =================================================
class_name PistaBaseModel
extends Resource

const CLASS_NAME_LOG: String = "PistaBaseModel"

## --- Geometria da pista (trapézio com perspectiva suave) ---
## Largura da pista no horizonte — bem fina
var road_top_width: float = 2.0

## Largura da pista na base — bem larga
var road_bottom_width: float = 900.0

var horizon_y: float = 215.0
var base_y: float = 648.0
var center_x: float = 576.0

## --- Pontos da Line2D ---
var point_count: int = 80

## --- Esteira de offsets — um valor por ponto ---
## offsets[0] = horizonte (mais recente) | offsets[N-1] = base (mais antigo)
var offsets: Array[float] = []

## --- Sistema de curvas (fila com duração variável por tipo) ---
## Direção de cada trecho: -1 = esquerda | 0 = reta | 1 = direita
var curve_queue: Array[int] = []

## Quantos segmentos sortear por vez quando a fila esvaziar
var curve_batch_size: int = 8

## Duração de RETAS (em ticks). Com tick_interval=0.03s,
## 333-1000 ticks = ~10s a 30s
var straight_duration_min: int = 166   # ~5s
var straight_duration_max: int = 333   # ~10s

## Duração de CURVAS (em ticks). Com tick_interval=0.03s,
## 1000-2000 ticks = ~30s a 60s — curvas longas, como uma rodovia real
var curve_duration_min: int = 1000
var curve_duration_max: int = 2000
var curve_rate: float = 0.4
var accumulated_offset_limit: float = 5000.0



## Posição lateral acumulada da pista (cresce/decresce durante
## curvas, decai lentamente durante retas)
var accumulated_offset: float = 0.0

## Taxa de decaimento de accumulated_offset durante retas —
## evita que o valor "fuja" indefinidamente após muitas curvas
## na mesma direção
var straight_decay_rate: float = 0.0008

## --- Timer de progresso ---
## Quanto tempo (em segundos) entre cada "tick" da esteira
var tick_interval: float = 0.03

## Tempo acumulado desde o último tick
var tick_timer: float = 0.0

## Fator que acelera o tick conforme a velocidade do carro aumenta
var speed_tick_factor: float = 0.002

## --- Cores climáticas (usadas a partir do EP08/EP09) ---
var color_day: Color = Color(0.54, 0.54, 0.54)
var color_dusk: Color = Color(0.6, 0.35, 0.3)
var color_fog: Color = Color(0.7, 0.7, 0.7)
var color_snow: Color = Color(0.85, 0.85, 0.9)
