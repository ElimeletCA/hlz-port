extends Node2D

# Script de medición para la escena de benchmark 2D (T0.9)
# Permite registrar FPS y tiempo de cuadro en perfiles de prueba

var frames_counted: int = 0
var time_elapsed: float = 0.0
var max_test_seconds: float = 5.0 # Duración de prueba automática

@onready var label_fps: Label = $CanvasLayer/LabelFPS

func _ready() -> void:
	print("[Benchmark2D] Iniciando escena de referencia 2D...")
	print("[Benchmark2D] Renderer actual: ", RenderingServer.get_video_adapter_name(), " (", RenderingServer.get_video_adapter_type(), ")")

func _process(delta: float) -> void:
	frames_counted += 1
	time_elapsed += delta
	
	if label_fps:
		label_fps.text = "FPS: %d | Frame: %.2f ms" % [Engine.get_frames_per_second(), delta * 1000.0]
		
	# Si se ejecuta en modo headless o automatizado con límite de tiempo
	if DisplayServer.get_name() == "headless" and time_elapsed >= 1.0:
		print("[Benchmark2D] Prueba headless superada a 1.0s. Saliendo limpiamente.")
		get_tree().quit(0)
