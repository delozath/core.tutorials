import network
import utime
from umqtt.simple import MQTTClient

class _connection:
    def __init__(self):
        self._connect()
    
    def _connect(self):
        SSID = "NOMBRE_DE_TU_RED"
        PASSWORD = "CAMBIA_ESTA_CLAVE"
        #
        wifi = network.WLAN(network.STA_IF)
        wifi.active(True)
        wifi.connect(SSID, PASSWORD)
        while not wifi.isconnected():
            print("Conectando a WiFi...")
            utime.sleep(1)
        #
        print("Conexión WiFi exitosa!")
        print("Dirección IP:", wifi.ifconfig()[0])
        self.wifi = wifi
#
class mqtt_driver(_connection):
    def __init__(self, BROKER):
        super().__init__()
        self.BROKER = BROKER
        #
        self._connect_broker()
    #
    def _connect_broker(self):
        _client = MQTTClient("esp32_client", self.BROKER)
        try:
            _client.connect()
            print("Conectado al broker MQTT")
            self.client = _client
        #
        except Exception as e:
            print("Error al conectar al broker:", e)
#
def main(BROKER, TOPIC):
    mqtt = mqtt_driver(BROKER)
    n = 0
    while True:
        msg = f"Iteración {n}:--> Hola desde ESP32"
        mqtt.client.publish(TOPIC, msg)
        print("Mensaje enviado:", msg)
        utime.sleep(5)
        n += 1

#
if __name__=='__main__':
    TOPIC = "esp32/hello"
    BROKER = "192.168.1.100"
    main(BROKER, TOPIC)
