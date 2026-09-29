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


# Capitolo 2 - Dockerfile multi-stage