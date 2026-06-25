import machine  
import network
import utime
from umqtt.simple import MQTTClient
#
#
class _connection:
    def __init__(self):
        self._connect()
    #
    def _connect(self):
        SSID = "NOMBRE RED"
        PASSWORD = "CONTRASEÑA"
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
#
class subscription:
    def __init__(self, client):
        self.client = client
    #
    def add(self, topic, func):
        self.client.set_callback(func)
        self.client.subscribe(topic)
        print(f"Suscrito a topic {topic}")
#
#
class mqtt_driver(_connection):
    def __init__(self, BROKER):
        super().__init__()
        self.BROKER = BROKER
        #
        self._connect_broker()
        self.led = machine.Pin(25, machine.Pin.OUT)
        self.led.value(1)
    #
    def _connect_broker(self):
        _client = MQTTClient("esp32_client_de_SU_NOMBRE", self.BROKER)
        try:
            _client.connect()
            print("Conectado al broker MQTT")
            self.client = _client
        #
        except Exception as e:
            print("Error al conectar al broker:", e)
    #
    def led_driver(self, topic):
        subs = subscription(self.client)
        subs.add(topic, self._ctrl_led)
    #
    def _ctrl_led(self, topic, msg):
        code = msg.decode()
        print(f"Mensaje recibido ->\n\tTopic: {topic.decode()}, Mensaje: {code}")
        if code == "ON":
            self.led.value(0)  
            print("\tLED encendido")
        #
        elif code == "OFF":
            self.led.value(1)  
            print("\tLED apagado")
        #
        else:
            self.led.value(1)  
            print("\tLED reset")  
#
#
def main(BROKER, TOPIC):
    mqtt = mqtt_driver(BROKER)
    mqtt.led_driver("esp32/led")
    #
    n = 0
    while True:
        utime.sleep(1)
        try:
            mqtt.client.check_msg()  
        #
        except Exception as e:
            print("Error:", e)
        #
        else:
            msg = f"{n}:--> ESP32 de SU NOMBRE conectada"
            mqtt.client.publish(TOPIC, msg)
            print("Mensaje enviado:", msg)
            n += 1
#
#
if __name__=='__main__':
    TOPIC = "esp32/hello"
    BROKER = "192.168.1.100"
    main(BROKER, TOPIC)

