#define __LANGUAGE_C__
#include <ADF4110.h>

uint32_t reference_counter_latch_ADF4110_Class::value(){
	return ((dly<<22)+(sync<<21)+(lockDetectPrecision<<20)+(testModeBits<<18)+(antiBacklashWidth<<16)+(R<<2)+controlBits);
};

uint32_t N_counter_latch_ADF4110_Class::value(){
	return ((cpGain<<21)+(B<<8)+(A<<2)+controlBits);
};

uint32_t function_latch_ADF4110_Class::value(){
	return ((prescalerValue<<22)+(powerDown2<<21)+(currentSetting2<<18)+(currentSetting1<<15)+(timerCounterControl<<11)+(fastLockMode<<10)+(fastLockEnable<<9)+(cpThreeState<<8)+(pdPolarity<<7)+(muxoutControl<<4)+(powerDown1<<3)+(counterReset<<2)+controlBits);
};

uint32_t initialization_latch_ADF4110_Class::value(){
	return ((prescalerValue<<22)+(powerDown2<<21)+(currentSetting2<<18)+(currentSetting1<<15)+(timerCounterControl<<11)+(fastLockMode<<10)+(fastLockEnable<<9)+(cpThreeState<<8)+(pdPolarity<<7)+(muxoutControl<<4)+(powerDown1<<3)+(counterReset<<2)+controlBits);
};

 void ADF4110_Class::setLatches(float setFreq){
	freq=setFreq;
	if (freq<0){
		function_latch.pdPolarity=0;
		}
	else{
		function_latch.pdPolarity=1;
	}
	

	int P = 1<<(3+(function_latch.prescalerValue));
 	uint32_t N=(int)(abs(freq)*(reference_counter_latch.R));
	N/=fRefIn;
	N_counter_latch.B=N/P; 
	N_counter_latch.A=N%P; 
	return;
}; 

void ADF4110_Class::begin(){
	//fRefIn
	fRefIn=10;
	freq=180;
	//Ref counter latch:
	reference_counter_latch.dly=0;
	reference_counter_latch.sync=0;
	reference_counter_latch.lockDetectPrecision=0;
	reference_counter_latch.testModeBits=0;
	reference_counter_latch.antiBacklashWidth=0;
	reference_counter_latch.R=20;
	reference_counter_latch.controlBits=0;
	
	//N counter latch:
	N_counter_latch.cpGain=0;
	N_counter_latch.B=45;
	N_counter_latch.A=0;
	N_counter_latch.controlBits=1;
	
	//Function latch:
	function_latch.prescalerValue=0;
	function_latch.powerDown2=0;
	function_latch.currentSetting2=5;
	function_latch.currentSetting1=5;
	function_latch.timerCounterControl=0;
	function_latch.fastLockMode=0;
	function_latch.fastLockEnable=0;
	function_latch.cpThreeState=0;
	function_latch.pdPolarity=1;
	function_latch.muxoutControl=0;
	function_latch.powerDown1=0;
	function_latch.counterReset=0;
	function_latch.controlBits=2;
    //Initialization latch:
	initialization_latch.prescalerValue=0;
	initialization_latch.powerDown2=0;
	initialization_latch.currentSetting2=5;
	initialization_latch.currentSetting1=5;
	initialization_latch.timerCounterControl=0;
	initialization_latch.fastLockMode=0;
	initialization_latch.fastLockEnable=0;
	initialization_latch.cpThreeState=0;
	initialization_latch.pdPolarity=1;
	initialization_latch.muxoutControl=0;
	initialization_latch.powerDown1=0;
	initialization_latch.counterReset=0;
	initialization_latch.controlBits=3;
	
};



//Initializing class:

ADF4110_Class   ADF4110;
