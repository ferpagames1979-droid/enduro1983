## SignalBus 
extends Node

## CarPlayerViewController
signal CarPlayerViewControllerSignal_speed_changed(speed : float)

## PistaBaseViewController
signal PistaBaseViewControllerSignal_road_offset_changed(offset: float)

## HudViewController
signal HudViewControllerSignal_distance_changed(new_distance: int)
signal HudViewControllerSignal_days_completed_changed(new_day : int)
signal HudViewControllerSignal_cars_remaining_changed(new_car : int)
signal HudViewControllerSignal_day_completed(new_day: int)

## CarIaPoolManager
signal CarIaPoolManagerSignal_car_passed

## DayViewController
signal DayViewControllerSignal_period_changed(period : DayModel.DayPeriod)
signal DayViewControllerSignal_day_ended()
