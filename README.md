# Ristorante Game

Gioco di cucina in stile bancone ravvicinato (tipo Cooking Fever/Cooking Mart),
ispirato al mondo della ristorazione reale.

## Concept
Un cliente alla volta mostra un ordine tramite un fumetto in alto (es.
"Pasta al pomodoro vuole: pasta → pomodoro → basilico"). Il giocatore clicca
le vaschette di ingredienti sul bancone, nell'ordine giusto, per comporre il
piatto. Quando è completo, il cliente paga (soldi + reputazione) e ne arriva
uno nuovo.

## Struttura del progetto

```
ristorante-game/
├── project.godot
├── scenes/
│   ├── ui/main_menu.tscn        # menu principale
│   └── counter/counter_room.tscn # IL GIOCO: bancone con vaschette
├── scripts/
│   ├── ui/main_menu.gd
│   └── counter/
│       ├── counter_game.gd       # logica: ordini, piatto, soldi, reputazione
│       └── ingredient_tray.gd    # vaschetta cliccabile
├── resources/recipes/            # ricette (.tres): nome, ingredienti in ordine, prezzo
└── (cartelle scenes/scripts/kitchen, staff, customer: VECCHIO prototipo
     a stanza laterale, non più usato ma lasciato nel progetto)
```

## Come aprire il progetto
1. Installa [Godot 4.3+](https://godotengine.org/download)
2. Import → seleziona `project.godot`
3. F5 per avviare, clic su "Inizia" nel menu

## Aggiungere una ricetta
Crea un nuovo file `.tres` in `resources/recipes/` con script `Recipe`:
nome, lista ingredienti (nell'ordine in cui vanno cliccati), tempo, prezzo.
Poi aggiungilo alla lista in `counter_game.gd` (`_ready()`).

## Aggiungere un ingrediente/vaschetta
In `counter_game.gd`, aggiungi il colore in `INGREDIENT_COLORS`.
Nella scena `counter_room.tscn`, duplica un nodo Tray e cambia
`ingredient_name` e colore dell'icona.

## Prossimi passi possibili
- Più clienti in coda (non uno alla volta)
- Timer per cliente (pazienza) per dare più tensione
- Animazioni di feedback (piatto che "salta" quando è pronto)
- Più ricette e ingredienti diversi
- Sblocco di nuovi piatti/bancone con i guadagni
