extends Node

# GameClock.gd — Reloj de simulación y desacoplamiento de ticks (T4.3)
# Sincroniza la lógica del juego a la frecuencia exacta original (TICK_HZ = 14 Hz)
# mientras permite que el renderizado y las animaciones corran a 60+ FPS fluidos.

const TICK_HZ: float = 14.0
const TICK_DURATION: float = 1.0 / TICK_HZ # ~0.071428 segundos (71.4 ms)

var tick_accumulator: float = 0.0
var total_ticks: int = 0
var simulation_paused: bool = false

# Señal emitida exactamente 14 veces por segundo para lógica fija
signal game_tick(tick_number: int)

# Factor de interpolación alfa [0.0, 1.0] para suavizado visual en _process
var interpolation_alpha: float = 0.0

func _ready() -> void:
	print("[GameClock] Inicializado: TICK_HZ = %.1f Hz (intervalo = %.3f ms)" % [TICK_HZ, TICK_DURATION * 1000.0])


func _physics_process(delta: float) -> void:
	if simulation_paused:
		return
		
	tick_accumulator += delta
	
	# Consumir ticks acumulados
	while tick_accumulator >= TICK_DURATION:
		total_ticks += 1
		tick_accumulator -= TICK_DURATION
		emit_signal("game_tick", total_ticks)
		
	# Calcular alfa para suavizado visual en _process
	interpolation_alpha = clampf(tick_accumulator / TICK_DURATION, 0.0, 1.0)


## Pausa o reanuda la simulación lógica de ticks
func set_simulation_paused(paused: bool) -> void:
	simulation_paused = paused


## Devuelve el tiempo total de simulación en segundos
func get_simulation_time() -> float:
	return float(total_ticks) * TICK_DURATION
