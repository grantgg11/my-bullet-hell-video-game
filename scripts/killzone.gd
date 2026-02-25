extends Area2D

@onready var timer: Timer = $Timer
var triggered := false

func _ready() -> void:
	timer.one_shot = true
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS 
	
func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	triggered = true
	
	print("You died")
	Engine.time_scale = 0.5
	if body.has_method("die"):
		body.call("die")
	timer.start()
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
