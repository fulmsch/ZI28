#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <string.h>
#include <sys/stat.h>
#include "config.h"

char *getConfigDir(void)
{
	//Priorities: 1. XDG_CONFIG_HOME, 2. HOME/.config, 3. getpwuid->home/.config
	char *baseDir, *homeDir, *configDir;
	char configDirName[] = "/.config";
	char appDirName[] = "/zi28emu/";
	if ((baseDir = getenv("XDG_CONFIG_HOME")) == NULL || baseDir[0] == 0) {
		//Couldn't get config dir from XDG
		if ((homeDir = getenv("HOME")) == NULL || homeDir[0] == 0) {
			struct passwd *pwd = getpwuid(getuid());
			if (pwd == NULL) return NULL;
			homeDir = pwd->pw_dir;
			if (homeDir[0] == 0) return NULL;
		}
		//Append /.config/zi28emu/
		configDir = malloc(strlen(homeDir) + sizeof(configDirName) + sizeof(appDirName));
		if (configDir == NULL) return NULL;
		strcpy(configDir, homeDir);
		strcat(configDir, configDirName);
	} else {
		//Append /zi28emu/
		configDir = malloc(strlen(baseDir) + sizeof(appDirName));
		if (configDir == NULL) return NULL;
		strcpy(configDir, baseDir);
	}
	strcat(configDir, appDirName);
	struct stat st;
	if (stat(configDir, &st)) {
		if(mkdir(configDir, 0755)) return NULL;
	}
	return configDir;
}
