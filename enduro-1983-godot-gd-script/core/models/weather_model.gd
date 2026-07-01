class_name WeatherModel
extends Resource

const CLASS_NAME_LOG = "WeatherModel"

enum Weather {
	CLEAR, 
	FOG, 
	SNOW
}

var current_weather : Weather = Weather.CLEAR

var weather_timer : float = 0

var weather_duration_min: float = 15

var weather_duration_max: float = 30

var fog_chance: Dictionary = {
	DayModel.DayPeriod.DAY : 0.8,
	DayModel.DayPeriod.SUNSET : 0.8,
	DayModel.DayPeriod.DUSK : 0.8,
	DayModel.DayPeriod.NIGHT : 0.8,	
}

var snow_chance: Dictionary = {
	DayModel.DayPeriod.DAY : 0.8,
	DayModel.DayPeriod.SUNSET : 0.8,
	DayModel.DayPeriod.DUSK : 0.8,
	DayModel.DayPeriod.NIGHT : 0.8,	
}

const SNOW_LATERAL_SPEED_MULTIPLIER: float = 0.5

var fog_color : Color = Color.WHITE_SMOKE

var fog_alpha : float = 0.6
