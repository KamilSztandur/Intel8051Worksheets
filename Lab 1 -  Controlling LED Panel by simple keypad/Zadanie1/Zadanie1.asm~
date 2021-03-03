;	.-------------------------------.
;	|   Czekaj Bartłomiej 307336	|
;	|     Sztandur Kamil 307354	|
;	*-------------------------------*

ORG 0000h
	ljmp main		; Skok do ciała głównej instrukcji.

ORG 0250h
main:
	MOV A, #11111110b	; Stan linijki świetlnej: 1 - zgaszone, 0 - zapalone.
loop:	MOV P3, A		; Zaktualizowanie stanu panelu LEDowego.
	lcall switch		; Przesunięcie linijki świetlnej, jeżeli potrzebne.
	ljmp loop		; Nieskończone zapętlenie procesu.

ORG 0500h
switch:				; Ustalenie, jakie przesunięcie należy wykonać.
	jb P2.0, firstON
	jnb P2.0, firstOFF
	RET
	
firstON:			; Port pierwszego klucza jest aktywny.
	JNB P2.1, switch_left	; Jeżeli oba aktywne, pomiń. Inaczej przesuń w lewo.
	RET

firstOFF:			; Port pierwszego klucza jest nieaktywny.
	JB P2.1, switch_right	; Jeżeli oba nieaktywne, pomiń. Inaczej przesuń w prawo.
	RET

switch_left:
	RL A			; Przesunięcie w lewo.
	RET
	
switch_right:
	RR A			; Przesunięcie w lewo.
	RET
END