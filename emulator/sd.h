#ifndef SD_H
#define SD_H

#include "module.h"
#include <stdio.h>

class SdCard {
	public:
		SdCard(FILE*);
		~SdCard(void);
		unsigned char transfer(unsigned char);
	private:
		FILE* imgFile;
};

class SdModule: public Module {
/* Addr:  Read:   Write:
   0      read    write
   1              transfer
   2              enable
   3              disable
*/
	public:
		SdModule(SdCard&);
		void write(unsigned short addr, unsigned char data);
		unsigned char read(unsigned short addr);
	private:
		SdCard* card;
		bool enable = false;
		unsigned char writeReg, readReg;
};

#endif
