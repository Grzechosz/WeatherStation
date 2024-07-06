# Projekt i architektura


## Opis
Projekt polegał na stworzeniu systemu monitorującego warunki środowiskowe, pomagające utrzymać rośliny w dobrej kondycji. System składa się z Raspberry Pi pełniącego rolę Access Pointa, który zbiera dane z dwóch ESP32, a następnie wysyła je do chmurowej bazy danych. Mikrokontrolery odczytują parametry środowiska za pomocą sensorów: czujnika wilgotności gleby, wilgotności otoczenia, temperatury oraz światła. Komunikacja między węzłami realizowana jest za pomocą Protocol Buffers. Zebrane dane mogą być wizualizowane z wykorzystaniem aplikacji mobilnej. Funkcję bazy danych pełni Firebase, przy wykorzystaniu usług Firestore (baza danych NOSQL) i Storage (przechowywanie zdjęć roślin).

## Uproszczona architektura systemu:
![architecture](https://github.com/Burakmeister/GardenControl/blob/master/architecture.png?raw=true)


# Zastosowane urządzenia oraz kody źródłowe


## Raspberry Pi
Głównym zadaniem Raspberry Pi w projekcie było pełnienie funkcji Access Pointa, do którego łączyły się poszczególne mikrokontrolery. Komunikacja między ESP32, a Raspberry Pi odbywała się z użyciem Protocol Buffers. Kod źródłowy 1. przedstawia realizację serwera komunikacyjnego w języku Python. Dane zebrane z czujników przesyłane są do chmurowej bazy danych, używając połączenia przewodowego.

## ESP32
Mikrokontrolery ESP32 służyły analizie danych przesłanych z czujników i przekształcenie ich do docelowej formy. Łączyły się one do Access Pointa, następnie dane przesyłane były co 30 minut do serwera na Raspberry Pi. Kod źródłowy 2. przedstawia realizację tych zadań.

Kod źródłowy 1. Kod z Raspberry Pi
```python
import socket
import protocol_pb2
import firebase_admin
from google.cloud import firestore
from firebase_admin import credentials
from datetime import datetime
import os

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "key.json"

cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.Client()
collection = db.collection("sensors")
sensors = collection.get()

server_address = ('0.0.0.0', 8080)
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(server_address)
server_socket.listen(2)

print("Waiting for ESP32 to connect...")

while True:
  client_socket, client_address = server_socket.accept()
  print("ESP32 device connected:", client_address)

  received_data = client_socket.recv(1024)
  if received_data:
    sensor_data = protocol_pb2.SensorData()
    sensor_data.ParseFromString(received_data)
    new_reading = {
      "temperature": round(sensor_data.temperature, 1),
      "light": sensor_data.percentLight,
      "soil_moisture": sensor_data.percentMoisture,
      "humidity": round(sensor_data.percentHumidity, 1)
      "time": datetime.now()
    }
  doc = collection.document(str(sensor_data.id))
  if doc.get().exists:
    doc.collection("readings").document(str(datetime.timestamp(datetime.now()))).set(new_reading)
    client_socket.close()
server_socket.close()
```


Kod źródłowy 2. Kod z ESP32
```C
#include <WiFi.h>
#include "pb_common.h"
#include "pb.h"
#include "pb_encode.h"
#include "protocol.pb.h"
#include <DHT.h>
#define DHT_SENSOR_PIN 23
#define DHT_SENSOR_TYPE DHT11
#define LIGHT_SENSOR_PIN 36
#define SOIL_MOISTURE_SENSOR_PIN 39

const char* ssid = "burak";
const char* password = "burakburak";
const char* serverAddress = "192.168.4.1"; const int espId = 2;
WiFiClient client;
DHT dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);

void sendSensorData(float temperature, float humidity, int light, int percentMoisture) {
  SensorData data = SensorData_init_zero;
  data.temperature = temperature;
  data.percentHumidity = humidity;
  data.percentLight = light;
  data.percentMoisture = percentMoisture;
  data.id = espId;
  // Serializacja komunikatu
  uint8_t buffer[128]; // Bufor na dane
  pb_ostream_t stream = pb_ostream_from_buffer(buffer, sizeof(buffer));
  pb_encode(&stream, SensorData_fields, &data);
  if (client.connect(serverAddress, 8080)) {
    client.write(buffer, stream.bytes_written); client.stop();
  } else {
    Serial.println("Failed to connect to server");
  }
}

void setup() {
  Serial.begin(115200);
  dht_sensor.begin();
  // Połączenie z siecią WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

void loop() {
  int analogValueLight = analogRead(LIGHT_SENSOR_PIN);
  int analogValueSoilMoisture = analogRead(SOIL_MOISTURE_SENSOR_PIN);
  int percentMoisture = (100-((analogValueSoilMoisture/4095.00)*100));
  float humi = dht_sensor.readHumidity();
  float tempC = dht_sensor.readTemperature();
  int percentLight = ( 100 - ( (analogValueLight/4095.00) * 100 ));

  // Wysłanie pomiarów
  sendSensorData(tempC, humi, percentLight, percentMoisture);
  delay(1800000); // Poczekaj 30 minut przed wysłaniem kolejnych pomiarów
}
```


## Wykorzystane czujniki


Rezystencyjny czujnik światła – przedstawiony na rysunku 1. wyposażony w 4 wyprowadzenia:
  VCC – napięcie zasilania z zakresu: 3.3V do 5V 
  GND – masa układu
  DO – wyjście cyfrowe, aktywne przy wysokim natężeniu światła 
  AO – wyjście analogowe

![light sensor](https://github.com/Burakmeister/GardenControl/blob/master/light_sensor.png?raw=true)

Rysunek 1. Rezystencyjny czujnik światła



Czujnik temperatury i wilgotności DHT11 – przedstawiony na rysunku 2. wyposażony w 3 wyprowadzenia:
  VCC – napięcie zasilania z zakresu: 3V do 5.5V 
  GND – masa układu
  DATA – wyjście cyfrowe

![temperature and humadity sensor](https://github.com/Burakmeister/GardenControl/blob/master/temperature_sensor.png?raw=true)

Rysunek 2. Czujnik temperatury i wilgotności



Czujnik wilgotności gleby – przedstawiony na rysunku 3., z podłączoną sondą z rysunku 4. wyposażony w 5 wyprowadzeń: 
  VCC – napięcie zasilania z zakresu: 3.3V do 5V
  GND – masa układu
  DO – wyjście cyfrowe, aktywne przy wysokim natężeniu światła 
  AO – wyjście analogowe
  Pozostałe 2 wyprowadzenia służące do połączenia z sondą

![soil moisture sensor](https://github.com/Burakmeister/GardenControl/blob/master/soil_moisture_sensor.png?raw=true)

Rysunek 3. Czujnik wilgotności gleby



![probe](https://github.com/Burakmeister/GardenControl/blob/master/probe.png?raw=true)

Rysunek 4. Sonda do pomiaru wilgotności gleby



# Aplikacja mobilna


## Opis
Aplikacja mobilna zaprojektowana została do monitorowania warunków roślin w czasie rzeczywistym. Wyświetla odczyty z czujników w postac interaktywnych wykresów. Pozwala przeglądać dane historyczne, aby śledzić zmiany w czasie. Intuicyjne przyciski umożliwiają szybkie przełączanie się między parametrami pomiarowymi. Daje również możliwość dodawania nowych roślin wraz z ich zdjęciami.


## Prezentacja
Rysunek 5. prezentuje widok listy roślin (po lewej stronie), zawierający kafelki prezentujące zdjęcia oraz nazwy. Na dole znajduje się przycisk Add, przenoszący do strony umożliwiającej dodanie do bazy danych nowej rośliny (po prawej stronie), przytrzymując kafelek można ją usunąć. Po wybraniu interesującego nas kwiatka, przechodzimy do odczytów z czujników (Rysunek 6.). Na tym widoku widnieją przyciski z informacją o ostatnim odczycie, służące do przełączania wykresów. W prawym górnym rogu ekranu znajduje się przycisk umożliwiający usunięcie historii odczytów z bazy danych.


![plants page and adding page](https://github.com/Burakmeister/GardenControl/blob/master/list_and_adding.png?raw=true)

Rysunek 5. Lista i opcja dodawania roślin


![readings page](https://github.com/Burakmeister/GardenControl/blob/master/readings_page.png?raw=true)

Rysunek 6. Odczyty z czujników


# Wnioski
## Trudności
Największą trudność stanowiło wygenerowanie plików dla Protocol Buffers. Wersja programu służącego do ich generowania musiała być identyczna dla języka Python i dla Arduino. Niektóre wersje miały problemy z kompatybilnością po stronie Raspberry Pi. Kolejnym problemem była odpowiednia implementacja wykresów live w aplikacji mobilnej, generowały one dużo błędów. Łączenie aplikacji z Firebase było stosunkowo proste, dzięki dobrej dokumentacji. Do obsługi sensora temperatury i wilgotności potrzebna była dedykowana biblioteka. Czujniki wilgotności gleby i światła miały odwrócone wartości na wyjściu analogowym, trzeba było je więc odpowiednio przekształcić.

## Przyszłość projektu
Sonda dołączona do sensora wilgotności gleby jest słabej jakości i zaczęła korodować już po dwóch tygodniach testów, należałoby ją zmienić lub zaprojektować własną. W przyszłości należałoby wprowadzić do urządzenia wodoodporną obudowę, gdyż w łatwy sposób można je uszkodzić. Aby udostępnić system innym użytkownikom, trzeba by dodać funkcję logowania i generowanie unikatowego identyfikatora dla każdego z czujników.
