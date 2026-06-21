# Ollama Qwen 2.5 en local

## Configurar contenedor Docker
Se utilizará el contenedor oficial de Ollama publicado por los autores.

Para facilitar la reproducibilidad se utilizará el archivo `compose.ollama.yaml` incluido en este folder. Su contenido base es el siguiente:

```yaml
# compose.ollama.yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: no #unless-stopped
    gpus: all
    ports:
      - "127.0.0.1:11434:11434"
    volumes:
      - ollama:/root/.ollama
    #network_mode: "host"
    environment:
      OLLAMA_KEEP_ALIVE: 24h
      OLLAMA_NUM_PARALLEL: 1

volumes:
  ollama:
```

En principio con esa configuración basta. Si en tu equipo el contenedor no logra salir a Internet para descargar modelos, se puede descomentar temporalmente `network_mode: "host"` y volverlo a comentar después.

También se puede elegir entre `no` y `unless-stopped` para que el contenedor se reinicie automáticamente si se detiene o al encender la computadora.


## Levantar contenedor
Utilizar el comando `docker-compose` para levantar el contenedor:

```bash
docker compose -f compose.ollama.yaml up -d
```

Si al levantarlo falla, probar con las siguientes alternativas:
```bash
# 1. Eliminar contenedor anterior del mismo nombre
docker rm -f ollama

# 2. Eliminar el servicio ollama local
# a veces el paquete Continue intenta instalar ollama localmente
# pero esto no implica que lo configure adecuadamente
sudo systemctl disable ollama
sudo systemctl stop ollama
```

## Detener el contenedor
Para detener el contenedor, puedes usar:

```bash
docker compose -f compose.ollama.yaml stop
```

## Instalar los modelos en el contenedor
Una vez con el contenedor levantado hay que instalar los modelos requeridos. En estos ejemplos se usan los modelos Qwen 2.5 de 1.5B y 7B, respectivamente.

NOTA: B equivale a 1000 millones de parámetros

```bash
docker exec -it ollama ollama pull qwen2.5-coder:1.5b
docker exec -it ollama ollama pull qwen2.5-coder:7b
```

Para correr un modelo y verificar que está activo ejecutar:
```bash
docker exec -it ollama ollama run qwen2.5-coder:1.5b
docker exec -it ollama ollama ps
```

*NOTA:* Una vez instalados los modelos y si ya no requieres acceso a Internet desde el contenedor, puedes dejar comentada la línea `#network_mode: "host"`.

## Opciones adicionales de operaciones con los modelos
Listar los modelos instalados

```bash
docker exec -it ollama ollama list
```

Para detener un modelo se utiliza el comando `stop` junto con el nombre del modelo que se desea detener, en este caso `qwen2.5-coder:1.5`

```bash
docker exec -it ollama ollama stop qwen2.5-coder:1.5b
```

También se pueden eliminar los modelos de la siguiente forma:

```bash
docker exec -it ollama ollama rm qwen2.5-coder:XX
```

Especificando `XX` con el identificador del modelo a eliminar


## Testing
Desde la terminal se ejecutará Qwen y se le harán un par de consultas. Posiblemente la primera vez tarde un poco en contestar.

```bash
docker exec -it ollama ollama run qwen2.5-coder:1.5b

hola quien eres
¡Hola! Soy Qwen, un asistente de inteligencia artificial creado por Alibaba Cloud. ¿En qué puedo ayudarte hoy?

Qué versión eres
Soy la última versión del modelo Qwen, disponible desde hace algunos meses.
```


## Configurar Ollama Local en VSCode (Opcional)

Si quieres usar [Continue](https://www.continue.dev/) para chat, edición y autocompletado dentro de [Visual Studio Code](https://code.visualstudio.com/), basta con registra Ollama local que quedó escuchando en `http://localhost:11434`.

La configuración se hace en el archivo `config.yaml` de Continue. Ahí registras los modelos disponibles; después la selección fina de cuál usar para cada tarea se puede ajustar desde la interfaz de la extensión.

La configuración que me ha funcionado es este:

```yaml
name: Main Config
version: 1.0.0
schema: v1

models:
  - name: Qwen 2.5 Coder 7B
    provider: ollama
    model: qwen2.5-coder:7b
    apiBase: http://localhost:11434
    roles:
      - chat
      - edit
      - apply
    requestOptions:
      timeout: 300000
    defaultCompletionOptions:
      contextLength: 16000
      maxTokens: 2048
      temperature: 0.1

  - name: Qwen 2.5 Coder 1.5B
    provider: ollama
    model: qwen2.5-coder:1.5b
    apiBase: http://localhost:11434
    roles:
      - autocomplete
      - chat
      - edit
      - apply
    requestOptions:
      timeout: 30000
    defaultCompletionOptions:
      contextLength: 4096
      maxTokens: 512
      temperature: 0.0
    autocompleteOptions:
      disable: false
      debounceDelay: 350
      maxPromptTokens: 1024
      onlyMyCode: true
      useCache: true
      useImports: true
      useRecentlyEdited: true
      useRecentlyOpened: true
```

El campo `model` debe coincidir con el nombre real del modelo instalado en Ollama. El campo `name` es solo la etiqueta que verás dentro de Continue.

Para verificar los nombres disponibles:

```bash
docker exec -it ollama ollama list
```
