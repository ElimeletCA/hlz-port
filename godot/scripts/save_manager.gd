extends Node

# save_manager.gd — Gestor de guardado y carga para Heroes Lore: Zero Port (T5.8)
# Soporta los 3 slots de guardado originales y formato JSON estructurado con validación semántica.

enum SaveStatus {
	FILE_MISSING = 0,
	FILE_EMPTY = 1,
	JSON_SYNTAX_ERROR = 2,
	SEMANTICALLY_INVALID = 3,
	VALID = 4
}

const DEFAULT_SAVE_DIR: String = "user://saves/"
const TEST_SAVE_DIR: String = "user://test_saves/"
const SCHEMA_VERSION_PREFIX: String = "1."
const CANONICAL_SCHEMA_VERSION: String = "1.0.0-fase5"

const VALID_CLASSES: Array[String] = [
	"Asesino", "Guerrero", "Caballero", "Pistolero", "Elemental", "Gunblader"
]

static var _current_save_dir: String = DEFAULT_SAVE_DIR


## Configura un directorio de almacenamiento personalizado (ej. para aislar tests)
static func set_save_dir(dir_path: String) -> void:
	_current_save_dir = dir_path
	_ensure_dir_exists()


## Restablece el directorio de guardado al directorio estándar de producción (user://saves/)
static func reset_save_dir() -> void:
	_current_save_dir = DEFAULT_SAVE_DIR


## Obtiene el directorio de guardado activo actualmente
static func get_save_dir() -> String:
	return _current_save_dir


static func _ensure_dir_exists() -> void:
	if not DirAccess.dir_exists_absolute(_current_save_dir):
		DirAccess.make_dir_recursive_absolute(_current_save_dir)


static func get_save_path(slot: int) -> String:
	return "%ssave_slot_%d.json" % [_current_save_dir, slot]


## Guarda los datos en el slot especificado cumpliendo con el esquema semántico
static func save_game(slot: int, data: Dictionary) -> bool:
	_ensure_dir_exists()
	var path := get_save_path(slot)
	
	# Asegurar metadatos obligatorios si no vienen predefinidos
	if not data.has("save_slot"):
		data["save_slot"] = slot
	if not data.has("timestamp") or str(data["timestamp"]).is_empty():
		data["timestamp"] = Time.get_datetime_string_from_system()
	if not data.has("version"):
		data["version"] = CANONICAL_SCHEMA_VERSION
		
	# Completar valores de estado jugable por defecto si se omitieron
	if not data.has("character_class"):
		data["character_class"] = "Asesino"
	if not data.has("level"):
		data["level"] = 1
	if not data.has("current_hp"):
		data["current_hp"] = 100
	if not data.has("max_hp"):
		data["max_hp"] = int(data["current_hp"])
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("[SaveManager] Error al abrir para guardar: ", path)
		return false
		
	var json_str := JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()
	print("[SaveManager] Partida guardada con éxito en slot %d: %s" % [slot, path])
	return true


## Comprueba si un diccionario cumple rigurosamente con el esquema semántico del proyecto
static func validate_save_dict(data: Variant) -> bool:
	if not (data is Dictionary):
		return false
	var dict: Dictionary = data
	if dict.is_empty():
		return false
		
	# --- 1. Verificación de Metadatos Obligatorios ---
	if not dict.has("save_slot") or not (dict["save_slot"] is int or dict["save_slot"] is float):
		return false
	var slot_num: int = int(dict["save_slot"])
	if slot_num < 1 or slot_num > 3:
		return false
		
	if not dict.has("version") or not (dict["version"] is String):
		return false
	var ver: String = dict["version"].strip_edges()
	if ver.is_empty() or not ver.begins_with(SCHEMA_VERSION_PREFIX):
		return false
		
	if not dict.has("timestamp") or not (dict["timestamp"] is String):
		return false
	var ts: String = dict["timestamp"].strip_edges()
	if ts.length() < 10: # Longitud mínima para YYYY-MM-DD
		return false
		
	# --- 2. Verificación de Estado Jugable Mínimo ---
	if not dict.has("character_class") or not (dict["character_class"] is String):
		return false
	var ch_class: String = dict["character_class"].strip_edges()
	if not VALID_CLASSES.has(ch_class):
		return false
		
	if not dict.has("level") or not (dict["level"] is int or dict["level"] is float):
		return false
	var level: int = int(dict["level"])
	if level < 1 or level > 99:
		return false
		
	if not dict.has("current_hp") or not (dict["current_hp"] is int or dict["current_hp"] is float):
		return false
	var current_hp: int = int(dict["current_hp"])
	if current_hp < 1:
		return false
		
	# --- 3. Verificaciones de consistencia de rangos ---
	if dict.has("max_hp"):
		if not (dict["max_hp"] is int or dict["max_hp"] is float):
			return false
		var max_hp: int = int(dict["max_hp"])
		if max_hp < current_hp:
			return false
			
	if dict.has("current_exp"):
		if not (dict["current_exp"] is int or dict["current_exp"] is float):
			return false
		if int(dict["current_exp"]) < 0:
			return false
			
	return true


## Evalúa detalladamente el estado del archivo de guardado en el slot indicado
static func evaluate_save_status(slot: int) -> SaveStatus:
	var path := get_save_path(slot)
	if not FileAccess.file_exists(path):
		return SaveStatus.FILE_MISSING
		
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return SaveStatus.FILE_MISSING
		
	var text := file.get_as_text()
	file.close()
	
	if text.strip_edges().is_empty():
		return SaveStatus.FILE_EMPTY
		
	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		return SaveStatus.JSON_SYNTAX_ERROR
		
	if not validate_save_dict(json.data):
		return SaveStatus.SEMANTICALLY_INVALID
		
	return SaveStatus.VALID


static func load_game(slot: int) -> Dictionary:
	var status := evaluate_save_status(slot)
	match status:
		SaveStatus.FILE_MISSING:
			print("[SaveManager] No existe archivo de guardado en slot %d" % slot)
			return {}
		SaveStatus.FILE_EMPTY:
			printerr("[SaveManager] Archivo de guardado vacío en slot %d" % slot)
			return {}
		SaveStatus.JSON_SYNTAX_ERROR:
			printerr("[SaveManager] Error sintáctico de JSON en slot %d" % slot)
			return {}
		SaveStatus.SEMANTICALLY_INVALID:
			printerr("[SaveManager] Guardado semánticamente inválido en slot %d" % slot)
			return {}
		SaveStatus.VALID:
			var path := get_save_path(slot)
			var file := FileAccess.open(path, FileAccess.READ)
			if file:
				var text := file.get_as_text()
				file.close()
				var parsed = JSON.parse_string(text)
				if parsed is Dictionary:
					print("[SaveManager] Partida cargada exitosamente de slot %d" % slot)
					return parsed
	return {}


## Comprueba si el slot contiene un archivo de guardado semánticamente válido
static func is_save_valid(slot: int) -> bool:
	return evaluate_save_status(slot) == SaveStatus.VALID


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


## Elimina de forma segura el archivo de guardado de un slot en el directorio activo
static func delete_save(slot: int) -> bool:
	var path := get_save_path(slot)
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		return err == OK
	return true


## Limpia de forma segura únicamente los archivos creados en el directorio de pruebas
static func clean_test_saves_dir() -> void:
	if _current_save_dir != TEST_SAVE_DIR:
		printerr("[SaveManager] clean_test_saves_dir() fue invocado fuera del directorio de pruebas.")
		return
	if DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		var dir := DirAccess.open(TEST_SAVE_DIR)
		if dir:
			dir.list_dir_begin()
			var file_name := dir.get_next()
			while not file_name.is_empty():
				if not dir.current_is_dir():
					DirAccess.remove_absolute("%s%s" % [TEST_SAVE_DIR, file_name])
				file_name = dir.get_next()
			dir.list_dir_end()
