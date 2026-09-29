# DevOps Lab

Piccola API Spring Boot usata per esercitarmi con Git, Linux e Docker.

## Obiettivo

Costruire una pipeline completa su GitHub Actions che effettui il deploy automatico dell'applicazione a ogni merge sul branch `main`.

## Tecnologie

- Java 21
- Spring Boot <versione>
- Maven (tramite wrapper `mvnw`)
- Docker

## Prerequisiti

- JDK 21
- Docker (per l'avvio in container)
- Maven non serve: viene scaricato dal wrapper `mvnw`

## Avvio in locale

```bash
./mvnw spring-boot:run
```

Su Windows: `mvnw.cmd spring-boot:run`.

## Avvio con Docker

1. Testare e generare il jar, che finisce nella cartella `target/`:
```bash
   ./mvnw package
```
2. Costruire l'immagine (contiene Java 21 e il jar):
```bash
   docker build -t devops-lab .
```
3. Avviare il container:
```bash
   docker run -p 8080:8080 devops-lab
```

Il passo 1 è necessario perché il Dockerfile copia il jar dalla cartella `target/`.

## Endpoint

Con l'applicazione avviata, in un secondo terminale:

```bash
curl -i http://localhost:8080/health
curl -i http://localhost:8080/hello
curl -i http://localhost:8080/percorso-inesistente
```

| Percorso                | Risposta       | Codice HTTP |
| ----------------------- | -------------- | ----------- |
| `/health`               | <output reale> | 200         |
| `/hello`                | <output reale> | 200         |
| `/percorso-inesistente` | <output reale> | 404         |

## Struttura del progetto

- `Dockerfile`: costruisce l'immagine a partire da `eclipse-temurin:21` e avvia il jar.
- `.dockerignore`: esclude dal contesto di build file inutili, come `.git` e i file dell'IDE.

## Decisioni

- `EXPOSE 8080`: documenta la porta su cui ascolta l'app. Non la pubblica: lo fa `-p` in `docker run`.
- `-p 8080:8080`: il primo numero è la porta del mio computer, il secondo quella del container.
- `CMD` in exec form (con le parentesi quadre): il processo Java riceve direttamente i segnali, per esempio `SIGTERM` allo stop del container.
- `target/` non è nel `.dockerignore`: la `COPY` del Dockerfile ha bisogno del jar. Cambierà con il multi-stage build.

## Prossimi passi

- [x] API con endpoint `/health` e `/hello`
- [x] Test e generazione del jar con Maven
- [x] Immagine Docker funzionante in locale
- [ ] Multi-stage build
- [ ] Immagine più leggera (JRE) e utente non root
- [ ] Workflow GitHub Actions: test e build a ogni push
- [ ] Push dell'immagine su GitHub Container Registry
- [ ] Deploy automatico a ogni merge su `main`