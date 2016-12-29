#include "sd.h"

SdCard::SdCard(FILE* file) {
	imgFile = file;
}

SdCard::~SdCard() {

}

unsigned char SdCard::transfer(unsigned char in) {

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
			if (enable) {
				readReg = card -> transfer(writeReg);
			} else {
				readReg = 0xff;
			}
			writeReg = 0xff;
			break;
		case 2:
			enable = true;
		case 3:
			enable = false;
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
