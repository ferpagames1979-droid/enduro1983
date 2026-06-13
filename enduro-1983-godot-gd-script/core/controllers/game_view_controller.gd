## =================================================
## CLASS: GameViewController
## DESCRIPTION: Main game scene controller.
## Orchestrates all game systems.
## AUTHOR: Ferpa Games
## VERSION: 1.0.0
## =================================================
class_name GameViewController
extends Node2D

const CLASS_NAME_LOG: String = "GameViewController"

@onready var car_player: CarPlayerViewController = %CarPlayerView

## 📌
func _ready() -> void:
	PrintLogManager.printlog(CLASS_NAME_LOG,
		PrintLogManager.LogType.INFO,
		CLASS_NAME_LOG + " _ready()")
