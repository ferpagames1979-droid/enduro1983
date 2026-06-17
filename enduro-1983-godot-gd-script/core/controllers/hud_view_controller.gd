class_name HudViewController
extends CanvasLayer

const CLASS_NAME_LOG = "HudViewController"

var model : HUDModel = null

@onready var distance_label: Label = %DistanceLabel
@onready var days_complete_label: Label = %DaysCompleteLabel
@onready var carrinho_texture: Label = %CarrinhoTexture
@onready var cars_remaining_label: Label = %CarsRemainingLabel

@onready var odometer_timer: Timer = %OdometerTimer
@onready var odometer: OdometerViewController = %OdometerContainer
const DIGIT_HEIGHT: float = 50

func _ready() -> void:
	model = HUDModel.new()
	PrintLogManager.printlog(CLASS_NAME_LOG, 
							 PrintLogManager.LogType.INFO, 
							"_ready()")
	SignalBus.HudViewControllerSignal_distance_changed.connect(_on_distance_changed)
	SignalBus.HudViewControllerSignal_cars_remaining_changed.connect(_on_cars_remaining_changed)
	SignalBus.HudViewControllerSignal_days_completed_changed.connect(_on_days_completed_changed)
	
	_update_distance_label()
	_update_days_completed_label()
	odometer_timer.timeout.connect(_on_odometer_timer_timeout)
	odometer_timer.start()	
	
func advance_odometer() -> void:
	var completed: bool = odometer.advance()
	if completed:
		model.distance += 1
		_update_distance_label()
	
func _on_distance_changed(new_distance: int) -> void:
	model.distance = new_distance
	_update_distance_label()
	
func _on_cars_remaining_changed(cars_count: int ) -> void:
	model.car_remaining = cars_count
	_updated_cars_remaining_label()
	
func _on_days_completed_changed(days_changed:int) -> void:
	model.days_completed = days_changed
	_update_days_completed_label()
	
func _update_distance_label() -> void:
	distance_label.text = "%04d " % model.distance
	
func _update_days_completed_label() -> void:
	days_complete_label.text = str(model.days_completed)
	
func _updated_cars_remaining_label() -> void:
	cars_remaining_label.text = "%d" % model.car_remaining
	
func _on_odometer_timer_timeout() -> void:
	advance_odometer()
