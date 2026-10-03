# Capitolo 1 - Dall'app Spring all'immagine Docker Single-Stage

## 1.1 Spring Initializr

Spring Initializr è uno strumento che permette di generare la configurazione iniziale di un progetto Spring Boot.

Questo è utile perché evita di dover configurare manualmente tutto ciò che serve prima ancora di scrivere la logica dell'applicazione.

Spring Initializr genera automaticamente la struttura iniziale del progetto, tra cui:

1. Il `pom.xml`, contenente le dipendenze e la configurazione Maven.
2. La classe principale con il metodo `main`.
3. I file di configurazione (`application.properties` o `application.yml`).
4. Il Maven Wrapper (`mvnw`, `mvnw.cmd` e `.mvn`).

In questo modo si ottiene una base di progetto già organizzata e configurata.

Attualmente il progetto è molto semplice: ci si è limitati a includere la dipendenza **Spring Web**, che permette di sviluppare applicazioni web e API REST, fornendo gli strumenti necessari per gestire richieste HTTP.

La dipendenza `spring-boot-starter-web` include Spring MVC, che mette a disposizione annotazioni come `@RestController`, `@RequestMapping` e `@GetMapping`.

> [!NOTE]
> Se si osserva il `pom.xml`, è presente la dipendenza `spring-boot-starter-web`, cioè lo starter che raggruppa le dipendenze necessarie per sviluppare applicazioni web con Spring Boot.

---

## 1.2 Struttura del progetto

Il progetto segue un'architettura a livelli (*layered architecture*).

Lo scopo è separare le diverse responsabilità dell'applicazione: ogni livello si occupa di un compito specifico. Questo rende il codice più leggibile, più facile da modificare, manutenibile e più semplice da testare.

Nel nostro caso la struttura è sostanzialmente:

```text
com.example.devops_lab
│
├── controller
│   ├── HealthController.java
│   └── HelloController.java
│
├── service
│   └── HelloService.java
│
└── DevopsLabApplication.java
```

Nel progetto sono presenti due livelli principali:

1. **Controller**
2. **Service**

Il livello **Controller** si occupa della comunicazione HTTP con il client e riceve le richieste indirizzate agli endpoint dell'applicazione.

Il livello **Service** contiene invece la logica applicativa e viene richiamato dai controller quando è necessario elaborare una richiesta.

### Esempio di Controller

```java
@RestController
@RequestMapping("/rest/api/hello")
public class HelloController {

    private final HelloService helloService;

    public HelloController(HelloService helloService) {
        this.helloService = helloService;
    }

    @GetMapping
    public String getHello() {
        return helloService.getHello();
    }
}
```

In questo esempio sono presenti tre annotazioni principali:

- `@RestController`  
  Indica a Spring che la classe è un **controller REST**, cioè un componente in grado di ricevere richieste HTTP e restituire direttamente una risposta al client.

- `@RequestMapping("/rest/api/hello")`  
  Definisce il percorso base degli endpoint contenuti nel controller.

- `@GetMapping`  
  Indica che il metodo associato deve essere eseguito quando arriva una richiesta HTTP di tipo `GET`.

In questo caso, una richiesta:

```text
GET /rest/api/hello
```

viene intercettata dal metodo `getHello()`.

Il metodo associato alla richiesta `GET` non contiene direttamente la logica applicativa, ma delega l'elaborazione a `HelloService`:

```java
return helloService.getHello();
```

Qui è visibile la separazione tra i due livelli: il **Controller** riceve e gestisce la richiesta HTTP, mentre il **Service** esegue la logica applicativa.

Il flusso può essere rappresentato in questo modo:

```text
Client
   |
   | GET /rest/api/hello
   v
HelloController
   |
   | helloService.getHello()
   v
HelloService
   |
   | return "hello"
   v
HelloController
   |
   | risposta HTTP
   v
Client
```

> [!NOTE]
> Nella progettazione di API REST è buona pratica utilizzare il **path per identificare la risorsa** e il **metodo HTTP per indicare l'operazione** da eseguire.
>
> Per esempio, si preferisce:
>
> `GET /api/users`
>
> rispetto a:
>
> `GET /api/getUsers`
>
> Questa convenzione deriva dai principi REST e rende gli endpoint più uniformi, leggibili e prevedibili.
>
> Non si tratta di un obbligo imposto da Spring: i singoli metodi possono avere path aggiuntivi quando serve identificare una risorsa specifica, ad esempio `GET /api/users/{id}`.

### Perché non è presente un Repository

Nelle applicazioni Spring è comune adottare una struttura a tre livelli logici:

```text
Controller
    ↓
Service
    ↓
Repository
    ↓
Database
```

Nel progetto corrente non è presente il livello `Repository` perché l'applicazione non utilizza un database e non necessita di persistenza dei dati.

Il `Repository`, quando presente, rappresenta il livello incaricato dell'accesso ai dati, ad esempio per eseguire operazioni di lettura, inserimento, modifica ed eliminazione.

Per questo motivo, nel progetto attuale è sufficiente una struttura composta da **Controller** e **Service**: aggiungere un livello `Repository` senza avere una sorgente dati non avrebbe una responsabilità concreta.

> [!NOTE]
> È preferibile parlare di **layer** o livelli logici dell'applicazione, piuttosto che di *tier*. Il termine *tier* viene spesso utilizzato per indicare livelli fisicamente separati, ad esempio client, application server e database.

---

## 1.3 Build dell'applicazione con Maven

Una volta definita la struttura dell'applicazione, il passo successivo consiste nel trasformare il codice sorgente in un artefatto eseguibile.

Nel progetto viene utilizzato **Maven** come strumento di build. Maven si occupa di gestire le dipendenze, compilare il codice, eseguire i test e creare il pacchetto finale dell'applicazione.

Grazie al **Maven Wrapper** è possibile eseguire Maven senza richiederne un'installazione manuale sul sistema. È quindi possibile utilizzare:

```bash
./mvnw clean package
```

Se Maven è già installato e disponibile nel sistema, è possibile utilizzare direttamente:

```bash
mvn clean package
```

Il comando è composto da due fasi principali:

- `clean`: elimina gli artefatti generati da build precedenti, in particolare la directory `target/`;
- `package`: compila il progetto, esegue i test e genera il pacchetto finale dell'applicazione.

Il flusso può essere rappresentato in questo modo:

```text
Codice sorgente
      ↓
     Maven
      ↓
 Compilazione
      ↓
     Test
      ↓
  Packaging
      ↓
     JAR
```

Al termine della build viene creata la directory `target/`, all'interno della quale viene generato il file `.jar` dell'applicazione.

Ad esempio:

```text
target/
└── devops-lab-0.0.1-SNAPSHOT.jar
```

Il file **JAR** (*Java ARchive*) rappresenta l'artefatto prodotto dalla build.

Nel caso di Spring Boot viene generato un **JAR eseguibile**, che permette di avviare direttamente l'applicazione tramite Java:

```bash
java -jar target/devops-lab-0.0.1-SNAPSHOT.jar
```

In questo modo l'applicazione può essere eseguita senza utilizzare l'IDE.

> [!NOTE]
> Il nome del file JAR dipende principalmente dai valori `artifactId` e `version` definiti nel `pom.xml`.
> Questi valori possono essere specificati inizialmente durante la creazione del progetto con Spring Initializr e modificati successivamente nel `pom.xml`.


# Capitolo 2 - Dockerfile

## 2.1 Cos'è un Dockerfile

Dopo aver generato il file JAR dell'applicazione, il passo successivo consiste nel definire come questa applicazione dovrà essere eseguita all'interno di Docker.

Per farlo viene utilizzato un file chiamato `Dockerfile`.

Il `Dockerfile` è un file di testo contenente una serie di istruzioni che Docker utilizza per costruire un'immagine.

In altre parole, descrive l'ambiente necessario per eseguire l'applicazione e specifica:

- da quale immagine di base partire;
- quali file copiare all'interno dell'immagine;
- quale directory utilizzare;
- quali informazioni esporre, come la porta dell'applicazione;
- quale comando eseguire all'avvio del container.

Il flusso può essere rappresentato in questo modo:

```text
Applicazione Spring Boot
        ↓
       JAR
        ↓
   Dockerfile
        ↓
 Docker Image
        ↓
   Container
```

Il Dockerfile non è quindi l'immagine Docker, ma rappresenta le istruzioni utilizzate per costruirla.

---
### Costruzione del Dockerfile del progetto

Nel progetto è stato utilizzato il seguente Dockerfile:

```dockerfile
FROM eclipse-temurin:21
WORKDIR /opt/app/
COPY target/devops-lab-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
CMD ["java", "-jar", "./devops-lab-0.0.1-SNAPSHOT.jar"]
```
#### 1. FROM
Indica l'immagine di base dalla quale costruire la nuova immagine Docker. Nel nostro caso `Eclipse-temurin:21`.

`Eclipse-temurin` è una distribuzione di OpenJDK e mette a disposizione Java 21 all'interno dell'immagine.

Questo è necessario perché il file JAR ha bisogno di una Java Virtual Machine per poter essere eseguito

> [!NOTE]
La versione di Java disponibile nell'immagine Docker deve essere
compatibile con la versione utilizzata per compilare l'applicazione.

#### 2. WORKDIR
WORKDIR definisce la directory di lavoro utilizzata dalle istruzioni
successive del Dockerfile.
In questo caso viene utilizzata `/opt/app`.

Da questo momento in poi i percorsi relativi utilizzati nelle istruzioni successive faranno riferimento a questa directory

> [💡 **tip!**]  Concettualmente è come eseguire una `cd /opt/app`

#### 3. COPY 
L'istruzione:

```dockerfile
COPY target/devops-lab-0.0.1-SNAPSHOT.jar .
```
copia il file JAR prodotto precedentemente da Maven all'interno dell'immagine Docker.

* **File di partenza:** 
    `target/devops-lab-0.0.1-SNAPSHOT.jar`
        
* **Origine della directory:** 
    La directory `target/` è quella generata dal comando:
    ```bash
    mvn clean package
    ```
    oppure:
    ```bash
    ./mvnw clean package
     ```

* **Destinazione (`.`):** 
    Il punto `.` presente alla fine dell'istruzione `COPY` indica la directory di lavoro corrente.

* **Risultato finale:** 
    Poiché precedentemente è stato definito:
    `WORKDIR /opt/app/` il comando equivale, concettualmente, a copiare il JAR nella destinazione finale:`/opt/app/devops-lab-0.0.1-SNAPSHOT.jar`

#### 4. EXPOSE
L'istruzione:

```dockerfile
EXPOSE 8080
```

indica che l'applicazione eseguita all'interno del container utilizza la porta **8080**.
Spring Boot, se non configurato diversamente, utilizza la porta 8080 come porta predefinita del server HTTP.

È importante però distinguere tra porta esposta e porta pubblicata.
EXPOSE non rende automaticamente la porta del container raggiungibile dal computer host.
L'istruzione ha principalmente lo scopo di documentare che l'applicazione è in ascolto sulla porta 8080 all'interno del container.
Per rendere la porta accessibile dall'esterno è necessario effettuare un `port binding`, o pubblicazione della porta, quando viene avviato il container.

*esempio*: `docker run -p 8080:8080 nome-immagine` la porta 8080 dell'host viene associata alla porta 8080 del container.

#### 5. CMD 
L'ultima istruzione del Dockerfile è:

```dockerfile
CMD ["java", "-jar", "./devops-lab-0.0.1-SNAPSHOT.jar"]
```

`CMD` definisce il comando predefinito che Docker esegue quando viene avviato un container a partire dall'immagine.

Il comando eseguito è equivalente a:

```bash
java -jar ./devops-lab-0.0.1-SNAPSHOT.jar
```

Poiché la directory di lavoro è:

```text
/opt/app/
```

il file:

```text
./devops-lab-0.0.1-SNAPSHOT.jar
```

corrisponde effettivamente a:

```text
/opt/app/devops-lab-0.0.1-SNAPSHOT.jar
```

Docker avvia quindi Java, che esegue il JAR e di conseguenza avvia l'applicazione Spring Boot.

La sintassi:

```dockerfile
CMD ["java", "-jar", "./devops-lab-0.0.1-SNAPSHOT.jar"]
```

è chiamata **exec form**.

Il comando viene rappresentato come un array, dove ogni elemento corrisponde a una parte del comando da eseguire.

> [!NOTE]
> `CMD` definisce un comando predefinito. Questo significa che può essere sostituito specificando un comando differente al momento dell'esecuzione del container.


# Capitolo 3 - Dockerfile multi-stage

### Preambolo: perché il multi-stage build

Da dove partiamo
Oggi la tua build ha due fasi separate. La prima la fai tu sul computer: ./mvnw package genera il jar in `target/`. La seconda la fa Docker: il Dockerfile copia quel jar in un'immagine con Java 21 e lo avvia.

#### Il problema
Questo schema funziona sul tuo computer, ma ha tre limiti:

Dipende dal tuo ambiente. L'immagine è corretta solo se prima hai eseguito Maven a mano. Chi clona il repository e lancia subito docker build ottiene un errore.
Non è adatto alla CI. Una pipeline parte da un repository pulito, dove `target/` non esiste. Dovresti far compilare il jar a un passaggio della pipeline, prima di Docker, e passarlo in qualche modo all'immagine: possibile, ma più fragile e con più pezzi da tenere insieme.
L'immagine è più grande del necessario. Per eseguire un jar basta un JRE, mentre hai usato un JDK completo, che contiene anche compilatore e strumenti di sviluppo. In produzione sono peso inutile e superficie d'attacco in più.

#### L'idea del multi-stage build
Un solo Dockerfile con più fasi, dette stage:

lo stage di build contiene tutto il necessario per compilare (JDK, Maven, sorgenti) e produce il jar;
lo stage finale parte da un'immagine leggera e riceve solo il risultato, cioè il jar.

Tutto ciò che sta negli stage intermedi non finisce nell'immagine finale. È come costruire in un cantiere e consegnare solo l'edificio, senza gru e attrezzi.

#### Cosa ottieni

Una build riproducibile: bastano git clone e docker build, su qualunque macchina.
Un'immagine più piccola e più sicura.
Un Dockerfile che la pipeline può usare così com'è, senza passaggi manuali.


## Capitolo 3.1 - Dal Single-Stage al Multi-Stage

### Punto di partenza: Single Stage
Nella versione single-stage ci preoccupavamo solamente dell'esecuzione dell'applicazione. Tutto ciò che riguardava la compilazione e la generazione dell'artefatto, tramite `mvn package`, veniva eseguito direttamente sulla macchina locale.

Il Dockerfile riceveva quindi un jar già pronto, lo copiava all'interno dell'immagine e lo utilizzava per avviare l'applicazione:
```dockerfile
..
COPY target/devops-lab-0.0.1-SNAPSHOT.jar .
CMD ["java", "-jar", "./devops-lab-0.0.1-SNAPSHOT.jar"]
```

#### Cosa si otteneva?
Un'immagine Docker in grado di eseguire l'applicazione, ma la sua costruzione dipendeva da un passaggio preliminare eseguito sulla macchina host.

Questo comporta alcune conseguenze:
- La build Docker non era autonoma: senza il file `.jar` già presente nella directory `target/` la build falliva.
- La generazione dell'artefatto dipendeva dall'ambiente della macchina host. Versione del *JDK*, configurazione locale e altri strumenti installati potevano quindi influenzare il risultato della build, riducendone la riproducibilità tra ambienti differenti.
- La directory `target/` doveva essere inclusa nel build context, perché Docker aveva bisogno del jar generato localmente; di conseguenza non poteva essere esclusa tramite `.dockerignore`.
- Il Dockerfile dipendeva direttamente dal nome del jar, compresa la sua versione, ad esempio `devops-lab-0.0.1-SNAPSHOT.jar`.
- La compilazione e l'esecuzione erano gestite da due ambienti differenti: la macchina host produceva l'artefatto, mentre Docker si occupava solamente della sua esecuzione.

La multi-stage build permette di spostare anche la fase di compilazione all'interno di Docker, rendendo il processo di build più autonomo e riproducibile.

### L'idea dei due stage

Si parla di **multi-stage build** quando all'interno dello stesso `Dockerfile` vengono definiti più stage tramite più istruzioni `FROM`.

Ogni `FROM` avvia un nuovo stage, basato sulla propria immagine di partenza. Solo l'ultimo stage diventa l'immagine finale: gli altri servono durante la build e non finiscono in ciò che si avvia o si pubblica.

Nel nostro caso vengono creati due ambienti distinti:

- `build`: compila l'applicazione e produce l'artefatto
- `run`: esegue l'artefatto prodotto

```dockerfile
# Dockerfile abbreviato
FROM eclipse-temurin:21-jdk-noble AS build
...
FROM eclipse-temurin:21-jre-noble AS run
...
```

Ogni stage ha il proprio filesystem e può usare strumenti diversi. Lo stage `build` contiene il JDK, il Maven Wrapper, il codice sorgente e le dipendenze necessarie alla compilazione. Lo stage `run` no: ha solo il JRE e il jar, **senza Maven e senza sorgenti**.

Con un solo stage tutto ciò che serve per compilare finiva nell'immagine da eseguire, e il jar andava costruito a mano sul mio computer prima di ogni build. Con due stage la build è riproducibile (bastano `git clone` e `docker build`) e l'immagine finale è più piccola.

#### Nomi degli stage

Uno stage si identifica con `AS`:

```dockerfile
FROM eclipse-temurin:21-jdk-noble AS build
```

Il nome permette agli stage successivi di recuperare solo gli artefatti necessari:

```dockerfile
COPY --from=build /opt/app/target/*.jar app.jar
```

Uno stage non eredita nulla dagli altri, tranne ciò che viene copiato esplicitamente con `COPY --from`. Si potrebbe usare anche il numero dello stage (per esempio `--from=0`), ma il nome resta corretto anche se in futuro si aggiungono stage in mezzo.

Con `docker build --target build .` si può fermare la build a uno stage intermedio, utile per verificarlo da solo.

#### In sintesi

Il multi-stage separa due responsabilità: produrre l'artefatto (`build`) ed eseguirlo (`run`).
## Capitolo 3.2 - Lo stage `build`

| Istruzione                                          | Descrizione                                                                                                                                                                  |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `FROM eclipse-temurin:21-jdk-noble AS build`        | Crea lo stage build a partire da un'immagine Eclipse Temurin con JDK 21 su Ubuntu Noble. Il JDK è necessario perché in questo stage il codice Java viene compilato.          |
| `WORKDIR /opt/app/`                                 | Imposta /opt/app/ come directory di lavoro dello stage.                                                                                                                      |
| `COPY .mvn/ .mvn`                                   | Copia nella build la configurazione utilizzata dal Maven Wrapper.                                                                                                            |
| `COPY mvnw pom.xml .`                               | Copia il Maven Wrapper e il pom.xml. Questi file vengono copiati prima del codice sorgente per permettere a Docker di riutilizzare più facilmente la cache delle dipendenze. |
| `RUN chmod +x mvnw && ./mvnw dependency:go-offline` | Risolve e scarica preventivamente dipendenze e plugin Maven necessari alla build.                                                                                            |
| `COPY src ./src`                                    | Copia il codice sorgente dell'applicazione nello stage di build. Viene eseguito dopo il download delle dipendenze perché il codice cambia più frequentemente del pom.xml.    |
| `RUN ./mvnw package -DskipTests`                    | Compila l'applicazione e genera il jar nella directory target/. I test vengono saltati perché sono previsti come fase separata del processo di build/CI.                     |

#### Perché lo stage build utilizza JDK?

Lo scopo dello stage `build` è trasformare il codice sorgente Java nell'artefatto eseguibile dell'applicazione.

Per questo è necessario avere il **JDK - Java Development Kit**, che contiene gli strumenti di sviluppo necessari, tra cui il compilatore Java `javac`. Per questo lo stage parte da:
```dockerfile
FROM eclipse-temurin:21-jdk-noble AS build
```
Lo stage finale invece non dovrà compilare nulla: riceverà un'applicazione già coompilata. Per questo potrà utilizzare un'immagine più minimale basata su JRE.

La separazione quindi permette di usare:

- BUILD
    JDK -> per compilare
- RUN
    JRE -> per eseguire

> [! NOTE]
> Nel tag eclipse-temurin:21-jdk-noble, noble identifica la release di Ubuntu utilizzata come base dell'immagine. Eclipse Temurin utilizza infatti il nome in codice della release per distinguere le diverse varianti basate su Ubuntu.

> Esempi: jammy, noble, resolute.

### Perché copiamo il Maven Wrapper?
L'immagine utilizzata fornisce Java, ma **non Maven**.
Di conseguenza un comando come:
```dockerfile
RUN mvn package
```
non funzionerebbe. A questo punto abbiamo 2 possibilità:

####   1. Installare Maven

Una possibilità sarebbe installarlo manualmente nello stage: 
```dockerfile
RUN apt install update && apt isntall -y maven
```
> [!NOTE]
> Se Maven venisse installato tramite `apt`, in un Dockerfile è buona pratica limitare i pacchetti installati e rimuovere gli indici APT non più necessari:
>
> ```dockerfile
> RUN apt-get update && \
>     apt-get install -y --no-install-recommends maven && \
>     rm -rf /var/lib/apt/lists/*
> ```
>
> `--no-install-recommends` evita di installare pacchetti solo raccomandati, mentre `rm -rf /var/lib/apt/lists/*` rimuove gli indici scaricati da `apt-get update`, riducendo il contenuto inutile dell'immagine finale.

Questa operazione però introduce una dipendenza aggiuntiva dall'ambiente dell'immagine e dalla versione Maven fornita dal package manager.

#### 2. Utilizzare il Maven Wrapper
Il progetto utilizza invece il **Maven Wrapper**, uno strumento che permette di eseguire Maven senza richiedere che Maven sia già installato sulla macchina e composto principalmente da: `mvnw` e `.mvn/`.

mvnw è lo script utilizzato sui sistemi Unix/Linux, mentre mvnw.cmd è la controparte per Windows.

Questi vengono copiati nello stage: 
```dockerfile
COPY .mvn/ .mvn
COPY mvnw pom.xml . 
```
> [!NOTE]
> Nel secondo passo oltre a mvnw nel progetto viene copiato anche il `pom.xml`.Questo è necessario perché Maven utilizza il pom.xml per conoscere configurazione, dipendenze e plugin del progetto.

Il risultato ottenuto è che possiamo eseguire i comadni maven attraverso `./mvnw`, senza Maven preinstallato nell'immagine.

Il vantaggio principale è la riproducibilità: il progetto definisce la versione di Maven che deve essere utilizzata, invece di dipendere da quella disponibile sulla macchina o nella distribuzione Linux.

> [!NOTE] Perché è presente in un progetto Spring?
> Il Maven Wrapper non appartiene a Spring e non è necessario per utilizzare Spring Boot.
> Quando però un progetto Maven viene generato tramite Spring Initializr, il progetto completo include normalmente anche il Maven Wrapper. Questo permette al progetto generato di essere eseguito subito senza richiedere un'installazione Maven separata.

### Perché copiare il pom.xml prima di /src
L'ordine delle istruzioni è intenzionale

```dockerfile
COPY .mvn/ .mvn
COPY mvnw pom.xml .

RUN ./mvnw dependency:go-offline

COPY src ./src
```

Docker costruisce l'immagine attraverso layer e può riutilizzare quelli già costruiti se le istruzioni e i relativi input non sono cambiati. Questo meccanismo prende il nome di **Caching**

Nel normale ciclo di sviluppo, il codice sorgente contenuto in `/src` cambia molto più frequentemente del `pom.xml`, che contiene la configurazione Maven del progetto, comrpense dipendenze e plugin.

Se il progetto `./src` venisse copiato prima, una modifica anche a una sola classe Java invaliderebbe il layer precedente e costringerebbe Docker a rieseguire anche la fase dedicata alle dipendenze.

Nel nostro caso, copiare il `pom.xml` prima del codice sorgente rende le build successive più efficienti, perché permette a Docker di riutilizzare il layer contenente le dipendenze finché la configurazione Maven non cambia.

### Perché `chmod +x mvnw`
Su Linux, per poter eseguire direttamente uno script, il file deve avere il *permesso di esecuzione.* 

`chmod+x mvnw` aggiunge il permesso di esecuzione al file mvnw.

Nei progetti generati tramite Spring Initializr, mvnw viene normalmente creato come script eseguibile sui sistemi Unix/Linux. 

Quando Docker esegue:
```dockerfile
COPY mvnw pom.xml .
```
non copia solamente il contenuto di mvnw: il file viene trasferito nello stage mantenendo anche il relativo mode proveniente dal build context. Se nel build context mvnw è eseguibile, continuerà quindi a esserlo dopo la COPY.

Nel nostro caso, dato che mvnw possiede già il bit di esecuzione, questa istruzione:
```dockerfile
RUN chmod +x mvnw && ./mvnw dependency:go-offline
```
può essere semplificata in:

```dockerfile
RUN ./mvnw dependency:go-offline
```

> [!!NOTE] 
> Il chmod +x può comunque essere mantenuto come misura difensiva nel caso in cui il build context venga ottenuto attraverso un meccanismo che non preserva il bit di esecuzione, ad esempio alcuni archivi, copie manuali o filesystem con una gestione differente dei permessi.
#### Come Git conserva questa informazione

Inoltre anche Git conserva questa informazione attraverso **l'executable bit**.

Possiamo verificarlo con:
```bash
git ls-files --stage mvnw
```

**Otteniamo qualcosa del genere**

```bash
    100755 <hash> 0 mvnw
```
Il valore `100755` indica che Git registra mvnw come normale file eseguibile.

Git non conserva tutti i permessi Unix del file. Per quanto riguarda l'eseguibilità, distingue principalmente tra

- **file esegubili** -> `100755`
- **file non eseguibile** -> `100644`

Di conseguenza, quando il repository viene clonato su un filesystem che supporta correttamente questi permessi, Git ricrea mvnw con il bit di esecuzione attivo.

### Cosa fa `dependency:go-offline`?

Il comando:
```bash
./mvnw dependency:go-offline
```
esegue il goal go-offline del Maven Dependency Plugin.

Il suo obiettivo è risolvere e scaricare preventivamente le dipendenze e i plugin necessari al progetto nella repository locale di Maven.

Nel Dockerfile viene utilizzato per un'altra ragione: separare il download delle dipendenze dalla compilazione del codice.

La prima build dovrà comunque scaricare tutto ciò che manca.

Nelle build successive, se pom.xml non è cambiato, Docker può riutilizzare quel layer e saltare questa operazione.

### Perché `package -DskipTests`?

`package` esegue il lifecycle Maven fino alla fase di packaging e produce il jar nella directory:

```text
target/
```

La parte:

```bash
-DskipTests
```

indica a Maven di non eseguire i test durante questa operazione.

Attualmente i test possono essere eseguiti esplicitamente con:

```bash
./mvnw test
```

e successivamente verranno inseriti in uno stage dedicato della pipeline CI.

In questo modo i test non vengono eseguiti due volte durante lo stesso processo.

### Perché non usare `clean package`?

In locale è comune eseguire:

```bash
./mvnw clean package
```

La fase `clean` elimina la directory `target/` e gli artefatti prodotti da compilazioni precedenti, così da partire da una build pulita.

Nel nostro stage Docker, però, questo passaggio non è normalmente necessario.

Lo stage `build` parte da un filesystem nuovo e la directory `target/` non esiste ancora. Viene creata da Maven durante la compilazione.

Inoltre `target/` è esclusa tramite `.dockerignore`, quindi un'eventuale directory `target/` presente sulla macchina host non viene inclusa nel build context e non può essere copiata accidentalmente nello stage.

## Capitolo 3.3 - Lo stage `run`

Lo stage `run` rappresenta l'ambiente finale nel quale verrà eseguita l'applicazione.

A differenza dello stage `build`, non deve più compilare il codice o utilizzare Maven: riceve il file `.jar` prodotto nello stage precedente e contiene solamente ciò che è necessario per eseguirlo.

```dockerfile
# RUN
FROM eclipse-temurin:21-jre-noble AS run

EXPOSE 8080

WORKDIR /opt/app/

RUN groupadd -r app && \
    useradd --no-log-init -r -g app app

COPY --from=build --chown=app:app /opt/app/target/*.jar app.jar

USER app

CMD ["java", "-jar", "./app.jar"]
```

| Istruzione                                                        | Descrizione                                                                                                                                                           |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `FROM eclipse-temurin:21-jre-noble AS run`                        | Crea lo stage `run` a partire da un'immagine Eclipse Temurin con JRE 21 su Ubuntu Noble. Il JRE è sufficiente perché in questo stage il codice è già stato compilato. |
| `EXPOSE 8080`                                                     | Documenta la porta sulla quale l'applicazione è prevista in ascolto all'interno del container.                                                                        |
| `WORKDIR /opt/app/`                                               | Imposta `/opt/app/` come directory di lavoro dello stage.                                                                                                             |
| `RUN groupadd -r app && useradd --no-log-init -r -g app app`      | Crea un gruppo e un utente di sistema dedicati all'applicazione.                                                                                                      |
| `COPY --from=build --chown=app:app /opt/app/target/*.jar app.jar` | Copia nello stage `run` il jar prodotto nello stage `build`, lo rinomina `app.jar` e ne assegna la proprietà all'utente e al gruppo `app`.                            |
| `USER app`                                                        | Imposta `app` come utente con cui verrà eseguita l'applicazione.                                                                                                      |
| `CMD ["java", "-jar", "./app.jar"]`                               | Definisce il comando eseguito all'avvio del container.                                                                                                                |

### Perché lo stage `run` utilizza il JRE?

Nello stage `build` avevamo bisogno del **JDK - Java Development Kit**, perché il codice sorgente doveva essere compilato tramite gli strumenti di sviluppo Java, tra cui `javac`.

Una volta terminata la build, però, possediamo già l'artefatto compilato:

```text
target/*.jar
```

Lo stage `run` non deve quindi più compilare:

```text
.java
 ↓
javac
 ↓
.class
```

ma solamente eseguire il bytecode Java già prodotto.

Per questo possiamo utilizzare:

```dockerfile
FROM eclipse-temurin:21-jre-noble AS run
```

Il **JRE - Java Runtime Environment** contiene l'ambiente necessario per eseguire un'applicazione Java, senza includere tutti gli strumenti di sviluppo presenti nel JDK.

La separazione permette quindi di utilizzare:

- BUILD  
  JDK → per compilare

- RUN  
  JRE → per eseguire

Questo permette inoltre di non includere nell'immagine finale strumenti che servivano solamente durante la fase di compilazione.

### Cosa fa `EXPOSE 8080`?

L'istruzione:

```dockerfile
EXPOSE 8080
```

documenta che l'applicazione è prevista in ascolto sulla porta `8080` all'interno del container.

Nel nostro caso Spring Boot utilizza la porta `8080`, quindi il Dockerfile rende esplicita questa informazione.

È importante però capire che `EXPOSE` **non pubblica la porta sulla macchina host**.

Se eseguiamo semplicemente:

```bash
docker run devops-lab
```

l'applicazione utilizzerà la porta `8080` all'interno del container, ma questa non viene automaticamente resa raggiungibile attraverso la porta `8080` della macchina host.

Per pubblicarla utilizziamo:

```bash
docker run -p 8080:8080 devops-lab
```


> [!NOTE]
> `EXPOSE` è principalmente una dichiarazione dell'immagine. Non obbliga il processo ad ascoltare su quella porta e non crea da solo alcun mapping verso la macchina host.

### Perché creare un utente dedicato?

Di default, se l'immagine non specifica un utente differente, il processo del container viene eseguito come `root`.

La nostra applicazione non necessita però dei privilegi amministrativi di `root`.

Per questo vengono creati un gruppo e un utente dedicati:

```dockerfile
RUN groupadd -r app && \
    useradd --no-log-init -r -g app app
```

Il primo comando:

```bash
groupadd -r app
```

crea un gruppo chiamato `app`.

L'opzione:

```text
-r
```

indica che si tratta di un **system group**, cioè un gruppo destinato principalmente a servizi e processi.

Successivamente:

```bash
useradd --no-log-init -r -g app app
```

crea l'utente `app`.

Le opzioni utilizzate indicano:

```text
-r
→ crea un system user

-g app
→ assegna "app" come gruppo principale

--no-log-init
→ evita l'inizializzazione di alcuni file relativi al login/accounting
```

Alla fine abbiamo quindi:

```text
utente → app
gruppo → app
```

Lo scopo è applicare il principio del **least privilege**: un processo dovrebbe possedere solamente i privilegi necessari per svolgere il proprio compito.

La nostra applicazione deve poter:

- leggere il jar;
- avviare Java;
- ascoltare sulla porta configurata;

ma non necessita di amministrare il sistema operativo del container.

### Cosa significa `COPY --from=build`?

Nello stage precedente le istruzioni `COPY` prendevano i file dal **build context**:

```dockerfile
COPY src ./src
```

Nello stage `run`, invece, utilizziamo:

```dockerfile
COPY --from=build --chown=app:app /opt/app/target/*.jar app.jar
```

La parte:

```text
--from=build
```

indica che il file non deve essere preso dalla macchina host, ma dallo stage chiamato `build`.

Gli stage non condividono automaticamente tutto il proprio filesystem.

Lo stage `run` riceve solamente ciò che decidiamo esplicitamente di copiare tramite `COPY --from`.

Gli strumenti e i file necessari solamente alla compilazione non vengono quindi trasferiti nell'immagine finale.

### Perché utilizzare `*.jar`?

Nello stage `build`, Maven può generare un artefatto con un nome contenente anche la versione:

```text
devops-lab-0.0.1-SNAPSHOT.jar
```

In una versione successiva potrebbe invece diventare:

```text
devops-lab-0.0.2-SNAPSHOT.jar
```

Se nel Dockerfile utilizzassimo il nome completo:

```dockerfile
COPY --from=build /opt/app/target/devops-lab-0.0.1-SNAPSHOT.jar .
```

dovremmo modificare il Dockerfile ogni volta che cambia la versione dell'applicazione.

Utilizzando:

```dockerfile
/opt/app/target/*.jar
```

non dipendiamo direttamente dal numero di versione presente nel nome.

> [!NOTE]
> L'utilizzo di `*.jar` presuppone che il pattern identifichi il jar corretto. Se Maven producesse più file `.jar`, sarebbe necessario utilizzare una selezione più specifica.

### Perché rinominare il jar in `app.jar`?

La parte finale della `COPY`:

```dockerfile
COPY --from=build ... app.jar
```

indica il nome del file nello stage `run`.

Quindi un file come:

```text
devops-lab-0.0.1-SNAPSHOT.jar
```

viene copiato come:

```text
/opt/app/app.jar
```

Questo permette di separare il nome utilizzato da Maven dal nome utilizzato all'interno del container.

Indipendentemente dalla versione dell'applicazione.

all'interno dell'immagine il file continuerà a essere:

```text
app.jar
```

e il comando di avvio potrà rimanere invariato:

```dockerfile
CMD ["java", "-jar", "./app.jar"]
```

### Cosa fa `--chown=app:app`?

Nella stessa istruzione troviamo:

```text
--chown=app:app
```

che stabilisce l'ownership del file copiato.

La sintassi:

```text
utente:gruppo
```

nel nostro caso diventa:

```text
app:app
│   │
│   └─ gruppo
└───── utente
```

Il risultato sarà quindi:

```text
/opt/app/app.jar

owner → app
group → app
```

`--chown` e `USER` hanno quindi responsabilità differenti:

```text
--chown=app:app
→ stabilisce a chi appartiene il file

USER app
→ stabilisce con quale utente viene eseguito il processo
```

### Perché `USER app`?

Dopo aver creato l'utente e preparato il file possiamo impostare:

```dockerfile
USER app
```

Da questo momento le istruzioni che dipendono dall'utente corrente e, soprattutto, il processo avviato dal container verranno eseguiti come `app` anziché come `root`.

Il nostro comando:

```dockerfile
CMD ["java", "-jar", "./app.jar"]
```

verrà quindi eseguito con l'utente:

```text
app
```

Possiamo verificarlo su un container in esecuzione tramite:

```bash
docker exec <container> whoami
```

ottenendo:

```text
app
```

oppure:

```bash
docker exec <container> id
```

per visualizzare UID, GID e gruppi associati al processo.


### Cosa fa `CMD`?

L'ultima istruzione:

```dockerfile
CMD ["java", "-jar", "./app.jar"]
```

definisce il comando predefinito che verrà eseguito quando viene creato un container dall'immagine.


### Lo stage `run` nel suo insieme

Possiamo quindi interpretare:

```dockerfile
FROM eclipse-temurin:21-jre-noble AS run
EXPOSE 8080
WORKDIR /opt/app/

RUN groupadd -r app && \
    useradd --no-log-init -r -g app app

COPY --from=build --chown=app:app /opt/app/target/*.jar app.jar

USER app

CMD ["java", "-jar", "./app.jar"]
```
Lo stage `run` contiene quindi solamente ciò che è necessario per l'esecuzione dell'applicazione, mentre tutto ciò che era necessario esclusivamente alla compilazione rimane confinato nello stage `build`.

