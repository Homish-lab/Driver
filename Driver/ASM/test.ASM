format		PE native 4.0 at 10000h
entry		DriverEntry
 
include		'%include%\win32w.inc'
include		'%include%\DDK\ntstatus.inc'
 
M	=	3000000						; Коэффициент задержки
 
;--- первая октава -------------------------------------------------------------------------------------------------------------------------
C4	=       0106h	; 261.63  Hz  ::  C   ::  (До)
Db4	=       0115h	; 277.18  Hz  ::  Cs  ::  (До диез)
D4	=       0126h	; 293.66  Hz  ::  D   ::  (Ре)
Eb4	=       0137h	; 311.13  Hz  ::  Ds  ::  (Ре диез)
E4	=       014Ah	; 329.63  Hz  ::  E   ::  (Ми)
F4	=       015Dh	; 349.23  Hz  ::  F   ::  (Фа)
Gb4	=       0172h	; 369.99  Hz  ::  Fs  ::  (Фа диез)
G4	=       0188h	; 392.00  Hz  ::  G   ::  (Соль)
Ab4	=       019Fh	; 415.30  Hz  ::  Gs  ::  (Соль диез)
LA4	=       01B8h	; 440.00  Hz  ::  A   ::  (Ля)
Bb4	=       01D2h	; 466.16  Hz  ::  As  ::  (Ля диез)
B4	=       01EEh	; 493.88  Hz  ::  H   ::  (Си)
;--- вторая октава ------------------------------------------------------------------------------------------------------------------------------------------
C5	=       020Bh	; 523.25  Hz  ::  C   ::  (До)
Db5	=       022Ah	; 554.37  Hz  ::  Cs  ::  (До диез)
D5	=       024Bh	; 587.33  Hz  ::  D   ::  (Ре)
Eb5	=       026Eh	; 622.25  Hz  ::  Ds  ::  (Ре диез)
E5	=       0293h	; 659.26  Hz  ::  E   ::  (Ми)
F5	=       02BAh	; 698.46  Hz  ::  F   ::  (Фа)
Gb5	=       02E4h	; 739.99  Hz  ::  Fs  ::  (Фа диез)
G5	=       0310h	; 783.99  Hz  ::  G   ::  (Соль)
Ab5	=       033Fh	; 830.61  Hz  ::  Gs  ::  (Соль диез)
LA5	=       0370h	; 880.00  Hz  ::  A   ::  (Ля)
Bb5	=       03A4h	; 932.33  Hz  ::  As  ::  (Ля диез)
B5	=       03DCh	; 987.77  Hz  ::  H   ::  (Си)
 
;=== сегмент кода ============================================================
 
section	'.text' code readable executable notpageable
 
proc	DriverEntry	DriverObject:DWORD, RegistryPath:DWORD
 
	stdcall		PlaySound, sound_buffer
 
	mov		eax, STATUS_DEVICE_CONFIGURATION_ERROR
	ret
endp
;-----------------------------------------------------------------------------
proc	PlaySound	buffer:DWORD
	push		eax ebx ecx esi
 
	cld
	mov		esi, [buffer]				; данные
	mov		ecx, SIZEOF.sound_buffer / 8		; размер буфера, счетчик = размер/8 (потому как для каждой записи нота-задержка используется 8 байт)
.loop:
	lodsd
	pushad
	invoke		HalMakeBeep, eax			; вывод сигнала необходимой частоты на динамик
	popad
.delay:
	lodsd
@@:	dec		eax
	jnz		@b
	pushad
	invoke		HalMakeBeep, 0				; отключаем динамик
	popad
	dec		ecx
	jnz		.loop
 
	pop		esi ecx ebx eax
	ret
endp
;------------------------------------------------------------------------------
sound_buffer	dd	G4 ,350*M,G4 ,350*M,G4 ,350*M,Eb4,250*M,Bb4,100*M,G4 ,350*M,Eb4,250*M,Bb4,100*M,G4 ,700*M
		dd	D5 ,350*M,D5 ,350*M,D5 ,350*M,Eb5,250*M,Bb4,100*M,Gb4,350*M,Eb4,250*M,Bb4,100*M,G4 ,700*M
		dd	G5 ,350*M,G4 ,250*M,G4 ,100*M,G5 ,350*M,Gb5,250*M,F5 ,100*M,E5 ,100*M,Eb5,100*M,E5 ,450*M
		dd	Ab4,150*M,Db5,350*M,C5 ,250*M,B4 ,100*M,Bb4,100*M,LA4,100*M,Bb4,450*M
		dd	Eb4,150*M,Gb4,350*M,Eb4,250*M,Bb4,100*M,G4 ,750*M
SIZEOF.sound_buffer = $-sound_buffer
 
;=== таблица импорта =========================================================
 
section	'.idata' import readable writeable
 
library	hal,'hal.dll'
 
import	hal,\
	HalMakeBeep, 'HalMakeBeep'
 
;=== таблица перемещений =====================================================
 
section	'.relocs' fixups readable writeable discardable