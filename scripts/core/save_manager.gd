extends Node
class_name SaveManager

## Gestisce il salvataggio e il caricamento dello stato di gioco.
## Salva: soldi, reputazione, ordini completati, stato dei tavoli.

const SAVE_PATH = "user://ristorante_save.json"

var game_config: GameConfig
var game_manager: GameManager

class SaveData:
	var money: int = 0
	var reputation: int = 0
	var orders_completed: int = 0
	var timestamp: float = 0.0
	
	func to_dict() -> Dictionary:
		return {
			"money": money,
			"reputation": reputation,
			"orders_completed": orders_completed,
			"timestamp": timestamp,
		}
	
	static func from_dict(data: Dictionary) -> SaveData:
		var save_data = SaveData.new()
		save_data.money = data.get("money", 100)
		save_data.reputation = data.get("reputation", 50)
		save_data.orders_completed = data.get("orders_completed", 0)
		save_data.timestamp = data.get("timestamp", 0.0)
		return save_data

func _ready() -> void:
	var root = get_tree().root.get_child(0)
	
	if root.has_meta("config"):
		game_config = root.get_meta("config")
	else:
		game_config = GameConfig.new()
	
	game_manager = root.get_node_or_null("GameManager")

## Salva lo stato attuale del gioco
func save_game() -> bool:
	if not game_manager:
		push_error("SaveManager: GameManager non trovato!")
		return false
	
	var save_data = SaveData.new()
	save_data.money = game_manager.money
	save_data.reputation = game_manager.reputation
	save_data.orders_completed = game_manager.orders_completed
	save_data.timestamp = Time.get_ticks_msec() / 1000.0
	
	var json = JSON.stringify(save_data.to_dict())
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Impossibile aprire il file di salvataggio!")
		return false
	
	file.store_string(json)
	print("SaveManager: Gioco salvato a %s" % SAVE_PATH)
	return true

## Carica lo stato salvato del gioco
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: Nessun file di salvataggio trovato.")
		return false
	
	if not game_manager:
		push_error("SaveManager: GameManager non trovato!")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Impossibile aprire il file di salvataggio!")
		return false
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("SaveManager: Errore nel parsing del JSON!")
		return false
	
	var data = json.data as Dictionary
	var save_data = SaveData.from_dict(data)
	
	# Applica i dati caricati al game manager
	game_manager.money = save_data.money
	game_manager.reputation = save_data.reputation
	game_manager.orders_completed = save_data.orders_completed
	
	# Emetti i segnali per aggiornare l'UI
	game_manager.money_changed.emit(game_manager.money)
	game_manager.reputation_changed.emit(game_manager.reputation)
	
	print("SaveManager: Gioco caricato da %s" % SAVE_PATH)
	return true

## Cancella il file di salvataggio
func delete_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var error = DirAccess.remove_absolute(SAVE_PATH)
		if error == OK:
			print("SaveManager: File di salvataggio cancellato.")
			return true
		else:
			push_error("SaveManager: Errore nel cancellare il file di salvataggio!")
			return false
	return true

## Ritorna true se esiste un file di salvataggio
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Ritorna le informazioni sul salvataggio (se esiste)
func get_save_info() -> Dictionary:
	if not has_save():
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	json.parse(json_string)
	
	return json.data as Dictionary
