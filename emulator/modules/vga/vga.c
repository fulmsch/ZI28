#include <stdio.h>
#include <stdbool.h>
#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <errno.h>
#include <SDL.h>

#define LUA_LIB


struct gpumod {
	bool isVisible;
	uint8_t vram[0x8000];
	uint8_t vram_old[0x8000];
	uint8_t xreg, yreg;
};


static int gpu_read(lua_State *L) {
	// x11x: read from vram
	// x1x1: advance coord registers
	// x0xx: status register
	lua_settop(L, 2);
	struct gpumod *module = lua_touserdata(L, 1);
	int isnum;
	unsigned int address = lua_tointegerx(L, 2, &isnum);
	if (module == NULL || !isnum) {
		return luaL_error(L, "Invalid argument");
	}

	unsigned char data = 0xff;

	if (address & 0x04) {
		if (address & 0x02) {
			data = module->vram[(module->xreg & 0x7f) | (module->yreg << 7)];
		}
		if (address & 0x01) {
			module->xreg++;
			if (module->xreg >= 0x80) {
				module->xreg = 0;
				module->yreg++;
			}
		}
	} else {
		// TODO implement status register, needs some concept of scanning
	}

	lua_pushinteger(L, data);
	return 1;
}

static int gpu_write(lua_State *L) {
	// x0x1: write to xreg
	// x01x: write to yreg
	// x11x: write to vram
	// x1x1: advance coord registers
	struct gpumod *module = lua_touserdata(L, 1);
	int isnum1, isnum2;
	unsigned int address = lua_tointegerx(L, 2, &isnum1);
	unsigned char data = lua_tointegerx(L, 3, &isnum2);
	if (module == NULL || !isnum1 || !isnum2) {
		return luaL_error(L, "Invalid argument");
	}

	if (address & 0x04) {
		if (address & 0x02) {
			module->vram[(module->xreg & 0x7f) | (module->yreg << 7)] = data;
		}
		if (address & 0x01) {
			module->xreg++;
			if (module->xreg >= 0x80) {
				module->xreg = 0;
				module->yreg++;
			}
		}
	} else {
		if (address & 0x02) {
			module->yreg = data;
		}
		if (address & 0x01) {
			module->xreg = data & 0x7f;
		}
	}
	return 0;
}

static int gpu_hideWindow(lua_State *L) {
	struct gpumod *module = lua_touserdata(L, 1);
	module->isVisible = false;
	return 0;
}

static int gpu_showWindow(lua_State *L) {
	struct gpumod *module = lua_touserdata(L, 1);
	module->isVisible = true;
	return 0;
}

static int gpuMain(void *data) {
	struct gpumod *module = (struct gpumod *)data;
	bool windowVisible = true;
	bool done = false;
	SDL_Event event;
	SDL_Window *window;
	SDL_Renderer *renderer;
	int x, y;

	for (int i = 0; i < 0x8000; i++) {
		module->vram[i] = 0;
		module->vram_old[i] = 0;
	}

#define WIDTH 1024
#define HEIGHT 768

	SDL_CreateWindowAndRenderer(WIDTH, HEIGHT, 0, &window, &renderer);
	SDL_RenderSetLogicalSize(renderer, 256, 192);
	SDL_RenderPresent(renderer);

	while(!done) {
		while(SDL_PollEvent(&event)) {
			if (event.type == SDL_QUIT) {
				module->isVisible = false;
				windowVisible = false;;
				SDL_HideWindow(window);
			}
		}
		if (windowVisible != module->isVisible) {
			windowVisible = module->isVisible;
			if (windowVisible) {
				SDL_ShowWindow(window);
			} else {
				SDL_HideWindow(window);
			}
		}
		if (!windowVisible) {
			SDL_Delay(16);
		}
		bool updateFlag = false;
		for (y = 0; y < 192; y++) {
			for (x = 0; x < 256; x++) {
				int address = (x >> 1) | (y << 7);
				uint8_t color = (module->vram[address] >> ((x & 1) * 4)) & 0x0f;
				uint8_t oldColor = (module->vram_old[address] >> ((x & 1) * 4)) & 0x0f;
//				if (color == oldColor) continue;
//				updateFlag = true;
				if (color != oldColor) updateFlag = true;
				oldColor &= 0xf0 >> ((x & 1) * 4);
				oldColor |= color << ((x & 1) * 4);
				module->vram_old[address] = oldColor;
//				if (module->vram_old[address] == color) continue;
//				module->vram_old[address] = color;

//				if (x & 1) {
//					color >>= 4;
//				} else {
//					color &= 0x0f;
//				}
				uint8_t r = !!(color & 0x04) * ((color & 0x08) ? 255 : 127);
				uint8_t g = !!(color & 0x02) * ((color & 0x08) ? 255 : 127);
				uint8_t b = !!(color & 0x01) * ((color & 0x08) ? 255 : 127);
				SDL_SetRenderDrawColor(renderer, r, g, b, 255);
				SDL_RenderDrawPoint(renderer, x, y);
			}
		}
		if (updateFlag) SDL_RenderPresent(renderer);
		SDL_Delay(16);
	}
	SDL_DestroyWindow(window);
	return 0;
}

static const luaL_Reg gpu_interface[] = {
	{"read",   gpu_read},
	{"write",  gpu_write},
	{"show",   gpu_showWindow},
	{"hide",   gpu_hideWindow},
	{NULL, NULL}
};



static int gpu_new(lua_State *L) {
	// Constructor
	SDL_Thread *gpuThread;
	lua_settop(L, 0);
	struct gpumod *module = lua_newuserdata(L, sizeof(struct gpumod));
	module->isVisible = true;
	gpuThread = SDL_CreateThread(gpuMain, "gpu", (void *)module);
	lua_createtable(L, 0, 1); //last arg: number of entries
	luaL_newlib(L, gpu_interface);
	lua_setfield(L, 2, "__index");
	lua_setmetatable(L, 1);
	return 1;
}

static const luaL_Reg module_gpu[] = {
	{"new", gpu_new},
	{NULL, NULL}
};

LUAMOD_API int luaopen_gpu(lua_State *L) {
  luaL_newlib(L, module_gpu);
  return 1;
}
