extends Node2D

# benchmark.gd — Escena de benchmark 2D sintética para medición de rendimiento (T4.10, T4.11, T4.12)
# Mide FPS, tiempos de cuadro y memoria en perfiles Bajo, Medio y Alto.

var frames_counted: int = 0
var time_elapsed: float = 0.0
var max_test_seconds: float = 3.0 # Duración de prueba por iteración
var frame_times: Array[float] = []

@onready var label_fps: Label = $CanvasLayer/LabelFPS
@onready var particles: CPUParticles2D = $ParticlesTest

func _ready() -> void:
	print("[Benchmark2D] Iniciando benchmark de rendimiento 2D...")
	var adapter = RenderingServer.get_video_adapter_name()
	var adapter_type = RenderingServer.get_video_adapter_type()
	print("[Benchmark2D] GPU Adapter: ", adapter, " (Tipo: ", adapter_type, ")")
	print("[Benchmark2D] Perfil actual: ", ProfileManager.get_profile_name())
	
	# Ajustar emisor de partículas según perfil
	if particles:
		var mult = ProfileManager.get_particle_multiplier()
		particles.amount = int(32.0 * mult)


func _process(delta: float) -> void:
	frames_counted += 1
	time_elapsed += delta
	frame_times.append(delta * 1000.0)
	
	if label_fps:
		var mem_mb = OS.get_static_memory_usage() / (1024.0 * 1024.0)
		label_fps.text = "FPS: %d | Frame: %.2f ms | RAM: %.1f MB | Perfil: %s" % [
			Engine.get_frames_per_second(),
			delta * 1000.0,
			mem_mb,
			ProfileManager.get_profile_name()
		]
		
	# En ejecución headless o automatizada, reportar métricas al finalizar
	if time_elapsed >= max_test_seconds:
		_report_results()
		get_tree().quit(0)


func _report_results() -> void:
	var avg_frame_time = 0.0
	for t in frame_times:
		avg_frame_time += t
	if frame_times.size() > 0:
		avg_frame_time /= float(frame_times.size())
		
	var avg_fps = 1000.0 / avg_frame_time if avg_frame_time > 0 else 0.0
	var mem_mb = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	
	print("\n=== RESULTADOS DE BENCHMARK 2D ===")
	print("  GPU Adapter:      ", RenderingServer.get_video_adapter_name())
	print("  Perfil:           ", ProfileManager.get_profile_name())
	print("  Resolución:       ", DisplayServer.window_get_size())
	print("  Total cuadros:    ", frames_counted)
	print("  FPS promedio:     %.1f FPS" % avg_fps)
	print("  Tiempo de cuadro: %.2f ms" % avg_frame_time)
	print("  Memoria estática: %.2f MB" % mem_mb)
	print("==================================\n")
