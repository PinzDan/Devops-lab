# DevOps Lab

Piccola API Spring Boot usata per esercitarmi con Git, Linux e Docker.

## Prerequisiti

- Java installato nella versione scelta su Spring Initializr

## Avvio

Dalla cartella del progetto:

```bash
./mvnw spring-boot:run
```

Su Windows: `mvnw.cmd spring-boot:run`.

## Verifica

Con l'applicazione avviata, in un secondo terminale:

```bash
curl -i http://localhost:8080/health
curl -i http://localhost:8080/hello
curl -i http://localhost:8080/percorso-inesistente
```

I primi due endpoint restituiscono HTTP 200; il percorso inesistente restituisce HTTP 404.