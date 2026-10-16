extends Node

# save_manager.gd — Gestor de guardado y carga para Heroes Lore: Zero Port (T5.8)
# Soporta los 3 slots de guardado originales y formato JSON estructurado.

const SAVE_DIR: String = "user://saves/"

static func _ensure_dir_exists() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


static func get_save_path(slot: int) -> String:
	return "%ssave_slot_%d.json" % [SAVE_DIR, slot]


static func save_game(slot: int, data: Dictionary) -> bool:
	_ensure_dir_exists()
	var path := get_save_path(slot)
	
	# Añadir metadatos
	data["save_slot"] = slot
	data["timestamp"] = Time.get_datetime_string_from_system()
	data["version"] = "1.0.0-fase5"
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("[SaveManager] Error al abrir para guardar: ", path)
		return false
		
	var json_str := JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()
	print("[SaveManager] Partida guardada con éxito en slot %d: %s" % [slot, path])
	return true


static func load_game(slot: int) -> Dictionary:
	var path := get_save_path(slot)
	if not FileAccess.file_exists(path):
		print("[SaveManager] No existe archivo de guardado en: ", path)
		return {}
		
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("[SaveManager] Error al abrir para leer: ", path)
		return {}
		
	var text := file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		print("[SaveManager] Partida cargada exitosamente de slot %d" % slot)
		return parsed
	else:
		printerr("[SaveManager] JSON corrupto o inválido en slot %d" % slot)
		return {}


static func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))


static func has_any_save() -> bool:
	for slot in [1, 2, 3]:
		if has_save(slot):
			return true
	return false


static func get_latest_save_slot() -> int:
	for slot in [1, 2, 3]:
		if has_save(slot):
			return slot
	return 0

