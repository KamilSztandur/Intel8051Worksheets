stopped SET 1
opening SET 2
closing SET 3
closed SET 0
opened SET 255
moving SET 4

ORG 0000h
	LJMP init
ORG 0003h				; Wektor przerwania INT0
	lcall object_detected		; przerwanie z portu 3 bit 2 - przeszkoda
	lcall reload_T0
	RETI
ORG 000Bh				; Wektor przerwania T0
	lcall check_status 		; Obsłużenie przerwania od T0
	lcall reload_T0
	RETI
ORG 0013h				; Wektor przerwania INT1
	lcall change_status		; przerwanie z portu 3 bit 3 - inerakcja z przyciskiem
	lcall reload_T0
	RETI

reload_T0:
	MOV TL0, #0A2h			; | Zresetowanie wartości timera
	MOV TH0, #0FFh			; |
	RET

init:
	MOV IE, #0h			; Wyłączenie wszystkich przerwań
	CLR TR0				; Zatrzymanie timera T0
	CLR TF0				; Wyzerowanie flagi przepełnienia
	MOV TMOD, #01h			; Inicjalizacja timera T0
	lcall reload_T0			; Ustawienie wartości timera CHANGE
	MOV IP, #5h			; Ustawienie priorytetu przerwań
	MOV IE, #87h			; Odblokuj przerwania timera T0 i klawiatury
	MOV DPTR, #3000h		; Ustaw indeks początkowy
	CLR A				; Wyzerowanie akumulatora
	MOV R0, #opened
	MOV R1, #closing
	MOV R7, #0h
	SETB TR0			; Uruchomienie odliczania
	SETB IE0			; Uruchomienie przerwań od klawiatury

main:	sjmp main			; Nieskończona pętla (czeka na przerwanie)

object_detected:
	CJNE R1, #closing, detector_fail
	MOV R0, #stopped
	RET
detector_fail:
	RET

change_status:
	CJNE R0, #opened, not_opened
	ljmp change_status_to_closing
	
not_opened:
	CJNE R0, #closed, not_closed
	ljmp change_status_to_opening
not_closed:
	CJNE R0, #stopped, change_status_to_stopped
	CJNE R1, #opening, change_status_to_opening
	lcall change_status_to_closing
	RET

change_status_to_stopped:
	MOV R0, #stopped
	RET

change_status_to_opening:
	MOV R1, #opening
	MOV R0, #moving
	RET
change_status_to_closing:
	MOV R1, #closing
	MOV R0, #moving
	RET

check_status:
	CJNE R0, #moving, one_of_stop_statuses		; sprawdzenie czy brama się porusza
	lcall change_LED_status
	RET


one_of_stop_statuses:
	CJNE R0, #stopped, closed_or_opened		; sprawdzenie czy brama zatrzymana
	RET

closed_or_opened:
	RET

change_LED_status:
	CJNE R1, #opening, LED_closing
	DEC R7
	MOV A, R7
	MOVC A, @A+DPTR
	MOV P2, A
	CJNE A, #255, return
	MOV R0, #opened
	CLR A
	RET

LED_closing:
	INC R7
	MOV A, R7
	MOVC A, @A+DPTR
	MOV P2, A
	CJNE A, #0, return
	MOV R0, #closed
	CLR A
	RET
return:
	RET
ORG 3000h ; Tablica zawierająca kolejne stany bramy (diod LED)
	DB 11111111b ; otwarta
	DB 01111111b
	DB 00111111b
	DB 00011111b
	DB 00001111b
	DB 00000111b
	DB 00000011b
	DB 00000001b
	DB 00000000b ; zamknięta
END