;		.-------------------------------.
;		|   Czekaj Bartłomiej 307336	|
;		|     Sztandur Kamil 307354	|
;		*-------------------------------*

ORG 0000h
	lcall reload_T0			; Reset licznika
	ljmp init			; Inicjalizuj licznik

ORG 000Bh				; Wektor przerwania T0
	lcall reload_T0
	ljmp incr_by_one 		; Obsłużenie przerwania

reload_T0:
	MOV TL0, #0FDh			; | Zresetowanie wartości timera
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
	INC 30h				; Zwiększ rejestr jedności o 1
	MOV A, 30h			; Przez akumulator sprawdź, czy rejestr jedności
	CJNE A, #1010b, update_LED	; nie przekroczył 10, jeżeli nie to aktualizuj ekran.
	ljmp incr_decs			; Jeżeli przekroczył, to zwiększ liczbę dziesiątek

incr_decs:
	INC 31h				; Zwiększ rejestr dziesiątek o 1
	MOV 30h, #0h			; Wyzeruj rejestr jedności
	MOV A, 31h			; Przez akumulator sprawdź, czy rejestr dziesiątek
	CJNE A, #1010b, update_LED	; nie przekroczył 10, jeżeli nie to aktualizuj ekran.
	ljmp overflowed			; Jeżeli przekroczył, to jest 100 i zresetuj go

overflowed:
	lcall reset_counter		; Całkowity reset licznika
	RETI

update_LED:	
	PUSH PSW		; Zrzuć na stos rejestr znaczników
	PUSH ACC		; Zrzuć na stos akumulator
	
	lcall parse_units	; Odczytaj sekwencję bitów ekranu dla aktualnej wartości
	MOV R0, A		; rejestru JEDNOŚCI i za pomocą akumulatora podaj odczytaną
	MOV P3, R0		; sekwencję do portu wyświetlacza jedności P3
	
	lcall parse_decs	; Odczytaj sekwencję bitów ekranu dla aktualnej wartości
	MOV R1, A		; rejestru DZIESIiĄEK i za pomocą akumulatora podaj odczytaną
	MOV P2, R1		; sekwencję do portu wyświetlacza dziesiątek P2
	
	POP ACC			; Odzyskaj wartość akumulatora ze stosu
	POP PSW			; Odzyskaj wartość rejestru znaczników ze stosu
	RETI

parse_units:	; Załaduj do akumulatora sekwencje bitów wyświetlacza dla cyfry jedności
	MOV A, 30h
	call set_corr_char_DPTR_index	; Ustaw prawidłowy indeks wskaźnika danych
	MOVC A, @A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do AC
	RET

parse_decs:	; Załaduj do akumulatora sekwencje bitów wyświetlacza dla cyfry dziesiątek
	MOV A, 31h
	call set_corr_char_DPTR_index	; Ustaw prawidłowy indeks wskaźnika danych
	MOVC A,@A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do AC
	RET

set_corr_char_DPTR_index:
	MOV DPTR, #3000h		; Ustaw indeks początkowy
	CJNE A, #00h, increment_dptr	; Wykonaj A iteracji, ustaw DPTR do wielkości A
DPTR_is_set:
	CLR A	; Rejestr DPTR ustawiony, zresetuj akumulator do wartości zerowej
	RET

increment_dptr:				; Iteracyjnie zwiększaj DPTR aż nie będzie równy A
	INC DPTR			; Główna pętla ustalająca DPTR
	DJNZ A, increment_dptr		; Dekrementuj A aż nie będzie równe 0
	LJMP DPTR_is_set		; Zakres nieprzepełniony, DPTR ustalone. Kończymy.


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