## =================================================
## CLASS: PistaBaseModel
## DESCRIPTION: Holds road geometry (perspective
## trapezoid) and the curve system.
##
## v4.1 — CUBIC BEZIER CURVE MODEL: each road edge
## (left/right) is drawn as a single cubic Bezier curve
## (4 control points: horizon, P1, P2, base) — smooth
## across the entire t=[0,1] range, no internal joints,
## no kinks. P0=horizon and P3=base are always centered
## on center_x. P1 receives the full curve_amount offset;
## P2 receives an attenuated offset (0.3x) to avoid
## overshoot near the base, guaranteeing monotonicity
## (left edge always decreases, right edge always
## increases — no crossing, no ripple).
##
## curve_amount (-1.0 to 1.0) eases smoothly (lerp) toward
## a target defined by the current segment in curve_queue.
## Segment durations differ by type: straights are shorter
## (5-10s), curves are longer (30-60s) — like a real highway.
## Pure data class — no logic, no scene references.
## AUTHOR: Ferpa Games
## VERSION: 4.1.0
## =================================================
class_name PistaBaseModel
extends Resource

const CLASS_NAME_LOG: String = "PistaBaseModel"

## --- Geometria da pista (trapézio) ---
## Largura da pista no horizonte — bem fina (vértice "fechado",
## sensação de distância)
var road_top_width: float = 1

## Largura da pista na base — bem larga
var road_bottom_width: float = 1000

var horizon_y: float = 300.0
var base_y: float = 600.0
var center_x: float = 576.0

## --- Pontos da Line2D ---
var point_count: int = 80

## --- Sistema de curvas (fila com duração variável por tipo) ---
## Direção de cada trecho: -1 = esquerda | 0 = reta | 1 = direita
var curve_queue: Array[int] = []

## Quantos segmentos sortear por vez quando a fila esvaziar
var curve_batch_size: int = 8

## Duração de RETAS (em ticks). Com tick_interval=0.03s,
## 166-333 ticks = ~5s a 10s
var straight_duration_min: int = 200
var straight_duration_max: int = 400

## Duração de CURVAS (em ticks). Com tick_interval=0.03s,
## 1000-2000 ticks = ~30s a 60s — curvas longas, como uma rodovia real
var curve_duration_min: int = 200
var curve_duration_max: int = 400

## Ticks restantes do segmento atual (consumido tick a tick)
var ticks_remaining: int = 0

## --- Curva atual (valor único, -1.0 a 1.0) ---
## Direção/intensidade atual da curva. 0 = reta, ±1 = curva máxima
var curve_amount: float = 0.0

## Velocidade de transição de curve_amount em direção ao alvo —
## leva ~3-4s para chegar perto do alvo (entrada/saída suaves)
var curve_amount_lerp_speed: float = 0.02

## Deslocamento máximo do ponto de controle P1 (33% do caminho)
## quando curve_amount = ±1. Horizonte (t=0) e base (t=1) sempre
## ficam centrados em center_x — a curva é uma Bezier cúbica
## (ver _redraw_road_edges no Controller)
var max_curve_offset: float = 180.0

## --- Timer de progresso ---
## Quanto tempo (em segundos) entre cada "tick" do sistema de curvas
var tick_interval: float = 0.03

## Tempo acumulado desde o último tick
var tick_timer: float = 0.0

## Fator que acelera o tick conforme a velocidade do carro aumenta
var speed_tick_factor: float = 0.002

## --- Cores climáticas (usadas a partir do EP08/EP09) ---
var color_day: Color = Color.LIGHT_GOLDENROD
var color_night: Color = Color.DARK_BLUE
var color_dusk: Color = Color.CORAL
var color_fog : Color = Color.DIM_GRAY
var color_snow: Color = Color.WHITE_SMOKE
