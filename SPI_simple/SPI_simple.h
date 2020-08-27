
/* 
2015.12.17
Library created for simple, fast and controllable SPI communication. Specially avoiding the arduino style overhead.
*/ 
#if !defined(_SPI_SIMPLE_H_INCLUDED)
#define _SPI_SIMPLE_H_INCLUDED

#define __LANGUAGE_C__

#include <stdio.h>
#include <WProgram.h>

#include <p32_defs.h>

class SPI_simple_Class {
public:
	
	uint32_t transfer(uint32_t dataOut);
	void begin(int BRG, int MODE, int SMP, int CKE, int CKP);	
	void end();
  
};

extern SPI_simple_Class SPI_simple;


#endif
