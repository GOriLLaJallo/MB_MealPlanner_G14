# Relazione Tecnica di Progettazione e Sviluppo: Meal Planner App

## 1. Descrizione dell'app

### Obiettivo dell'applicazione
L'obiettivo dell'applicazione è fornire agli utenti uno strumento completo e intuitivo per gestire la propria alimentazione quotidiana. L'app unisce in un unico ambiente la gestione delle ricette, il monitoraggio della dispensa, la pianificazione dei pasti settimanali e la generazione intelligente della lista della spesa.

### Tipologia di utenti a cui è rivolta
L'app è rivolta a chiunque desideri ottimizzare la gestione dei propri pasti:
- **Studenti o lavoratori fuorisede** che necessitano di organizzare la spesa e i pasti per evitare sprechi.
- **Famiglie** che devono pianificare pranzi e cene per più persone.
- **Appassionati di cucina o fitness** che vogliono tracciare ricette e abitudini alimentari.

### Problema che l'app intende risolvere
L'applicazione risolve il problema della disorganizzazione alimentare e degli sprechi di cibo. Molte persone comprano ingredienti che poi dimenticano in dispensa fino alla scadenza, oppure perdono tempo ogni giorno per decidere cosa cucinare. L'app centralizza queste informazioni, suggerendo cosa cucinare in base alle giacenze e calcolando automaticamente cosa manca da comprare.

### Principali scenari d'uso
1. **Ritorno dalla spesa:** L'utente usa la funzione "Trasferisci in Dispensa" dalla schermata Lista della Spesa per aggiornare automaticamente l'inventario.
2. **Pianificazione della Domenica:** L'utente apre il *Meal Plan*, seleziona i pasti per la settimana successiva e genera automaticamente la lista della spesa per gli ingredienti mancanti.
3. **Mancanza di idee (Cosa cucino oggi?):** L'utente consulta la Dashboard e riceve un suggerimento automatico su quale ricetta preparare sfruttando gli ingredienti già presenti in dispensa.

---

## 2. Requisiti

### Funzionalità implementate
- **Gestione Ricette (CRUD):** Inserimento, visualizzazione (con Hero animation), modifica ed eliminazione. Supporto a metadati come tempo di preparazione, porzioni, note e categoria.
- **Gestione Dispensa (CRUD):** Controllo scorte con quantità, unità di misura, date di scadenza, note aggiuntive e filtri di ricerca.
- **Pianificazione Pasti:** Assegnazione di ricette a giorni specifici e per specifiche categorie di pasto (Colazione, Pranzo, ecc.). Navigazione diretta dal pasto alla ricetta.
- **Lista della Spesa:** Compilazione manuale, smarcamento dei prodotti acquistati, generazione automatica e trasferimento degli acquisti in dispensa.
- **Statistiche e Abitudini:** Visualizzazione tramite grafici (a torta e a barre) delle abitudini alimentari, degli ingredienti più usati e del tempo medio di preparazione.

### Funzionalità considerate ma non implementate
- **Autenticazione Cloud:** Non implementata in quanto il vincolo tecnico richiedeva il salvataggio locale dei dati senza uso di backend.
- **Scansione Codici a Barre:** Per l'inserimento rapido dei prodotti in dispensa (richiederebbe librerie native di machine learning e un database API remoto).

### Feature avanzate scelte
L'app implementa ben **quattro** feature avanzate (il minimo richiesto era due):
1. **Generazione automatica della spesa:** Calcolo degli ingredienti mancanti per i pasti pianificati nei successivi 7 giorni, sottraendo le giacenze attuali in dispensa.
2. **Suggerimento intelligente ricette:** La Dashboard consiglia ricette basandosi sulla disponibilità degli ingredienti in dispensa, ottimizzando il consumo.
3. **Gestione intelligente delle scadenze:** Alert visivi e filtri dedicati per evidenziare i prodotti in scadenza (entro 3 giorni) o già scaduti.
4. **Gestione Consumi e Scalo Dispensa:** Scalo automatico degli ingredienti dalla dispensa quando un pasto viene consumato tramite l'apposito pulsante.

### Eventuali limitazioni note
Poiché i dati sono salvati tramite database locale SQLite (`sqflite`), disinstallare l'app o cancellare i dati comporta la perdita delle informazioni (non essendo sincronizzati su cloud). Le conversioni tra unità di misura (es. grammi e chilogrammi) durante la generazione della spesa avvengono con tolleranza basilare e potrebbero richiedere accorgimenti manuali per casi complessi (es. "1 pezzo" vs "100 grammi").

---

## 3. Progettazione dell'app

### Struttura generale dell'app
L'applicazione adotta una struttura a singolo modulo basata su una "Single Page Application" a livello di architettura di navigazione primaria, governata da una `BottomNavigationBar` che persiste durante l'uso principale.

### Schermate principali
- **Dashboard:** Centro di controllo con alert scadenze, suggeritore ricette e accesso rapido alle metriche principali.
- **Ricette (`recipes_screen`):** Griglia/Lista delle ricette con filtri per categoria, barra di ricerca testuale e slider per il tempo di preparazione.
- **Dispensa (`pantry_screen`):** Inventario con indicazioni cromatiche per le scadenze.
- **Pianificazione (`meal_plan_screen`):** Elenco dei pasti raggruppati cronologicamente per giorno.
- **Spesa (`shopping_list_screen`):** Lista interattiva suddivisa in "Da Acquistare" e "Acquistati".
- **Statistiche (`statistics_screen`):** Visualizzazione dei dati tramite libreria grafica.

### Flusso di navigazione
Il flusso principale avviene tramite la `BottomNavigationBar` (`MainScreen`). Le azioni di dettaglio o inserimento (es. `RecipeDetailScreen`, `RecipeFormScreen`) vengono gestite spingendo nuove route nello stack di navigazione (`Navigator.push`). I form minori (es. inserimento prodotto in dispensa) utilizzano `ModalBottomSheet` per mantenere il contesto visivo della pagina sottostante.

### Organizzazione dei dati
I dati sono modellati tramite semplici classi Dart (`Recipe`, `PantryItem`, `MealPlan`, `ShoppingItem`). Ognuna di queste classi implementa i metodi `toMap()` e `factory fromMap()` per serializzare e deserializzare agevolmente gli oggetti in formato JSON per la memorizzazione locale.

---

## 4. Scelte tecnologiche

### Framework utilizzato
**Flutter** (tramite il linguaggio Dart). Scelto per la sua capacità di generare UI fluide, reattive e native-like con un'unica base di codice, facilitando la creazione di interfacce complesse (come le animazioni Sliver o Hero).

### Librerie principali
- **`provider`:** Utilizzata per la gestione dello stato reattivo e per iniettare le dipendenze in tutto l'albero dei widget.
- **`sqflite`:** Utilizzata per il salvataggio persistente locale tramite database SQLite.
- **`fl_chart`:** Utilizzata per renderizzare grafici a torta e a barre di alta qualità nella schermata delle statistiche.
- **`intl`:** Indispensabile per la corretta formattazione delle stringhe di data (es. giorni della settimana e layout `dd/MM/yyyy`).

### Motivazione delle scelte effettuate
Il pattern `Provider` è stato scelto al posto di soluzioni più complesse (come BLoC o Riverpod) perché l'app ha un ambito dati ben definito (CRUD su 4 entità) e `Provider` offre un bilanciamento perfetto tra curva di apprendimento, verbosità e prestazioni, garantendo che i widget si ricostruiscano solo quando strettamente necessario.

### Modalità di gestione della persistenza
I dati vengono salvati nel filesystem locale tramite database relazionale SQLite (`sqflite`). La lettura avviene in modo asincrono all'avvio dell'app (`loadData`). Per facilitare i test e la dimostrazione delle feature, è stato implementato un sistema di inserimento di *mock data* che si attiva automaticamente qualora il database risulti vuoto.

---

## 5. Implementazione

### Organizzazione del codice
Il progetto segue una struttura standard e pulita:
- `/lib/models/`: Contiene le classi dei dati e la logica di serializzazione.
- `/lib/providers/`: Contiene `AppProvider`, il "cuore" logico dell'app.
- `/lib/screens/`: Contiene tutti i widget che rappresentano pagine intere o viste primarie.
- `/lib/utils/`: Contiene classi di supporto come `AppTheme` per la gestione dei colori.

### Componenti/widget principali
Si fa largo uso di componenti Material Design 3. In particolare:
- `Card` e `ListTile` per le liste.
- `SliverAppBar` associata a `Hero` per le transizioni immagine della pagina ricetta.
- `FilterChip` e `Slider` per la UI avanzata di ricerca e filtraggio.

### Gestione dello stato
Demandata a `ChangeNotifier` (`AppProvider`). Tutte le modifiche ai dati passano tramite metodi del provider (es. `addRecipe()`, `deletePantryItem()`). Al termine dell'operazione, il provider chiama `notifyListeners()`, scatenando il rebuild esclusivo dei widget `Consumer` che ascoltano quella particolare struttura, e avvia la routine di salvataggio in locale in background.

### Gestione della navigazione
Basata su `Navigator 1.0` (metodi `.push()` e `.pop()`) all'interno delle tab di una `BottomNavigationBar`. Questo approccio risulta sufficiente ed efficace per la ridotta profondità dell'albero di navigazione.

### Gestione dei dati persistenti
Affidata ad chiamate CRUD direttamente al database locale SQLite gestito in `DatabaseHelper`. Questo garantisce che la UI e il database locale siano sempre perfettamente sincronizzati.

### Parti particolarmente significative o complesse
La **generazione automatica della spesa** (`generateShoppingList` in `app_provider.dart`) ha richiesto una logica elaborata:
1. Filtra i pasti pianificati nel range di date scelto.
2. Trova la ricetta associata ad ogni pasto.
3. Somma tutti gli ingredienti richiesti raggruppandoli per nome.
4. Per ogni ingrediente necessario, verifica la giacenza in dispensa (`pantryItems`).
5. Sottrae la quantità disponibile; se il fabbisogno supera la giacenza, aggiunge la differenza alla Lista della Spesa.
Questa logica costituisce il ponte funzionale tra 3 domini (Pasti, Ricette e Dispensa), realizzando il reale valore aggiunto dell'app.
