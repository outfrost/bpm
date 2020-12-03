extends Control

const BEAT_COLOURS: Array = [
	Color(0.9, 0.578, 0.225),
	Color(0.816, 0.9, 0.225),
	Color(0.309, 0.9, 0.225),
	Color(0.225, 0.9, 0.647),
	Color(0.225, 0.647, 0.9),
	Color(0.309, 0.225, 0.9),
	Color(0.816, 0.225, 0.9),
	Color(0.9, 0.225, 0.478),
]
const BEAT_DIM_COLOUR: Color = Color(0.188, 0.188, 0.188)

onready var label: Label = $Label
onready var beats: Array = $Beats.get_children()
onready var reset_button: Button = $ResetButton
onready var about: Control = $About

var buf: PoolIntArray = PoolIntArray()
var idx: int = 0
var ct: int = 0
var total_ct: int = 0

func _init() -> void:
	buf.resize(4)
	print(buf)

func _ready() -> void:
	reset_button.connect("pressed", self, "reset")

func _process(_delta: float) -> void:
	var bars: int = total_ct / 4
	for i in range(4):
		if (i <= (idx - 1) && i >= (idx - ct)):
			beats[i].color = BEAT_COLOURS[bars % 8]
		elif bars > 0:
			beats[i].color = BEAT_COLOURS[(bars + 7) % 8]
		else:
			beats[i].color = BEAT_DIM_COLOUR

	if ct < 2:
		return
	var total_msec: int = buf[(idx + 3) % 4] - buf[(idx - ct + 4) % 4]
	var avg_msec: float = (total_msec as float) / ((ct - 1) as float)
	var bpm: float = 1000.0 * 60.0 / avg_msec
	label.text = "%03.f" % bpm

func _gui_input(event: InputEvent) -> void:
	input(event)
	accept_event()

func _unhandled_input(event: InputEvent) -> void:
	input(event)

func input(event: InputEvent) -> void:
	if !event.is_pressed():
		return
	if event.is_action("ui_cancel"):
		reset()
	elif event.is_action("about"):
		about.show()
	elif (
		event is InputEventKey
		|| event is InputEventMouseButton
		|| event is InputEventJoypadButton
		|| event is InputEventScreenTouch
		|| event is InputEventMIDI
	):
		buf[idx] = OS.get_ticks_msec()
		idx = (idx + 1) % 4
		ct += 1
		if ct > 4:
			ct = 4
		total_ct += 1

func reset() -> void:
	idx = 0
	ct = 0
	total_ct = 0
