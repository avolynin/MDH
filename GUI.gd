extends Control

@onready var label_mode: Label = $LabelMode

func _on_manipulator_mode_changed(mode):
	label_mode.text = "Mode: " + mode
	if mode == "+":
		label_mode.set("modulate", Color.GREEN)
	else:
		label_mode.set("modulate", Color.RED)
