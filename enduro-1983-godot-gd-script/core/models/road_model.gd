class_name RoadModel
extends Resource

const ROAD_LINES := 160

var screen_width := 1152.0
var horizon_y := 220.0
var base_y := 540.0
var center_x := 576.0

var offsets : Array[float] = []

var curve_queue : Array[int] = []

var accumulator := 0.0

var min_offset := -250.0
var max_offset := 250.0

var curve_delta := 2.0

var tick_timer := 0.0
var tick_interval := 0.03



func setup():

	offsets.clear()

	for i in range(ROAD_LINES):
		offsets.append(0.0)
