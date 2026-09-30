# DevOps Lab

Piccola API Spring Boot usata per esercitarmi con Git, Linux e Docker.

> [!NOTE]
> Se vuoi approfondire gli aspetti teorici trattati nel progetto, consulta il file `notes.md` presente nel repository.

## Obiettivo

Costruire una pipeline completa su GitHub Actions che effettui il deploy automatico dell'applicazione a ogni merge sul branch `main`.

## Tecnologie

- Java 21
- Spring Boot 4.1.1
- Maven tramite Maven Wrapper (`mvnw`)
- Docker

## Prerequisiti

Per eseguire l'applicazione con Docker è necessario solamente:

- Docker

Per eseguire l'applicazione o i test direttamente sulla macchina locale è necessario:

- JDK 21

Non è necessario installare Maven: il progetto utilizza il Maven Wrapper (`mvnw`), che gestisce la versione di Maven prevista dal progetto.

## Avvio dell'app in locale

Richiede JDK 21.

```bash
./mvnw spring-boot:run
```

Su Windows:

```powershell
mvnw.cmd spring-boot:run
```

## Test

I test vengono eseguiti separatamente dalla build dell'immagine Docker:

```bash
./mvnw test
```

Il Dockerfile usa `-DskipTests` durante la creazione del jar perché la fase di build dell'immagine è separata dalla fase di test. In seguito i test verranno eseguiti automaticamente dalla pipeline CI.

## Avvio con Docker

Il Dockerfile usa una multi-stage build: il jar viene compilato nello stage di build e copiato successivamente nell'immagine runtime. Non è quindi necessario generare manualmente la cartella `target/` prima di eseguire `docker build`.

1. Costruire l'immagine:

   ```bash
   docker build -t devops-lab .
   ```

2. Avviare il container:

   ```bash
   docker run -p 8080:8080 devops-lab
   ```

## Endpoint

Con l'applicazione avviata, in un secondo terminale:

```bash
curl -i http://localhost:8080/rest/api/health
curl -i http://localhost:8080/rest/api/hello
curl -i http://localhost:8080/percorso-inesistente
```

| Percorso                | Risposta                   | Codice HTTP |
| ----------------------- | -------------------------- | ----------: |
| `/rest/api/health`      | body vuoto                 |         200 |
| `/rest/api/hello`       | `hello`                    |         200 |
| `/percorso-inesistente` | JSON di errore Spring Boot |         404 |

La risposta `404` viene generata automaticamente da Spring Boot e contiene informazioni sull'errore, tra cui timestamp, status HTTP, tipo di errore e percorso richiesto. Il timestamp varia a ogni richiesta.

## Struttura del progetto

- `Dockerfile`: utilizza una multi-stage build. Lo stage `build` usa `eclipse-temurin:21-jdk-noble` per compilare l'applicazione con Maven Wrapper; lo stage `run` usa `eclipse-temurin:21-jre-noble`, contiene solamente il jar necessario all'esecuzione e avvia l'applicazione con un utente non root.
- `.dockerignore`: esclude dal build context file non necessari, tra cui `.git`, file dell'IDE e `target/`. Il jar viene infatti generato direttamente nello stage di build Docker.
- `pom.xml`: definisce dipendenze, versione di Java, versione di Spring Boot e configurazione Maven.
- `src/`: contiene il codice sorgente e i test dell'applicazione.

## Decisioni

- `EXPOSE 80`80: documenta la porta sulla quale ascolta l'applicazione. Non pubblica la porta sull'host: questo viene fatto con `-p` durante `docker run`.

- `-p 8080:8080`: il primo numero indica la porta dell'host, il secondo la porta del container.

- Multi-stage build: compilazione ed esecuzione sono separate. Lo stage di build contiene JDK, Maven Wrapper e sorgenti, mentre l'immagine finale contiene solamente il JRE e il jar dell'applicazione.

- JRE nello stage runtime: l'applicazione compilata non necessita del JDK completo per essere eseguita, quindi lo stage finale usa `eclipse-temurin:21-jre-noble`.

- Cache delle dipendenze Maven: `pom.xml`, `mvnw` e `.mvn/` vengono copiati prima di `src/`. `dependency:go-offline` viene quindi eseguito in un layer separato, che può essere riutilizzato finché le dipendenze non cambiano.

- `target/` è esclusa dal `.dockerignore`: con la multi-stage build il jar viene generato all'interno dello stage `build`, quindi la build Docker non dipende più da artefatti compilati sulla macchina host.

- Il jar viene copiato nello stage runtime come `app.jar`. In questo modo il comando di avvio non dipende dal nome o dalla versione del jar generato da Maven.

- L'applicazione viene eseguita con un utente dedicato non root. L'utente e il gruppo `app` vengono creati nello stage runtime e il jar viene copiato con ownership `app:app`.

- `CMD` usa la exec form:

  ```dockerfile
  CMD ["java", "-jar", "app.jar"]
  ```

  In questo modo Java viene avviato direttamente come processo del container e può ricevere correttamente segnali come `SIGTERM`.

- La build Docker usa `-DskipTests`: i test non vengono eseguiti durante la creazione dell'immagine e devono essere eseguiti separatamente con `./mvnw test`. In futuro questa responsabilità verrà assegnata alla pipeline CI.

- Il progetto utilizza Maven Wrapper invece di richiedere un'installazione Maven sulla macchina host. `mvnw` è versionato da Git come file eseguibile (`100755`), quindi non è necessario eseguire `chmod +x` nel Dockerfile.

## Prossimi passi

- [x] API con endpoint `/rest/api/health` e `/rest/api/hello`
- [x] Test e generazione del jar con Maven
- [x] Immagine Docker funzionante in locale
- [x] Multi-stage build
- [x] Immagine runtime basata su JRE
- [x] Utente non root nel container
- [x] Ottimizzazione della cache delle dipendenze Maven
- [ ] Workflow GitHub Actions: test e build a ogni push
- [ ] Push dell'immagine su GitHub Container Registry
- [ ] Deploy automatico a ogni merge su `main`
