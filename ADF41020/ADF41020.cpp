#define __LANGUAGE_C__
#include <ADF41020.h>

uint32_t reference_counter_latch_ADF41020_Class::value(){
	return ((1<<23)+(1<<20)+(1<<16)+(R<<2)+controlBits);
};

uint32_t N_counter_latch_ADF41020_Class::value(){
	return ((cpGain<<21)+(B<<8)+(A<<2)+controlBits);
};

uint32_t function_latch_ADF41020_Class::value(){
	return ((prescalerValue<<22)+(powerDown2<<21)+(currentSetting2<<18)+(currentSetting1<<15)+(timerCounterControl<<11)+(fastLockMode<<10)+(fastLockEnable<<9)+(cpThreeState<<8)+(pdPolarity<<7)+(muxoutControl<<4)+(powerDown1<<3)+(counterReset<<2)+controlBits);
};

 void ADF41020_Class::setLatches(float setFreq){
	freq=setFreq;
	if (freq<0){
		function_latch.pdPolarity=1;
		}
	else{
		function_latch.pdPolarity=0;
	}
	
	int P = 1<<(3+(function_latch.prescalerValue));
 	uint32_t N=(int)(abs(freq)*(reference_counter_latch.R));
	N/=4*fRefIn;
	N_counter_latch.B=N/P; 
	N_counter_latch.A=N%P; 
	return;
}; 

void ADF41020_Class::begin(){
	//fRefIn (MHz)
	fRefIn=100;
	freq=6564;
	//Ref counter latch:
	reference_counter_latch.R=200;
	reference_counter_latch.controlBits=0;
	
	//N counter latch:
	N_counter_latch.cpGain=0;
	N_counter_latch.B=102;
	N_counter_latch.A=18;
	N_counter_latch.controlBits=1;
	
	//Function latch:
	function_latch.prescalerValue=2;
	function_latch.powerDown2=0;
	function_latch.currentSetting2=5;
	function_latch.currentSetting1=5;
	function_latch.timerCounterControl=0;
	function_latch.fastLockMode=0;
	function_latch.fastLockEnable=0;
	function_latch.cpThreeState=0;
	function_latch.pdPolarity=0;
	function_latch.muxoutControl=0;
	function_latch.powerDown1=0;
	function_latch.counterReset=0;
	function_latch.controlBits=2;
};


//Initializing class:

ADF41020_Class   ADF41020;