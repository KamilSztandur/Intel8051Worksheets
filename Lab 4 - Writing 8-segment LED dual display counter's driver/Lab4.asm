;		.-------------------------------.
;		|   Czekaj Bartłomiej 307336	|
;		|     Sztandur Kamil 307354	|
;		*-------------------------------*

ORG 0000h
	ljmp init			; Inicjalizuj licznik

ORG 000Bh				; Wektor przerwania T0
	lcall reload_T0
	ljmp incr_by_one 		; Obsłużenie przerwania

reload_T0:
	MOV TL0, #088h			; | Zresetowanie wartości timera
	MOV TH0, #0FFh			; |
	RET
	
init:
	MOV IE, #0h			; Wyłączenie wszystkich przerwań
	CLR TR0				; Zatrzymanie timera T0
	CLR TF0				; Wyzerowanie flagi przepełnienia
	MOV TMOD, #01h			; Inicjalizacja timera T0
	lcall reload_T0			; Ustawienie wartości timera
	MOV IP, #0h			; Ustawienie priorytetu przerwań na niski
	MOV IE, #82h			; Odblokuj przerwania timera T0
	MOV DPTR, #3000h		; Ustaw indeks początkowy
	lcall reset_counter
	SETB TR0			; Uruchomienie odliczania

main:	sjmp main			; Nieskończona pętla (czeka na przerwanie)

reset_counter:
	MOV 30h, #0h			; Reset rejestru liczącego jedności
	MOV 31h, #0h			; Reset rejestru liczącego dziesiątki
	MOV P2, #11000000b		; Wyświetl znak "0" na wyświetlaczu dziesiątek
	MOV P3, #11000000b		; Wyświetl znak "0" na wyświetlaczu jedności
	RET

incr_by_one:
	PUSH PSW			; Zrzuć na stos rejestr znaczników
	PUSH ACC			; Zrzuć na stos akumulator
	INC 30h				; Zwiększ rejestr jedności o 1
	MOV A, 30h			; | Przez akumulator sprawdź, czy rejestr jedności
	CJNE A, #1010b, update_LED_unit	; | nie przekroczył 10, jeżeli nie to aktualizuj ekran.
	ljmp incr_decs			; Jeżeli przekroczył, to zwiększ liczbę dziesiątek

incr_decs:
	INC 31h				; Zwiększ rejestr dziesiątek o 1
	MOV 30h, #0h			; Wyzeruj rejestr jedności
	MOV A, 31h			; | Przez akumulator sprawdź, czy rejestr dziesiątek
	CJNE A, #1010b, update_LED_tens	; | nie przekroczył 10, jeżeli nie to aktualizuj ekran.
	ljmp overflowed			; Jeżeli przekroczył, to jest 100 i zresetuj go

overflowed:
	lcall reset_counter		; Całkowity reset licznika
	POP ACC				; Odzyskaj wartość akumulatora ze stosu
	POP PSW				; Odzyskaj wartość rejestru znaczników ze stosu
	RETI				; Powrót z przerwania

update_LED_unit:
	MOV A, 30h			; Pobierz liczbę binarną odpowiadającą cyfrze
	MOVC A, @A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do A
	MOV P3, A			; Wyświetl nową cyfrę jedności
	POP ACC				; Odzyskaj wartość akumulatora ze stosu
	POP PSW				; Odzyskaj wartość rejestru znaczników ze stosu
	RETI				; Powrót z przerwania

update_LED_tens:
	MOV P3, #11000000b		; Wyświetl znak "0" na wyświetlaczu jedności
	MOV A, 31h			; Pobierz liczbę binarną odpowiadającą cyfrze
	MOVC A, @A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do A
	MOV P2, A			; Wyświetl nową cyfrę dziesiątek
	POP ACC				; Odzyskaj wartość akumulatora ze stosu
	POP PSW				; Odzyskaj wartość rejestru znaczników ze stosu
	RETI				; Powrót z przerwania

ORG 3000h ; Tablica przechowująca właściwe sekwencje bitów dla znaków wyświetlacza
	DB 11000000b ;0
	DB 11111001b ;1
	DB 10100100b ;2
	DB 10110000b ;3
	DB 10011001b ;4
	DB 10010010b ;5
	DB 10000010b ;6
	DB 11111000b ;7
	DB 10000000b ;8
	DB 10010000b ;9
