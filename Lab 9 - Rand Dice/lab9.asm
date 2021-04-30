;		.-------------------------------.
;		|   Czekaj Bartłomiej 307336	|
;		|     Sztandur Kamil 307354	|
;		*-------------------------------*

ORG 0000h
	ljmp init			; Inicjalizuj licznik
ORG 0003h				; Wektor przerwania INT0
	lcall keyboard_interruption	; przerwanie z portu 3 bit 2
	RETI
ORG 000Bh				; Wektor przerwania T0
	lcall reload_T0
	ljmp check_status 		; Obsłużenie przerwania od T0


keyboard_interruption:
	JNB P3.2, reset_counter		; Reset licznika jeśli pin 2 zwarty do masy

reload_T0:
	MOV TL0, #0D2h			; | Zresetowanie wartości timera
	MOV TH0, #0FFh			; |
	RET
set_timer_delay:
	MOV TL0, #000h			; | ustawienie opóźnienia na wyświetlenie wylosowanej cyfry
	MOV TH0, #0FFh			; |
	RET

init:
	MOV IE, #0h			; Wyłączenie wszystkich przerwań
	CLR TR0				; Zatrzymanie timera T0
	CLR TF0				; Wyzerowanie flagi przepełnienia
	MOV TMOD, #17			; Inicjalizacja timera T0
	lcall reload_T0			; Ustawienie wartości timera
	MOV IP, #4h			; Ustawienie priorytetu przerwań
	MOV IE, #83h			; Odblokuj przerwania timera T0 i klawiatury(port 3.2)
	MOV DPTR, #3000h		; Ustaw indeks początkowy
	lcall reset_counter
	SETB TR0			; Uruchomienie odliczania
	SETB TR1
	SETB IE0			; Uruchomienie przerwań od klawiatury

main:	sjmp main			; Nieskończona pętla (czeka na przerwanie)

reset_counter:
	MOV 30h, #0h			; Reset rejestru liczącego jedności
	MOV 31h, #0h			; Reset rejestru liczącego dziesiątki
	MOV P2, #11000000b		; Wyświetl znak "0" na wyświetlaczu dziesiątek
	MOV P1, #11000000b		; Wyświetl znak "0" na wyświetlaczu jedności
	CLR A
	MOV R1, #0
	JNB P3.2, reset_counter
	RET

check_status:
	JB P3.1, check_if_R0_is_one
	MOV R0, #1
	lcall display_saved_number
	RETI

check_if_R0_is_one:
	CJNE R0, #0, get_random_number
	lcall display_saved_number
	RETI

get_random_number:
	MOV A, TL1
	MOV B, #6
	DIV AB
	MOV A, #1
	ADD A, B
	MOV B, A
	MOV R0, #0
	lcall display_random_number
	RETI

display_random_number:
	MOV A, B			; Pobierz losową liczbę binarną odpowiadającą cyfrze
	MOVC A, @A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do A
	MOV P1, A			; Wyświetl cyfrę jedności
	MOV P2, #11000000b		; Wyświetl znak "0" na wyświetlaczu dziesiątek
	lcall set_timer_delay
	lcall add_number_to_sum
	RET

display_saved_number:
	MOV A, 30h			; Pobierz liczbę binarną odpowiadającą cyfrze
	MOVC A, @A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do A
	MOV P1, A			; Wyświetl nową cyfrę jedności
	MOV A, 31h			; Pobierz liczbę binarną odpowiadającą cyfrze
	MOVC A, @A+DPTR			; Pobierz sekwencję bitów szukanej cyfry do A
	MOV P2, A			; Wyświetl nową cyfrę dziesiątek
	RET

add_number_to_sum:
	MOV A, R1
	ADD A, B
	MOV R1, A
	MOV B, #10
	DIV AB
	CJNE A, #10, not_overflowed
	lcall overflowed
	RET
not_overflowed:
	MOV 30h, B
	MOV 31h, A
	RET

overflowed:
	lcall reset_counter		; Całkowity reset licznika
	RET				; Powrót z przerwania

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

END

