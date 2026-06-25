import machine  
import network
import utime
from umqtt.simple import MQTTClient


class _Connection:
    def __init__(self):
        # en el entorno real en un .env en Hash AES
        # load_env
        pass
    
    @classmethod
    def connect(cls):
        SSID = "NOMBRE_DE_TU_RED"
        PASSWORD = "CAMBIA_ESTA_CLAVE"
        
        wifi = network.WLAN(network.STA_IF)
        wifi.active(True)
        wifi.connect(SSID, PASSWORD)
        while not wifi.isconnected():
            print("Conectando a WiFi...")
            utime.sleep(1)
        
        print("Conexión WiFi exitosa!")
        print("Dirección IP:", wifi.ifconfig()[0])
        cls.wifi = wifi
        return cls

class Subscription:
    def __init__(self, client):
        self.client = client
    
    @classmethod
    def add(cls, client, topic, func):
        inst = cls(client)
        inst.client.set_callback(func)
        inst.client.subscribe(topic)
        print(f"Suscrito a topic {topic}")
        return cls


class DriverMQTT:
    def __init__(self, BROKER):
        self.conn = _Connection.connect()
        self.BROKER = BROKER
        
        self._connect_broker()
        self.led = machine.Pin(25, machine.Pin.OUT)
        self.led.value(1)

        self.suscriptions = []
    
    def _connect_broker(self):
        _client = MQTTClient("esp32_client", self.BROKER)
        try:
            _client.connect()
            print("Conectado al broker MQTT")
            self.client = _client
        
        except Exception as e:
            print("Error al conectar al broker:", e)
    
    def led_driver(self, topic):
        self.suscriptions.append(
            Subscription.add(self.client, topic, self._callback)
        )
    
    def _callback(self, topic, msg):
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

def main(BROKER, TOPIC):
    mqtt = DriverMQTT(BROKER)
    mqtt.led_driver("esp32/led")
    
    n = 0
    while True:
        utime.sleep(1)
        try:
            mqtt.client.check_msg()  
        
        except Exception as e:
            print("Error:", e)
        
        else:
            msg = f"{n}:--> ESP32 conectada"
            mqtt.client.publish(TOPIC, msg)
            print("Mensaje enviado:", msg)
            n += 1

if __name__=='__main__':
    TOPIC = "esp32/hello"
    BROKER = "192.168.1.100"
    main(BROKER, TOPIC)
