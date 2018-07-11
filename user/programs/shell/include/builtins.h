#ifndef BUILTINS_H
#define BUILTINS_H

#include "interpreter.h"

void builtin_cd      (commandParam_t *param);
void builtin_clear   (commandParam_t *param);
void builtin_echo    (commandParam_t *param);
void builtin_exit    (commandParam_t *param);
void builtin_false   (commandParam_t *param);
void builtin_help    (commandParam_t *param);
void builtin_monitor (commandParam_t *param);
void builtin_pwd     (commandParam_t *param);
void builtin_true    (commandParam_t *param);

#endif
