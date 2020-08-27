#if !defined(_ADF41020_H_INCLUDED)
#define _ADF41020_H_INCLUDED

#define __LANGUAGE_C__
#include <stdio.h>
#include <WProgram.h>

class reference_counter_latch_ADF41020_Class{
	public:
		int R;
		int controlBits;
		uint32_t value();	
};

class N_counter_latch_ADF41020_Class{
	public:
		int cpGain;
		int B;
		int A;
		int controlBits;
		uint32_t value();	
};
class function_latch_ADF41020_Class{
	public:
		int prescalerValue;
		int powerDown2;
		int currentSetting2;
		int currentSetting1;
		int timerCounterControl;
		int fastLockMode;
		int fastLockEnable;
		int cpThreeState;
		int pdPolarity;
		int muxoutControl;
		int powerDown1;
		int counterReset;
		int controlBits;
		uint32_t value();
};	




class ADF41020_Class{
	public:
		int fRefIn; //In MHz
		float freq; //In MHz
		reference_counter_latch_ADF41020_Class        reference_counter_latch;
		N_counter_latch_ADF41020_Class                N_counter_latch;
		function_latch_ADF41020_Class                 function_latch;
		

		void setLatches(float setFreq);
		void begin();
};

extern ADF41020_Class   ADF41020;

#endif
