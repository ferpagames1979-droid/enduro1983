class_name CarBaseController
extends AnimatedSprite2D

const CLASS_NAME_LOG = "CarBaseController"

enum CarType { PLAYER, IA }

var car_type : CarType = CarType.PLAYER
var model : CarModel 

@onready var head_lights: Sprite2D = %HeadLights

func _ready() -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG, 
							PrintLogManager.LogType.INFO,
							" _ready()")
	model = CarModel.new()
	position.x = model.lane_x
	head_lights.visible = false
	play("default")
	_on_ready()
	
func _on_ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if model.is_chashed:
		return
	_handle_movement(delta)
	_clamp_position()
		
## abstract method needs to be implement on child class 
func _handle_movement(_delta : float) -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG, 
							 PrintLogManager.LogType.WARNING,
							" _handle_movement")
							
func _clamp_position() -> void:
	position.x = clamp(position.x, model.min_x, model.max_x)
	model.lane_x = position.x
	
func set_car_color(color:Color) -> void:
	self_modulate = color
	
func set_night_mode(is_night : bool) -> void:
	head_lights.visible = is_night
	
