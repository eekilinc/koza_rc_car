/*
 * RC Car Controller Arduino Sketch for HC-06 Bluetooth Module
 * 
 * This sketch controls a two-wheel RC car (or tank) using Bluetooth
 * commands received from the Flutter mobile application.
 * 
 * Hardware Setup:
 * - HC-06 Bluetooth Module:
 *   - VCC -> 5V
 *   - GND -> GND
 *   - TX -> Arduino RX (Pin 0) or Software Serial
 *   - RX -> Arduino TX (Pin 1) or Software Serial
 * 
 * - Motor Driver (L298N or similar):
 *   - IN1 -> Arduino Pin 5
 *   - IN2 -> Arduino Pin 6
 *   - IN3 -> Arduino Pin 9
 *   - IN4 -> Arduino Pin 10
 *   - GND -> Arduino GND
 *   - +5V -> Arduino 5V (or separate power)
 * 
 * Default Commands:
 * - 'F' or 'f' = Forward
 * - 'B' or 'b' = Backward
 * - 'L' or 'l' = Left (Turn left or strafe left)
 * - 'R' or 'r' = Right (Turn right or strafe right)
 * - 'S' or 's' = Stop
 */

#include <SoftwareSerial.h>

// Software Serial for HC-06 (RX, TX)
// Adjust pins if using different Arduino
SoftwareSerial hc06(8, 7); // RX on pin 8, TX on pin 7

// Motor control pins
const int motor1Pin1 = 5;  // Left motor direction 1
const int motor1Pin2 = 6;  // Left motor direction 2
const int motor2Pin1 = 9;  // Right motor direction 1
const int motor2Pin2 = 10; // Right motor direction 2

// Extra control pins
const int ledPin = 11;      // LED light
const int hornPin = 12;     // Buzzer/Horn
const int speedPin = 3;     // PWM for speed control (use PWM-capable pin)

// Motor speed (PWM value: 0-255)
int motorSpeed = 255; // Maximum speed (can be changed dynamically)

void setup() {
  // Initialize serial communication with computer (for debugging)
  Serial.begin(9600);
  
  // Initialize software serial for HC-06 (baud rate: 9600)
  hc06.begin(9600);
  
  // Set motor pins as outputs
  pinMode(motor1Pin1, OUTPUT);
  pinMode(motor1Pin2, OUTPUT);
  pinMode(motor2Pin1, OUTPUT);
  pinMode(motor2Pin2, OUTPUT);
  
  // Set extra control pins as outputs
  pinMode(ledPin, OUTPUT);
  pinMode(hornPin, OUTPUT);
  pinMode(speedPin, OUTPUT);
  
  // Initial states
  digitalWrite(ledPin, LOW);    // LED off
  digitalWrite(hornPin, LOW);   // Horn off
  
  // Stop motors initially
  stopMotors();
  
  Serial.println("RC Car Controller Initialized");
  Serial.println("Waiting for Bluetooth commands...");
}

void loop() {
  // Check if data is available from HC-06
  if (hc06.available()) {
    String command = "";
    
    // Read the complete command
    while (hc06.available()) {
      command += (char)hc06.read();
      delay(2); // Small delay to ensure complete command reading
    }
    
    Serial.print("Received command: ");
    Serial.println(command);
    
    // Process the command
    processCommand(command);
  }
}

void processCommand(String cmd) {
  // Remove any whitespace
  cmd.trim();
  
  // Movement commands (single character)
  if (cmd.length() == 1) {
    char moveCmd = tolower(cmd[0]);
    switch(moveCmd) {
      case 'f':  // Forward
        moveForward();
        break;
      case 'b':  // Backward
        moveBackward();
        break;
      case 'l':  // Left
        turnLeft();
        break;
      case 'r':  // Right
        turnRight();
        break;
      case 's':  // Stop
        stopMotors();
        break;
    }
  }
  // LED Control (L0 = OFF, L1 = ON)
  else if (cmd.startsWith("L")) {
    String value = cmd.substring(1);
    if (value == "0") {
      digitalWrite(ledPin, LOW);
      Serial.println("LED turned OFF");
    } else if (value == "1") {
      digitalWrite(ledPin, HIGH);
      Serial.println("LED turned ON");
    }
  }
  // Speed Control (V000-V255)
  else if (cmd.startsWith("V")) {
    String speedStr = cmd.substring(1);
    int speed = speedStr.toInt();
    
    if (speed >= 0 && speed <= 255) {
      motorSpeed = speed;
      Serial.print("Motor speed set to: ");
      Serial.println(motorSpeed);
    }
  }
  // Horn Control (H1 = activate)
  else if (cmd == "H1") {
    activateHorn();
  }
  else {
    Serial.print("Unknown command: ");
    Serial.println(cmd);
  }
}

void moveForward() {
  // Left motor forward
  analogWrite(motor1Pin1, motorSpeed);
  analogWrite(motor1Pin2, 0);
  
  // Right motor forward
  analogWrite(motor2Pin1, motorSpeed);
  analogWrite(motor2Pin2, 0);
  
  Serial.println("Moving Forward");
}

void moveBackward() {
  // Left motor backward
  analogWrite(motor1Pin1, 0);
  analogWrite(motor1Pin2, motorSpeed);
  
  // Right motor backward
  analogWrite(motor2Pin1, 0);
  analogWrite(motor2Pin2, motorSpeed);
  
  Serial.println("Moving Backward");
}

void turnLeft() {
  // Left motor stop/slow
  analogWrite(motor1Pin1, 0);
  analogWrite(motor1Pin2, 0);
  
  // Right motor forward (to turn left)
  analogWrite(motor2Pin1, motorSpeed);
  analogWrite(motor2Pin2, 0);
  
  Serial.println("Turning Left");
}

void turnRight() {
  // Left motor forward (to turn right)
  analogWrite(motor1Pin1, motorSpeed);
  analogWrite(motor1Pin2, 0);
  
  // Right motor stop/slow
  analogWrite(motor2Pin1, 0);
  analogWrite(motor2Pin2, 0);
  
  Serial.println("Turning Right");
}

void stopMotors() {
  // Stop all motors
  analogWrite(motor1Pin1, 0);
  analogWrite(motor1Pin2, 0);
  analogWrite(motor2Pin1, 0);
  analogWrite(motor2Pin2, 0);
  
  Serial.println("Motors Stopped");
}

/*
 * NOTES:
 * 
 * 1. Motor Direction Configuration:
 *    - To make the car move forward, both motors should spin in the same direction
 *    - To make the car turn, reduce power to one motor or reverse it
 * 
 * 2. PWM Speed Control:
 *    - motorSpeed can be adjusted (0-255) for faster or slower movement
 *    - Use analogWrite() to control motor speed
 * 
 * 3. Baud Rate:
 *    - HC-06 default baud rate is 9600
 *    - Make sure both Serial and SoftwareSerial use the same baud rate
 * 
 * 4. Power Supply:
 *    - Use a separate power source for motors (usually 6-12V)
 *    - Don't draw motor current through Arduino pins directly
 * 
 * 5. Alternative Turn Commands:
 *    Instead of stopping one motor to turn, you can:
 *    - Add new commands like 'L' for left strafe (both motors forward, one slower)
 *    - Use PWM values to create smooth curves
 * 
 * 6. Enhanced Version with Speed Control:
 *    Add commands like:
 *    - '1'-'9' for different speed levels
 *    - 'U' to increase speed
 *    - 'D' to decrease speed
 */

void activateHorn() {
  // Activate horn for 500ms
  digitalWrite(hornPin, HIGH);
  Serial.println("Horn activated");
  delay(500);
  digitalWrite(hornPin, LOW);
  Serial.println("Horn deactivated");
}

