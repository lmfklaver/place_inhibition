static int outLPin = 12 ; // choose the pin for the left solenoid
static int outRPin = 11; // choose the pin for the right solenoid
static int outStim = 10;  // output pin for stim location
static int inLPin = 7;   // choose the input pin for left semsor
static int inRPin = 6;   // choose the input pin for right semsor
static int inStim = 4;   // input pin for stim location

static boolean ON = HIGH;
static boolean OFF = !ON;

int durL = 60; // duration left solenoid opens
int durR = 60; // duration right solenoid opens
int durStim = 60; //duration stim is on

boolean left = 0;     // variable for reading the pin status
boolean right = 0;
boolean conda = 0;

boolean nextLeft = 1;
boolean nextRight = 0;

byte next = outLPin;

void setup() {
 
  pinMode(outLPin, OUTPUT);  // declare left solenoid pin as output
  pinMode(outRPin, OUTPUT);  // declare right solenoid pin as output
  pinMode(outStim, OUTPUT);  // declare stim output pin as output
  pinMode(inLPin, INPUT);    // declare left sensor as input
  pinMode(inRPin, INPUT);    // declare right sensor as input
  pinMode(inStim, INPUT);    // declare stim input as input
  digitalWrite(outLPin, HIGH); // turn solenoids OFF
  digitalWrite(outRPin, HIGH);  // turn solenoids OFF
  digitalWrite(outStim, HIGH);
  pinMode(inLPin, INPUT_PULLUP);    // declare left sensor as input
  pinMode(inRPin, INPUT_PULLUP);    // declare right sensor as input
  pinMode(inStim, INPUT_PULLUP);
}

void loop(){
  if (next == outRPin){
    left = digitalRead(inLPin);  // read input value
    right = digitalRead(inRPin);  // read input value
    
   
    if (right == ON && left == OFF) {         // check if the input is HIGH (button released)
      digitalWrite(next, HIGH);  // turn LED ON
      delay(durR);
      digitalWrite(next, LOW);
      next = outLPin;
    } else {
      digitalWrite(next, LOW);  // turn LED OFF
    }
  } else {
    left = digitalRead(inLPin);  // read input value
    right = digitalRead(inRPin);  // read input value
    
    
    
    
    if (left == ON && right == OFF) {         // check if the input is HIGH (button released)
      digitalWrite(next, HIGH);  // turn LED ON
      delay(durL);
      digitalWrite(next, LOW);
      next = outRPin;
    } else {
      digitalWrite(next, LOW);  // turn LED OFF
      
    conda = digitalRead(inStim); 
    if (conda == ON){
    digitalWrite(outStim, LOW); // turn on stim
    delay(durStim);
    digitalWrite(outStim, LOW); // turn off stim
    }else{
    digitalWrite(outStim, HIGH);
    }
    
    }
      
    }  
  }
