#include "sd.h"

SdCard::SdCard(FILE* file) {
	imgFile = file;
	status = COMMAND;
	count = 0;
}

SdCard::~SdCard() {

}

unsigned char SdCard::transfer(unsigned char in) {
	unsigned char out = 0xff;
	if (enable) {
		switch (status) {
			case IDLE:
				break;
			case COMMAND:
				commandFrame[count] = in;
				count++;
				if (count >= 6) {
					parseCommand();
				}
				break;
			case RESPONSE:
				out = response;
				status = IDLE;
				break;
			case READ:
				break;
			case WRITE:
				break;
			default:
				break;
		}
	}
	return out;
}

void SdCard::setCS(bool state) {
	if (!enable && state) {
		status = COMMAND;
	}
	enable = state;
}

void SdCard::parseCommand() {
	unsigned char command = commandFrame[0] & 0x3f;
	unsigned int argument;

	argument = commandFrame[4];
	argument += commandFrame[3] << 8;
	argument += commandFrame[2] << 16;
	argument += commandFrame[1] << 24;

	count = 0;

	switch (command) {
		case GO_IDLE_STATE:
			response = 0x01;
			status = RESPONSE;
			break;
		case SEND_OP_COND:
			response = 0x00;
			status = RESPONSE;
			break;
		case STOP_TRANSMISSION:
			break;
		case SET_BLOCKLEN:
			blockLen = argument;
			response = 0x00;
			status = RESPONSE;
			break;
		case READ_MULTIPLE_BLOCK:
			break;
		default:
			break;
	}
}




SdModule::SdModule(SdCard& c) {
	card = &c;
}

void SdModule::write(unsigned short addr, unsigned char data) {
	switch (addr) {
		case 0:
			writeReg = data;
			break;
		case 1:
			readReg = card -> transfer(writeReg);
			writeReg = 0xff;
			break;
		case 2:
			card -> setCS(true);
			break;
		case 3:
			card -> setCS(false);
			break;
		default:
			break;
	}
	return;
}

unsigned char SdModule::read(unsigned short addr) {
	unsigned char data = 0xff;
	switch (addr) {
		case 0:
			data = readReg;
			break;
		default:
			break;
	}
	return data;
}
