#include "sd.h"
#include "main.h"
#include "ui.h"

//SdCard::SdCard(char* fileName) {
//	imgFile = fopen(fileName, "rb");
//	status = IDLE;
//}

//SdCard::~SdCard() {
//	fclose(imgFile);
//}

unsigned char SdCard_transfer(struct SdCard *card, unsigned char in) {
	unsigned char out = 0xff;
	if (card->enable) {
		switch (card->status) {
			case IDLE:
				if ((in & 0xc0) != 0x40)
					break;
				card->status = COMMAND;
				card->count = 0;
			case COMMAND:
				card->commandFrame[card->count] = in;
				card->count++;
				if (card->count >= 6) {
					SdCard_parseCommand(card);
				}
				break;
			case RESPONSE:
				out = card->response;
				card->status = IDLE;
				break;
			case S_READ_RESPONSE:
				out = card->response;
				card->status = S_READ;
				card->count = 0;
				break;
			case S_READ:
				if (card->count == 0) {
					// Data token
					out = 0xfe;
					card->count++;
				} else if (card->count > card->blockLen + 2) {
					card->count = 0;
					card->status = COMMAND;
				} else if (card->count > card->blockLen) {
					// CRC, not calculated
					out = 0xff;
					card->count++;
				} else {
					out = fgetc(card->imgFile);
					card->count++;
				}
				break;
			case M_READ_RESPONSE:
				out = card->response;
				card->status = M_READ;
				card->count = 0;
				break;
			case M_READ:
				if ((in & 0xc0) == 0x40) {
					card->status = COMMAND;
					card->count = 0;
				} else {
					if (card->count == 0) {
						// Data token
						out = 0xfe;
						card->count++;
					} else if (card->count > card->blockLen + 2) {
						card->count = 0;
						out = 0xff;
					} else if (card->count > card->blockLen) {
						// CRC, not calculated
						out = 0xff;
						card->count++;
					} else {
						out = fgetc(card->imgFile);
						card->count++;
					}
				}
				break;
			case S_WRITE_RESPONSE:
				out = card->response;
				card->status = S_WRITE;
				card->count = 0;
				break;
			case S_WRITE:
				if (card->count >= card->blockLen + 4) {
					out = 0x05;
					card->status = COMMAND;
					card->count = 0;
				} else if (card->count >= card->blockLen + 2) {
					card->count++; //crc
				} else if (card->count > 1) {
					fputc(in, card->imgFile);
					card->count++;
				} else if (in == 0xfe || card->count == 0) {
					//ignore first byte, look for data token
					card->count++;
				}
				break;
			default:
				break;
		}
	}
	return out;
}

void SdModule_setCS(struct SdModule *module, int state) {
	module->cs = state;
	if (module->card != NULL) {
		if (!module->card->enable && state) {
			module->card->status = IDLE;
		}
		module->card->enable = state;
	}
}

void SdCard_parseCommand(struct SdCard *card) {
	unsigned char command = card->commandFrame[0] & 0x3f;
	unsigned int argument;

	argument = card->commandFrame[4];
	argument += card->commandFrame[3] << 8;
	argument += card->commandFrame[2] << 16;
	argument += card->commandFrame[1] << 24;

	switch (command) {
		case GO_IDLE_STATE:
			card->response = 0x01;
			card->status = RESPONSE;
			break;
		case SEND_OP_COND:
			card->response = 0x00;
			card->status = RESPONSE;
			break;
		case STOP_TRANSMISSION:
			card->response = 0x00;
			card->status = RESPONSE;
			break;
		case SET_BLOCKLEN:
			card->blockLen = argument;
			card->response = 0x00;
			card->status = RESPONSE;
			break;
		case READ_SINGLE_BLOCK:
			fseek(card->imgFile, argument, SEEK_SET);
			card->response = 0x00;
			card->status = S_READ_RESPONSE;
			break;
		case READ_MULTIPLE_BLOCK:
			fseek(card->imgFile, argument, SEEK_SET);
			card->response = 0x00;
			card->status = M_READ_RESPONSE;
			break;
		case WRITE_BLOCK:
			fseek(card->imgFile, argument, SEEK_SET);
			card->response = 0x00;
			card->status = S_WRITE_RESPONSE;
			break;
		default:
			break;
	}
	console("Command: %d, Argument: %d, Response: %d.\n", command, argument, card->response);
}




//SdModule::SdModule(SdCard& c) {
//	card = &c;
//}

void SdModule_write(struct SdModule *module, unsigned short addr, unsigned char data) {
	switch (addr) {
		case 0:
			module->writeReg = data;
			break;
		case 1:
			if (module->card != NULL) {
				module->readReg = SdCard_transfer(module->card, module->writeReg);
			} else {
				module->readReg = 0xff;
			}
			module->writeReg = 0xff;
			break;
		case 2:
			SdModule_setCS(module, 1);
			break;
		case 3:
			SdModule_setCS(module, 0);
			break;
		default:
			break;
	}
	return;
}

unsigned char SdModule_read(struct SdModule *module, unsigned short addr) {
	unsigned char data = 0xff;
	switch (addr) {
		case 0:
			if (module->card != NULL) {
				data = module->readReg;
			}
			break;
		default:
			break;
	}
	return data;
}
