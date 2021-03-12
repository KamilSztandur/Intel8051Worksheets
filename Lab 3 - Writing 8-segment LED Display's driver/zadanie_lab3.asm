;		.-------------------------------.
;		|   Czekaj Bartłomiej 307336	|
;		|     Sztandur Kamil 307354	|
;		*-------------------------------*

ORG 0000h
	ljmp init			; Inicjalizuj licznik

ORG 000Bh				; Wektor przerwania T0
	lcall reload_T0			; Reset licznika
	ljmp update_LED 		; Obsłużenie przerwania

reload_T0:
	MOV TL0, #0F2h			; | Zresetowanie wartości timera
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
	SETB TR0			; Uruchomienie odliczania
	
	lcall set_zero			; Ustawienie "zera" na wyświetlaczu
main:	sjmp main			; Nieskończona pętla (czeka na przerwanie)


update_LED:
	MOV R0, P1			; Załadowanie wartości portu wejściowego do R0 
	ANL A, R0			; Sprawdź, czy były zmiany na bitach portu P1
	CJNE A, #11111111b, update 	; Jeżeli były na jakimkolwiek, to zmień znak
	RETI				; Jeżeli nic się nie zmieniło, nie zmieniaj znaku

update:				; Wyświetla konkretny znak na podstawie danych wejściowych
	MOV A, P1 		; Zapisz aktualną wartość portu wejściowego do akumulatora
	PUSH PSW		; Zapisz wartości znaczników na stos
	PUSH ACC		; Zapisz wartość akumulatora na stos
	
	lcall find_corr_char 	; Załaduj do A sekwencję bitów znaku dla danego wejścia
	MOV R0, A		; | Przepisz sekwencję bitów tego znaku z akumulatora
	MOV P3, R0		; | do portu wyświetlacza P3, korzystając z R0
	
	POP ACC			; Odzyskaj wartość akumulatora ze stosu
	POP PSW			; Odzyskaj wartości znaczników ze stosu
	RETI

set_zero:
	MOV P3, #11000000b		; Wyświetl znak "0" na wyświetlaczu
	RET


find_corr_char:
	MOV A, P1
	call set_corr_char_DPTR_index	; Ustaw prawidłowy indeks wskaźnika danych
	MOVC A,@A+DPTR			; Pobierz sekwencję bitów szukanego znaku do AC
	RET

set_corr_char_DPTR_index:
	CPL A	; Odwróć bity A, bo segmenty wyświetlacza są zapalone dla stanów niskich
	MOV DPTR, #3000h		; Ustaw indeks początkowy
	CJNE A, #00h, increment_dptr	; Wykonaj A iteracji, ustaw DPTR do wielkości A
DPTR_is_set:
	CLR A	; Rejestr DPTR ustawiony, zresetuj akumulator do wartości zerowej
	RET
	
increment_dptr:				; Iteracyjnie zwiększaj DPTR aż nie będzie równy A
	MOV R5, #19h			; Wartość R5 mówi ile zostało do końca zakresu
loop:					; Główna pętla ustalająca DPTR
	INC DPTR			; Zwiększ DPTR o 1
	DEC R5				; Zmniejsz R5 o 1
	CJNE R5, #0h, cont		; Jeżeli zakres nie został przepełniony, kontynuuj
	LJMP DPTR_is_set 		; Zakres przepełniony, więc kończymy pracę.
cont:	DJNZ A, loop			; Dekrementuj A aż nie będzie równe 0
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
	DB 10001000b ;A
	DB 10000011b ;b
	DB 10100111b ;c
	DB 11000110b ;C
	DB 10100001b ;d
	DB 10000110b ;E
	DB 10001110b ;F
	DB 11000010b ;G
	DB 10001011b ;h
	DB 10001001b ;H
	DB 11000111b ;L
	DB 10100011b ;o
	DB 10001100b ;P
	DB 11100011b ;u
	DB 11000001b ;U
	DB 10111111b ;-
	; Zmniejsz dopuszczalny zakres DPTR w 'increment_dptr', gdy dodajesz elementy