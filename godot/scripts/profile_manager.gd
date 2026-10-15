extends Node

# ProfileManager.gd — Gestor de perfiles de rendimiento y calidad gráfica (T4.11)
# Define y aplica los perfiles Bajo, Medio y Alto sin comprometer la legibilidad.

enum QualityProfile {
	LOW = 0,
	MEDIUM = 1,
	HIGH = 2
}

var current_profile: QualityProfile = QualityProfile.MEDIUM

signal profile_changed(profile_name: String)

func _ready() -> void:
	print("[ProfileManager] Inicializado con perfil: ", get_profile_name())


## Aplica un perfil por nombre ("low", "medium", "high") o enum
func set_profile(profile: QualityProfile) -> void:
	current_profile = profile
	
	match profile:
		QualityProfile.LOW:
			# Perfil Bajo: pensado para gráficas integradas (Intel UHD)
			# Reduce carga de partículas y desactiva luces 2D secundarias
			RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
			print("[ProfileManager] Perfil BAJO activado: partículas al 50%, MSAA deshabilitado")
			
		QualityProfile.MEDIUM:
			# Perfil Medio: equilibrado para 1080p nativo
			RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_2X)
			print("[ProfileManager] Perfil MEDIO activado: partículas 100%, MSAA 2X")
			
		QualityProfile.HIGH:
			# Perfil Alto: optimizado para GPU dedicada (RTX 3050 Ti) y salida 4K
			RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_4X)
			print("[ProfileManager] Perfil ALTO activado: partículas enriquecidas, MSAA 4X")
			
	emit_signal("profile_changed", get_profile_name())


func get_profile_name() -> String:
	match current_profile:
		QualityProfile.LOW: return "Bajo"
		QualityProfile.MEDIUM: return "Medio"
		QualityProfile.HIGH: return "Alto"
	return "Medio"


## Devuelve el factor multiplicador de partículas según el perfil
func get_particle_multiplier() -> float:
	match current_profile:
		QualityProfile.LOW: return 0.5
		QualityProfile.MEDIUM: return 1.0
		QualityProfile.HIGH: return 1.5
	return 1.0
