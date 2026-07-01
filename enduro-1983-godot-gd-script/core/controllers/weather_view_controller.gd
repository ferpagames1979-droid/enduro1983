class_name WeatherViewController
extends Node

const CLASS_NAME_LOG = "WeatherViewController"

var model : WeatherModel = null

var _pista: PistaBaseViewController = null

var _day : DayViewController = null

func _ready() -> void:
	model = WeatherModel.new()
	PrintLogManager.printlog(CLASS_NAME_LOG, 
							PrintLogManager.LogType.INFO,
							"_ready()")
	SignalBus.DayViewControllerSignal_period_changed.connect(_on_period_changed)
	
func _process(delta: float) -> void:
	if _pista == null:
		return
	if model.current_weather == WeatherModel.Weather.CLEAR:
		return
	model.weather_timer -= delta
	if model.weather_timer <= 0:
		_set_weather(WeatherModel.Weather.CLEAR)
		
func _set_weather(weather: WeatherModel.Weather) -> void:
	model.current_weather = weather
	model.weather_timer = randf_range(model.weather_duration_min, 
									 model.weather_duration_max)
									
	var tween: Tween = create_tween()
	
	match weather:
		WeatherModel.Weather.CLEAR:
			tween.tween_property(_pista.weather_sprite, "modulate:a", 0, 2)
			if _day != null:
				_day.set_snow_mode(false)
		WeatherModel.Weather.FOG:
			_pista.weather_sprite.self_modulate = model.fog_color
			tween.tween_property(_pista.weather_sprite, "modulate:a", model.fog_alpha, 3)
			if _day != null:
				_day.set_snow_mode(false)
		WeatherModel.Weather.SNOW:			
			tween.tween_property(_pista.weather_sprite, "modulate:a", 0, 1)
			if _day != null:
				_day.set_snow_mode(true)
				
	SignalBus.WeatherViewControllerSignal_weather_changed.emit(weather)
	
	PrintLogManager.printlog(CLASS_NAME_LOG,
							PrintLogManager.LogType.INFO,
							"Weather -> %s" % WeatherModel.Weather.keys()[weather])
	
func _on_period_changed(period : DayModel.DayPeriod) -> void:
	var roll : float = randf()
	
	if roll < model.snow_chance[period]:         
		_set_weather(WeatherModel.Weather.SNOW)
	elif roll < model.snow_chance[period] + model.fog_chance[period]: 
		_set_weather(WeatherModel.Weather.FOG)
	else:
		_set_weather(WeatherModel.Weather.CLEAR)
