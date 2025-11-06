#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>

// ===== إعداد بيانات الشبكة =====
#define WIFI_SSID "DEV"
#define WIFI_PASSWORD "12345678"

// ===== إعداد Firebase =====
// ⚠️ اكتب هنا رابط مشروعك بدون https://
#define FIREBASE_HOST "https://smarthealthemergency-ccf39-default-rtdb.europe-west1.firebasedatabase.app/"
#define FIREBASE_AUTH "gMmD6iZORFpmEODPljnYJe0wvgtgjhcFOx5VWLyb"

// ===== إنشاء الكائنات =====
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

int pulsePin = A0; // مدخل حساس النبض

void setup() {
  Serial.begin(9600);

  // ===== الاتصال بالواي فاي =====
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");

  // ===== إعداد Firebase =====
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  int pulseValue = analogRead(pulsePin);
  Serial.print("Pulse: ");
  Serial.println(pulseValue);

  // ===== رفع القراءة إلى Firebase =====
  if (Firebase.setInt(fbdo, "/patient1/pulse", pulseValue)) {
    Serial.println("Uploaded successfully!");
  } else {
    Serial.print("Error: ");
    Serial.println(fbdo.errorReason());
  }

  delay(2000); // تحديث كل ثانيتين
}
