class_name CarPlayerViewController
extends CarBaseController

const CLASS_NAME_LOG_CHILD = "CarPlayerViewController"

func _on_ready() -> void:
	car_type = CarType.PLAYER
	set_car_color(Color.WHITE)
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD, 
							PrintLogManager.LogType.INFO,
							"_on_ready")
							
func _handle_movement(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		position.x += model.lateral_speed * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= model.lateral_speed * delta
		
	##acceleration
	if Input.is_action_pressed("ui_up"):
		model.current_speed = min(model.current_speed + model.acceleration * delta * 60, 
								 model.max_speed)
		sprite_frames.set_animation_speed("default", 100)
	elif Input.is_action_pressed("ui_down"):
		model.current_speed = max(model.current_speed - model.brake_force * delta * 60, 
						 model.min_speed)
		sprite_frames.set_animation_speed("default", 3)
	else:
		model.current_speed = max(model.current_speed - model.deceleration * delta * 60,
								 model.min_speed)
		sprite_frames.set_animation_speed("default", 8)
	SignalBus.CarPlayerViewControllerSignal_speed_changed.emit(model.current_speed)
				
func set_night_mode(_is_night : bool) -> void:
	head_lights.visible = false
