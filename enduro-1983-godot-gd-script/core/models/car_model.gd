
## =================================================
## CLASS: CarModel
## DESCRIPTION: Holds car physics data — speed, movement
## limits, and crash state. Shared by CarBaseController
## and all child classes (CarPlayerViewController,
## CarIaViewController).
## Pure data class — no logic, no scene references.
## AUTHOR: Ferpa Games
## VERSION: 1.1.0
## =================================================
class_name CarModel
extends Resource

const CLASS_NAME_LOG: String = "CarModel"

var lane_x: float = 576.0
var min_x: float = 280.0
var max_x: float = 872.0

var current_speed: float = 200.0
var min_speed: float = 80.0
var max_speed: float = 600.0
var acceleration: float = 60.0
var deceleration: float = 40.0
var brake_force: float = 120.0
var lateral_speed: float = 250.0
var lateral_speed_base: float = 250

## Flag de colisão — quando true, o player fica travado em
## min_speed e sem controle por crash_penalty_duration segundos
var is_crashed: bool = false

## Duração da penalidade de colisão em segundos
var crash_penalty_duration: float = 3.0

## Timer interno da penalidade — decresce a cada frame
## em _handle_movement() até chegar a 0 e liberar o controle
var crash_timer: float = 0.0
