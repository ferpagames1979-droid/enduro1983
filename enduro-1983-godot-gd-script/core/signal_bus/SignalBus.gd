extends Node

## CarPlayerViewController
signal CarPlayerViewControllerSignal_speed_changed(speed : float)

## PistaBaseViewController
signal PistaBaseViewControllerSignal_road_offset_changed(offset: float)

## HudViewController
signal HudViewControllerSignal_distance_changed(new_distance: int)
signal HudViewControllerSignal_days_completed_changed(new_days: int)
signal HudViewControllerSignal_cars_remaining_changed(new_count: int)
