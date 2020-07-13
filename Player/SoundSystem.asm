
INCLUDE	"SoundSystem.def"
; tabs=8,hard

;***************************************************************************************************************************
;*	default behaviors
;***************************************************************************************************************************

; force support for color gameboy-specific roms to be disabled if not user-specified
IF !DEF(SOUNDSYSTEM_GBC_COMPATIBLE)
SOUNDSYSTEM_GBC_COMPATIBLE	EQU	0
ENDC

; force support for large roms to be disabled if not user-specified
IF !DEF(SOUNDSYSTEM_LARGE_ROM)
SOUNDSYSTEM_LARGE_ROM	EQU	0
ENDC

; force the code to reside in bank 0 if not user-specified
IF !DEF(SOUNDSYSTEM_CODE_BANK)
SOUNDSYSTEM_CODE_BANK	EQU	0
ENDC

; force the variables to reside in wram bank 0 if not user-specified
IF !DEF(SOUNDSYSTEM_WRAM_BANK)
SOUNDSYSTEM_WRAM_BANK	EQU	0
ENDC

; force the sfx to be enabled if not user-specified
if !DEF(SOUNDSYSTEM_ENABLE_SFX)
SOUNDSYSTEM_ENABLE_SFX	EQU	1
ENDC

; force the vu meters to be disabled if not user-specified
if !DEF(SOUNDSYSTEM_ENABLE_VUM)
SOUNDSYSTEM_ENABLE_VUM	EQU	0
ENDC

; force certain settings if the rom is not specific to color gameboy
IF (SOUNDSYSTEM_GBC_COMPATIBLE == 0)
PURGE	SOUNDSYSTEM_WRAM_BANK
SOUNDSYSTEM_WRAM_BANK	EQU	0
ENDC

; do some sanity checking
IF (SOUNDSYSTEM_GBC_COMPATIBLE != 0)
ASSERT(SOUNDSYSTEM_WRAM_BANK < 8)

; force boolean
PURGE	SOUNDSYSTEM_GBC_COMPATIBLE
SOUNDSYSTEM_GBC_COMPATIBLE	EQU	1
ENDC

IF (SOUNDSYSTEM_LARGE_ROM != 0)
ASSERT(SOUNDSYSTEM_CODE_BANK < 512)

; force boolean
PURGE	SOUNDSYSTEM_LARGE_ROM
SOUNDSYSTEM_LARGE_ROM	EQU	1
ENDC

IF (SOUNDSYSTEM_ENABLE_SFX != 0)
; force boolean
PURGE	SOUNDSYSTEM_ENABLE_SFX
SOUNDSYSTEM_ENABLE_SFX	EQU	1
ENDC

IF (SOUNDSYSTEM_ENABLE_VUM != 0)
; force boolean
PURGE	SOUNDSYSTEM_ENABLE_VUM
SOUNDSYSTEM_ENABLE_VUM	EQU	1
ENDC

sizeof_BANK_VAR	= 1+SOUNDSYSTEM_LARGE_ROM	; the size, in bytes, of the bank variables

; display the configuration
PRINTT "SoundSystem Configuration:\n"

IF (SOUNDSYSTEM_GBC_COMPATIBLE == 0)
PRINTT "     GBC Only: no\n"
ELSE
PRINTT "     GBC Only: YES\n"
ENDC

IF (SOUNDSYSTEM_LARGE_ROM == 0)
PRINTT "    Large ROM: no\n"
ELSE
PRINTT "    Large ROM: YES\n"
ENDC

PRINTT "    Code Bank: {SOUNDSYSTEM_CODE_BANK}\n"
PRINTT "    WRAM Bank: {SOUNDSYSTEM_WRAM_BANK}\n"

IF (SOUNDSYSTEM_ENABLE_SFX == 0)
PRINTT "          SFX: disabled\n"
ELSE
PRINTT "          SFX: ENABLED\n"
ENDC

IF (SOUNDSYSTEM_ENABLE_VUM == 0)
PRINTT "    VU Meters: disabled\n"
ELSE
PRINTT "    VU Meters: ENABLED\n"
ENDC


;***************************************************************************************************************************
;*	hardware registers
;***************************************************************************************************************************
rROMB0			EQU	$2000	; $2000->$2FFF
rROMB1			EQU	$3000	; $3000->$3FFF - If more than 256 ROM banks are present.
rSVBK			EQU	$FF70

rAUD1SWEEP		EQU	$FF10
rAUD1LEN		EQU	$FF11
rAUD1ENV		EQU	$FF12
rAUD1LOW		EQU	$FF13
rAUD1HIGH		EQU	$FF14

rAUD2LEN		EQU	$FF16
rAUD2ENV		EQU	$FF17
rAUD2LOW		EQU	$FF18
rAUD2HIGH		EQU	$FF19
rAUD3ENA		EQU	$FF1A
rAUD3LEN		EQU	$FF1B
rAUD3LEVEL		EQU	$FF1C
rAUD3LOW		EQU	$FF1D
rAUD3HIGH		EQU	$FF1E

rAUD4LEN		EQU	$FF20
rAUD4ENV		EQU	$FF21
rAUD4POLY		EQU	$FF22
rAUD4GO			EQU	$FF23
rAUDVOL			EQU	$FF24
rAUDTERM		EQU	$FF25
rAUDENA			EQU	$FF26

_AUD3WAVERAM		EQU	$FF30	; $FF30->$FF3F

; values for rAUD1LEN, rAUD2LEN
AUDLEN_DUTY_75		EQU	%11000000	; 75%
AUDLEN_DUTY_50		EQU	%10000000	; 50%
AUDLEN_DUTY_25		EQU	%01000000	; 25%
AUDLEN_DUTY_12_5	EQU	%00000000	; 12.5%

AUDLEN_LENGTHMASK	EQU	%00111111

; values for rAUD1HIGH, rAUD2HIGH, rAUD3HIGH
AUDHIGH_RESTART		EQU	%10000000
AUDHIGH_LENGTH_ON	EQU	%01000000
AUDHIGH_LENGTH_OFF	EQU	%00000000

; values for rAUD3ENA
AUD3ENA_ON		EQU	%10000000

; values for rAUDVOL
AUDVOL_VIN_LEFT		EQU	%10000000	; SO2
AUDVOL_VIN_RIGHT	EQU	%00001000	; SO1

; values for rAUDTERM
; SO2
AUDTERM_4_LEFT		EQU	%10000000
AUDTERM_3_LEFT		EQU	%01000000
AUDTERM_2_LEFT		EQU	%00100000
AUDTERM_1_LEFT		EQU	%00010000
; SO1
AUDTERM_4_RIGHT		EQU	%00001000
AUDTERM_3_RIGHT		EQU	%00000100
AUDTERM_2_RIGHT		EQU	%00000010
AUDTERM_1_RIGHT		EQU	%00000001

AUDTERM_ALL		EQU	$FF	; shorthand instead of ORing all the EQUs together


;***************************************************************************************************************************
;*	supported music commands
;***************************************************************************************************************************
RSSET	0

MUSIC_CMD_ENDOFFRAME		RB	1

MUSIC_CMD_PLAYINSTNOTE		RB	1
MUSIC_CMD_PLAYINST		RB	1

MUSIC_CMD_SETVOLUME		RB	1
;MUSIC_CMD_SETPANNING		RB	1
MUSIC_CMD_VIBRATO_ON		RB	1
;MUSIC_CMD_DUALNOTE_ON		RB	1
MUSIC_CMD_EFFECT_OFF		RB	1
;MUSIC_CMD_SETMASTERVOLUME	RB	1

MUSIC_CMD_SYNCFLAG		RB	1

MUSIC_CMD_ENDOFPATTERN		RB	1
;MUSIC_CMD_LOOPPATTERN		RB	1
MUSIC_CMD_GOTOORDER		RB	1
MUSIC_CMD_ENDOFSONG		RB	1

MUSIC_CMD_SETSPEED		RB	1
MUSIC_CMD_ENDOFFRAME1X		RB	1
MUSIC_CMD_ENDOFFRAME2X		RB	1
MUSIC_CMD_ENDOFFRAME3X		RB	1
MUSIC_CMD_ENDOFFRAME4X		RB	1

MUSIC_CMD_PITCHUP_ON		RB	1
MUSIC_CMD_PITCHDOWN_ON		RB	1
MUSIC_CMD_TRIPLENOTE_ON		RB	1

MUSIC_CMD_EXTRA			RB	1

;***************************************************************************************************************************
;*	supported music effects
;***************************************************************************************************************************
RSRESET

MUSIC_FX_NONE			RB	1
MUSIC_FX_VIB1			RB	1
MUSIC_FX_VIB2			RB	1
;MUSIC_FX_DUALFREQ1		RB	1
;MUSIC_FX_DUALFREQ2		RB	1

MUSIC_FX_TRIPLEFREQ1		RB	1
MUSIC_FX_TRIPLEFREQ2		RB	1
MUSIC_FX_TRIPLEFREQ3		RB	1

MUSIC_FX_PITCHUP		RB	1
MUSIC_FX_PITCHDOWN		RB	1

;***************************************************************************************************************************
;*	supported instrument commands
;***************************************************************************************************************************
RSRESET

; common commands
MUSIC_INSTCMD_X_FRAMEEND	RB	1
MUSIC_INSTCMD_X_START		RB	1
MUSIC_INSTCMD_X_END		RB	1
MUSIC_INSTCMD_X_ENVELOPE	RB	1
MUSIC_INSTCMD_X_STARTFREQ	RB	1
MUSIC_INSTCMD_X_ENVELOPEVOL	RB	1
MUSIC_INSTCMD_X_STARTENVVOLFREQ	RB	1
MUSIC_INSTCMD_X_PANMID		RB	1
MUSIC_INSTCMD_X_PANRIGHT	RB	1
MUSIC_INSTCMD_X_PANLEFT		RB	1

; count of common instrument commands
MUSIC_INSTCMD_COMMONCOUNT	RB	0

; specific commands
; channels 1 and 2
RSSET	MUSIC_INSTCMD_COMMONCOUNT
MUSIC_INSTCMD_12_PULSELEN	RB	1
MUSIC_INSTCMD_1_SWEEP		RB	1

; channel 3
RSSET	MUSIC_INSTCMD_COMMONCOUNT
MUSIC_INSTCMD_3_WAVE		RB	1
MUSIC_INSTCMD_3_LEN		RB	1

; channel 4
RSSET	MUSIC_INSTCMD_COMMONCOUNT
MUSIC_INSTCMD_4_POLYLOAD	RB	1
MUSIC_INSTCMD_4_LEN		RB	1


;***************************************************************************************************************************
;*	wSoundFXLock bit definitions
;***************************************************************************************************************************
SFXLOCKF_4_LEFT		EQU	AUDTERM_4_LEFT
SFXLOCKF_3_LEFT		EQU	AUDTERM_3_LEFT
SFXLOCKF_2_LEFT		EQU	AUDTERM_2_LEFT
SFXLOCKF_1_LEFT		EQU	AUDTERM_1_LEFT

SFXLOCKF_4_RIGHT	EQU	AUDTERM_4_RIGHT
SFXLOCKF_3_RIGHT	EQU	AUDTERM_3_RIGHT
SFXLOCKF_2_RIGHT	EQU	AUDTERM_2_RIGHT
SFXLOCKF_1_RIGHT	EQU	AUDTERM_1_RIGHT

SFXLOCKB_CHANNEL4	EQU	3
SFXLOCKB_CHANNEL3	EQU	2
SFXLOCKB_CHANNEL2	EQU	1
SFXLOCKB_CHANNEL1	EQU	0


;***************************************************************************************************************************
;*	work ram
;***************************************************************************************************************************
IF (SOUNDSYSTEM_WRAM_BANK == 0)
SECTION	"SoundSystem Variables",WRAM0,ALIGN[7]
ELSE
SECTION	"SoundSystem Variables",WRAMX,BANK[SOUNDSYSTEM_WRAM_BANK],ALIGN[7]
ENDC

wMusicSyncFlag:			DS	1	; arbitrary value set by the song to sync visual effects with bg music

; soundfx variables
wSoundFXLock:			DS	1	; bitfield (see above), 1 = Music, 0 = SFX Locked
wSoundFXTable:			DS	2	; table of soundfx pointers
wSoundFXBank:			DS	sizeof_BANK_VAR	; bank of soundfxs
wSoundFXStart:			DS	4	; sound fx to start
wSoundFXNote:			DS	1	; sound fx's start note

; music/sfx shared variables
wMusicSFXPanning:		DS	1
wMusicSFXInstPause:		DS	4	; frames left before instrument/soundfx update
wMusicSFXInstPtr:		DS	8	; pointers to playing instruments/soundfx
; wMusicSFXInstBankX was split to allow better handling of large rom bank switching
wMusicSFXInstBank1:		DS	sizeof_BANK_VAR	; bank of active instrument for channel 1
wMusicSFXInstBank2:		DS	sizeof_BANK_VAR	; bank of active instrument for channel 2
wMusicSFXInstBank3:		DS	sizeof_BANK_VAR	; bank of active instrument for channel 3
wMusicSFXInstBank4:		DS	sizeof_BANK_VAR	; bank of active instrument for channel 4
wMusicSFXInstChnl3WaveID:	DS	1	; current waveid loaded, IDs of 255 in instruments will load, whatever the value here
wMusicSFXInstChnl3Lock:		DS	1	; 0 = no lock, 1 = external lock

; music variables
wMusicPlayMode:			DS	1	; current music mode, 0 = off, 1 = on
wMusicNextFrame:		DS	1	; number of frames until the next music commands
wMusicCommandPtr:		DS	2	; position of playing music
wMusicCommandBank:		DS	sizeof_BANK_VAR	; bank of playing music
wMusicOrderPtr:			DS	2	; position of pattern order list (list of pointers to start of patterns)
wMusicOrderBank:		DS	sizeof_BANK_VAR	; bank of order list
wMusicInstrumentTable:		DS	2	; table of instrument pointers
wMusicInstrumentBank:		DS	sizeof_BANK_VAR	; bank of instruments

wMusicPatternLoopCounter:	DS	1	; pattern loop counter

; miscellaneous variables
wChannelMusicFreqs:		DS	8	; GB frequencies of channels for music backup
wChannelMusicNotes:		DS	8	; GB frequencies of channels for music backup
wChannelFreqs:			DS	8	; GB frequencies of channels
wChannelVols:			DS	4	; volumes of channels, byte[4:VOL,4:xxxx]

wMusicSpeed:			DS	1	; speed

; effect variables
wChannelMusicEffects:		DS	4	; active effect, 0 = none
wChannelMusicFXParam:		DS	8	; parameters for effects (WORDs)
wChannelMusicFXParam2:		DS	8	; parameters for effects (WORDs)

wTemp:				DS	2	; temporary storage for player calcs

IF (SOUNDSYSTEM_ENABLE_VUM)
wVUMeters::			DS	4	; vu meter data for the channels
ENDC


;***************************************************************************************************************************
;*	Identification
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Identity",ROM0
ELSE
SECTION	"SoundSystem_Identity",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC
Version:
	DB	"SoundSystem v20.194 Code: S. Hockenhull"


;***************************************************************************************************************************
;*	SoundSystem_Init
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Init",ROM0
ELSE
SECTION	"SoundSystem_Init",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SoundSystem_Init::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	; set all channel samples to 'stop'
	ld	hl,wMusicSFXInstPtr
	ld	e,4
.instptrloop:
	ld	a,LOW(Music_InstrumentEnd)
	ld	[hl+],a
	ld	a,HIGH(Music_InstrumentEnd)
	ld	[hl+],a
	dec	e
	jr	nz,.instptrloop

	; set all channel volumes to 8
	ld	a,$80
	ld	hl,wChannelVols
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl],a

	; set all channel sfxs to unused (etc.)
	ld	a,$FF
	ld	hl,wSoundFXStart
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl],a
	ld	[wSoundFXLock],a
	ld	[wMusicSFXPanning],a
	ld	[wMusicSFXInstChnl3WaveID],a

	; clear all channel music effects
	xor	a
	ld	hl,wChannelMusicEffects
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl],a
	ld	[wMusicSFXInstChnl3Lock],a
	; clear all sfx pause timers
	ld	hl,wMusicSFXInstPause
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl],a

	; enable sound
	ld	a,AUD3ENA_ON
	ldh	[rAUDENA],a

	; channel 1
	xor	a
	ldh	[rAUD1SWEEP],a

	; all channels off
	call	Music_Pause

	; general
	ld	a,(AUDVOL_VIN_LEFT|AUDVOL_VIN_RIGHT) ^ $FF	; same as ~(), but ~ here triggers a false warning
	ldh	[rAUDVOL],a
	ld	a,AUDTERM_ALL
	ldh	[rAUDTERM],a

	ret

; dummy instrument to init/clear instrument pointers
Music_InstrumentEnd:
	DB	MUSIC_INSTCMD_X_END


;***************************************************************************************************************************
;*	SoundSystem_Process
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Process",ROM0
ELSE
SECTION	"SoundSystem_Process",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SoundSystem_Process::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	IF (SOUNDSYSTEM_ENABLE_SFX)
	; sfx start process
	ld	hl,wSoundFXStart
	ld	c,4
.multisfx:
	ld	a,[hl]
	push	hl
	push	bc

	xor	$FF
	jp	z,.nonewsfx
	ld	b,a	; save

	; change the rom bank
	ld	a,[wSoundFXBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wSoundFXBank+1]
	ld	[rROMB1],a
	ENDC

	; lock & update SFX
	ld	a,b	; restore
	cpl
	; calculate table plus index address
	ld	b,a	;save
	ld	a,[wSoundFXTable]
	ld	e,a
	ld	a,[wSoundFXTable+1]
	ld	d,a
	ld	a,b	;restore
	ld	b,0
	add	a
	rl	b
	add	a
	rl	b
	add	a	; 4 words
	rl	b
	add	e
	ld	l,a
	ld	a,0	; can't xor a here becuase of the adc
	adc	d
	add	b
	ld	h,a

	push	hl
	ld	a,[wSoundFXNote]
	add	a
	ld	l,a
	ld	h,HIGH(FrequencyTable)
	ASSERT	LOW(FrequencyTable) == 0

	ld	a,[hl+]
	ld	[wTemp],a
	ld	a,[hl]
	ld	[wTemp+1],a	; store note freq
	pop	hl

	; update wSoundFXLock
	ld	a,[wSoundFXLock]
	ld	d,a

	; load channel 1
	ld	a,[hl+]
	ld	c,a
	ld	a,[hl+]
	ld	b,a
	or	c
	jr	z,.nosfxchnl1
	ld	a,c
	ld	[wMusicSFXInstPtr],a
	ld	a,b
	ld	[wMusicSFXInstPtr+1],a

	; update the rom bank
	ld	a,[wSoundFXBank]
	ld	[wMusicSFXInstBank1],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wSoundFXBank+1]
	ld	[wMusicSFXInstBank1+1],a
	ENDC

	ld	a,[wTemp]
	ld	[wChannelFreqs+0],a
	ld	a,[wTemp+1]
	ld	[wChannelFreqs+1],a

	ld	a,d
	and	~(SFXLOCKF_1_LEFT|SFXLOCKF_1_RIGHT)
	ld	d,a
	ld	a,1	; set counter to immediate start
	ld	[wMusicSFXInstPause],a
.nosfxchnl1:

	; load channel 2
	ld	a,[hl+]
	ld	c,a
	ld	a,[hl+]
	ld	b,a
	or	c
	jr	z,.nosfxchnl2
	ld	a,c
	ld	[wMusicSFXInstPtr+2],a
	ld	a,b
	ld	[wMusicSFXInstPtr+3],a

	; update the rom bank
	ld	a,[wSoundFXBank]
	ld	[wMusicSFXInstBank2],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wSoundFXBank+1]
	ld	[wMusicSFXInstBank2+1],a
	ENDC

	ld	a,[wTemp]
	ld	[wChannelFreqs+2],a
	ld	a,[wTemp+1]
	ld	[wChannelFreqs+3],a

	ld	a,d
	and	~(SFXLOCKF_2_LEFT|SFXLOCKF_2_RIGHT)
	ld	d,a
	ld	a,1	; set counter to immediate start
	ld	[wMusicSFXInstPause+1],a
.nosfxchnl2:

	; load channel 3
	ld	a,[hl+]
	ld	c,a
	ld	a,[hl+]
	ld	b,a
	or	c
	jr	z,.nosfxchnl3
	ld	a,[wMusicSFXInstChnl3Lock]
	or	a
	jr	nz,.nosfxchnl3
	ld	a,c
	ld	[wMusicSFXInstPtr+4],a
	ld	a,b
	ld	[wMusicSFXInstPtr+5],a

	; update the rom bank
	ld	a,[wSoundFXBank]
	ld	[wMusicSFXInstBank3],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wSoundFXBank+1]
	ld	[wMusicSFXInstBank3+1],a
	ENDC

	ld	a,[wTemp]
	ld	[wChannelFreqs+4],a
	ld	a,[wTemp+1]
	ld	[wChannelFreqs+5],a

	ld	a,d
	and	~(SFXLOCKF_3_LEFT|SFXLOCKF_3_RIGHT)
	ld	d,a
	ld	a,1	; set counter to immediate start
	ld	[wMusicSFXInstPause+2],a
.nosfxchnl3:

	; load channel 4
	ld	a,[hl+]
	ld	c,a
	ld	a,[hl+]
	ld	b,a
	or	c
	jr	z,.nosfxchnl4
	ld	a,c
	ld	[wMusicSFXInstPtr+6],a
	ld	a,b
	ld	[wMusicSFXInstPtr+7],a

	; update the rom bank
	ld	a,[wSoundFXBank]
	ld	[wMusicSFXInstBank4],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wSoundFXBank+1]
	ld	[wMusicSFXInstBank4+1],a
	ENDC

	ld	a,d
	and	(SFXLOCKF_4_LEFT|SFXLOCKF_4_RIGHT) ^ $FF	; same as ~(), but ~ here triggers a false warning
	ld	d,a
	ld	a,1	; set counter to immediate start
	ld	[wMusicSFXInstPause+3],a
.nosfxchnl4:

	pop	bc
	pop	hl
	; update wSoundFXLock
	ld	a,d
	ld	[wSoundFXLock],a

	; de-flag sfx start
	ld	a,$FF
	ld	[hl+],a
	dec	c
	jp	nz,.multisfx
	jr	.newsfxdone
.nonewsfx:
	add	sp,4
.newsfxdone:
	ENDC

	;-------------------------------
	; instruments and SFX process
	;-------------------------------
	; channel 1
	ld	hl,wMusicSFXInstPause
	ld	a,[hl]
	or	a			; is channel 1 active?
	jr	z,SSFP_Inst1UpdateDone	; no, skip
	dec	a
	ld	[hl],a
	jr	nz,SSFP_Inst1UpdateDone

	; change the rom bank
	ld	a,[wMusicSFXInstBank1]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicSFXInstBank1+1]
	ld	[rROMB1],a
	ENDC

	ld	hl,wMusicSFXInstPtr
	ld	a,[hl+]
	ld	d,[hl]
	ld	e,a
	jp	SSFP_Inst1Update
SSFP_Inst1UpdateFrameEnd:
	; save back
	ld	hl,wMusicSFXInstPtr
	ld	a,e
	ld	[hl+],a
	ld	[hl],d
SSFP_Inst1UpdateDone:

	;-------------------------------
	; channel 2
	ld	hl,wMusicSFXInstPause+1
	ld	a,[hl]
	or	a			; is channel 2 active?
	jr	z,SSFP_Inst2UpdateDone	; no, skip
	dec	a
	ld	[hl],a
	jr	nz,SSFP_Inst2UpdateDone

	; change the rom bank
	ld	a,[wMusicSFXInstBank2]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicSFXInstBank2+1]
	ld	[rROMB1],a
	ENDC

	ld	hl,wMusicSFXInstPtr+2
	ld	a,[hl+]
	ld	d,[hl]
	ld	e,a
	jp	SSFP_Inst2Update
SSFP_Inst2UpdateFrameEnd:
	; save back
	ld	hl,wMusicSFXInstPtr+2
	ld	a,e
	ld	[hl+],a
	ld	[hl],d
SSFP_Inst2UpdateDone:

	;-------------------------------
	; channel 3
	ld	hl,wMusicSFXInstPause+2
	ld	a,[hl]
	or	a			; is channel 3 active?
	jr	z,SSFP_Inst3UpdateDone	; no, skip
	dec	a
	ld	[hl],a
	jr	nz,SSFP_Inst3UpdateDone

	; change the rom bank
	ld	a,[wMusicSFXInstBank3]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicSFXInstBank3+1]
	ld	[rROMB1],a
	ENDC

	ld	hl,wMusicSFXInstPtr+4
	ld	a,[hl+]
	ld	d,[hl]
	ld	e,a
	jp	SSFP_Inst3Update
SSFP_Inst3UpdateFrameEnd:
	; save back
	ld	hl,wMusicSFXInstPtr+4
	ld	a,e
	ld	[hl+],a
	ld	[hl],d
SSFP_Inst3UpdateDone:

	;-------------------------------
	; channel 4
	ld	hl,wMusicSFXInstPause+3
	ld	a,[hl]
	or	a			; is channel 4 active?
	jr	z,SSFP_Inst4UpdateDone	; no, skip
	dec	a
	ld	[hl],a
	jr	nz,SSFP_Inst4UpdateDone

	; change the rom bank
	ld	a,[wMusicSFXInstBank4]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicSFXInstBank4+1]
	ld	[rROMB1],a
	ENDC

	ld	hl,wMusicSFXInstPtr+6
	ld	a,[hl+]
	ld	d,[hl]
	ld	e,a
	jp	SSFP_Inst4Update
SSFP_Inst4UpdateFrameEnd:
	; save back
	ld	hl,wMusicSFXInstPtr+6
	ld	a,e
	ld	[hl+],a
	ld	[hl],d
SSFP_Inst4UpdateDone:

	;-------------------------------
	; process music
	ld	a,[wMusicPlayMode]
	or	a		; is music playing?
	ret	z		; no, exit early (nothing to do)

	;-------------------------------
	; update music effects
	;-------------------------------
	; channel 1
	ld	a,[wChannelMusicEffects]
	or	a			; is channel 1 playing music fx?
	jr	z,SSFP_MusicFX_Done1	; no, skip to the next channel

	; check if sound effect active (no music fx then)
	ld	b,a			; preserve wChannelMusicEffects[0]
	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL1,a	; is channel 1 playing fx?
	jr	z,SSFP_MusicFX_Done1	; no, skip to the next channel

	; call the fx handler
	ld	a,b			; restore wChannelMusicEffects[0]
	ld	hl,SSFP_MusicFX_JumpTable1
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl
SSFP_MusicFX_Done1:	; some handlers return here

	;-------------------------------
	; channel 2
	ld	a,[wChannelMusicEffects+1]
	or	a			; is channel 2 playing music fx?
	jr	z,SSFP_MusicFX_Done2	; no, skip to the next channel

	; check if sound effect active (no music fx then)
	ld	b,a			; preserve wChannelMusicEffects[1]
	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL2,a	; is channel 2 playing fx?
	jr	z,SSFP_MusicFX_Done2	; no, skip to the next channel

	; call the fx handler
	ld	a,b			; restore wChannelMusicEffects[1]
	ld	hl,SSFP_MusicFX_JumpTable2
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl
SSFP_MusicFX_Done2:	; some handlers return here

	;-------------------------------
	; channel 3
	ld	a,[wChannelMusicEffects+2]
	or	a			; is channel 3 playing music fx?
	jr	z,SSFP_MusicFX_Done3	; no, skip to the next channel

	; check if sound effect active (no music fx then)
	ld	b,a			; preserve wChannelMusicEffects[2]
	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL3,a	; is channel 3 playing fx?
	jr	z,SSFP_MusicFX_Done3	; no, skip to the next channel

	; call the fx handler
	ld	a,b			; restore wChannelMusicEffects[2]
	ld	hl,SSFP_MusicFX_JumpTable3
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl
SSFP_MusicFX_Done3:	; some handlers return here

	;-------------------------------
	; update music
	; determine if music should update this frame
	ld	a,[wMusicNextFrame]
	dec	a
	ld	[wMusicNextFrame],a
	ret	nz	; no update needed

	; change the rom bank
	ld	a,[wMusicCommandBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicCommandBank+1]
	ld	[rROMB1],a
	ENDC

	; put the music command	handler in de
	ld	hl,wMusicCommandPtr
	ld	a,[hl+]
	ld	e,a
	ld	d,[hl]

	;-------------------------------
SSFP_MusicUpdate:	; some handlers return here
	ld	a,[de]
	inc	de
	ld	hl,SSFP_Music_JumpTable
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl

	;-------------------------------
SSFP_MusicUpdateFrameEnd:	; some handlers return here
	; update the ptr for next time
	ld	hl,wMusicCommandPtr
	ld	a,e
	ld	[hl+],a
	ld	[hl],d

	ret


;***************************************************************************************************************************
;*	Music_PrepareInst
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Music_PrepareInst",ROM0
ELSE
SECTION	"SoundSystem_Music_PrepareInst",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

Music_PrepareInst::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	ld	hl,wMusicInstrumentTable
	ld	a,e
	ld	[hl+],a
	ld	a,d
	ld	[hl+],a	; hl = wMusicInstrumentBank
	ASSERT	wMusicInstrumentBank == wMusicInstrumentTable+2
	ld	a,c
	ld	[hl+],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,b
	ld	[hl],a
	ENDC
	ret


;***************************************************************************************************************************
;*	Music_Play
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Music_Play",ROM0
ELSE
SECTION	"SoundSystem_Music_Play",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

Music_Play::
	push	bc
	call	Music_Pause
	pop	bc

	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	; change to the rom bank containting the order list
	ld	a,c
	ld	[wMusicOrderBank],a
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,b
	ld	[wMusicOrderBank+1],a
	ld	[rROMB1],a
	ENDC

	; set to advance on next frame
	ld	a,1
	ld	[wMusicNextFrame],a

	; clear misc variables
	xor	a
	ld	[wMusicPatternLoopCounter],a	; pattern loop count = not in a loop
	; ld [MusicOrderLoopCounter],a	; init order loop count to zero (not in a loop)
	ld	[wMusicSyncFlag],a

	; clear effects
	ld	hl,wChannelMusicEffects
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl],a

	; set command pointer to value of first order
	ld	h,d
	ld	l,e
	ld	a,[hl+]
	ld	[wMusicCommandPtr],a
	ld	a,[hl+]
	ld	[wMusicCommandPtr+1],a
	ld	a,[hl+]
	ld	[wMusicCommandBank],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[hl]
	ld	[wMusicCommandBank+1],a
	ENDC

	; set order pointer to next order
	ld	a,e
	add	4
	ld	[wMusicOrderPtr],a
	ld	a,d
	adc	0
	ld	[wMusicOrderPtr+1],a

	; turn on the music
	ld	a,1
	ld	[wMusicPlayMode],a

	ret


;***************************************************************************************************************************
;*	Music_Pause
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Music_Pause",ROM0
ELSE
SECTION	"SoundSystem_Music_Pause",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

Music_Pause::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	; stop playing
	xor	a
	ld	[wMusicPlayMode],a

	; turn off channels used by music
	ld	a,[wSoundFXLock]
	ld	b,a
	ld	c,AUDHIGH_RESTART

	;-------------------------------
	; channel 1
	bit	SFXLOCKB_CHANNEL1,b	; is channel 1 playing music?
	jr	z,.nomusic1		; no, skip to the next channel
	; clear the channel 1 registers
	xor	a
	ldh	[rAUD1ENV],a
	ld	a,c
	ldh	[rAUD1HIGH],a

	; set the stop command
	ld	hl,wMusicSFXInstPtr
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)
.nomusic1:

	;-------------------------------
	; channel 2
	bit	SFXLOCKB_CHANNEL2,b	; is channel 2 playing music?
	jr	z,.nomusic2		; no, skip to the next channel
	; clear the channel 2 registers
	xor	a
	ldh	[rAUD2ENV],a
	ld	a,c
	ldh	[rAUD2HIGH],a

	; set the stop command
	ld	hl,wMusicSFXInstPtr+2
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)
.nomusic2:

	;-------------------------------
	; channel 3
	bit	SFXLOCKB_CHANNEL3,b	; is channel 3 playing music?
	jr	z,.nomusic3		; no, skip to the next channel
	; clear the channel 3 registers
	xor	a
	ldh	[rAUD3ENA],a

	; set the stop command
	ld	hl,wMusicSFXInstPtr+4
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)
.nomusic3:

	;-------------------------------
	; channel 4
	bit	SFXLOCKB_CHANNEL4,b	; is channel 4 playing music?
	ret	nz			; no, exit
	; clear the channel 4 registers
	xor	a
	ldh	[rAUD4ENV],a
	ld	a,c
	ldh	[rAUD4GO],a

	; set the stop command
	ld	hl,wMusicSFXInstPtr+6
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)

	ret


;***************************************************************************************************************************
;*	Music_Resume
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_Music_Resume",ROM0
ELSE
SECTION	"SoundSystem_Music_Resume",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

Music_Resume::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC
	ld	a,1
	ld	[wMusicPlayMode],a
	ret


;***************************************************************************************************************************
;*	SFX_Prepare
;***************************************************************************************************************************
IF (SOUNDSYSTEM_ENABLE_SFX)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SFX_Prepare",ROM0
ELSE
SECTION	"SoundSystem_SFX_Prepare",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SFX_Prepare::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	ld	hl,wSoundFXTable
	ld	a,e
	ld	[hl+],a
	ld	a,d
	ld	[hl+],a	; hl = wSoundFXBank here
	ASSERT	wSoundFXBank == wSoundFXTable+2
	ld	a,c
	ld	[hl+],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,b
	ld	[hl],a
	ENDC
	ret
ENDC


;***************************************************************************************************************************
;*	SFX_Play
;***************************************************************************************************************************
IF (SOUNDSYSTEM_ENABLE_SFX)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SFX_Play",ROM0
ELSE
SECTION	"SoundSystem_SFX_Play",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SFX_Play::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	; find an open channel, else put it on channel 4
	ld	hl,wSoundFXStart
	ld	d,4
.loop:
	ld	a,[hl]
	xor	$FF		; is this channel open?
	jr	z,.found	; yes, store the sfx data
	inc	hl
	dec	d
	jr	nz,.loop
.found:
	ld	a,b
	ld	[hl],a
	ld	a,c
	ld	[wSoundFXNote],a

	ret
ENDC


;***************************************************************************************************************************
;*	SFX_Stop
;***************************************************************************************************************************
IF (SOUNDSYSTEM_ENABLE_SFX)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SFX_Stop",ROM0
ELSE
SECTION	"SoundSystem_SFX_Stop",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SFX_Stop::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	; turn off channels used by sfx
	ld	a,[wSoundFXLock]
	ld	b,a
	ld	c,AUDHIGH_RESTART

	; channel 1
	bit	SFXLOCKB_CHANNEL1,b	; is channel 1 playing sfx?
	jr	nz,.nosfx1		; no, skip to the next channel
	xor	a
	ld	[rAUD1ENV],a
	ld	a,c
	ld	[rAUD1HIGH],a
	ld	hl,wMusicSFXInstPtr
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)
.nosfx1:

	; channel 2
	bit	SFXLOCKB_CHANNEL2,b	; is channel 2 playing sfx?
	jr	nz,.nosfx2		; no, skip to the next channel
	xor	a
	ld	[rAUD2ENV],a
	ld	a,c
	ld	[rAUD2HIGH],a
	ld	hl,wMusicSFXInstPtr+2
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)
.nosfx2:

	; channel 3
	bit	SFXLOCKB_CHANNEL3,b	; is channel 3 playing sfx?
	jr	nz,.nosfx3		; no, skip to the next channel
	ld	a,[wMusicSFXInstChnl3Lock]
	or	a
	jr	nz,.nosfx3
	ld	[rAUD3ENA],a	; a = 0 here
	ld	hl,wMusicSFXInstPtr+4
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)
.nosfx3:

	; channel 4
	bit	SFXLOCKB_CHANNEL4,b	; is channel 4 playing sfx?
	ret	nz			; no, exit
	xor	a
	ld	[rAUD4ENV],a
	ld	a,c
	ld	[rAUD4GO],a
	ld	hl,wMusicSFXInstPtr+6
	ld	[hl],LOW(Music_InstrumentEnd)
	inc	l
	ld	[hl],HIGH(Music_InstrumentEnd)

	ret
ENDC


;***************************************************************************************************************************
;*	SFX_LockChannel3
;***************************************************************************************************************************
IF (SOUNDSYSTEM_ENABLE_SFX)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SFX_LockChannel3",ROM0
ELSE
SECTION	"SoundSystem_SFX_LockChannel3",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SFX_LockChannel3::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	ld	a,1
	ld	[wMusicSFXInstChnl3Lock],a
	ld	a,[wSoundFXLock]
	and	~(SFXLOCKF_3_LEFT|SFXLOCKF_3_RIGHT)
	ld	[wSoundFXLock],a
	ld	hl,wMusicSFXInstPtr
	ld	a,LOW(Music_InstrumentEnd)
	ld	[hl+],a
	ld	a,HIGH(Music_InstrumentEnd)
	ld	[hl],a
	ret
ENDC


;***************************************************************************************************************************
;*	SFX_UnlockChannel3
;***************************************************************************************************************************
IF (SOUNDSYSTEM_ENABLE_SFX)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SFX_UnlockChannel3",ROM0
ELSE
SECTION	"SoundSystem_SFX_UnlockChannel3",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SFX_UnlockChannel3::
	IF (SOUNDSYSTEM_WRAM_BANK != 0)
	ld	a,SOUNDSYSTEM_WRAM_BANK
	ldh	[rSVBK],a
	ENDC

	xor	a
	ld	[wMusicSFXInstChnl3Lock],a
	ld	a,[wSoundFXLock]
	or	SFXLOCKF_3_LEFT|SFXLOCKF_3_RIGHT
	ld	[wSoundFXLock],a
	ret
ENDC


;***************************************************************************************************************************
;*	music fx handlers
;***************************************************************************************************************************

; channel 1

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_VIB1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_VIB1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_VIB1:
	ld	hl,wChannelFreqs+0*2
	ld	a,[hl]
	add	1	; can't use inc a here because of the adc
	ld	[hl+],a
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	adc	0
	and	$07
	ld	[hl],a
	ldh	[rAUD1HIGH],a

	ld	hl,wChannelMusicFXParam+0*2+1
	dec	[hl]
	dec	hl
	jp	nz,SSFP_MusicFX_Done1
	ld	a,[hl+]
	ld	[hl],a

	; store the fx id
	ld	a,MUSIC_FX_VIB2
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_VIB2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_VIB2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_VIB2:
	ld	hl,wChannelFreqs+0*2
	ld	a,[hl]
	add	$FF	; can't use dec a here because of the adc
	ld	[hl+],a
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	adc	$FF
	and	$07
	ld	[hl],a
	ldh	[rAUD1HIGH],a

	ld	hl,wChannelMusicFXParam+0*2+1
	dec	[hl]
	dec	hl
	jp	nz,SSFP_MusicFX_Done1
	ld	a,[hl+]
	ld	[hl],a

	; store the fx id
	ld	a,MUSIC_FX_VIB1
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_FX_DUALFREQ1)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_DUALFREQ1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_DUALFREQ1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_DUALFREQ1:
	ld	hl,wChannelMusicFXParam+0*2
	ld	a,[hl+]
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	ldh	[rAUD1HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_DUALFREQ2
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_FX_DUALFREQ2)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_DUALFREQ2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_DUALFREQ2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_DUALFREQ2:
	ld	hl,wChannelFreqs+0*2
	ld	a,[hl+]
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	ldh	[rAUD1HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_DUALFREQ1
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_TF1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_TF1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_TF1:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+0]
	ld	c,a
	ld	a,[wChannelMusicFXParam+0*2+0]
	add	c
	cp	6*12
	jr	c,.noteok
	ld	a,6*12-1
.noteok:
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	ldh	[rAUD1HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ2
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_TF2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_TF2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_TF2:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+0]
	ld	c,a
	ld	a,[wChannelMusicFXParam+0*2+1]
	add	c
	cp	6*12
	jr	c,.noteok
	ld	a,6*12-1
.noteok:
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	ldh	[rAUD1HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ3
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_TF3",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_TF3",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_TF3:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+0]
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	ldh	[rAUD1HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ1
	ld	[wChannelMusicEffects+0],a
	jp	SSFP_MusicFX_Done1

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_PITCHUP",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_PITCHUP",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_PITCHUP:
	ld	hl,wChannelMusicFXParam+0*2
	ld	a,[hl]
	dec	a
	ld	[hl+],a
	jp	nz,SSFP_MusicFX_Done1
	ld	a,[hl-]
	ld	[hl],a

	ld	hl,wChannelMusicFXParam2+0*2
	ld	b,[hl]
	ld	hl,wChannelFreqs+0*2
	ld	a,[hl]
	add	b
	ld	[hl+],a
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	adc	0
	and	$07
	ld	[hl],a
	ldh	[rAUD1HIGH],a

	jp	SSFP_MusicFX_Done1

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX1_PITCHDOWN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX1_PITCHDOWN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX1_PITCHDOWN:
	ld	hl,wChannelMusicFXParam+0*2
	ld	a,[hl]
	dec	a
	ld	[hl+],a
	jp	nz,SSFP_MusicFX_Done1
	ld	a,[hl-]
	ld	[hl],a

	ld	hl,wChannelMusicFXParam2+0*2
	ld	b,[hl]
	ld	hl,wChannelFreqs+0*2
	ld	a,[hl]
	sub	b
	ld	[hl+],a
	ldh	[rAUD1LOW],a
	ld	a,[hl]
	sbc	$00
	and	$07
	ld	[hl],a
	ldh	[rAUD1HIGH],a

	jp	SSFP_MusicFX_Done1


; ==========================================================================================================================
; channel 2

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_VIB1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_VIB1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_VIB1:
	ld	hl,wChannelFreqs+1*2
	ld	a,[hl]
	add	1	; can't use inc a here because of the adc
	ld	[hl+],a
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	adc	0
	and	$07
	ld	[hl],a
	ldh	[rAUD2HIGH],a

	ld	hl,wChannelMusicFXParam+1*2+1
	dec	[hl]
	dec	hl
	jp	nz,SSFP_MusicFX_Done2
	ld	a,[hl+]
	ld	[hl],a

	; store the fx id
	ld	a,MUSIC_FX_VIB2
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_VIB2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_VIB2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_VIB2:
	ld	hl,wChannelFreqs+1*2
	ld	a,[hl]
	add	$FF	; can't use dec a here because of the adc
	ld	[hl+],a
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	adc	$FF
	and	$07
	ld	[hl],a
	ldh	[rAUD2HIGH],a

	ld	hl,wChannelMusicFXParam+1*2+1
	dec	[hl]
	dec	hl
	jp	nz,SSFP_MusicFX_Done2
	ld	a,[hl+]
	ld	[hl],a

	; store the fx id
	ld	a,MUSIC_FX_VIB1
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_FX_DUALFREQ1)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_DUALFREQ1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_DUALFREQ1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_DUALFREQ1:
	ld	hl,wChannelMusicFXParam+1*2
	ld	a,[hl+]
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	ldh	[rAUD2HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_DUALFREQ2
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_FX_DUALFREQ2)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_DUALFREQ2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_DUALFREQ2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_DUALFREQ2:
	ld	hl,wChannelFreqs+1*2
	ld	a,[hl+]
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	ldh	[rAUD2HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_DUALFREQ1
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_TF1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_TF1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_TF1:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+1]
	ld	c,a
	ld	a,[wChannelMusicFXParam+1*2+0]
	add	c
	cp	6*12
	jr	c,.noteok
	ld	a,6*12-1
.noteok:
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	ldh	[rAUD2HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ2
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_TF2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_TF2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_TF2:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+1]
	ld	c,a
	ld	a,[wChannelMusicFXParam+1*2+1]
	add	c
	cp	6*12
	jr	c,.noteok
	ld	a,6*12-1
.noteok:
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	ldh	[rAUD2HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ3
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_TF3",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_TF3",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_TF3:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+1]
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	ldh	[rAUD2HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ1
	ld	[wChannelMusicEffects+1],a
	jp	SSFP_MusicFX_Done2

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_PITCHUP",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_PITCHUP",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_PITCHUP:
	ld	hl,wChannelMusicFXParam+1*2
	ld	a,[hl]
	dec	a
	ld	[hl+],a
	jp	nz,SSFP_MusicFX_Done2
	ld	a,[hl-]
	ld	[hl],a

	ld	hl,wChannelMusicFXParam2+1*2
	ld	b,[hl]
	ld	hl,wChannelFreqs+1*2
	ld	a,[hl]
	add	b
	ld	[hl+],a
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	adc	0
	and	$07
	ld	[hl],a
	ldh	[rAUD2HIGH],a

	jp	SSFP_MusicFX_Done2

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX2_PITCHDOWN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX2_PITCHDOWN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX2_PITCHDOWN:
	ld	hl,wChannelMusicFXParam+1*2
	ld	a,[hl]
	dec	a
	ld	[hl+],a
	jp	nz,SSFP_MusicFX_Done2
	ld	a,[hl-]
	ld	[hl],a

	ld	hl,wChannelMusicFXParam2+1*2
	ld	b,[hl]
	ld	hl,wChannelFreqs+1*2
	ld	a,[hl]
	sub	b
	ld	[hl+],a
	ldh	[rAUD2LOW],a
	ld	a,[hl]
	sbc	$00
	and	$07
	ld	[hl],a
	ldh	[rAUD2HIGH],a

	jp	SSFP_MusicFX_Done2


; ==========================================================================================================================
; channel 3

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_VIB1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_VIB1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_VIB1:
	ld	hl,wChannelFreqs+2*2
	ld	a,[hl]
	add	1	; can't use inc a here because of the adc
	ld	[hl+],a
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	adc	0
	and	$07
	ld	[hl],a
	ldh	[rAUD3HIGH],a

	ld	hl,wChannelMusicFXParam+2*2+1
	dec	[hl]
	dec	hl
	jp	nz,SSFP_MusicFX_Done3
	ld	a,[hl+]
	ld	[hl],a

	; store the fx id
	ld	a,MUSIC_FX_VIB2
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_VIB2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_VIB2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_VIB2:
	ld	hl,wChannelFreqs+2*2
	ld	a,[hl]
	add	$FF	; can't use dec a here because of the adc
	ld	[hl+],a
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	adc	$FF
	and	$07
	ld	[hl],a
	ldh	[rAUD3HIGH],a

	ld	hl,wChannelMusicFXParam+2*2+1
	dec	[hl]
	dec	hl
	jp	nz,SSFP_MusicFX_Done3
	ld	a,[hl+]
	ld	[hl],a

	; store the fx id
	ld	a,MUSIC_FX_VIB1
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_FX_DUALFREQ1)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_DUALFREQ1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_DUALFREQ1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_DUALFREQ1:
	ld	hl,wChannelMusicFXParam+2*2
	ld	a,[hl+]
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	ldh	[rAUD3HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_DUALFREQ2
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_FX_DUALFREQ2)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_DUALFREQ2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_DUALFREQ2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_DUALFREQ2:
	ld	hl,wChannelFreqs+2*2
	ld	a,[hl+]
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	ldh	[rAUD3HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_DUALFREQ1
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_TF1",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_TF1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_TF1:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+2]
	ld	c,a
	ld	a,[wChannelMusicFXParam+2*2+0]
	add	c
	cp	6*12
	jr	c,.noteok
	ld	a,6*12-1
.noteok:
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	ldh	[rAUD3HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ2
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_TF2",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_TF2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_TF2:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+2]
	ld	c,a
	ld	a,[wChannelMusicFXParam+2*2+1]
	add	c
	cp	6*12
	jr	c,.noteok
	ld	a,6*12-1
.noteok:
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	ldh	[rAUD3HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ3
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_TF3",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_TF3",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_TF3:
	ld	hl,FrequencyTable
	ASSERT	LOW(FrequencyTable) == 0
	ld	a,[wChannelMusicNotes+2]
	add	a
	ld	l,a
	ld	a,[hl+]
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	ldh	[rAUD3HIGH],a

	; store the fx id
	ld	a,MUSIC_FX_TRIPLEFREQ1
	ld	[wChannelMusicEffects+2],a
	jp	SSFP_MusicFX_Done3

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_PITCHUP",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_PITCHUP",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_PITCHUP:
	ld	hl,wChannelMusicFXParam+2*2
	ld	a,[hl]
	dec	a
	ld	[hl+],a
	jp	nz,SSFP_MusicFX_Done3
	ld	a,[hl-]
	ld	[hl],a

	ld	hl,wChannelMusicFXParam2+2*2
	ld	b,[hl]
	ld	hl,wChannelFreqs+2*2
	ld	a,[hl]
	add	b
	ld	[hl+],a
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	adc	0
	and	$07
	ld	[hl],a
	ldh	[rAUD3HIGH],a

	jp	SSFP_MusicFX_Done3

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_FX3_PITCHDOWN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_FX3_PITCHDOWN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_FX3_PITCHDOWN:
	ld	hl,wChannelMusicFXParam+2*2
	ld	a,[hl]
	dec	a
	ld	[hl+],a
	jp	nz,SSFP_MusicFX_Done3
	ld	a,[hl-]
	ld	[hl],a

	ld	hl,wChannelMusicFXParam2+2*2
	ld	b,[hl]
	ld	hl,wChannelFreqs+2*2
	ld	a,[hl]
	sub	b
	ld	[hl+],a
	ldh	[rAUD3LOW],a
	ld	a,[hl]
	sbc	$00
	and	$07
	ld	[hl],a
	ldh	[rAUD3HIGH],a

	jp	SSFP_MusicFX_Done3


;***************************************************************************************************************************
;*	music command handlers
;***************************************************************************************************************************

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFFRAME:
	ld	a,[de]
	inc	de
	ld	[wMusicNextFrame],a
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_PLAYINST/NOTE",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_PLAYINST/NOTE",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_PLAYINSTNOTE:
	ld	a,[de]
	inc	de

	ld	l,a
	ld	a,[de]
	and	$03
	ld	b,HIGH(wChannelMusicNotes)
	add	LOW(wChannelMusicNotes)
	ld	c,a
	ld	a,l
	ld	[bc],a

	ld	a,l
	add	a
	ld	l,a
	ld	h,HIGH(FrequencyTable)
	ASSERT	LOW(FrequencyTable) == 0

	ld	b,HIGH(wChannelMusicFreqs)
	ld	a,[de]
	and	$03
	add	a
	add	LOW(wChannelMusicFreqs)
	ld	c,a
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a	; store note freq
	; fall-through

; --------------------------------------------------------------------------------------------------------------------------
SSFP_MUSIC_CMD_PLAYINST:
	ld	a,[de]
	inc	de

	ld	b,a	;save
	and	$FC
	srl	a
	ld	c,a
	ld	hl,wMusicInstrumentTable
	ld	a,[hl+]
	add	c
	ld	c,a
	ld	a,[hl]
	adc	0
	ld	h,a
	ld	l,c

	; check for lock
	ld	a,[wSoundFXLock]
	ld	c,a

	ld	a,b	;restore
	and	$03
	jp	z,.playchannel1
	dec	a
	jr	z,.playchannel2
	dec	a
	jr	z,.playchannel3

.playchannel4:
	bit	SFXLOCKB_CHANNEL4,c
	jp	z,.channeldone

	; change the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[rROMB1],a
	ENDC

	ld	a,[hl+]
	ld	[wMusicSFXInstPtr+3*2],a
	ld	a,[hl]
	ld	[wMusicSFXInstPtr+3*2+1],a
	ld	a,1
	ld	[wMusicSFXInstPause+3],a

	; update the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[wMusicSFXInstBank4],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[wMusicSFXInstBank4+1],a
	ENDC

	ld	hl,wChannelMusicFreqs+3*2
	ld	bc,wChannelFreqs+3*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jr	.channeldone

.playchannel2:
	bit	SFXLOCKB_CHANNEL2,c
	jr	z,.channeldone

	; change the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[rROMB1],a
	ENDC

	ld	a,[hl+]
	ld	[wMusicSFXInstPtr+1*2],a
	ld	a,[hl]
	ld	[wMusicSFXInstPtr+1*2+1],a
	ld	a,1
	ld	[wMusicSFXInstPause+1],a

	; update the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[wMusicSFXInstBank2],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[wMusicSFXInstBank2+1],a
	ENDC

	ld	hl,wChannelMusicFreqs+1*2
	ld	bc,wChannelFreqs+1*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jr	.channeldone

.playchannel3:
	bit	SFXLOCKB_CHANNEL3,c
	jr	z,.channeldone

	; change the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[rROMB1],a
	ENDC

	ld	a,[hl+]
	ld	[wMusicSFXInstPtr+2*2],a
	ld	a,[hl]
	ld	[wMusicSFXInstPtr+2*2+1],a
	ld	a,1
	ld	[wMusicSFXInstPause+2],a

	; update the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[wMusicSFXInstBank3],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[wMusicSFXInstBank3+1],a
	ENDC

	ld	hl,wChannelMusicFreqs+2*2
	ld	bc,wChannelFreqs+2*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jr	.channeldone

.playchannel1:
	bit	SFXLOCKB_CHANNEL1,c
	jr	z,.channeldone

	; change the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[rROMB1],a
	ENDC

	ld	a,[hl+]
	ld	[wMusicSFXInstPtr+0*2],a
	ld	a,[hl]
	ld	[wMusicSFXInstPtr+0*2+1],a
	ld	a,1
	ld	[wMusicSFXInstPause+0],a

	; update the rom bank
	ld	a,[wMusicInstrumentBank]
	ld	[wMusicSFXInstBank1],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicInstrumentBank+1]
	ld	[wMusicSFXInstBank1+1],a
	ENDC

	ld	hl,wChannelMusicFreqs+0*2
	ld	bc,wChannelFreqs+0*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

.channeldone:
	; change the rom bank
	ld	a,[wMusicCommandBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicCommandBank+1]
	ld	[rROMB1],a
	ENDC

	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETVOLUME",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETVOLUME",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_SETVOLUME:
	ld	a,[de]
	inc	de
	ld	c,a
	and	$03
	add	LOW(wChannelVols)
	ld	l,a
	ld	a,HIGH(wChannelVols)
	adc	0
	ld	h,a
	ld	a,c
	and	$F0
	ld	[hl],a
	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_CMD_SETPANNING)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETPANNING",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETPANNING",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_SETPANNING:
	ld	a,[de]
	inc	de
	ld	hl,wSoundFXLock
	and	[hl]
	cpl
	ldh	[rAUDTERM],a
	jp	SSFP_MusicUpdate
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_VIBRATO_ON",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_VIBRATO_ON",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_VIBRATO_ON:
	ld	a,[de]
	ld	c,a
	and	3
	add	LOW(wChannelMusicEffects)
	ld	h,HIGH(wChannelMusicEffects)
	ld	l,a
	ld	[hl],MUSIC_FX_VIB1

	sub	LOW(wChannelMusicEffects)
	add	a
	add	LOW(wChannelMusicFXParam)
	ld	c,a
	ld	b,HIGH(wChannelMusicFXParam)
	ld	a,[de]
	swap	a
	and	$0F
	ld	[bc],a	; store max
	inc	bc
	ld	l,a
	and	1
	srl	l
	or	l
	ld	[bc],a	; store max
	inc	de

	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_CMD_DUALNOTE_ON)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_DUALNOTE_ON",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_DUALNOTE_ON",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_DUALNOTE_ON:
	ld	a,[de]
	inc	de
	; note
	add	a
	ld	l,a
	ld	h,HIGH(FrequencyTable)
	ASSERT	LOW(FrequencyTable) == 0

	ld	b,HIGH(wChannelMusicFXParam)
	ld	a,[de]
	and	$03
	add	a
	add	LOW(wChannelMusicFXParam)
	ld	c,a
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a	; store note freq

	ld	a,[de]
	inc	de

	ld	c,a
	and	3
	add	LOW(wChannelMusicEffects)
	ld	h,HIGH(wChannelMusicEffects)
	ld	l,a
	ld	[hl],MUSIC_FX_DUALFREQ1

	jp	SSFP_MusicUpdate
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_EFFECT_OFF",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_EFFECT_OFF",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_EFFECT_OFF:
	ld	a,[de]
	inc	de
	add	LOW(wChannelMusicEffects)
	ld	h,HIGH(wChannelMusicEffects)
	ld	l,a
	ld	[hl],MUSIC_FX_NONE
	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_CMD_SETMASTERVOLUME)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETMASTERVOLUME",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETMASTERVOLUME",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_SETMASTERVOLUME:
	ld	a,[de]
	inc	de
	ldh	[rAUDVOL],a
	jp	SSFP_MusicUpdate
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SYNCFLAG",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SYNCFLAG",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_SYNCFLAG:
	ld	a,[de]
	inc	de
	ld	[wMusicSyncFlag],a
	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFPATTERN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFPATTERN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFPATTERN:
	; change the rom bank
	ld	a,[wMusicOrderBank]
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[wMusicOrderBank+1]
	ld	[rROMB1],a
	ENDC

	ld	hl,wMusicOrderPtr
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	add	4
	ld	[wMusicOrderPtr],a
	ld	a,h
	adc	0
	ld	[wMusicOrderPtr+1],a

	ld	a,[hl+]
	ld	e,a
	ld	a,[hl+]
	ld	d,a

	; change and update the rom bank
	ld	a,[hl+]
	ld	[wMusicCommandBank],a
	ld	[rROMB0],a
	IF (SOUNDSYSTEM_LARGE_ROM != 0)
	ld	a,[hl]
	ld	[wMusicCommandBank+1],a
	ld	[rROMB1],a
	ENDC

	ld	a,1
	ld	[wMusicNextFrame],a
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF DEF(MUSIC_CMD_LOOPPATTERN)
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_LOOPPATTERN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_LOOPPATTERN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_LOOPPATTERN:
	ld	a,[wMusicPatternLoopCounter]
	or	a
	jr	nz,.alreadylooping
	; loop
	ld	a,[de]
	ld	l,a
	inc	de
	ld	a,[de]
	ld	h,a
	add	hl,de
	inc	de
	ld	a,[de]
	ld	e,l
	ld	d,h
	ld	[wMusicPatternLoopCounter],a
	jp	SSFP_MusicUpdate

.alreadylooping:
	dec	a
	ld	[wMusicPatternLoopCounter],a
	jr	z,.donelooping
	; loop
	ld	a,[de]
	ld	l,a
	inc	de
	ld	a,[de]
	ld	h,a
	add	hl,de
	ld	e,l
	ld	d,h
	jp	SSFP_MusicUpdate

.donelooping:
	; skip
	inc	de
	inc	de
	inc	de
	jp	SSFP_MusicUpdate
ENDC

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_GOTOORDER",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_GOTOORDER",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_GOTOORDER:
	ld	a,[wMusicOrderPtr]
	ld	c,a
	ld	a,[wMusicOrderPtr+1]
	ld	b,a
	ld	a,[de]
	inc	de
	ld	l,a
	ld	a,[de]
	inc	de
	ld	h,a
	add	hl,bc
	ld	a,h
	ld	[wMusicOrderPtr+1],a
	ld	a,l
	ld	[wMusicOrderPtr],a
	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFSONG",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFSONG",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFSONG:
	xor	a
	ld	[wMusicPlayMode],a
	dec	de
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETSPEED",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_SETSPEED",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_SETSPEED:
	ld	a,[de]
	inc	de
	ld	[wMusicSpeed],a
	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME1X",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME1X",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFFRAME1X:
	ld	a,[wMusicSpeed]
	ld	[wMusicNextFrame],a
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME2X",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME2X",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFFRAME2X:
	ld	a,[wMusicSpeed]
	add	a
	ld	[wMusicNextFrame],a
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME3X",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME3X",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFFRAME3X:
	ld	a,[wMusicSpeed]
	ld	c,a
	add	a
	add	c
	ld	[wMusicNextFrame],a
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME4X",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_ENDOFFRAME4X",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_ENDOFFRAME4X:
	ld	a,[wMusicSpeed]
	add	a
	add	a
	ld	[wMusicNextFrame],a
	jp	SSFP_MusicUpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_PITCHUPDOWN_ON",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_PITCHUPDOWN_ON",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_PITCHUP_ON:
	ld	a,[de]
	and	3
	add	LOW(wChannelMusicEffects)
	ld	h,HIGH(wChannelMusicEffects)
	ld	l,a
	ld	[hl],MUSIC_FX_PITCHUP
	jr	SSFP_MUSIC_CMD_PITCHUP_reuse

SSFP_MUSIC_CMD_PITCHDOWN_ON:
	ld	a,[de]
	and	3
	add	LOW(wChannelMusicEffects)
	ld	h,HIGH(wChannelMusicEffects)
	ld	l,a
	ld	[hl],MUSIC_FX_PITCHDOWN

SSFP_MUSIC_CMD_PITCHUP_reuse:
	sub	LOW(wChannelMusicEffects)
	add	a
	add	LOW(wChannelMusicFXParam)
	ld	c,a
	ld	b,HIGH(wChannelMusicFXParam)
	ld	a,[de]
	swap	a
	and	$0F
	ld	[bc],a	; store max
	inc	c
	ld	[bc],a	; store max
	ld	a,7
	add	c
	ld	c,a
	ld	a,[de]
	srl	a
	srl	a
	and	3
	inc	a
	ld	[bc],a
	inc	de
	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_TRIPLENOTE_ON",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_TRIPLENOTE_ON",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_TRIPLENOTE_ON:
	ld	a,[de]
	inc	de
	; note
	ld	l,a

	ld	b,HIGH(wChannelMusicFXParam)
	ld	a,[de]
	and	$03
	add	a
	add	LOW(wChannelMusicFXParam)
	ld	c,a
	ld	a,l
	swap	a
	and	$0F
	ld	[bc],a
	inc	c
	ld	a,l
	and	$0F
	ld	[bc],a	; store note freq

	ld	a,[de]
	inc	de

	ld	c,a
	and	3
	add	LOW(wChannelMusicEffects)
	ld	h,HIGH(wChannelMusicEffects)
	ld	l,a
	ld	[hl],MUSIC_FX_TRIPLEFREQ1

	jp	SSFP_MusicUpdate

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_MUSIC_CMD_EXTRA",ROM0
ELSE
SECTION	"SoundSystem_SSFP_MUSIC_CMD_EXTRA",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_MUSIC_CMD_EXTRA:
	ld	a,[de]
	inc	de
	ld	c,a
	and	3
	jr	z,SSFP_MUSIC_CMD_EXTRA_chnl1
	dec	a
	jr	z,SSFP_MUSIC_CMD_EXTRA_chnl2
	dec	a
	jr	z,SSFP_MUSIC_CMD_EXTRA_chnl3
	; chnl 4
	jp	SSFP_MusicUpdate

SSFP_MUSIC_CMD_EXTRA_chnl1:
	ld	a,c
	and	$FC
	ldh	[rAUD1LEN],a
	jp	SSFP_MusicUpdate

SSFP_MUSIC_CMD_EXTRA_chnl2:
	ld	a,c
	and	$FC
	ldh	[rAUD2LEN],a
	jp	SSFP_MusicUpdate

SSFP_MUSIC_CMD_EXTRA_chnl3:
	ld	a,[wMusicSFXInstChnl3Lock]
	or	a
	jp	nz,SSFP_MusicUpdate
	ld	a,c
	and	$FC
	ldh	[rAUD3LEVEL],a
	jp	SSFP_MusicUpdate


;***************************************************************************************************************************
;*	instrument command handlers
;***************************************************************************************************************************

; channel 1

CHANNELINDEX	SET	0

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1Update",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1Update",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1Update:
	ld	a,[de]
	inc	de
	ld	hl,SSFP_Inst1_JumpTable
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_FRAMEEND",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_FRAMEEND",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_FRAMEEND:
	ld	a,[de]
	inc	de
	ld	[wMusicSFXInstPause+CHANNELINDEX],a	; load new pause
	jp	SSFP_Inst1UpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_START",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_START",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_START:
	ld	a,[wChannelFreqs+CHANNELINDEX*2]
	ldh	[rAUD1LOW],a
	ld	a,[de]
	inc	de
	ld	hl,wChannelFreqs+CHANNELINDEX*2+1
	or	[hl]
	ldh	[rAUD1HIGH],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_END",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_END",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_END:
	dec	de	; rewind counter
	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL1,a
	jp	nz,SSFP_Inst1UpdateFrameEnd
	or	SFXLOCKF_1_LEFT|SFXLOCKF_1_RIGHT
	ld	[wSoundFXLock],a

	; restore music freq
	ld	hl,wChannelMusicFreqs+0*2
	ld	bc,wChannelFreqs+0*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jp	SSFP_Inst1UpdateFrameEnd	; do nothing else (counter loaded with 0 (256) frame wait)

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_ENVELOPE",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_ENVELOPE",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_ENVELOPE:
	ld	a,[de]
	inc	de
	ld	hl,wChannelVols+CHANNELINDEX
	or	[hl]
	ldh	[rAUD1ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+0],a
	ENDC

	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_STARTFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_STARTFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_STARTFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD1LOW],a
	ld	a,[de]
	inc	de
	ldh	[rAUD1HIGH],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_ENVELOPEVOL",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_ENVELOPEVOL",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_ENVELOPEVOL:
	ld	a,[de]
	inc	de
	ldh	[rAUD1ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+0],a
	ENDC

	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_STARTENVVOLFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_STARTENVVOLFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_STARTENVVOLFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD1ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+0],a
	ENDC

	ld	a,[de]
	inc	de
	ldh	[rAUD1LOW],a
	ld	a,[de]
	inc	de
	ldh	[rAUD1HIGH],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_PANMID",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_PANMID",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_PANMID:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_1_LEFT|AUDTERM_1_RIGHT
	or	[hl]
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_PANRIGHT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_PANRIGHT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_PANRIGHT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_1_RIGHT
	or	[hl]
	and	~AUDTERM_1_LEFT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_PANLEFT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_PANLEFT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_PANLEFT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_1_LEFT
	or	[hl]
	and	~AUDTERM_1_RIGHT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_PULSELEN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_PULSELEN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_PULSELEN:
	ld	a,[de]
	inc	de
	ldh	[rAUD1LEN],a
	jp	SSFP_Inst1Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst1_CMD_SWEEP",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst1_CMD_SWEEP",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst1_CMD_SWEEP:
	ld	a,[de]
	inc	de
	ldh	[rAUD1SWEEP],a
	jp	SSFP_Inst1Update


; ==========================================================================================================================
; channel 2

CHANNELINDEX	SET	1

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2Update",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2Update",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2Update:
	ld	a,[de]
	inc	de
	ld	hl,SSFP_Inst2_JumpTable
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_FRAMEEND",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_FRAMEEND",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_FRAMEEND:
	ld	a,[de]
	inc	de
	ld	[wMusicSFXInstPause+CHANNELINDEX],a	; load new pause
	jp	SSFP_Inst2UpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_START",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_START",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_START:
	ld	a,[wChannelFreqs+CHANNELINDEX*2]
	ldh	[rAUD2LOW],a
	ld	a,[de]
	inc	de
	ld	hl,wChannelFreqs+CHANNELINDEX*2+1
	or	[hl]
	ldh	[rAUD2HIGH],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_END",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_END",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_END:
	dec	de	; rewind counter
	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL2,a
	jp	nz,SSFP_Inst2UpdateFrameEnd
	or	SFXLOCKF_2_LEFT|SFXLOCKF_2_RIGHT
	ld	[wSoundFXLock],a

	; restore music freq
	ld	hl,wChannelMusicFreqs+1*2
	ld	bc,wChannelFreqs+1*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jp	SSFP_Inst2UpdateFrameEnd	; do nothing else (counter loaded with 0 (256) frame wait)

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_ENVELOPE",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_ENVELOPE",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_ENVELOPE:
	ld	a,[de]
	inc	de
	ld	hl,wChannelVols+CHANNELINDEX
	or	[hl]
	ldh	[rAUD2ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+1],a
	ENDC

	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_STARTFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_STARTFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_STARTFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD2LOW],a
	ld	a,[de]
	inc	de
	ldh	[rAUD2HIGH],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_ENVELOPEVOL",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_ENVELOPEVOL",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_ENVELOPEVOL:
	ld	a,[de]
	inc	de
	ldh	[rAUD2ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+1],a
	ENDC

	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_STARTENVVOLFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_STARTENVVOLFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_STARTENVVOLFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD2ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+1],a
	ENDC

	ld	a,[de]
	inc	de
	ldh	[rAUD2LOW],a
	ld	a,[de]
	inc	de
	ldh	[rAUD2HIGH],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_PANMID",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_PANMID",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_PANMID:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_2_LEFT|AUDTERM_2_RIGHT
	or	[hl]
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_PANRIGHT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_PANRIGHT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_PANRIGHT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_2_RIGHT
	or	[hl]
	and	~AUDTERM_2_LEFT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_PANLEFT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_PANLEFT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_PANLEFT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_2_LEFT
	or	[hl]
	and	~AUDTERM_2_RIGHT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_PULSELEN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_PULSELEN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_PULSELEN:
	ld	a,[de]
	inc	de
	ldh	[rAUD2LEN],a
	jp	SSFP_Inst2Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst2_CMD_SWEEP",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst2_CMD_SWEEP",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst2_CMD_SWEEP:
	inc	de	; ignore
	jp	SSFP_Inst2Update


; ==========================================================================================================================
; channel 3

CHANNELINDEX	SET	2

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3Update",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3Update",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3Update:
	ld	a,[de]
	inc	de
	ld	hl,SSFP_Inst3_JumpTable
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_FRAMEEND",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_FRAMEEND",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_FRAMEEND:
	ld	a,[de]
	inc	de
	ld	[wMusicSFXInstPause+CHANNELINDEX],a	; load new pause
	jp	SSFP_Inst3UpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_START",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_START",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_START:
	ld	a,[wChannelFreqs+CHANNELINDEX*2]
	ldh	[rAUD3LOW],a
	ld	a,AUD3ENA_ON
	ldh	[rAUD3ENA],a
	ld	a,[de]
	inc	de
	ld	hl,wChannelFreqs+CHANNELINDEX*2+1
	or	[hl]
	ldh	[rAUD3HIGH],a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_END",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_END",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_END:
	dec	de	; rewind counter
	xor	a
	ldh	[rAUD3ENA],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	ld	[wVUMeters+2],a
	ENDC

	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL3,a
	jp	nz,SSFP_Inst3UpdateFrameEnd
	or	SFXLOCKF_3_LEFT|SFXLOCKF_3_RIGHT
	ld	[wSoundFXLock],a

	; restore music freq
	ld	hl,wChannelMusicFreqs+2*2
	ld	bc,wChannelFreqs+2*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jp	SSFP_Inst3UpdateFrameEnd	; do nothing else (counter loaded with 0 (256) frame wait)

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_ENVELOPE",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_ENVELOPE",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_ENVELOPE:
	ld	a,[de]
	inc	de
	ld	hl,wChannelVols+CHANNELINDEX
	or	[hl]
	ldh	[rAUD3LEVEL],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	sla	a
	and	$0C
	dec	a
	xor	$0C
	ld	[wVUMeters+2],a
	ENDC

	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_STARTFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_STARTFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_STARTFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD3LOW],a
	ld	a,AUD3ENA_ON
	ldh	[rAUD3ENA],a
	ld	a,[de]
	inc	de
	ldh	[rAUD3HIGH],a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_ENVELOPEVOL",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_ENVELOPEVOL",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_ENVELOPEVOL:
	ld	a,[de]
	inc	de
	ldh	[rAUD3LEVEL],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	sla	a
	and	$0C
	dec	a
	xor	$0C
	ld	[wVUMeters+2],a
	ENDC

	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_STARTENVVOLFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_STARTENVVOLFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_STARTENVVOLFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD3LEVEL],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	sla	a
	and	$0C
	dec	a
	xor	$0C
	ld	[wVUMeters+2],a
	ENDC

	ld	a,[de]
	inc	de
	ldh	[rAUD3LOW],a
	ld	a,AUD3ENA_ON
	ldh	[rAUD3ENA],a
	ld	a,[de]
	inc	de
	ldh	[rAUD3HIGH],a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_PANMID",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_PANMID",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_PANMID:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_3_LEFT|AUDTERM_3_RIGHT
	or	[hl]
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_PANRIGHT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_PANRIGHT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_PANRIGHT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_3_RIGHT
	or	[hl]
	and	~AUDTERM_3_LEFT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_PANLEFT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_PANLEFT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_PANLEFT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_3_LEFT
	or	[hl]
	and	~AUDTERM_3_RIGHT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_WAVE",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_WAVE",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_WAVE:
	ld	hl,wMusicSFXInstChnl3WaveID
	ld	a,[de]
	inc	de
	cp	255
	jr	z,.loadlong
	cp	[hl]
	jr	z,.skip

.loadlong:
	ld	hl,_AUD3WAVERAM
	xor	a
	ldh	[rAUD3ENA],a
	REPT	16
	ld	a,[de]
	inc	de
	ld	[hl+],a
	ENDR
	jp	SSFP_Inst3Update

.skip:
	ld	a,e
	add	16
	ld	e,a
	ld	a,d
	adc	0
	ld	d,a
	jp	SSFP_Inst3Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst3_CMD_LEN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst3_CMD_LEN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst3_CMD_LEN:
	ld	a,[de]
	inc	de
	ldh	[rAUD3LEN],a
	jp	SSFP_Inst3Update


; ==========================================================================================================================
; channel 4

CHANNELINDEX	SET	3

IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4Update",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4Update",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4Update:
	ld	a,[de]
	inc	de
	ld	hl,SSFP_Inst4_JumpTable
	add	a
	add	l
	ld	l,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	jp	hl

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_FRAMEEND",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_FRAMEEND",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_FRAMEEND:
	ld	a,[de]
	inc	de
	ld	[wMusicSFXInstPause+CHANNELINDEX],a	; load new pause
	jp	SSFP_Inst4UpdateFrameEnd

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_START",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_START",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_START:
	ld	a,[de]
	inc	de
	ldh	[rAUD4GO],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_END",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_END",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_END:
	dec	de	; rewind counter
	ld	a,[wSoundFXLock]
	bit	SFXLOCKB_CHANNEL4,a
	jp	nz,SSFP_Inst4UpdateFrameEnd
	or	SFXLOCKF_4_LEFT|SFXLOCKF_4_RIGHT
	ld	[wSoundFXLock],a

	; restore music freq
	ld	hl,wChannelMusicFreqs+3*2
	ld	bc,wChannelFreqs+3*2
	ld	a,[hl+]
	ld	[bc],a
	inc	c
	ld	a,[hl]
	ld	[bc],a

	jp	SSFP_Inst4UpdateFrameEnd	; do nothing else (counter loaded with 0 (256) frame wait)

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_ENVELOPE",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_ENVELOPE",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_ENVELOPE:
	ld	a,[de]
	inc	de
	ld	hl,wChannelVols+CHANNELINDEX
	or	[hl]
	ldh	[rAUD4ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+3],a
	ENDC

	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_STARTFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_STARTFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_STARTFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD4POLY],a
	ld	a,[de]
	inc	de
	ldh	[rAUD4GO],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_ENVELOPEVOL",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_ENVELOPEVOL",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_ENVELOPEVOL:
	ld	a,[de]
	inc	de
	ldh	[rAUD4ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+3],a
	ENDC

	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_STARTENVVOLFREQ",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_STARTENVVOLFREQ",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_STARTENVVOLFREQ:
	ld	a,[de]
	inc	de
	ldh	[rAUD4ENV],a

	IF (SOUNDSYSTEM_ENABLE_VUM)
	swap	a
	and	$0F
	ld	[wVUMeters+3],a
	ENDC

	ld	a,[de]
	inc	de
	ldh	[rAUD4POLY],a
	ld	a,[de]
	inc	de
	ldh	[rAUD4GO],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_PANMID",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_PANMID",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_PANMID:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_4_LEFT|AUDTERM_4_RIGHT
	or	[hl]
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_PANRIGHT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_PANRIGHT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_PANRIGHT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_4_RIGHT
	or	[hl]
	and	AUDTERM_4_LEFT ^ $FF	; same as ~, but ~ here triggers a false warning
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_PANLEFT",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_PANLEFT",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_PANLEFT:
	ld	hl,wMusicSFXPanning
	ld	a,AUDTERM_4_LEFT
	or	[hl]
	and	~AUDTERM_4_RIGHT
	ld	[hl],a
	ldh	[rAUDTERM],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_POLYLOAD",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_POLYLOAD",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_POLYLOAD:
	ld	a,[de]
	inc	de
	ldh	[rAUD4POLY],a
	jp	SSFP_Inst4Update

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem_SSFP_Inst4_CMD_LEN",ROM0
ELSE
SECTION	"SoundSystem_SSFP_Inst4_CMD_LEN",ROMX,BANK[SOUNDSYSTEM_CODE_BANK]
ENDC

SSFP_Inst4_CMD_LEN:
	ld	a,[de]
	inc	de
	ldh	[rAUD4LEN],a
	jp	SSFP_Inst4Update


;***************************************************************************************************************************
;*	tables of fx/command handlers
;***************************************************************************************************************************
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Music FX Table 1",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Music FX Table 1",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_MusicFX_JumpTable1:
	DW	$0000	; dummy
	DW	SSFP_MUSIC_FX1_VIB1
	DW	SSFP_MUSIC_FX1_VIB2
	IF DEF(MUSIC_FX_DUALFREQ1)
	DW	SSFP_MUSIC_FX1_DUALFREQ1
	ENDC
	IF DEF(MUSIC_FX_DUALFREQ2)
	DW	SSFP_MUSIC_FX1_DUALFREQ2
	ENDC
	DW	SSFP_MUSIC_FX1_TF1
	DW	SSFP_MUSIC_FX1_TF2
	DW	SSFP_MUSIC_FX1_TF3
	DW	SSFP_MUSIC_FX1_PITCHUP
	DW	SSFP_MUSIC_FX1_PITCHDOWN

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Music FX Table 2",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Music FX Table 2",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_MusicFX_JumpTable2:
	DW	$0000	; dummy
	DW	SSFP_MUSIC_FX2_VIB1
	DW	SSFP_MUSIC_FX2_VIB2
	IF DEF(MUSIC_FX_DUALFREQ1)
	DW	SSFP_MUSIC_FX2_DUALFREQ1
	ENDC
	IF DEF(MUSIC_FX_DUALFREQ2)
	DW	SSFP_MUSIC_FX2_DUALFREQ2
	ENDC
	DW	SSFP_MUSIC_FX2_TF1
	DW	SSFP_MUSIC_FX2_TF2
	DW	SSFP_MUSIC_FX2_TF3
	DW	SSFP_MUSIC_FX2_PITCHUP
	DW	SSFP_MUSIC_FX2_PITCHDOWN

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Music FX Table 3",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Music FX Table 3",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_MusicFX_JumpTable3:
	DW	$0000	; dummy
	DW	SSFP_MUSIC_FX3_VIB1
	DW	SSFP_MUSIC_FX3_VIB2
	IF DEF(MUSIC_FX_DUALFREQ1)
	DW	SSFP_MUSIC_FX3_DUALFREQ1
	ENDC
	IF DEF(MUSIC_FX_DUALFREQ2)
	DW	SSFP_MUSIC_FX3_DUALFREQ2
	ENDC
	DW	SSFP_MUSIC_FX3_TF1
	DW	SSFP_MUSIC_FX3_TF2
	DW	SSFP_MUSIC_FX3_TF3
	DW	SSFP_MUSIC_FX3_PITCHUP
	DW	SSFP_MUSIC_FX3_PITCHDOWN

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Music Table",ROM0,ALIGN[6]
ELSE
SECTION	"SoundSystem Music Table",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[6]
ENDC

SSFP_Music_JumpTable:
	DW	SSFP_MUSIC_CMD_ENDOFFRAME
	DW	SSFP_MUSIC_CMD_PLAYINSTNOTE
	DW	SSFP_MUSIC_CMD_PLAYINST
	DW	SSFP_MUSIC_CMD_SETVOLUME
	IF DEF(MUSIC_CMD_SETPANNING)
	DW	SSFP_MUSIC_CMD_SETPANNING
	ENDC
	DW	SSFP_MUSIC_CMD_VIBRATO_ON
	IF DEF(MUSIC_CMD_DUALNOTE_ON)
	DW	SSFP_MUSIC_CMD_DUALNOTE_ON
	ENDC
	DW	SSFP_MUSIC_CMD_EFFECT_OFF
	IF DEF(MUSIC_CMD_SETMASTERVOLUME)
	DW	SSFP_MUSIC_CMD_SETMASTERVOLUME
	ENDC
	DW	SSFP_MUSIC_CMD_SYNCFLAG
	DW	SSFP_MUSIC_CMD_ENDOFPATTERN
	IF DEF(MUSIC_CMD_LOOPPATTERN)
	DW	SSFP_MUSIC_CMD_LOOPPATTERN
	ENDC
	DW	SSFP_MUSIC_CMD_GOTOORDER
	DW	SSFP_MUSIC_CMD_ENDOFSONG
	DW	SSFP_MUSIC_CMD_SETSPEED
	DW	SSFP_MUSIC_CMD_ENDOFFRAME1X
	DW	SSFP_MUSIC_CMD_ENDOFFRAME2X
	DW	SSFP_MUSIC_CMD_ENDOFFRAME3X
	DW	SSFP_MUSIC_CMD_ENDOFFRAME4X
	DW	SSFP_MUSIC_CMD_PITCHUP_ON
	DW	SSFP_MUSIC_CMD_PITCHDOWN_ON
	DW	SSFP_MUSIC_CMD_TRIPLENOTE_ON
	DW	SSFP_MUSIC_CMD_EXTRA

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Inst1 Table",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Inst1 Table",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_Inst1_JumpTable:	; common commands
	DW	SSFP_Inst1_CMD_FRAMEEND
	DW	SSFP_Inst1_CMD_START
	DW	SSFP_Inst1_CMD_END
	DW	SSFP_Inst1_CMD_ENVELOPE
	DW	SSFP_Inst1_CMD_STARTFREQ
	DW	SSFP_Inst1_CMD_ENVELOPEVOL
	DW	SSFP_Inst1_CMD_STARTENVVOLFREQ
	DW	SSFP_Inst1_CMD_PANMID
	DW	SSFP_Inst1_CMD_PANRIGHT
	DW	SSFP_Inst1_CMD_PANLEFT
	; specific commands
	DW	SSFP_Inst1_CMD_PULSELEN
	DW	SSFP_Inst1_CMD_SWEEP

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Inst2 Table",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Inst2 Table",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_Inst2_JumpTable:	; common commands
	DW	SSFP_Inst2_CMD_FRAMEEND
	DW	SSFP_Inst2_CMD_START
	DW	SSFP_Inst2_CMD_END
	DW	SSFP_Inst2_CMD_ENVELOPE
	DW	SSFP_Inst2_CMD_STARTFREQ
	DW	SSFP_Inst2_CMD_ENVELOPEVOL
	DW	SSFP_Inst2_CMD_STARTENVVOLFREQ
	DW	SSFP_Inst2_CMD_PANMID
	DW	SSFP_Inst2_CMD_PANRIGHT
	DW	SSFP_Inst2_CMD_PANLEFT
	; specific commands
	DW	SSFP_Inst2_CMD_PULSELEN
	DW	SSFP_Inst2_CMD_SWEEP

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Inst3 Table",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Inst3 Table",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_Inst3_JumpTable:	; common commands
	DW	SSFP_Inst3_CMD_FRAMEEND
	DW	SSFP_Inst3_CMD_START
	DW	SSFP_Inst3_CMD_END
	DW	SSFP_Inst3_CMD_ENVELOPEVOL	; prevent crash
	DW	SSFP_Inst3_CMD_STARTFREQ
	DW	SSFP_Inst3_CMD_ENVELOPEVOL
	DW	SSFP_Inst3_CMD_STARTENVVOLFREQ
	DW	SSFP_Inst3_CMD_PANMID
	DW	SSFP_Inst3_CMD_PANRIGHT
	DW	SSFP_Inst3_CMD_PANLEFT
	; specific commands
	DW	SSFP_Inst3_CMD_WAVE
	DW	SSFP_Inst3_CMD_LEN

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Inst4 Table",ROM0,ALIGN[5]
ELSE
SECTION	"SoundSystem Inst4 Table",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[5]
ENDC

SSFP_Inst4_JumpTable:	; common commands
	DW	SSFP_Inst4_CMD_FRAMEEND
	DW	SSFP_Inst4_CMD_START
	DW	SSFP_Inst4_CMD_END
	DW	SSFP_Inst4_CMD_ENVELOPE
	DW	SSFP_Inst4_CMD_STARTFREQ
	DW	SSFP_Inst4_CMD_ENVELOPEVOL
	DW	SSFP_Inst4_CMD_STARTENVVOLFREQ
	DW	SSFP_Inst4_CMD_PANMID
	DW	SSFP_Inst4_CMD_PANRIGHT
	DW	SSFP_Inst4_CMD_PANLEFT
	; specific commands
	DW	SSFP_Inst4_CMD_POLYLOAD
	DW	SSFP_Inst4_CMD_LEN

; --------------------------------------------------------------------------------------------------------------------------
IF (SOUNDSYSTEM_CODE_BANK == 0)
SECTION	"SoundSystem Frequency Table",ROM0,ALIGN[8]
ELSE
SECTION	"SoundSystem Frequency Table",ROMX,BANK[SOUNDSYSTEM_CODE_BANK],ALIGN[8]
ENDC

FrequencyTable:
	DW	$0020,$0091,$00FC,$0160,$01C0,$0219,$026E,$02BE,$030a,$0351,$0394,$03D4
	DW	$0410,$0448,$047E,$04B0,$04E0,$050D,$0537,$055F,$0585,$05A8,$05Ca,$05EA
	DW	$0608,$0624,$063F,$0658,$0670,$0686,$069C,$06B0,$06C2,$06D4,$06E5,$06F5
	DW	$0704,$0712,$071F,$072C,$0738,$0743,$074E,$0758,$0761,$076a,$0773,$077A
	DW	$0782,$0789,$0790,$0796,$079C,$07A2,$07A7,$07AC,$07B1,$07B5,$07B9,$07BD
	DW	$07C1,$07C5,$07C8,$07CB,$07CE,$07D1,$07D3,$07D6,$07D8,$07DB,$07DD,$07DF
