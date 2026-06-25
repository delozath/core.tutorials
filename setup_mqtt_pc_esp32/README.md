# Tutorial: instalación y prueba de MQTT en Ubuntu y una red local

Este tutorial guía la instalación de un broker MQTT en una computadora con Ubuntu y su integración con un gateway o router local, por ejemplo un router de laboratorio. El objetivo es que una computadora funcione como servidor MQTT dentro de una red de laboratorio y que otros dispositivos, como otra computadora, una ESP32 o un broadcaster conectado por Ethernet o Wi-Fi, puedan publicar y suscribirse a mensajes.

Nota para publicación: los nombres de red, contraseñas y marcas específicas se dejaron como valores genéricos. Las direcciones `192.168.1.x` se conservan como ejemplo didáctico porque pertenecen a rangos privados y hacen el tutorial más fácil de seguir; si coinciden con una red real, conviene cambiarlas por otros valores privados antes de publicar el material. Este balance mantiene el tutorial descargable y funcional sin exponer credenciales ni identificadores personales.

<details>
<summary>Índice del tutorial</summary>

- [1. Objetivo de la práctica](#1-objetivo-de-la-práctica)
- [2. Material requerido](#2-material-requerido)
- [3. Conceptos básicos](#3-conceptos-básicos)
- [4. Esquema general de red](#4-esquema-general-de-red)
- [5. Configurar el gateway o router](#5-configurar-el-gateway-o-router)
- [6. Identificar la interfaz de red en Ubuntu](#6-identificar-la-interfaz-de-red-en-ubuntu)
- [7. Configurar IP fija en Ubuntu](#7-configurar-ip-fija-en-ubuntu)
- [8. Instalar Mosquitto en Ubuntu](#8-instalar-mosquitto-en-ubuntu)
- [9. Configurar Mosquitto para aceptar clientes de la red](#9-configurar-mosquitto-para-aceptar-clientes-de-la-red)
- [10. Primera prueba local en Ubuntu](#10-primera-prueba-local-en-ubuntu)
- [11. Prueba desde otro dispositivo conectado al router](#11-prueba-desde-otro-dispositivo-conectado-al-router)
- [12. Conectar un broadcaster o dispositivo embebido](#12-conectar-un-broadcaster-o-dispositivo-embebido)
- [12.3 Ejemplo ESP32: prender y apagar un LED por MQTT](#123-ejemplo-esp32-prender-y-apagar-un-led-por-mqtt)
- [13. Uso opcional de Node-RED](#13-uso-opcional-de-node-red)
- [14. Diagnóstico de fallas comunes](#14-diagnóstico-de-fallas-comunes)
- [15. Buenas prácticas para el laboratorio](#15-buenas-prácticas-para-el-laboratorio)
- [16. Anexo A: qué es una dirección IP y por qué se utiliza](#16-anexo-a-qué-es-una-dirección-ip-y-por-qué-se-utiliza)
- [17. Anexo B: minitutorial para ponchar un cable Ethernet](#17-anexo-b-minitutorial-para-ponchar-un-cable-ethernet)
- [18. Anexo C: probar una conexión entre dos computadoras](#18-anexo-c-probar-una-conexión-entre-dos-computadoras)
- [19. Anexo D: seguridad MQTT y firewall en Ubuntu](#19-anexo-d-seguridad-mqtt-y-firewall-en-ubuntu)
- [20. Referencias adicionales](#20-referencias-adicionales)

</details>

## 1. Objetivo de la práctica

Al terminar, el estudiante podrá:

- Configurar una red local para comunicación MQTT.
- Asignar una dirección IP fija a una computadora Ubuntu.
- Instalar y habilitar Mosquitto como broker MQTT.
- Probar publicación y suscripción de mensajes MQTT.
- Conectar un dispositivo cliente por Ethernet o Wi-Fi.
- Identificar fallas comunes de red usando comandos básicos.

## 2. Material requerido

- Una computadora con Ubuntu.
- Un gateway o router local.
- Cable Ethernet.
- Acceso de administrador en Ubuntu.
- Otro cliente de prueba: otra computadora, una ESP32, una Raspberry Pi o un broadcaster compatible con red.
- Opcional: pinzas ponchadoras, conectores RJ45 y probador de cable.

## 3. Conceptos básicos

MQTT es un protocolo de mensajería ligero basado en el modelo publicador/suscriptor. En lugar de que dos dispositivos se comuniquen directamente entre sí, ambos se conectan a un servidor intermedio llamado broker.

Conceptos clave:
- Broker: servidor que recibe y distribuye mensajes MQTT. En este tutorial será Mosquitto en Ubuntu.
- Cliente: dispositivo que publica o recibe mensajes.
- Topic: canal lógico de comunicación, por ejemplo `esp32/hello` o `sensor/temperatura`.
- Publicar: enviar un mensaje a un topic.
- Suscribirse: escuchar los mensajes de un topic.
- Puerto MQTT: por convención MQTT sin cifrado usa el puerto `1883`.

## 4. Esquema general de red

Se recomienda usar una red local simple:

```text
Internet opcional
      |
[Gateway o router local]
      | Ethernet o Wi-Fi
      +-- Ubuntu: broker MQTT, IP fija 192.168.1.100
      +-- Cliente 1: computadora de prueba
      +-- Cliente 2: broadcaster, ESP32 u otro dispositivo
```

En este ejemplo se usará:

```text
Red local:        192.168.1.0/24
Gateway/router:   192.168.1.1
Ubuntu broker:    192.168.1.100
Puerto MQTT:      1883
```

La dirección `192.168.1.100` puede cambiarse, pero debe estar libre y pertenecer a la misma red local que el router.

## 5. Configurar el gateway o router

### 5.1 Conexión física

1. Conecte el router a la alimentación eléctrica.
2. Conecte la computadora Ubuntu al router usando un cable Ethernet.
3. Si el broadcaster tiene puerto Ethernet, conéctelo también al router.
4. Si el broadcaster solo usa Wi-Fi, primero configure la red inalámbrica del router.

### 5.2 Acceso a la interfaz web del router

En muchos routers domésticos o de laboratorio la dirección de administración es:

```text
http://192.168.1.1/
```

Desde Ubuntu:

1. Abra Firefox o el navegador disponible.
2. Escriba `http://192.168.1.1/`.
3. Inicie sesión con las credenciales del router.
4. Si no conoce la clave, revise la etiqueta del equipo o el manual del fabricante.

Si esa dirección no responde, revise la puerta de enlace actual:

```bash
ip route
```

Busque una línea similar a:

```text
default via 192.168.1.1 dev enp7s0
```

La IP después de `default via` normalmente es la dirección del gateway.

### 5.3 Configuración general recomendada en el router

En la interfaz gráfica del router, busque secciones con nombres similares a `Basic Setup`, `LAN`, `Local Network`, `DHCP Server`, `Wireless` o `Wi-Fi`.

Configure:

- Dirección LAN del router: `192.168.1.1`.
- Máscara de red: `255.255.255.0`.
- Servidor DHCP: habilitado.
- Rango DHCP sugerido: `192.168.1.50` a `192.168.1.99`.
- Nombre de red Wi-Fi, SSID: `NOMBRE_DE_TU_RED`.
- Seguridad Wi-Fi: `WPA2-Personal` o `WPA2/WPA3-Personal`.
- Contraseña Wi-Fi: use una clave de laboratorio acordada por el profesor.

La IP fija del broker se propone como `192.168.1.100`, fuera del rango DHCP. Esto reduce el riesgo de que el router asigne accidentalmente la misma IP a otro dispositivo.

Guarde los cambios y reinicie el router si la interfaz lo solicita.

## 6. Identificar la interfaz de red en Ubuntu

En Ubuntu, abra una terminal y ejecute:

```bash
ip link
```

Ubique el nombre de la interfaz Ethernet. Algunos nombres comunes son:

```text
enp7s0
enp3s0
eno1
eth0
```

También puede revisar las conexiones de NetworkManager:

```bash
nmcli device status
```

Ejemplo de salida:

```text
DEVICE  TYPE      STATE      CONNECTION
enp7s0  ethernet  connected  Wired connection 1
wlp2s0  wifi      connected  NOMBRE_DE_TU_RED
lo      loopback  unmanaged  --
```

En los comandos siguientes se usará `enp7s0`. Si su computadora tiene otro nombre de interfaz, sustitúyalo.

## 7. Configurar IP fija en Ubuntu

### 7.1 Opción A: configuración por terminal

Ejecute en Ubuntu:

```bash
sudo nmcli con add \
  con-name mqtt-lan \
  type ethernet \
  ifname enp7s0 \
  ipv4.method manual \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "192.168.1.1 8.8.8.8" \
  ipv6.method ignore
```

Active la conexión:

```bash
sudo nmcli con up mqtt-lan
```

Verifique la IP:

```bash
ip addr show enp7s0
```

Debe aparecer algo similar a:

```text
inet 192.168.1.100/24
```

Compruebe comunicación con el router:

```bash
ping -c 4 192.168.1.1
```

### 7.2 Opción B: configuración con GUI de Ubuntu

1. Abra `Settings`.
2. Entre a `Network`.
3. Seleccione la conexión cableada.
4. Presione el icono de configuración.
5. Abra la pestaña `IPv4`.
6. Cambie el método a `Manual`.
7. Escriba:
   - Address: `192.168.1.100`
   - Netmask: `255.255.255.0`
   - Gateway: `192.168.1.1`
   - DNS: `192.168.1.1, 8.8.8.8`
8. Guarde los cambios.
9. Apague y encienda la conexión cableada desde la misma ventana.

Después verifique en terminal:

```bash
ip addr
ping -c 4 192.168.1.1
```

## 8. Instalar Mosquitto en Ubuntu

Actualice la lista de paquetes:

```bash
sudo apt update
```

Instale el broker y los clientes de prueba:

```bash
sudo apt install mosquitto mosquitto-clients
```

Habilite el servicio para que arranque automáticamente:

```bash
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
```

Revise el estado:

```bash
sudo systemctl status mosquitto
```

Debe aparecer `active (running)`.

## 9. Configurar Mosquitto para aceptar clientes de la red

Para aprovechar el tiempo de clase, la práctica usará conexiones directas dentro de la red local del laboratorio. En esta configuración los clientes MQTT podrán conectarse al broker sin usuario ni contraseña.

Esta decisión simplifica la prueba inicial y permite concentrarse en red, topics, publicación y suscripción. Las recomendaciones de seguridad, autenticación y firewall se dejan en el [Anexo D](#19-anexo-d-seguridad-mqtt-y-firewall-en-ubuntu).

Abra un archivo nuevo:

```bash
sudo nano /etc/mosquitto/conf.d/laboratorio.conf
```

Escriba:

```conf
listener 1883 0.0.0.0
allow_anonymous true
```

Guarde con `Ctrl+O`, presione `Enter` y salga con `Ctrl+X`.

Reinicie Mosquitto:

```bash
sudo systemctl restart mosquitto
sudo systemctl status mosquitto
```

Verifique que escucha en el puerto `1883`:

```bash
ss -lntp | grep 1883
```

Debe observar una línea donde Mosquitto escucha en `0.0.0.0:1883` o en la IP del equipo.

## 10. Primera prueba local en Ubuntu

Abra dos terminales en Ubuntu.

En la terminal 1, suscríbase a un topic:

```bash
mosquitto_sub \
  -h localhost \
  -p 1883 \
  -t 'esp32/hello'
```

En la terminal 2, publique un mensaje:

```bash
mosquitto_pub \
  -h localhost \
  -p 1883 \
  -t 'esp32/hello' \
  -m 'hello from ubuntu'
```

La terminal 1 debe mostrar:

```text
hello from ubuntu
```

## 11. Prueba desde otro dispositivo conectado al router

Conecte otra computadora a la red `NOMBRE_DE_TU_RED` por Wi-Fi o por Ethernet.

Verifique que puede alcanzar al broker:

```bash
ping -c 4 192.168.1.100
```

Si la otra computadora también usa Ubuntu o Debian, instale los clientes:

```bash
sudo apt update
sudo apt install mosquitto-clients
```

Desde el cliente, publique:

```bash
mosquitto_pub \
  -h 192.168.1.100 \
  -p 1883 \
  -t 'esp32/hello' \
  -m 'hello from wifi client'
```

En el broker o en cualquier cliente suscrito al topic `esp32/hello` debe aparecer el mensaje.

Para suscribirse desde el cliente:

```bash
mosquitto_sub \
  -h 192.168.1.100 \
  -p 1883 \
  -t 'esp32/hello'
```

## 12. Conectar un broadcaster o dispositivo embebido

El procedimiento exacto depende del fabricante, pero el flujo general es el mismo.

### 12.1 Si el broadcaster usa Ethernet

1. Conecte el cable Ethernet entre el broadcaster y el router.
2. Entre a la interfaz de configuración del broadcaster, si tiene pantalla o página web.
3. Configure red por DHCP o asigne una IP manual dentro de la misma red, por ejemplo `192.168.1.120`.
4. Configure:
   - MQTT broker: `192.168.1.100`
   - MQTT port: `1883`
   - Username: sin usuario
   - Password: sin contraseña
   - Client ID: un nombre único, por ejemplo `broadcaster01`
5. Guarde cambios y reinicie el servicio o el equipo si se solicita.

### 12.2 Si el broadcaster usa Wi-Fi

1. En la configuración inalámbrica del broadcaster, seleccione la red `NOMBRE_DE_TU_RED`.
2. Escriba la contraseña Wi-Fi configurada en el router.
3. Espere a que obtenga IP.
4. Configure los datos MQTT:
   - Host: `192.168.1.100`
   - Port: `1883`
   - User: sin usuario
   - Password: sin contraseña
   - Topic de publicación: el indicado por la práctica, por ejemplo `broadcaster/status`.

### 12.3 Ejemplo ESP32: prender y apagar un LED por MQTT

Este ejemplo permite controlar un LED conectado a una ESP32 mediante mensajes MQTT enviados desde Ubuntu u otro cliente de la red. La ESP32 se conecta al Wi-Fi del laboratorio, se suscribe al topic correspondiente

Desde Ubuntu publique comandos hacia la ESP32:

```bash
mosquitto_pub -h 192.168.1.100 -p 1883 -t 'esp32/led' -m 'ON'
mosquitto_pub -h 192.168.1.100 -p 1883 -t 'esp32/led' -m 'OFF'
```

### 12.4 Prueba desde Ubuntu

Suscríbase a todos los topics del broadcaster:

```bash
mosquitto_sub \
  -h localhost \
  -p 1883 \
  -t 'broadcaster/#' \
  -v
```

El símbolo `#` significa todos los subtopics debajo de `broadcaster/`.

## 13. Uso opcional de Node-RED

Node-RED usa por defecto el puerto `1880`. No es el puerto MQTT; es la interfaz web de Node-RED. Puede servir para crear paneles gráficos o flujos de prueba que publiquen y reciban mensajes MQTT.

Si Node-RED está instalado en Ubuntu, acceda desde un navegador en la misma computadora:

```text
http://localhost:1880/
```

Desde otra computadora de la red:

```text
http://192.168.1.100:1880/
```

En la GUI de Node-RED:

1. Agregue un nodo `mqtt in`.
2. Configure el servidor MQTT como `192.168.1.100`.
3. Use el puerto `1883`.
4. Deje usuario y contraseña vacíos para esta práctica.
5. Conecte el nodo a un nodo `debug`.
6. Presione `Deploy`.
7. Publique un mensaje con `mosquitto_pub` y revise la pestaña `Debug`.

## 14. Diagnóstico de fallas comunes

### 14.1 No responde el router

Revise cable y dirección del gateway:

```bash
ip route
ping -c 4 192.168.1.1
```

Si no hay respuesta:

- Confirme que el cable esté conectado.
- Revise que la interfaz de red esté activa.
- Pruebe otro puerto LAN del router.
- Reinicie la conexión en Ubuntu.

### 14.2 El cliente no alcanza al broker

Desde el cliente:

```bash
ping -c 4 192.168.1.100
```

Si no responde:

- Verifique que ambos equipos estén en la misma red.
- Revise que Ubuntu conserve la IP `192.168.1.100`.
- Revise que el router no tenga aislamiento de clientes Wi-Fi activado.

### 14.3 El ping funciona pero MQTT no conecta

En Ubuntu:

```bash
sudo systemctl status mosquitto
ss -lntp | grep 1883
```

Posibles causas:

- Mosquitto no está corriendo.
- El archivo de configuración tiene errores.
- El cliente está usando usuario o contraseña aunque el broker de práctica acepta conexiones directas.
- El firewall bloquea el puerto `1883`, si se activó manualmente. Revise el [Anexo D](#19-anexo-d-seguridad-mqtt-y-firewall-en-ubuntu).

Revise los registros:

```bash
journalctl -u mosquitto -n 50 --no-pager
```

### 14.4 Probar el puerto desde otra computadora

Si tiene `nc` instalado:

```bash
nc -vz 192.168.1.100 1883
```

Una conexión exitosa indica que el puerto está abierto.

## 15. Buenas prácticas para el laboratorio

- Documente la IP asignada a cada equipo.
- No use la misma IP fija en dos dispositivos.
- Use nombres de cliente MQTT distintos.
- No publique credenciales reales en repositorios públicos.
- Use topics organizados, por ejemplo `grupo01/sensor/temperatura`.
- En una red institucional, pida autorización antes de conectar routers propios.
- Para producción, use autenticación robusta y cifrado TLS; esta práctica usa MQTT sin cifrado solo por claridad didáctica.

## 16. Anexo A: qué es una dirección IP y por qué se utiliza

Una dirección IP identifica a un dispositivo dentro de una red. Es similar a una dirección postal: permite que los datos lleguen al equipo correcto.

En IPv4, una IP tiene cuatro números separados por puntos:

```text
192.168.1.100
```

Cada número puede ir de `0` a `255`. La máscara de red indica qué parte de la dirección identifica a la red y qué parte identifica al equipo.

En este tutorial se usó:

```text
IP:      192.168.1.100
Máscara: 255.255.255.0
CIDR:    /24
```

Con `/24`, los primeros tres bloques identifican la red:

```text
Red:     192.168.1
Equipo: 100
```

Por eso los equipos `192.168.1.50`, `192.168.1.100` y `192.168.1.120` pueden comunicarse directamente si están conectados al mismo router y usan la misma máscara.

La puerta de enlace o gateway, por ejemplo `192.168.1.1`, es el equipo que permite salir hacia otras redes. Normalmente es el router.

## 17. Anexo B: minitutorial para ponchar un cable Ethernet

Para construir un cable Ethernet directo se recomienda el estándar T568B en ambos extremos.

### 17.1 Material

- Cable UTP categoría 5e o superior.
- Dos conectores RJ45.
- Pinzas ponchadoras.
- Pelacables o cutter.
- Probador de cable Ethernet.

### 17.2 Orden de colores T568B

Con el conector RJ45 viendo hacia usted, con la pestaña hacia abajo y los contactos metálicos hacia arriba, el orden de izquierda a derecha es:

```text
1. Blanco/naranja
2. Naranja
3. Blanco/verde
4. Azul
5. Blanco/azul
6. Verde
7. Blanco/café
8. Café
```

### 17.3 Procedimiento

1. Corte el cable a la longitud necesaria.
2. Retire aproximadamente 2 cm de cubierta exterior.
3. Desenrede y alinee los ocho conductores.
4. Ordene los colores según T568B.
5. Recorte las puntas para que queden parejas.
6. Inserte los conductores hasta el fondo del conector RJ45.
7. Verifique que cada cable llegue al frente del conector.
8. Inserte el conector en la pinza ponchadora.
9. Presione firmemente hasta completar el ponchado.
10. Repita el mismo orden T568B en el otro extremo.

### 17.4 Prueba del cable

Conecte ambos extremos al probador de cable. Las luces deben avanzar del `1` al `8` en el mismo orden. Si una luz no enciende o aparece cruzada, corte el conector y vuelva a ponchar ese extremo.

## 18. Anexo C: probar una conexión entre dos computadoras

Esta prueba permite confirmar que el cable y las interfaces Ethernet funcionan aún sin router.

### 18.1 Computadora A

Configure IP manual:

```bash
sudo nmcli con add \
  con-name prueba-directa-a \
  type ethernet \
  ifname enp7s0 \
  ipv4.method manual \
  ipv4.addresses 192.168.10.1/24 \
  ipv6.method ignore
```

Active:

```bash
sudo nmcli con up prueba-directa-a
```

### 18.2 Computadora B

Configure IP manual:

```bash
sudo nmcli con add \
  con-name prueba-directa-b \
  type ethernet \
  ifname enp7s0 \
  ipv4.method manual \
  ipv4.addresses 192.168.10.2/24 \
  ipv6.method ignore
```

Active:

```bash
sudo nmcli con up prueba-directa-b
```

### 18.3 Prueba de comunicación

Desde la computadora A:

```bash
ping -c 4 192.168.10.2
```

Desde la computadora B:

```bash
ping -c 4 192.168.10.1
```

Si ambos pings responden, el enlace físico y la configuración IP funcionan.

Para regresar a la red del laboratorio, desactive la conexión de prueba y active la conexión normal:

```bash
sudo nmcli con down prueba-directa-a
sudo nmcli con up mqtt-lan
```

En la otra computadora use el nombre de conexión que corresponda.

## 19. Anexo D: seguridad MQTT y firewall en Ubuntu

La configuración principal del tutorial acepta conexiones directas para facilitar la práctica en clase. Esa configuración debe usarse únicamente en una red local controlada, porque cualquier equipo conectado a la misma red puede publicar o suscribirse al broker.

Para una práctica extendida o una red compartida, combine autenticación MQTT y reglas de firewall.

### 19.1 Activar usuario y contraseña en Mosquitto

Edite el archivo de configuración:

```bash
sudo nano /etc/mosquitto/conf.d/laboratorio.conf
```

Cambie el contenido por:

```conf
listener 1883 0.0.0.0
allow_anonymous false
password_file /etc/mosquitto/passwd
```

Cree un usuario MQTT:

```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd mqttuser
```

Use una contraseña de laboratorio acordada por el profesor. Reinicie Mosquitto:

```bash
sudo systemctl restart mosquitto
sudo systemctl status mosquitto
```

Con autenticación activada, los comandos de prueba deben incluir usuario y contraseña:

```bash
mosquitto_sub \
  -h 192.168.1.100 \
  -p 1883 \
  -u mqttuser \
  -P 'contraseña_de_laboratorio' \
  -t 'esp32/hello'
```

### 19.2 Revisar el firewall de Ubuntu

Si Ubuntu usa `ufw`, revise su estado:

```bash
sudo ufw status
```

Si está activo y desea permitir MQTT desde la red local, habilite el puerto `1883/tcp`:

```bash
sudo ufw allow 1883/tcp
sudo ufw reload
sudo ufw status
```

Si también usará Node-RED desde otras computadoras, permita el puerto `1880/tcp`:

```bash
sudo ufw allow 1880/tcp
```

En una red institucional, confirme estas reglas con el responsable de red antes de aplicarlas.

## 20. Referencias adicionales

- Eclipse Mosquitto: https://mosquitto.org/
- Documentación de Mosquitto: https://mosquitto.org/documentation/
- MQTT Version 5.0, OASIS Standard: https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html
- Ubuntu NetworkManager: https://help.ubuntu.com/community/NetworkManager
