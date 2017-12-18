#ifndef SD_H
#define SD_H

//#include "module.h"
#include <stdio.h>

enum command_t {
	GO_IDLE_STATE        =  0,
	SEND_OP_COND         =  1,
	STOP_TRANSMISSION    = 12,
	SET_BLOCKLEN         = 16,
	READ_SINGLE_BLOCK    = 17,
	READ_MULTIPLE_BLOCK  = 18,
	WRITE_BLOCK          = 24,
	WRITE_MULTIPLE_BLOCK = 25
};

struct SdCard {
	FILE* imgFile;
	int enable;
	unsigned char commandFrame[6];
	unsigned char response;
	int blockLen;
	int count;
	enum {
		IDLE,
		COMMAND,
		RESPONSE,
		S_READ_RESPONSE, //single block read
		S_READ,
		M_READ_RESPONSE, //multiple block read
		M_READ,
		S_WRITE_RESPONSE,
		S_WRITE
	} status;
};

struct SdModule {
	struct SdCard* card;
	unsigned char writeReg, readReg;
	int cs;
};

void SdModule_write(struct SdModule*, unsigned short addr, unsigned char data);
unsigned char SdModule_read(struct SdModule*, unsigned short addr);
void SdModule_setCS(struct SdModule*, int);

unsigned char SdCard_transfer(struct SdCard*, unsigned char);
void SdCard_parseCommand(struct SdCard*);

/*
class SdCard {
	public:
		SdCard(char*);
		~SdCard(void);
		unsigned char transfer(unsigned char);
		void setCS(bool);
	private:
		void parseCommand(void);
		FILE* imgFile;
		bool enable = false;
		unsigned char commandFrame[6];
		unsigned char response;
		int blockLen;
		int count;
		enum status_t {
			IDLE,
			COMMAND,
			RESPONSE,
			READ_RESPONSE,
			READ,
			WRITE
		} status;
		enum command_t {
			GO_IDLE_STATE = 0,
			SEND_OP_COND = 1,
			STOP_TRANSMISSION = 12,
			SET_BLOCKLEN = 16,
			READ_MULTIPLE_BLOCK = 18
		};
};


class SdModule: public Module {
// Addr:  Read:   Write:
// 0      read    write
// 1              transfer
// 2              enable
// 3              disable

	public:
		SdModule(SdCard&);
		void write(unsigned short addr, unsigned char data);
		unsigned char read(unsigned short addr);
	private:
		SdCard* card;
		unsigned char writeReg, readReg;
};
*/

#endif
