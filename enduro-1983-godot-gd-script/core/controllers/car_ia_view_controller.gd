class_name CarIaViewController
extends CarBaseController

const CLASS_NAME_LOG_CHILD: String = "CarIaViewController"

const IA_COLORS: Array[Color] = [
	Color.BLUE,
	Color.SEA_GREEN,
	Color.HOT_PINK,
	Color.ORANGE,
	Color.WEB_PURPLE
]

var ia_model: CarIaModel = null

@onready var area_2d: Area2D = %Area2D


var pista: PistaBaseViewController = null

const PUSH_DISTANCE: float = 120

func _on_ready() -> void:
	car_type = CarType.IA
	ia_model = CarIaModel.new()
	model = ia_model
	set_car_color(IA_COLORS[randi() % IA_COLORS.size()])
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD,
		PrintLogManager.LogType.INFO,
		"_on_ready")


func _handle_movement(delta: float) -> void:
	var t: float = _get_t()
	var approach_speed: float = ia_model.relative_speed * delta
	ia_model.screen_y += approach_speed
	t = _get_t()  ## recalcula t após avançar screen_y

	var current_scale: float = lerp(
		ia_model.scale_min, ia_model.scale_max, t)
	scale = Vector2(current_scale, current_scale)

	if pista != null:
		var center_x: float = pista.get_center_x_at(t)
		var half_width: float = pista.get_half_width_at(t)
		var lane_offset: float = 0.0

		match ia_model.lane:
			CarIaModel.Lane.LEFT:
				lane_offset = -half_width * CarIaModel.LANE_OFFSET_RATIO
			CarIaModel.Lane.RIGHT:
				lane_offset = half_width * CarIaModel.LANE_OFFSET_RATIO
			CarIaModel.Lane.CENTER:
				lane_offset = 0.0

		position.x = center_x + lane_offset

	position.y = ia_model.screen_y


func should_despawn() -> bool:
	return ia_model.screen_y >= ia_model.base_y


func set_night_mode(is_night: bool) -> void:
	visible = true
	head_lights.visible = is_night


func _get_t() -> float:
	var t1: float = ia_model.screen_y - ia_model.horizon_y
	var t2: float = ia_model.base_y - ia_model.horizon_y
	return clamp(t1 / t2, 0.0, 1.0)


func setup(relative_speed: float, lane: CarIaModel.Lane,
	pista_ref: PistaBaseViewController) -> void:
	ia_model.relative_speed = relative_speed
	ia_model.lane = lane
	ia_model.screen_y = ia_model.horizon_y
	ia_model.passed_player = false  
	ia_model.was_hit = false        
	pista = pista_ref
	position.y = ia_model.horizon_y
	
	
func push_away(player_x: float) -> void:
	ia_model.was_hit = true
	## Empurra para o lado oposto ao player
	if position.x >= player_x:
		position.x += PUSH_DISTANCE
	else:
		position.x -= PUSH_DISTANCE
	PrintLogManager.printlog(CLASS_NAME_LOG_CHILD,
		PrintLogManager.LogType.INFO,
		"push_away — IA empurrada para x=%.1f" % position.x)
		
		
		
