# 🎮 GUIDA DI INTEGRAZIONE - Refactor Completo Ristorante Game

## ✅ Cosa è stato fatto

Abbiamo eseguito un **refactor completo** del progetto Godot ristorante-game con i seguenti miglioramenti:

### 1. **GameConfig Centralizzato** ✨
- Nuovo file: `scripts/core/game_config.gd`
- Centralizza tutti i valori di configurazione (prezzi, difficoltà, timeout, ecc.)
- Consente facile bilanciamento del gioco senza toccare il codice

### 2. **Sistema di Pazienza Clienti** ⏳
- **Prima**: Clienti aspettavano infinitamente
- **Dopo**: Se aspettano troppo, se ne vanno arrabbiati e penalizzano la reputazione
- `customer.gd` completamente rivisitato con timer di pazienza

### 3. **Penalità Reputazione Dinamica** 📉
- `game_manager.gd`: Ora penalizza quando clienti se ne vanno arrabbiati
- Reputazione varia tra 0-100 (prima era bloccata a 100)
- Difficoltà crescente con ordini completati

### 4. **Difficoltà Ricette Considerata** 🍳
- `work_station.gd`: Calcola tap richiesti basato su difficoltà ricetta (non più fisso)
- Timeout stazioni: Se nessuno clicca per 60s, l'ordine va perso
- Bonus prezzo dinamico basato su tempo di completamento

### 5. **Sistema di Affaticamento Staff** 😴
- `staff_member.gd`: Lo staff si affatica e ralenta
- Recupera energia quando idle
- Velocità ridotta al 50-80% quando affaticato

### 6. **Menu di Selezione Ricette** 🎯
- **Nuovo file**: `scripts/ui/recipe_selection_menu.gd`
- Il giocatore sceglie quale ricetta preparare (non random!)
- Mostra difficoltà e prezzo
- `waitress.gd` modificata per usare il menu

### 7. **Sistema di Salvataggio** 💾
- **Nuovo file**: `scripts/core/save_manager.gd`
- Salva: soldi, reputazione, ordini completati
- Autosave periodico (configurabile)
- Salva su file JSON in `user://ristorante_save.json`

### 8. **Codice Documentato e Pulito** 📚
- Ogni file ha commenti dettagliati
- Docstring per tutte le funzioni principali
- Code è più leggibile e manutenibile

---

## 🚀 Come integrarsi nella scena

### Passo 1: Verifica che i file siano creati
Assicurati che questi file esistano in `scripts/`:
```
scripts/
  ├── core/
  │   ├── game_config.gd ✅ NUOVO
  │   ├── game_manager.gd ✅ MODIFICATO
  │   └── save_manager.gd ✅ NUOVO
  ├── customer/
  │   ├── customer.gd ✅ MODIFICATO
  │   └── customer_manager.gd ✅ MODIFICATO
  ├── kitchen/
  │   ├── work_station.gd ✅ MODIFICATO
  │   ├── table_spot.gd ✅ MODIFICATO
  │   └── kitchen_room.gd ⚠️ DA AGGIORNARE
  ├── staff/
  │   ├── waitress.gd ✅ MODIFICATO
  │   └── staff_member.gd ✅ MODIFICATO
  └── ui/
      └── recipe_selection_menu.gd ✅ NUOVO
```

### Passo 2: Aggiorna la scena kitchen_room.tscn

Nella scena `scenes/kitchen/kitchen_room.tscn`:

1. **Aggiungi il SaveManager al nodo GameManager** (opzionale, già fatto in codice ma verificare):
   - Il SaveManager viene creato automaticamente in `game_manager._ready()`

2. **Aggiungi il RecipeSelectionMenu alla HUD**:
   - Crea un nuovo nodo `Control` sotto `HUD`
   - Nomina: `RecipeSelectionMenu`
   - Assegna lo script `recipe_selection_menu.gd`
   - Aggiungi sotto una `VBoxContainer`:
     - `TitleLabel` (Label)
     - `RecipesContainer` (VBoxContainer)
     - `CancelButton` (Button)
   - Imposta anchors a "Center" per centrare il menu
   - Imposta size appropriato (es. 400x300)

3. **Assicurati che customer_manager sia correttamente inizializzato** in `kitchen_room.gd`:
   ```gdscript
   var customer_manager: CustomerManager = $CustomerManager
   customer_manager.tables = tables
   customer_manager.door_position = $Environment/EntranceDoor.global_position + Vector2(55, 200)
   customer_manager.customer_scene = load("res://scenes/staff/customer.tscn")
   customer_manager.customers_container = $Customers
   ```

### Passo 3: Connessioni segnali (importante!)

In `kitchen_room.gd`, aggiungi queste connessioni dopo la creazione del customer_manager:

```gdscript
# Connetti gli eventi dei clienti arrabbiati
for table in tables:
    if table.current_customer:
        table.current_customer.customer_left_angry.connect(game_manager.customer_left_angry)
```

### Passo 4: Inizializza la Waitress correttamente

In `kitchen_room.gd`, verificati che la waitress sia inizializzata con il menu:

```gdscript
var waitress: Waitress = $Staff/Cameriera
waitress.tables = tables
waitress.recipes = recipe_list
waitress.game_manager = game_manager
waitress.kitchen_pickup_position = $Environment/Counter.global_position
waitress.recipe_menu = $HUD/RecipeSelectionMenu
waitress._ready()
```

---

## 📊 Configurazione consigliata

Modifica `game_config.gd` per bilanciare il gioco:

```gdscript
# ECONOMIA
starting_money: 100  # Soldi iniziali
base_order_value: 10  # Prezzo base

# REPUTAZIONE
starting_reputation: 50  # Reputazione iniziale
reputation_increase_per_order: 1  # +1 per ordine completato
reputation_decrease_per_timeout: 3  # -3 se cliente se ne va arrabbiato
reputation_bonus_if_quick: 1  # Bonus se veloce

# CLIENTI
customer_base_patience: 15.0  # Secondi prima di stancarsi
customer_spawn_interval: 3.0  # Secondi tra arrivi clienti

# STAZIONI
work_station_base_taps_multiplier: 2.0  # Tap per secondo
work_station_timeout_seconds: 60.0  # Timeout se nessuno clicca
```

---

## 🧪 Testing checklist

- [ ] Apri il ristorante e osserva i clienti
- [ ] I clienti iniziano impazienti dopo 10 secondi
- [ ] Se non serves il cibo in tempo, il cliente se ne va (reputazione cala)
- [ ] La cameriera mostra il menu di selezione ricette
- [ ] Scegli una ricetta dal menu
- [ ] Il numero di tap richiesti varia con la difficoltà
- [ ] Completa ordini e raccogli soldi
- [ ] Dopo 10 ordini, osserva se la difficoltà aumenta
- [ ] Il gioco salva i progressi automaticamente
- [ ] Lo staff si ralenta dopo molti ordini (affaticamento)

---

## 🔧 Troubleshooting

**"RecipeSelectionMenu non trovato"**
- Assicurati che il nodo esista nella scena
- Nel codice cercherà in `$HUD/RecipeSelectionMenu`
- Se non esiste, la cameriera sceglierà casualmente (fallback)

**"GameConfig non trovato"**
- Il config viene creato automaticamente in `game_manager._ready()`
- Se hai valori di default nel GameConfig, verranno usati

**"Customer non ha il metodo `set_recipe_and_patience`"**
- Verificati che tu stia usando il customer.gd aggiornato
- Il metodo viene usato dalla waitress dopo la selezione ricetta

**"Le connessioni dei segnali non funzionano"**
- Verificati che GameManager sia presente nella scena
- Verifica le connessioni in `kitchen_room.gd._ready()`

---

## 📝 Note importanti

1. **GameConfig è il cuore dei bilanciamenti**: Modifica lì per tutte le meccaniche
2. **SaveManager è opzionale ma consigliato**: Aggiunge persistenza
3. **RecipeSelectionMenu migliora gameplay**: Permet al giocatore di controllare gli ordini
4. **Affaticamento staff rende il gioco più sfidante**: Aggiungi difficoltà crescente
5. **Pazienza clienti aggiunge urgenza**: Senso di tempo pressato

---

## 🎯 Possibili estensioni future

- [ ] Menu pausa con salva/carica
- [ ] Animazioni di impazienz del cliente (piedi che tamburellano)
- [ ] Suoni di feedback per azioni
- [ ] Leaderboard con i migliori punteggi
- [ ] Livelli di difficoltà predefiniti (Easy/Normal/Hard)
- [ ] Sistema di upgrades per lo staff
- [ ] Ricette dinamiche basate su ingredienti

---

**Refactor completato! Buon gioco! 🎉**
