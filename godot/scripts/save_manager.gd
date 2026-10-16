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
	
	# Añadir metadatos si no están presentes
	if not data.has("save_slot"):
		data["save_slot"] = slot
	if not data.has("timestamp") or str(data["timestamp"]).is_empty():
		data["timestamp"] = Time.get_datetime_string_from_system()
	if not data.has("version"):
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


## Comprueba si un diccionario contiene datos y metadatos de guardado válidos
static func validate_save_dict(data: Variant) -> bool:
	if not (data is Dictionary):
		return false
	var dict: Dictionary = data
	if dict.is_empty():
		return false
	# Debe contener al menos metadatos de guardado reconocibles
	var has_meta: bool = dict.has("save_slot") or dict.has("timestamp") or dict.has("version")
	var has_gameplay: bool = dict.has("level") or dict.has("character_class") or dict.has("current_hp")
	return has_meta or has_gameplay


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
	
	if text.strip_edges().is_empty():
		printerr("[SaveManager] Archivo de guardado vacío en slot %d" % slot)
		return {}
	
	var parsed = JSON.parse_string(text)
	if validate_save_dict(parsed):
		print("[SaveManager] Partida cargada exitosamente de slot %d" % slot)
		return parsed
	else:
		printerr("[SaveManager] JSON corrupto, inválido o vacío en slot %d" % slot)
		return {}


## Comprueba si el slot contiene un archivo existente y con contenido JSON válido
static func is_save_valid(slot: int) -> bool:
	var path := get_save_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	if text.strip_edges().is_empty():
		return false
	var parsed = JSON.parse_string(text)
	return validate_save_dict(parsed)


## Comprueba si un slot tiene un guardado utilizable y válido
static func has_save(slot: int) -> bool:
	return is_save_valid(slot)


## Comprueba únicamente la existencia del archivo físico (útil para diagnósticos)
static func has_save_file(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))


## Comprueba si existe al menos un guardado válido entre los slots disponibles
static func has_any_save() -> bool:
	for slot in [1, 2, 3]:
		if is_save_valid(slot):
			return true
	return false


## Obtiene la marca de tiempo comparable (segundos unix) a partir de los metadatos o fecha de archivo
static func _get_save_unix_time(data: Dictionary, path: String) -> int:
	if data.has("timestamp") and typeof(data["timestamp"]) == TYPE_STRING:
		var ts_str: String = data["timestamp"].strip_edges()
		if not ts_str.is_empty():
			var unix := Time.get_unix_time_from_datetime_string(ts_str)
			if unix > 0:
				return unix
	if FileAccess.file_exists(path):
		return int(FileAccess.get_modified_time(path))
	return 0


## Selecciona el slot (1, 2 o 3) con el guardado válido más reciente según sus metadatos
static func get_latest_save_slot() -> int:
	var latest_slot: int = 0
	var highest_unix: int = -1
	var latest_iso: String = ""
	
	for slot in [1, 2, 3]:
		if not is_save_valid(slot):
			continue
			
		var data := load_game(slot)
		var path := get_save_path(slot)
		var unix := _get_save_unix_time(data, path)
		var iso: String = str(data.get("timestamp", ""))
		
		if unix > highest_unix:
			highest_unix = unix
			latest_iso = iso
			latest_slot = slot
		elif unix == highest_unix and not iso.is_empty():
			# Desempate lexicográfico para timestamps ISO de igual segundo
			if iso > latest_iso:
				latest_iso = iso
				latest_slot = slot
				
	return latest_slot


## Elimina de forma segura el archivo de guardado de un slot
static func delete_save(slot: int) -> bool:
	var path := get_save_path(slot)
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		return err == OK
	return true


