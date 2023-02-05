extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_full_screen_toogle_pressed():
	OS.window_fullscreen = !OS.window_fullscreen;
