// #include <MsTimer2.h> // Extrict control time library

/*====================================================================================== 
  ==================== PINS ============================================================
  ======================================================================================*/
const int solenoidPin = 22; // Ouputpin for close circuit on transistor
const int lickmeterPin = 3;  // Input pin for touch state
const int dig2Intan = 50; // this is giving a HIGH for when the click comes out 

/*===================================================================================== 
  ==================== SETTINGS ========================================================
  ======================================================================================*/
int rewardPosition = 0; // from 0 to 100
int caudal = 100; // in ms LK: is this the opening time of the solenoid? extend for bigger water reward 
int in_sms; // position from unity
int prev_in_sms; //  previous position from unity
int lickmeterState = 0; 
int checkpoint = 0;
int unityStarted = 0; 
int analogValue = 0;

unsigned long timePrev = 0;
unsigned long timeNow = 0;
unsigned long timeInterval = 2500; // minimum time interval between water rewards

void setup() {
  Serial.begin(9600);
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(solenoidPin, OUTPUT); // set pin as OUTPUT
  pinMode(dig2Intan, OUTPUT); // set pin as OUTPUT
  digitalWrite(solenoidPin, LOW); // OFF
  digitalWrite(dig2Intan, LOW); // OFF
    
  pinMode(lickmeterPin, INPUT);
}


void loop() {

timeNow = millis();



if (Serial.available() > 0) {
    in_sms = Serial.read();
    analogValue = (in_sms*2)+30;
        }

 

        
if (in_sms == 75){
  checkpoint = 1;
}
        

//&& (timeNow - timePrev >= timeInterval)
   
  if (prev_in_sms != in_sms){
    // update voltage position in DAC output
     analogWrite(DAC0,analogValue);
    if (in_sms == rewardPosition && checkpoint == 1 ){
      digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
      digitalWrite(solenoidPin, HIGH); // ON
      digitalWrite(dig2Intan, HIGH); // ON
      delay(caudal); // change this for extension of water reward
      digitalWrite(solenoidPin, LOW); // OFF
      digitalWrite(dig2Intan, LOW); // OFF
      //delay(100);
      digitalWrite(LED_BUILTIN, LOW);   // turn the LED on (HIGH is the voltage level)
      checkpoint = 0;
      timePrev = timeNow;
      }
      
  }
 analogValue = 0;

//  Serial.print("trial: ");
 //   Serial.println(in_sms);

  
  prev_in_sms = in_sms;
/*
  lickmeterState = digitalRead(lickmeterPin);
  if (lickmeterState == HIGH) {
    digitalWrite(LED_BUILTIN, HIGH);
  } else {
    digitalWrite(LED_BUILTIN, LOW);
  }
*/
}
