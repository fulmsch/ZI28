#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <errno.h>

#define LUA_LIB

struct sdcard {
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

struct sdmod {
	struct sdcard card;
	unsigned char writeReg, readReg;
	int cs;
};

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

static void card_parseCommand(struct sdcard *card) {
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
	//printf("Command: %d, Argument: %d, Response: %d.\n", command, argument, card->response);
}

static unsigned char card_transfer(struct sdcard *card, unsigned char in) {
	unsigned char out = 0xff;
	if (!card->enable) {
		return out;
	}
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
				card_parseCommand(card);
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
	return out;
}

static int sd_read(lua_State *L) {
	lua_settop(L, 2);
	struct sdmod *module = lua_touserdata(L, 1);
	int isnum;
	unsigned int address = lua_tointegerx(L, 2, &isnum);
	if (module == NULL || !isnum) {
		return luaL_error(L, "Invalid argument");
	}

	unsigned char data = 0xff;
	if (address == 0 && module->card.imgFile != NULL) {
		data = module->readReg;
	}
	lua_pushinteger(L, data);
	//printf("read @%d -> %d\n", address, data);
	return 1;
}

static int sd_write(lua_State *L) {
	struct sdmod *module = lua_touserdata(L, 1);
	int isnum1, isnum2;
	unsigned int address = lua_tointegerx(L, 2, &isnum1);
	unsigned char data = lua_tointegerx(L, 3, &isnum2);
	if (module == NULL || !isnum1 || !isnum2) {
		return luaL_error(L, "Invalid argument");
	}

	switch (address) {
		case 0:
			module->writeReg = data;
			break;
		case 1:
			if (module->card.imgFile != NULL) {
				module->readReg = card_transfer(&module->card, module->writeReg);
			} else {
				module->readReg = 0xff;
			}
			module->writeReg = 0xff;
			break;
		case 2:
			module->cs = 1;
			if (module->card.imgFile != NULL) {
				if (!module->card.enable) {
					module->card.status = IDLE;
				}
				module->card.enable = 1;
			}
			break;
		case 3:
			module->cs = 0;
			if (module->card.imgFile != NULL) {
				module->card.enable = 0;
			}
			break;
		default:
			break;
	}
	//printf("write @%d : %d\n", address, data);
	return 0;
}

static int sd_insert(lua_State *L) {
	lua_settop(L, 2);
	struct sdmod *module = lua_touserdata(L, 1);
	const char *filename = lua_tostring(L, 2);
	if (module == NULL || filename == NULL) {
		return luaL_error(L, "Invalid argument");
	}

	if (!(module->card.imgFile = fopen(filename, "r+"))) {
		return luaL_error(L, "%s", strerror(errno));
	}
	module->card.status = IDLE;
	//TODO reset other fields?
	
	return 0;
}

static int sd_eject(lua_State *L) {
	lua_settop(L, 1);
	struct sdmod *module = lua_touserdata(L, 1);
	if (module == NULL) {
		return luaL_error(L, "Invalid argument");
	}

	fclose(module->card.imgFile);
	module->card.imgFile = NULL;
	return 0;
}

static const luaL_Reg sd_interface[] = {
	{"read",   sd_read},
	{"write",  sd_write},
	{"insert", sd_insert},
	{"eject",  sd_eject},
	{NULL, NULL}
};



static int sd_new(lua_State *L) {
	// Constructor
	lua_settop(L, 0);
	struct sdmod *module = lua_newuserdata(L, sizeof(struct sdmod));
	module->card.imgFile = NULL;
	lua_createtable(L, 0, 1); //last arg: number of entries
	luaL_newlib(L, sd_interface);
	lua_setfield(L, 2, "__index");
	lua_setmetatable(L, 1);
	return 1;
}

static const luaL_Reg module_sd[] = {
	{"new", sd_new},
	{NULL, NULL}
};

LUAMOD_API int luaopen_sd(lua_State *L) {
  luaL_newlib(L, module_sd);
  return 1;
}
