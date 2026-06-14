class_name CarIaViewController
extends CarBaseController

const CLASS_NAME_LOG_CHILD = "CarIaViewController"

const IA_COLORS: Array[Color] = [
	Color.BLUE,
	Color.SEA_GREEN,
	Color.HOT_PINK,
	Color.ORANGE,
	Color.WEB_PURPLE	
]

func _on_ready() -> void:
	car_type = CarType.IA
	set_car_color(IA_COLORS[randi() % IA_COLORS.size()])	
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD, 
							PrintLogManager.LogType.INFO,
							"_on_ready")
							
func _handle_movement(_delta: float) -> void:
	pass
				
func set_night_mode(is_night : bool) -> void:
	visible = !is_night
	head_lights.visible = is_night
