class_name DayModel
extends Resource

const CLASS_NAME_LOG = "DayModel"

enum DayPeriod {
	DAY,
	SUNSET,
	DUSK, 
	NIGHT
}

var current_period: DayPeriod = DayPeriod.DAY

var period_timer: float = 0

var period_durations : Dictionary = {
	DayPeriod.DAY : 10,
	DayPeriod.SUNSET : 10,
	DayPeriod.DUSK : 10,
	DayPeriod.NIGHT : 10,
}

var field_colors : Dictionary = {
	DayPeriod.DAY : Color.LIGHT_GRAY,
	DayPeriod.SUNSET : Color.SANDY_BROWN,
	DayPeriod.DUSK : Color.SLATE_GRAY,
	DayPeriod.NIGHT : Color.BLACK,
}

var cloud_colors : Dictionary = {
	DayPeriod.DAY : Color.WHITE,
	DayPeriod.SUNSET : Color.ORANGE,
	DayPeriod.DUSK : Color.DIM_GRAY,
	DayPeriod.NIGHT : Color.DARK_GRAY,
}

var city_colors : Dictionary = {
	DayPeriod.DAY : Color.WHITE,
	DayPeriod.SUNSET : Color.SANDY_BROWN,
	DayPeriod.DUSK : Color.DIM_GRAY,
	DayPeriod.NIGHT : Color.DARK_SLATE_GRAY,
}

var road_edge_colors : Dictionary = {
	DayPeriod.DAY : Color.WHITE,
	DayPeriod.SUNSET : Color.WHITE,
	DayPeriod.DUSK : Color.WHITE,
	DayPeriod.NIGHT : Color.WHITE,
}

var road_edge_snow_color : Color = Color.CORNFLOWER_BLUE

var transition_duration : float = 2

const CARS_DAY_ONE : int = 200

const CARS_DAY_TWO_PLUS : int = 300

var current_day : int = 1

#
var field_snow_color: Color = Color.WHITE_SMOKE
