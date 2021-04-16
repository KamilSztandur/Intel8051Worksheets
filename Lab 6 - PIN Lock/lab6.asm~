;		.-------------------------------.
;		|   Czekaj Bartłomiej 307336	|
;		|     Sztandur Kamil 307354	|
;		*-------------------------------*

ORG 0000h
	ljmp init

ORG 000Bh					; Wektor przerwania T0
	ljmp detect_pressed_key			; Obsłużenie przerwania od T0
	lcall reload_T0

reload_T0:
	MOV TL0, #0F7h				; | Zresetowanie wartości timera
	MOV TH0, #0FFh				; |
	RET

init:
	MOV IE, #0h				; Wyłączenie wszystkich przerwań
	CLR TR0					; Zatrzymanie timera T0
	CLR TF0					; Wyzerowanie flagi przepełnienia
	MOV TMOD, #01h				; Inicjalizacja timera T0
	lcall reload_T0				; Ustawienie wartości timera
	MOV IP, #0h				; Ustawienie priorytetu przerwań na niski
	MOV IE, #82h				; Odblokuj przerwania timera T0
	MOV DPTR, #3000h			; Ustaw indeks początkowy
	MOV 30h, #11111111b			; inicjalizacja wartości w pamięci, tu będziemy przechowywać ostatnią z klawiatury cyfrę
	MOV R0, #0b
	MOV R1, #0b
	MOV R2, #0b
	MOV R3, #11111111b
	MOV R4, #11111111b
	MOV R5, #11111111b
	MOV R6, #11111111b
	MOV R7, #11111111b
	SETB TR0				; Uruchomienie odliczania

main:	sjmp main				; Nieskończona pętla (czeka na przerwanie)
	
indexes_detected:
	lcall get_pressed_key_number		; Pobierz wartość liczby na klawiszu do akumulatora
	lcall reload_t0
	CJNE R7, #0, variable_R7_eq_1 		; Gdy R7 = 1, to wciśnięty klawisz został "odkliknięty"
	CJNE A, 30h, new_value			; | porównanie pobranej z klawiatury liczby z ostatnio pobraną,
	RETI					; | uniemożliwia ponowne wstawienie cyfry z tej samej interakcji

variable_R7_eq_1:
	JMP new_value

new_value:
	MOV R7, #0				; zerujemy R7
	CJNE A, #255, save_current_number	; jeśli wybrano cyfrę to zapisz ją do rejestrów R3-R6
	ljmp show_error_and_reset		; jeśli to nie cyfra to wyświetl błąd

save_current_number:
	MOV P3, #11111111b
	CJNE R3, #11111111b, save_current_number_to_R4 ; jak nie ma miejsca w R3 to do R4 itd...
	MOV R3, A				; jest miejsce
	MOV 30h, A				; zapisanie ostatniej wartości
	RETI
save_current_number_to_R4:
 	CJNE R4, #11111111b, save_current_number_to_R5
	MOV R4, A
	MOV 30h, A
	RETI
save_current_number_to_R5:
	CJNE R5, #11111111b, save_current_number_to_R6
	MOV R5, A
	MOV 30h, A
	RETI

save_current_number_to_R6:
	MOV R6, A 				; git wszystkie cyfry zebrane
	RETI

check_correctness_of_PIN:
	MOV A, #0h
	MOVC A,@A+DPTR				; pobiera z pamięci prawidłową cyfre
	MOV 30h, R3
	CJNE A, 30h, show_error_and_reset	; jeśli nie zgadza się to wyświetli błąd
	
	MOV A, #1h
	MOVC A,@A+DPTR
	MOV 30h, R4
	CJNE A, 30h, show_error_and_reset
	
	MOV A, #2h
	MOVC A,@A+DPTR
	MOV 30h, R5
	CJNE A, 30h, show_error_and_reset
	
	MOV A, #3h
	MOVC A,@A+DPTR
	MOV 30h, R6
	CJNE A, 30h, show_error_and_reset

	jmp correct_PIN				; wszystkie cyfry poprawne, skok do wyświetlenia komunikatu o poprawności
	
correct_PIN:
	MOV P3, #254
	jmp reset_registers			; wyświetliło poprawność, teraz zresetuje rejestry
	
show_error_and_reset:
	MOV P3, #253
	jmp reset_registers			; wyświetliło niepoprawność PIN-u, również zresetuje rejestry
	
reset_registers:				; reset rejestrów + reload timera
	MOV R0, #0b
	MOV R1, #0b
	MOV R2, #0b
	MOV R3, #11111111b
	MOV R4, #11111111b
	MOV R5, #11111111b
	MOV R6, #11111111b
	MOV R7, #11111111b
	lcall reload_t0
	RETI

detect_pressed_key:				; Wykrywanie wciśniętego klawisza
	MOV R0, #00000000b 			; Licznik pomocniczy do określenia wykrycia przycisku
	MOV R1, #11111111b			; Rejestr z indeksem wiersza wciśniętego przycisku
	MOV R2, #11111111b			; Rejestr z indeksem kolumny wciśniętego przycisku

rows:						; WIERSZE
row0:	MOV P1, #11111110b			; Zbadaj ten wiersz
	lcall check				; Sprawdź, czy wykryto w tym rzędzie przycisk
	JNC row1				; Jeżeli nie, to szukaj w następnym
	MOV R1, #00000000b			; Jeżeli tak, to zapisz indeks tego wiersza do R1
	ljmp cols				; Przeszukaj kolumny, bo wiersz już znaleziony

row1:	MOV P1, #11111101b			; Zbadaj ten wiersz
	lcall check				; Sprawdź, czy wykryto w tym rzędzie przycisk
	JNC row2				; Jeżeli nie, to szukaj w następnym
	MOV R1, #00000001b			; Jeżeli tak, to zapisz indeks tego wiersza do R1
	ljmp cols				; Przeszukaj kolumny, bo wiersz już znaleziony

row2:	MOV P1, #11111011b			; Zbadaj ten wiersz
	lcall check				; Sprawdź, czy wykryto w tym rzędzie przycisk
	JNC row3				; Jeżeli nie, to szukaj w następnym
	MOV R1, #00000010b			; Jeżeli tak, to zapisz indeks tego wiersza do R1
	ljmp cols				; Przeszukaj kolumny, bo wiersz już znaleziony

row3:	MOV P1, #11110111b			; Zbadaj ten wiersz
	lcall check				; Sprawdź, czy wykryto w tym rzędzie przycisk
	JNC no_row				; Nie wykryto wciśniętego przycisku w żadnym wierszu
	MOV R1, #00000011b			; Jeżeli tak, to zapisz indeks tego wiersza do R1
	ljmp cols				; Przeszukaj kolumny, bo wiersz już znaleziony

no_row:						; Żaden wiersz nie wykrył przycisku - powrót
	MOV A, #11111111b
	MOV R7, #11111111b
	CJNE R3, #11111111b, pin0_r
	lcall reload_t0
	RETI
pin0_r:	CJNE R4, #11111111b, pin1_r		; Pierwsza cyfra PINu została wpisana.
	lcall reload_t0
	RETI
pin1_r: CJNE R5, #11111111b, pin2_r		; Druga cyfra PINu została wpisana.
	lcall reload_t0
	RETI
pin2_r: CJNE R6, #11111111b, pin3_r		; Trzecia cyfra PINu została wpisana.
	lcall reload_t0
	RETI
pin3_r: CJNE R4, #11111111b, pin4_r		; Czwarta cyfra PINu została wpisana.
	lcall reload_t0				
	RETI
pin4_r: LJMP check_correctness_of_PIN		; Gotowe. Skok do sprawdzenia poprawności PIN-u	

jump_to_saving:					; zapisanie cyfry
	POP A
	MOV R7, #255
	lcall reload_t0
	ljmp save_current_number

cols:	MOV P1, #11101111b			; Zbadaj tę kolumnę
	lcall check				; Sprawdź, czy wykryto w tej kolumnie przycisk
	JNC col5				; Jeżeli nie, to szukaj w następnej
	MOV R2, #00000100b			; Jeżeli tak, to zapisz indeks tej kolumny do R2
	ljmp indexes_detected			; Mamy oba indeksy. Zakończ przeszukiwanie.

col5:	MOV P1, #11011111b			; Zbadaj tę kolumnę
	lcall check				; Sprawdź, czy wykryto w tej kolumnie przycisk
	JNC col6				; Jeżeli nie, to szukaj w następnej
	MOV R2, #00000101b			; Jeżeli tak, to zapisz indeks tej kolumny do R2
	ljmp indexes_detected			; Mamy oba indeksy. Zakończ przeszukiwanie.

col6:	MOV P1, #10111111b			; Zbadaj tę kolumnę
	lcall check				; Sprawdź, czy wykryto w tej kolumnie przycisk
	JNC col7				; Jeżeli nie, to szukaj w następnej
	MOV R2, #00000110b			; Jeżeli tak, to zapisz indeks tej kolumny do R2
	ljmp indexes_detected			; Mamy oba indeksy. Zakończ przeszukiwanie.

col7:	MOV P1, #01111111b			; Zbadaj tę kolumnę
	lcall check				; Sprawdź, czy wykryto w tej kolumnie przycisk
	JNC no_col				; Nie wykryto wciśniętego przycisku w żadnej kolumnie
	MOV R2, #00000111b			; Jeżeli tak, to zapisz indeks tej kolumny do R2
	ljmp indexes_detected			; Mamy oba indeksy. Zakończ przeszukiwanie.

no_col:						; Skoro nie wykryto w żadnej kolumnie, to powrót
	lcall reload_t0
	RETI

check: 						; WAŻNE!!! NIEZAPALONY BIT = ZAPALONA LINIA
bit0:	JB P1.0, bit1				; Sprawdź czy bit 0 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit1:	JB P1.1, bit2				; Sprawdź czy bit 1 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit2:	JB P1.2, bit3				; Sprawdź czy bit 2 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit3:	JB P1.3, bit4				; Sprawdź czy bit 3 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit4:	JB P1.4, bit5				; Sprawdź czy bit 4 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit5:	JB P1.5, bit6				; Sprawdź czy bit 5 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit6:	JB P1.6, bit7				; Sprawdź czy bit 6 jest zapalony 
	INC R0					; Jeżeli nie jest zapalony, to inkrementuj licznik R0
bit7:	JB P1.7, fin				; Sprawdź czy bit 6 jest zapalony 
	INC R0
fin:	CJNE R0, #10b, not_pressed		; Mniej niz 2 bity, nie ma tu wcisnietego klawisza

is_pressed:
	SETB C					; Zasygnalizuj bitem C, że znaleziono klawisz
	MOV R0, #00000000b			; Wyzeruj licznik R0
	RET

not_pressed:
	CLR C					; Nie znaleziono tu klawisza, wyzeruj bit C
	MOV R0, #00000000b			; Wyzeruj licznik R0
	RET


get_pressed_key_number:
is_in_row0:
	CJNE R1, #0d, is_in_row1		; Jeżeli to nie ten wiersz, to przelacz na nastepny
is_in_row0_col4:
	CJNE R2, #4d, is_in_row0_col5		; Jeżeli to nie ta kolumna, to przelacz na nastepna
	MOV A, #00000001b 			; Wciśnięty klawisz to '1'
	RET
is_in_row0_col5:
	CJNE R2, #5d, is_in_row0_col6		; Jeżeli to nie ta kolumna, to przelacz na nastepna
	MOV A, #00000010b 			; Wciśnięty klawisz to '2'
	RET
is_in_row0_col6:
	CJNE R2, #6d, unknown_button		; Wykryto niedozwolony klawisz
	MOV A, #00000011b 			; Wciśnięty klawisz to '3'
	RET

is_in_row1:
	CJNE R1, #1d, is_in_row2		; Jeżeli to nie ten wiersz, to przelacz na nastepny
is_in_row1_col4:
	CJNE R2, #4d, is_in_row1_col5		; Jeżeli to nie ta kolumna, to przelacz na nastepna
	MOV A, #00000100b 			; Wciśnięty klawisz to '4'
	RET
is_in_row1_col5:
	CJNE R2, #5d, is_in_row1_col6		; Jeżeli to nie ta kolumna, to przelacz na nastepna
	MOV A, #00000101b 			; Wciśnięty klawisz to '5'
	RET
is_in_row1_col6:
	CJNE R2, #6d, unknown_button		; Wykryto niedozwolony klawisz
	MOV A, #00000110b 			; Wciśnięty klawisz to '6'
	RET

is_in_row2:
	CJNE R1, #2d, is_in_row3		; Jeżeli to nie ten wiersz, to przelacz na nastepny
is_in_row2_col4:
	CJNE R2, #4d, is_in_row2_col5		; Jeżeli to nie ta kolumna, to przelacz na nastepna
	MOV A, #00000111b 			; Wciśnięty klawisz to '7'
	RET
is_in_row2_col5:
	CJNE R2, #5d, is_in_row2_col6		; Jeżeli to nie ta kolumna, to przelacz na nastepna
	MOV A, #00001000b 			; Wciśnięty klawisz to '8'
	RET
is_in_row2_col6:
	CJNE R2, #6d, unknown_button		; Wykryto niedozwolony klawisz
	MOV A, #00001001b 			; Wciśnięty klawisz to '9'
	RET

is_in_row3:
	CJNE R1, #3d, unknown_button		; Wykryto niedozwolony klawisz
is_in_row3_col_5:
	CJNE R2, #5d, unknown_button		; Wykryto niedozwolony klawisz
	MOV A, #00000000b 			; Wciśnięty klawisz to '0'
	RET

unknown_button:					; Nieprawidłowy klawisz. Awaryjna sekwencja bitów
	MOV A, #11111111b
	RET

ORG 3000h ; Tablica przechowująca PIN
	db 00000010b ; 2
	db 00000001b ; 1
	db 00000000b ; 0
	db 00000111b ; 7
END
