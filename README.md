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
- Scena cucina (`scenes/kitchen/kitchen_room.tscn`), vista laterale 2D.
  Sala di 16 metri (convenzione: 1 metro reale = 100 pixel di gioco):
  cucina sul lato sinistro (0-5m, pavimento più chiaro), bancone di
  separazione, sala con tavoli in legno sulla destra, muro di fondo con
  2 finestre e una porta d'ingresso sul lato destro
- Script `EnvPiece` (`scripts/kitchen/env_piece.gd`): elemento statico
  placeholder dell'ambiente (muro, tavolo, finestra, porta...) — un
  rettangolo colorato per ora, pronto per essere sostituito da sprite reali
- Script `WorkStation` (`scripts/kitchen/work_station.gd`): logica generica
  di una stazione che riceve un ingrediente, ci lavora per un tempo definito,
  e produce un risultato — riutilizzabile per cottura, impiattamento, ecc.
- Script `StaffMember` (`scripts/staff/staff_member.gd`): membro dello staff
  autonomo, con stati Idle → si muove verso una stazione → lavora → torna
  libero. Il giocatore non lo controlla direttamente, lo assume e supervisiona
- Script `GameManager` (`scripts/core/game_manager.gd`): cuore della
  simulazione. Genera ordini a intervalli regolari, li assegna al primo staff
  libero e alla prima stazione libera, calcola guadagni e reputazione
- Script `Recipe` (`scripts/data/recipe.gd`): risorsa dati per definire un
  piatto (ingredienti, tempo di preparazione, prezzo, difficoltà). Due
  ricette di esempio già pronte in `resources/recipes/`
- HUD base che mostra soldi, reputazione e ultimo ordine completato

## Come aprire il progetto
1. Scarica e installa [Godot 4.3+](https://godotengine.org/download)
2. Apri Godot → "Import" → seleziona la cartella `ristorante-game`
   (o il file `project.godot` al suo interno)
3. Premi F5 (o il tasto Play) per avviare il gioco

## Prossimi passi possibili
- Sostituire i placeholder (rettangoli colorati) con sprite/grafica vera
- Sistema di assunzione staff (interfaccia per assumere/licenziare, costi)
- Coda visibile degli ordini in attesa
- Più stazioni e ricette più complesse (più passaggi)
- Eventi/clienti con pazienza limitata che influenzano la reputazione

## Convenzione misure
1 metro reale = 100 pixel di gioco. Per aggiungere o ridimensionare
elementi dell'ambiente, basta indicare la misura reale in metri (es.
"tavolo 80cm x 80cm" → 80x80 px) e verrà convertita di conseguenza.
