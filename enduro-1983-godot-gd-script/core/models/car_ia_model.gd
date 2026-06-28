## =================================================
## CLASS: CarIaModel
## DESCRIPTION: Holds IA car data — relative speed,
## spawn position, screen Y boundaries, lane assignment,
## overtake/collision flags, and per-IA spawn interval.
##
## Each IA has its own relative_speed (randomly assigned
## at spawn) and spawn_interval (randomly assigned by
## CarIaPoolManager after each spawn) — creating varied
## "personalities": some IAs are slow and easy to pass,
## others are fast and challenging. Spawn intervals vary
## so IAs don't all arrive in waves.
##
## Extends CarModel adding IA-specific fields.
## Pure data class — no logic, no scene references.
## AUTHOR: Ferpa Games
## VERSION: 1.2.0
## =================================================
class_name CarIaModel
extends CarModel

const CLASS_NAME_LOG_CHILD: String = "CarIaModel"

enum Lane { LEFT, CENTER, RIGHT }

## Faixa que a IA ocupa — relativa ao centro da pista,
## recalculada a cada frame considerando a curva atual
var lane: Lane = Lane.CENTER

## Fração da meia-largura usada para offset lateral.
## 0.0 = no centro | 0.5 = meio entre centro e borda | 1.0 = na borda
const LANE_OFFSET_RATIO: float = 0.5

## Velocidade relativa ao player — determina o quão rápido
## a IA "se aproxima" (desce na tela) por frame.
## Sorteada individualmente no spawn para criar variedade:
## algumas IAs lentas (fáceis), outras rápidas (desafio)
var relative_speed: float = 0.0

## Velocidade mínima sorteável para esta IA (dia 1)
## Aumentada pelo CarIaPoolManager a cada dia concluído
const RELATIVE_SPEED_MIN: float = 20.0

## Velocidade máxima sorteável para esta IA (dia 1).
## Range amplo (20-120) garante contraste entre IAs lentas e rápidas
const RELATIVE_SPEED_MAX: float = 120.0

## Posição Y atual na tela — horizon_y (spawn) até base_y (despawn)
var screen_y: float = 0.0

var horizon_y: float = 300.0
var base_y: float = 600.0

var scale_min: float = 0.1
var scale_max: float = 1.0

## Flag que garante que a ultrapassagem é contada apenas
## uma vez por IA — evita decrementar cars_remaining múltiplas
## vezes enquanto a IA passa pelo Y do player.
## Resetada para false no setup() a cada reutilização do pool
var passed_player: bool = false

## Flag que indica se esta IA foi despawnada por colisão —
## IAs colididas NÃO contam como ultrapassagem.
## Resetada para false no setup() a cada reutilização do pool
var was_hit: bool = false

## Intervalo de spawn individual desta IA — sorteado pelo
## CarIaPoolManager após cada spawn dentro de
## [SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX].
## Evita que todas as IAs apareçam em "ondas" regulares,
## criando espaçamento variado entre carros na pista
var spawn_interval: float = 2.0

## Intervalo mínimo entre spawns — IAs podem aparecer
## mais próximas uma da outra
const SPAWN_INTERVAL_MIN: float = 0.8

## Intervalo máximo entre spawns — dá mais espaçamento
## entre carros, permitindo respirar entre ultrapassagens
const SPAWN_INTERVAL_MAX: float = 3.5
