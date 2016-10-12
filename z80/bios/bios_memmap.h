sysStack:		equ		8000h
monStack:		equ		4200h

sdBuffer:		equ		4200h

;BIOS memory map
memBase:		equ		0000h	;change to 0000h

nmiEntry:		equ		memBase + 66h


;Monitor workspace
workspace:       equ		4000h
inputBuffer:     equ		workspace + 0
inputBufferSize: equ		40h
lineCounter:     equ		inputBuffer + inputBufferSize

xmodemRecvPacketNumber:		equ		lineCounter + 1
xmodemRecvPacketAddress:	equ		xmodemRecvPacketNumber + 1

header:				equ		xmodemRecvPacketAddress + 1
byteCountField:		equ		header + 0
addressField:		equ		byteCountField + 2
recordTypeField:	equ		addressField + 4

outputDev:			equ		recordTypeField + 2
inputDev:			equ		outputDev + 1

stackSave:			equ		inputDev + 1
registerStackBot:	equ		stackSave + 2
registerStack:		equ		stackSave +14




