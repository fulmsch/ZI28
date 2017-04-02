#ifndef SD_H
#define SD_H

//#include "module.h"
#include <stdio.h>

enum command_t {
	GO_IDLE_STATE = 0,
	SEND_OP_COND = 1,
	STOP_TRANSMISSION = 12,
	SET_BLOCKLEN = 16,
	READ_SINGLE_BLOCK = 17,
	READ_MULTIPLE_BLOCK = 18
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
		S_READ_RESPONSE,
		S_READ,
		M_READ_RESPONSE,
		M_READ,
		WRITE
	} status;
};

struct SdModule {
	struct SdCard* card;
	unsigned char writeReg, readReg;
};

void SdModule_write(struct SdModule*, unsigned short addr, unsigned char data);
unsigned char SdModule_read(struct SdModule*, unsigned short addr);
unsigned char SdCard_transfer(struct SdCard*, unsigned char);
void SdCard_setCS(struct SdCard*, int);
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
