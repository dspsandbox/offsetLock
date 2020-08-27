//Running un chipKit uc32 !!!!


#define LED 43
#define CE_COOLER 10
#define CE_REPUMPER 9
#define TRIG_COOLER 8
#define TRIG_REPUMPER 7
#define LE_COOLER 6
#define LE_REPUMPER 5
#define SERIAL_COMMUNICATION 4

#define BUFFER_LEN 100 //Length of communication buffer

#include <SPI_simple.h>
#include <ADF4110.h>
#include <ADF41020.h>


float floatMap(float x, float in_min, float in_max, float out_min, float out_max)
{
  if(in_max==in_min){
    return out_max;
  }
  else{
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  }
}



//SPI:
uint32_t BRG=1;//20 MHz SCLK (slowest timestep in datasheet is t3+t4=50ns->the fastest SCLK is 20MHz ) 
uint32_t MODE=2; //32 bit 
uint32_t SMP=0; //Input data sampled at middle of data output time
uint32_t CKE=1; //Serial output data changes on transition from active clock state to Idle clock state 
uint32_t CKP=0; // Idle state for clock is a low level; active state is a high level

//Triggers:
uint32_t TrigFlagCooler=0; //Rising edge detected
uint32_t TrigFlagRepumper=0;
uint32_t TriggerStateCooler=0; //State of digital pin
uint32_t TriggerStateRepumper=0;
uint32_t TriggerStateOldCooler=0;
uint32_t TriggerStateOldRepumper=0;

//Communication:
char newSerialChar;
String serialBuffer="";


bool serialFlagCooler=0; //Is 1 for serial communication concerning the cooler and 0 otherwise.
float freqArrayCooler[BUFFER_LEN];
float sweepTimeArrayCooler[BUFFER_LEN];
int indexCooler=0; //Current position in freq array
int freqStepsCooler=0; //Total available freq steps

bool serialFlagRepumper=0; //Is 1 for serial communication concerning the repumper and 0 otherwise.
float freqArrayRepumper[BUFFER_LEN];
float sweepTimeArrayRepumper[BUFFER_LEN];
int indexRepumper=0; 
int freqStepsRepumper=0; 




//time stamps for sweeps

uint32_t startTime;
uint32_t currentTime;
uint32_t endTime;
float startFrequency;
float currentFrequency;
float endFrequency;
uint32_t delay_us=8; // Added so each time setp is 20 us


void setup() {
  pinMode(LED, OUTPUT);
  pinMode(CE_COOLER, OUTPUT);
  pinMode(CE_REPUMPER, OUTPUT);
  pinMode(TRIG_COOLER, INPUT);
  pinMode(TRIG_REPUMPER, INPUT);
  pinMode(LE_COOLER, OUTPUT);
  pinMode(LE_REPUMPER, OUTPUT);
  pinMode(SERIAL_COMMUNICATION, INPUT);
  
  //Setting LE to LOW
  digitalWrite(LE_COOLER,LOW);
  digitalWrite(LE_REPUMPER,LOW);
  
  //Start serial:
  Serial.begin(9600);
  Serial.print("DIGITAL OFFSET LOCK \n");
  Serial.print("Version "__DATE__ " " __TIME__"\n\n");

  //Start SPI:
  SPI_simple.begin(BRG, MODE, SMP, CKE, CKP);
  
  //Set default values of latches into ADF4110 and ADF41020 classes:
  ADF4110.begin();
  ADF41020.begin();
  
  
  //Initializing ADF4110 device:
  digitalWrite(LE_COOLER,LOW);
  SPI_simple.transfer(ADF4110.initialization_latch.value());
  digitalWrite(LE_COOLER,HIGH);
  delay(1);

  digitalWrite(LE_COOLER,LOW);
  SPI_simple.transfer(ADF4110.reference_counter_latch.value());
  digitalWrite(LE_COOLER,HIGH);
  delay(1);
  
  digitalWrite(LE_COOLER,LOW);
  SPI_simple.transfer(ADF4110.N_counter_latch.value());
  digitalWrite(LE_COOLER,HIGH);
  delay(1);

 
  //digitalWrite(LE_COOLER,LOW);

 
  
  Serial.write("ADF4100 INITIALIZATION LATCH \n");
  Serial.println(ADF4110.initialization_latch.value(),HEX);
  Serial.write("ADF4100 REFERENCE COUNTER LATCH \n");
  Serial.println(ADF4110.reference_counter_latch.value(),HEX);
  Serial.write("ADF4100 N COUNTER LATCH \n");
  Serial.println(ADF4110.N_counter_latch.value(),HEX);


    
    
  //Initializing ADF41020 device:
  digitalWrite(LE_REPUMPER,LOW);
  SPI_simple.transfer(ADF41020.function_latch.value());
  digitalWrite(LE_REPUMPER,HIGH);
  delay(1);
  
  digitalWrite(LE_REPUMPER,LOW);
  SPI_simple.transfer(ADF41020.reference_counter_latch.value());
  digitalWrite(LE_REPUMPER,HIGH);
  delay(1);
  
  digitalWrite(LE_REPUMPER,LOW);
  SPI_simple.transfer(ADF41020.N_counter_latch.value());
  digitalWrite(LE_REPUMPER,HIGH);
  delay(1);
  
  //digitalWrite(LE_REPUMPER,LOW);
  
  Serial.write("ADF41020 FUNCTION LATCH \n");
  Serial.println(ADF41020.function_latch.value(),HEX);
  Serial.write("ADF41020 REFERENCE COUNTER LATCH \n");
  Serial.println(ADF41020.reference_counter_latch.value(),HEX);
  Serial.write("ADF41020 N COUNTER LATCH \n");
  Serial.println(ADF41020.N_counter_latch.value(),HEX);
   
}    
    
    
    

void loop() {
   
  TriggerStateCooler=digitalRead(TRIG_COOLER);
  TrigFlagCooler=(!TriggerStateOldCooler)&TriggerStateCooler;
  TriggerStateOldCooler=TriggerStateCooler;
  
  TriggerStateRepumper=digitalRead(TRIG_REPUMPER);
  TrigFlagRepumper=(!TriggerStateOldRepumper)&TriggerStateRepumper;
  TriggerStateOldRepumper=TriggerStateRepumper;
  
  
  digitalWrite(LED,freqStepsCooler|freqStepsRepumper);

//Communication:

  if (Serial.available() > 0){
    newSerialChar=Serial.read();
    if (newSerialChar=='!'){
      serialBuffer="";
      freqStepsCooler=0;
      indexCooler=0;
      freqStepsRepumper=0;
      indexRepumper=0;
      serialFlagCooler=0;
      serialFlagRepumper=0;
      
      for(int i=0; i<BUFFER_LEN;i++){
        freqArrayCooler[i]=0;
        sweepTimeArrayCooler[i]=0;
        freqArrayRepumper[i]=0;
        sweepTimeArrayRepumper[i]=0;
      }

    }
    
    if (newSerialChar=='c'){
      
      serialBuffer="";
      serialFlagCooler=1;
      serialFlagRepumper=0;

    }
    
    if (newSerialChar=='r'){
      serialBuffer="";
      serialFlagCooler=0;
      serialFlagRepumper=1;

    }
    
    if (newSerialChar==';'){
      if (serialFlagCooler==1){
      sweepTimeArrayCooler[freqStepsCooler]=serialBuffer.substring(1).toFloat();
      

    }
      if (serialFlagRepumper==1){
        sweepTimeArrayRepumper[freqStepsRepumper]=serialBuffer.substring(1).toFloat();
        
      }
      serialBuffer="";

    }
    
    if (newSerialChar=='#'){
      if (serialFlagCooler==1){
        freqArrayCooler[freqStepsCooler]=serialBuffer.substring(1).toFloat();
        freqStepsCooler++;
  
    }
      if (serialFlagRepumper==1){
        freqArrayRepumper[freqStepsRepumper]=serialBuffer.substring(1).toFloat();
        freqStepsRepumper++;
      }
      serialBuffer="";
      
      
      
      
      serialFlagCooler=0;
      serialFlagRepumper=0;
    }   
    
    
    if (newSerialChar=='?'){
      Serial.print("COOLER freq:\n");
      for (int i; i<freqStepsCooler; i++){
        Serial.println(freqArrayCooler[i]);
      }
      Serial.print("COOLER sweep time:\n");
      for (int i; i<freqStepsCooler; i++){
        Serial.println(sweepTimeArrayCooler[i]);
      }
      
      Serial.print("REPUMPER freq:\n");
      for (int i; i<freqStepsRepumper; i++){
        Serial.println(freqArrayRepumper[i]);
      }
      Serial.print("REPUMPER sweep time:\n");
      for (int i; i<freqStepsRepumper; i++){
        Serial.println(sweepTimeArrayRepumper[i]);
      }
      serialFlagCooler=0;
      serialFlagRepumper=0;
    }
    
    if ((serialFlagCooler==1)||(serialFlagRepumper==1)){
      serialBuffer+=newSerialChar;
      
    }
  }
  
  
//Trigger cooler

  if((TrigFlagCooler==1)&&(freqStepsCooler>0)){
    startFrequency=ADF4110.freq;
    endFrequency=freqArrayCooler[indexCooler];
    startTime=micros();
    endTime=startTime+((uint32_t) (sweepTimeArrayCooler[indexCooler]*1000));
    while(true){
      currentTime=micros();
      currentTime=constrain(currentTime,startTime,endTime);
      currentFrequency=floatMap(currentTime,startTime,endTime,startFrequency,endFrequency);
      
      ADF4110.setLatches(currentFrequency);
      digitalWrite(LE_COOLER,LOW);
      SPI_simple.transfer(ADF4110.function_latch.value());
      digitalWrite(LE_COOLER,HIGH);
      delayMicroseconds(delay_us);
      
      digitalWrite(LE_COOLER,LOW);
      SPI_simple.transfer(ADF4110.N_counter_latch.value());
      digitalWrite(LE_COOLER,HIGH);
      delayMicroseconds(delay_us);
      
      
      if (currentTime==endTime){
        break;
      }
    }    
    indexCooler++;
    
    if (indexCooler==freqStepsCooler){
      indexCooler=0;
      freqStepsCooler=0;
    }
  }
  
//Trigger repumper:

 if((TrigFlagRepumper==1)&&(freqStepsRepumper>0)){
    startFrequency=ADF41020.freq;
    endFrequency=freqArrayRepumper[indexRepumper];
    startTime=micros();
    endTime=startTime+((uint32_t) (sweepTimeArrayRepumper[indexRepumper]*1000));
    
    while(true){
      currentTime=micros();
      currentTime=constrain(currentTime,startTime,endTime);
      currentFrequency=floatMap(currentTime,startTime,endTime,startFrequency,endFrequency);
      
      ADF41020.setLatches(currentFrequency);
      
      digitalWrite(LE_REPUMPER,LOW);
      SPI_simple.transfer(ADF41020.function_latch.value());
      digitalWrite(LE_REPUMPER,HIGH);
      delayMicroseconds(delay_us);
      
      digitalWrite(LE_REPUMPER,LOW);
      SPI_simple.transfer(ADF41020.N_counter_latch.value());
      digitalWrite(LE_REPUMPER,HIGH);
      delayMicroseconds(delay_us);
      if (currentTime==endTime){
        break;
      }
    }    
    indexRepumper++;
    
    if (indexRepumper==freqStepsRepumper){
      indexRepumper=0;
      freqStepsRepumper=0;
    }
  }

  
}
  
 
