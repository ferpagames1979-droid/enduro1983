class_name GameViewController
extends Node2D

const CLASS_NAME_LOG= "GameViewController"

@onready var car_player_view: CarPlayerViewController = %CarPlayerView
@onready var day_view_controller: DayViewController = %DayViewController
@onready var pista_base_view: PistaBaseViewController = %PistaBaseView

func _ready() -> void:	
	PrintLogManager.printlog(CLASS_NAME_LOG, 
							 PrintLogManager.LogType.INFO,
							" _ready()")
	CarIaPoolView._pista = %PistaBaseView
	CarIaPoolView._player_ref = %CarPlayerView
	
	day_view_controller._pista = pista_base_view
	
	SignalBus.DayViewControllerSignal_day_ended.connect(_on_day_ended)
	
func _on_day_ended() -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG, PrintLogManager.LogType.INFO, 
	"day ended")
	
