#include <SdFat.h>
#include <SdFatUtil.h>

const long LOG_INTERVAL = 20 * 1000;

const int SD_PIN = 10;
const int LM35_PIN = 0;
const int ANALOG_PIN_RES = 1024;
const float INPUT_VOLTAGE = 5.0;
const float LM35_RES = 0.01;

const int DISP_B1 = 7;
const int DISP_C1 = 6;
const int DISP_A2 = 3;
const int DISP_B2 = 2;
const int DISP_C2 = A4;
const int DISP_D2 = A3;
const int DISP_E2 = A2;
const int DISP_F2 = 5;
const int DISP_G2 = 4;

Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;
long start;

void setup() {
  Serial.begin(9600);
  Serial.println();
  Serial.println("Booting up...");

  initDisp();
  initSd();
  findUniqueFilename();

  start = millis();
}

void loop() {
  float voltageReading = analogRead(LM35_PIN) * INPUT_VOLTAGE / ANALOG_PIN_RES;
  float temp = voltageReading / LM35_RES;

  dispData(temp);
  transmitData(now(), temp);

  delay(LOG_INTERVAL - (now() % LOG_INTERVAL));
}

void initDisp() {
  pinMode(DISP_B1, OUTPUT);
  pinMode(DISP_C1, OUTPUT);
  pinMode(DISP_A2, OUTPUT);
  pinMode(DISP_B2, OUTPUT);
  pinMode(DISP_C2, OUTPUT);
  pinMode(DISP_D2, OUTPUT);
  pinMode(DISP_E2, OUTPUT);
  pinMode(DISP_F2, OUTPUT);
  pinMode(DISP_G2, OUTPUT);
  clearDisp();
  digitalWrite(DISP_G2, LOW);
}

void clearDisp() {
  digitalWrite(DISP_B1, HIGH);
  digitalWrite(DISP_C1, HIGH);
  digitalWrite(DISP_A2, HIGH);
  digitalWrite(DISP_B2, HIGH);
  digitalWrite(DISP_C2, HIGH);
  digitalWrite(DISP_D2, HIGH);
  digitalWrite(DISP_E2, HIGH);
  digitalWrite(DISP_F2, HIGH);
  digitalWrite(DISP_G2, HIGH);
}

void initSd() {
  pinMode(SD_PIN, OUTPUT);

  bool success = false;
  while (!success) {
    success = card.init();
    if (!success) {
      error("initSd() -> Sd2Card.init()\nRetrying in two seconds...", false);
      delay(2 * 1000);
    }
  }

  if (!volume.init(card)) error("initSd() -> SdVolume.init(Sd2Card)", true);
  if (!root.openRoot(volume)) error("initSd() -> SdFile.openRoot(SdVolume)", true);
}

void findUniqueFilename() {
  char filename[] = "log000.txt";
  for (int i = 0; i < 1000; ++i) {
    filename[3] = i / 100 + '0';
    filename[4] = i % 100 / 10 + '0';
    filename[5] = i % 10 + '0';
    if (file.open(root, filename, O_CREAT | O_EXCL | O_WRITE | O_APPEND)) {
      Serial.println("Opening file: " + String(filename));
      return;
    }
  }
  error ("findUniqueFilename() -> SdFile.open(SdFile, char*, uint8_t)", true);
}

void dispData(float temp) {
  int t = round(temp);
  clearDisp();
  if (t < 0) {
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_E2, LOW);
    digitalWrite(DISP_F2, LOW);
    return;
  }
  if (t > 19) {
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_E2, LOW);
    digitalWrite(DISP_F2, LOW);
    digitalWrite(DISP_G2, LOW);
    return;
  }
  if (t > 9 && t < 20) {
    digitalWrite(DISP_B1, LOW);
    digitalWrite(DISP_C1, LOW);
    t -= 10;
  }
  switch(t) {
  case 0:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_E2, LOW);
    digitalWrite(DISP_F2, LOW);
    break;
  case 1:
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    break;
  case 2:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_E2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  case 3:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  case 4:
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_F2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  case 5:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_F2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  case 6:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_E2, LOW);
    digitalWrite(DISP_F2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  case 7:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    break;
  case 8:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_D2, LOW);
    digitalWrite(DISP_E2, LOW);
    digitalWrite(DISP_F2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  case 9:
    digitalWrite(DISP_A2, LOW);
    digitalWrite(DISP_B2, LOW);
    digitalWrite(DISP_C2, LOW);
    digitalWrite(DISP_F2, LOW);
    digitalWrite(DISP_G2, LOW);
    break;
  default:
    digitalWrite(DISP_G2, LOW);
  }
}

//void activateSegments(...) {
//  va_list vl;
//  
//}

void transmitData(long now, float temp) {
  long s = now / 1000;
  long m = s / 60;
  long h = m / 60;
  s %= 60;
  m %= 60;

  char data[30];
  sprintf(data, "%.2ld:%.2ld:%.2ld, %d\n", h, m, s, round(temp));

  transmit(data);
}

long now() {
  return millis() - start;
}

void transmit(String s) {
  Serial.print(s);
  file.print(s);
  if (!file.sync()) error("transmit(String) -> SdFile.sync()", false);
}

void error(String s, bool halt) {
  Serial.println("ERROR: " + s);
  if (halt)
    while(1);
}




