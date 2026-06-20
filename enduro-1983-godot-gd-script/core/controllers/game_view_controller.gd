class_name GameViewController
extends Node2D

const CLASS_NAME_LOG= "GameViewController"

@onready var car_player_view: CarPlayerViewController = %CarPlayerView

func _ready() -> void:
	CarIaPoolView._pista = %PistaBaseView
	PrintLogManager.printlog(CLASS_NAME_LOG, 
							 PrintLogManager.LogType.INFO,
							" _ready()")
