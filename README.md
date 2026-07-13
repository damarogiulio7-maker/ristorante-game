# Ristorante Game

Gestionale/simulazione di ristorante per mobile, sviluppato con Godot 4.

## Concept
Il giocatore gestisce un ristorante: prepara piatti attraverso diverse
stazioni di lavoro (taglio, cottura, impiattamento...), gestisce ordini,
fornitori e la reputazione del locale. Ispirato a meccaniche di cucina reali.

## Struttura del progetto

```
ristorante-game/
├── project.godot          # file di configurazione principale del progetto
├── scenes/                # scene di gioco (.tscn)
│   ├── ui/                 # menu, HUD, schermate
│   ├── kitchen/             # scena principale della cucina e stazioni
│   └── player/              # eventuale personaggio/interazione giocatore
├── scripts/                # codice GDScript (.gd)
│   ├── ui/
│   ├── kitchen/              # logica delle stazioni di lavoro
│   ├── player/
│   └── data/                 # risorse dati (es. Recipe.gd)
├── assets/
│   ├── sprites/               # immagini, icone
│   ├── audio/                 # suoni ed effetti
│   └── fonts/
├── resources/
│   └── recipes/                # file .tres, una ricetta per file
└── addons/                    # eventuali plugin Godot
```

## Cosa c'è già
- Menu principale funzionante (`scenes/ui/main_menu.tscn`) con bottone "Inizia"
- Scena cucina base (`scenes/kitchen/kitchen_main.tscn`) con una prima
  stazione di lavoro (taglio)
- Script `WorkStation` (`scripts/kitchen/work_station.gd`): logica generica
  di una stazione che riceve un ingrediente, ci lavora per un tempo definito,
  e produce un risultato — riutilizzabile per cottura, impiattamento, ecc.
- Script `Recipe` (`scripts/data/recipe.gd`): risorsa dati per definire un
  piatto (ingredienti, tempo di preparazione, prezzo, difficoltà)

## Come aprire il progetto
1. Scarica e installa [Godot 4.3+](https://godotengine.org/download)
2. Apri Godot → "Import" → seleziona la cartella `ristorante-game`
   (o il file `project.godot` al suo interno)
3. Premi F5 (o il tasto Play) per avviare il gioco

## Prossimi passi possibili
- Collegare la stazione di taglio a un input reale (drag & drop o tap)
- Creare le prime ricette come risorse `.tres`
- Aggiungere un sistema di ordini/clienti
- Aggiungere sprite reali al posto dei placeholder
