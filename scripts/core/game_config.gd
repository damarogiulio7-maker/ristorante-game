extends Node
class_name GameConfig

## File centralizzato di configurazione del gioco.
## Tutti i valori importanti sono qui per facile modifica e bilanciamento.

# ==================== ECONOMIA ====================
var starting_money: int = 100
var base_order_value: int = 10  # Prezzo base se ricetta non è configurata

# ==================== REPUTAZIONE ====================
var starting_reputation: int = 50
var reputation_increase_per_order: int = 1
var reputation_decrease_per_timeout: int = 3  # Penalità se cliente se ne va arrabbiato
var reputation_bonus_if_quick: int = 1  # Bonus se completato prima della pazienza
var max_reputation: int = 100
var min_reputation: int = 0

# ==================== CLIENTI ====================
var customer_spawn_interval: float = 3.0  # Secondi tra spawn clienti
var customer_move_speed: float = 140.0
var customer_base_patience: float = 15.0  # Secondi prima di stancarsi
var customer_patience_multiplier_easy: float = 2.0  # Moltiplicatore per ricette facili
var customer_patience_multiplier_hard: float = 0.8  # Moltiplicatore per ricette difficili
var customer_eating_time: float = 4.0
var customer_max_in_queue: int = 10  # Max clienti in attesa
var impatience_threshold: float = 0.7  # A che % di pazienza diventa "impatiente"

# ==================== STAZIONI DI LAVORO ====================
var work_station_base_taps_multiplier: float = 2.0  # Tap richiesti per secondo di ricetta
var work_station_difficulty_multiplier: float = 1.5  # Come la difficoltà moltiplicare i tap
var work_station_timeout_seconds: float = 60.0  # Timeout se nessuno clicca

# ==================== STAFF ====================
var staff_base_speed: float = 1.0
var staff_speed_per_skill_level: float = 0.15  # Velocità extra per skill level
var staff_fatigue_recovery_per_rest: float = 0.5
var staff_fatigue_factor: float = 0.8  # Fattore moltiplicatore quando affaticato

# ==================== PREZZO DINAMICO ====================
var price_difficulty_multiplier: float = 0.5  # Quanto aggiunge il prezzo per difficoltà
var price_time_bonus_threshold: float = 0.5  # Se completato prima di questo % della pazienza = bonus
var price_time_bonus_amount: int = 5

# ==================== DIFFICOLTÀ ====================
var difficulty_scaling_enabled: bool = true
var difficulty_increase_every_n_orders: int = 10
var difficulty_reputation_factor: float = 0.01  # Come la reputazione influenza difficoltà

# ==================== SALVATAGGIO ====================
var autosave_enabled: bool = true
var autosave_interval: float = 30.0  # Secondi tra autosave

# Funzione per ottenere il tempo di pazienza per una ricetta
func get_customer_patience_for_recipe(recipe: Recipe) -> float:
	var base_patience = customer_base_patience
	if recipe.difficulty <= 2:
		base_patience *= customer_patience_multiplier_easy
	elif recipe.difficulty >= 4:
		base_patience *= customer_patience_multiplier_hard
	return base_patience

# Funzione per calcolare il prezzo dinamico
func calculate_order_price(recipe: Recipe, time_spent: float, max_time: float) -> int:
	var base_price = recipe.sale_price
	
	# Bonus difficoltà
	var difficulty_bonus = (recipe.difficulty - 1) * int(recipe.sale_price * price_difficulty_multiplier)
	
	# Bonus se veloce
	var time_bonus = 0
	if time_spent < (max_time * price_time_bonus_threshold):
		time_bonus = price_time_bonus_amount
	
	return max(base_price, base_price + difficulty_bonus + time_bonus)

# Funzione per ottenere i tap richiesti per una stazione
func get_taps_required(recipe: Recipe, duration: float) -> int:
	var base_taps = int(round(duration * work_station_base_taps_multiplier))
	var difficulty_modifier = 1.0 + ((recipe.difficulty - 1) * work_station_difficulty_multiplier)
	return max(3, int(round(base_taps * difficulty_modifier)))

# Funzione per verificare se incrementare la difficoltà
func should_increase_difficulty(orders_completed: int) -> bool:
	if not difficulty_scaling_enabled:
		return false
	return orders_completed > 0 and orders_completed % difficulty_increase_every_n_orders == 0
