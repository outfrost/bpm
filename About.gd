extends Control

func _ready() -> void:
	$Description.connect("meta_clicked", self, "on_meta_clicked")

func _gui_input(event: InputEvent) -> void:
	if handle_input(event):
		accept_event()

func _unhandled_input(event: InputEvent) -> void:
	if handle_input(event):
		get_tree().set_input_as_handled()

func handle_input(event: InputEvent) -> bool:
	if !visible || !event.is_pressed():
		return false
	if (
		event is InputEventKey
		|| event is InputEventMouseButton
		|| event is InputEventJoypadButton
		|| event is InputEventScreenTouch
		|| event is InputEventMIDI
	):
		hide()
	return true

func on_meta_clicked(meta: String):
	show()
	if meta.begins_with("http"):
		OS.shell_open(meta)
