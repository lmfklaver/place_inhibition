
 #include <string.h> 
 int ofpin = 25; // Arduino Digital Output pin that goes to CED and Intan
 String digiValue;

void setup() {
  // put your setup code here, to run once:
   Serial.begin(9600);
   pinMode(ofpin,OUTPUT);
   digitalWrite(ofpin,LOW);
}

void loop() {

  while (Serial.available()) {
    //read logical string output from bonsai (True or False)
      digiValue = Serial.readStringUntil('\n'); 
    // define a character as the first letter in the string (T or F)
      char chr_digiValue = digiValue[0];
    // if True, turn pin High
      if(chr_digiValue == 'T') {
        digitalWrite(ofpin, HIGH);
      }
    //if False, turn pin Low
      else {
        digitalWrite(ofpin, LOW);
      }
      digiValue = "";
  }
  // We create pulses in our graphical editor in Spike2 (if High, stim 300ms, wait until Low again, wait an additional # sec, repeat)
}
