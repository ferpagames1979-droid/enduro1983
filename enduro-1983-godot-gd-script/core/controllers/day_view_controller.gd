class_name DayViewController
extends Node

const CLASS_NAME_LOG = "DayViewController"

var model : DayModel = null

var _pista : PistaBaseViewController = null

func _ready() -> void:
	model = DayModel.new()
	PrintLogManager.printlog(CLASS_NAME_LOG, PrintLogManager.LogType.INFO, "_ready()")
	model.period_timer = model.period_durations[DayModel.DayPeriod.DAY]
	SignalBus.HudViewControllerSignal_day_completed.connect(_on_day_completed)
	
func _process(delta: float) -> void:
	if _pista == null:
		return
	model.period_timer -= delta
	if model.period_timer <= 0:
		_advance_period()
		
func _advance_period() -> void:
	var next_period: DayModel.DayPeriod

	match model.current_period:
		DayModel.DayPeriod.DAY:
			next_period = DayModel.DayPeriod.SUNSET
		DayModel.DayPeriod.SUNSET:
			next_period = DayModel.DayPeriod.DUSK
		DayModel.DayPeriod.DUSK:
			next_period = DayModel.DayPeriod.NIGHT
		DayModel.DayPeriod.NIGHT:
			## ← ADICIONAR: para o timer para não chamar infinitamente
			model.period_timer = 999999.0
			SignalBus.DayViewControllerSignal_day_ended.emit()
			PrintLogManager.printlog(CLASS_NAME_LOG,
				PrintLogManager.LogType.INFO,
				"day ended - signal emitted")
			return

	_apply_period(next_period)
		
func _apply_period(period: DayModel.DayPeriod) -> void:
	model.current_period = period
	model.period_timer = model.period_durations[period]

	var tween: Tween = create_tween()
	var duration: float = model.transition_duration

	## Terreno — ColorRect raiz da PistaBaseView
	tween.tween_property(_pista.field_rect, "self_modulate",
		model.field_colors[period], duration)

	## Nuvens — Sprite2D (não o Parallax2D pai)
	tween.parallel().tween_property(_pista.clouds_sprite, "self_modulate",
		model.cloud_colors[period], duration)

	## Cidade — Sprite2D (não o Parallax2D pai)
	tween.parallel().tween_property(_pista.city_sprite, "self_modulate",
		model.city_colors[period], duration)

	## Bordas da pista — instantâneo
	var edge_color: Color = model.road_edge_colors[period]
	_pista.road_edge_left.self_modulate = edge_color
	_pista.road_edge_right.self_modulate = edge_color

	SignalBus.DayViewControllerSignal_period_changed.emit(period)

	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		"period -> %s" % DayModel.DayPeriod.keys()[period])
	

func set_snow_mode(is_snow: bool) -> void:
	if _pista == null:
		return

	var edge_color: Color = model.road_edge_snow_color \
		if is_snow else model.road_edge_colors[model.current_period]

	## Usa shader parameter em vez de self_modulate
	## (self_modulate é ignorado quando ShaderMaterial está ativo)
	_pista.road_edge_left.material.set_shader_parameter(
		"line_color", edge_color)
	_pista.road_edge_right.material.set_shader_parameter(
		"line_color", edge_color)

	## Terreno
	var field_color: Color = model.field_snow_color \
		if is_snow else model.field_colors[model.current_period]
	var tween: Tween = create_tween()
	tween.tween_property(_pista.field_rect, "self_modulate",
		field_color, 2.0)

	PrintLogManager.printlog("DayViewController",
		PrintLogManager.LogType.INFO,
		"set_snow_mode(%s)" % is_snow)
	
func _on_day_completed(_new_day:int) -> void:
	_apply_period(DayModel.DayPeriod.DAY)
	PrintLogManager.printlog(CLASS_NAME_LOG, PrintLogManager.LogType.INFO, 
		"cycle reset to day")
	
