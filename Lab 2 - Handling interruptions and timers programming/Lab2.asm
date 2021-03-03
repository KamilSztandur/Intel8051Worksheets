;	.-------------------------------.
;	|   Czekaj Bartłomiej 307336	|
;	|     Sztandur Kamil 307354	|
;	*-------------------------------*

ORG 0000h
	ljmp init	; Inicjalizuj licznik

ORG 000Bh		; Wektor przerwania T0
	lcall reload_T0	; Reset licznika
	ljmp send_if_req; Obsłużenie przerwania

init:
	MOV IE, #0h	; Wyłączenie wszystkich przerwań
	CLR TR0		; Zatrzymanie timera T0 
	CLR TF0		; Wyzerowanie flagi przepełnienia
	MOV TMOD, #01h	; Inicjalizacja timera T0
	lcall reload_T0	; Ustawienie wartości timera
	MOV IP, #0h	; Ustawienie priorytetu przerwań na niski
	MOV IE, #82h	; Odblokuj przerwania timera T0
	SETB TR0	; Uruchomienie odliczania
	MOV C, 0	; | Ustawienie wartości początkowej rejestru F1
	MOV PSW.1, C 	; | przechowującego "stan poprzedni" przycisku na 0
main:
	sjmp main	; Nieskończona pętla (czeka na przerwanie)

reload_T0:
	MOV TL0, #0F2h	; Ustawienie wartości timera
	MOV TH0, #0FFh	;
	RET

send_if_req:
	JB P1.0, save	; Sprawdź, czy aktualnie przycisk jest otwarty.
	JNB PSW.1, save	; Sprawdź, czy przed chwilą był zamknięty.
	lcall send	; Oba niespełnione warunki oznaczaja, że jest w spadku
save:
	MOV C, P1.0	; | Zapamiętaj aktualną wartość jako poprzednią.
	MOV PSW.1, C	; | Jest ona kluczowa do określenia czy jest spadek.
	RETI

send:
	PUSH PSW	; Zapisz wartości znaczników
	PUSH ACC	; Zapisz wartość akumulatora
	MOV A, P2	; | Przesłanie wartości z P2
	MOV P3, A	; | na P3 poprzez akumulator.
	POP ACC		; Odzyskaj wartość akumulatora
	POP PSW		; Odzyskaj wartości znaczników
	RET
END