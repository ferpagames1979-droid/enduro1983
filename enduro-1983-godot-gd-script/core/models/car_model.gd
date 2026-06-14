class_name CarModel
extends Resource

const CLASS_NAME_LOG = "CarModel"

var lane_x : float = 576

var min_x : float = 280
var max_x : float = 872

var current_speed : float = 200
var min_speed : float = 80
var max_speed: float = 600

var acceleration : float = 60
var deceleration : float = 40
var brake_force : float = 120

var lateral_speed : float = 250
var is_crashed : bool = false
