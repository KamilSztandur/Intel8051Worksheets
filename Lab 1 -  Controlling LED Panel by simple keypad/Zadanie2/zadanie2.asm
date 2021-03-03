;	.-------------------------------.
;	|   Czekaj Bartłomiej 307336	|
;	|     Sztandur Kamil 307354	|
;	*-------------------------------*

ORG 0000h
	ljmp main		; Skok do ciała głównej instrukcji.

ORG 0250h
main:
	MOV A, #11111110b	; Stan linijki świetlnej: 1 - zgaszone, 0 - zapalone.
	MOV P3,A		; Ustalamy stan początkowy panelu LED.
	lcall switch_left	; Ponieważ poszątkowo świeci się dioda z prwej strony, rotujemy w lewo.

switch_left:
	RL A			; Rotacja w lewo bitów w akumulatorze.
	MOV P3,A		; Aktualizacja stanu panelu LED.
	jnb acc.7, switch_right ; Jeżeli dorarliśmy do końca panelu z lewej strony, rozpoczyna się rotacja w prawo.
	LJMP switch_left	; Jeśli to jeszcze nie skrajna dioda to ponownie następuje rotacja w lewo.

switch_right:
	RR A			; Rotacja w lewo bitów w akumulatorze.
	MOV P3,A		; Aktualizacja stanu panelu LED.
	jnb acc.0, switch_left  ; Jeżeli zapalona jest skrajna prawa dioda to rozpoczyna się rotacja w lewo.
	LJMP switch_right	; Ponowne wykonanie rotacji w prawo.
END