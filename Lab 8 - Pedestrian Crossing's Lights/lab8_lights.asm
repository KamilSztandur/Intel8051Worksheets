;		.-------------------------------.
;		|   Czekaj Bartłomiej 307336	|
;		|     Sztandur Kamil 307354	|
;		*-------------------------------*
;
; P0.0 - Czerwone światło
; P0.1 - Żółte światło
; P0.2 - Zielona światło
;
; P3.2 - Port przycisku zmiany świateł przez pieszych

ORG 0000h
	LJMP init

ORG 0003h
	MOV R0, P0
	CJNE R0, #11111011b, lights_change_request_denied
	MOV TL0, #252d 	; | Ustawienie wartosci timera tak, aby znacznie szybciej
	MOV TH0, #255d	; | się ukończył.
	RETI

lights_change_request_denied:		; Światło nie jest zielone, odrzucono
	RETI

unlock_lights_switch_button:		; | Odblokuj możliwość zmiany świateł
	MOV IE, #10000001b		; | przyciskiem P3.2
	RET

lock_lights_switch_button:		; | Zablokuj możliwość zmiany świateł
	MOV IE, #00000000b		; | przyciskiem P3.2
	RET

ORG 0050h
init:
	MOV IE, #0h			; Wyłączenie wszystkich przerwań
	CLR TR0				; Zatrzymanie timera T0
	CLR TF0				; Wyzerowanie flagi przepełnienia
	MOV TMOD, #01h			; Inicjalizacja timera T0
main:
	lcall set_red_light		; Ustaw czerwone światło
	lcall red_delay 		; Czekaj czas przeznaczony dla czerwonego światła
	lcall set_red_yellow_light	; Ustaw czerwone i żółte światło
	lcall yellow_delay		; Czekaj czas przeznaczony dla żółtego światła
	lcall set_green_light		; Ustaw zielone światło
	lcall green_delay		; Czekaj czas przeznaczony dla zielonego światła 
	lcall set_yellow_light		; Ustaw żółte światło
	lcall yellow_delay		; Czekaj czas przeznaczony dla żółtego światła
	sjmp main

ORG 0100h
set_red_light:				; Ustawienie czerwonego światła
	CLR P0.0			; Zapal czerwone światło
	SETB P0.1			; Zgaś żółte światło
	SETB P0.2			; Zgaś zielone światło
	RET

set_red_yellow_light:			; Ustawienie czerwonego i zielonego światła
	CLR P0.0			; Zapal czerwone światło
	CLR P0.1			; Zapal żółte światło
	SETB P0.2			; Zgaś zielone światło
	RET

set_green_light:			; Ustawienie zielonego światła
	SETB P0.0			; Zgaś czerwone światło
	SETB P0.1			; Zgaś żółte światło
	CLR P0.2			; Zapal zielone światło
	RET

set_yellow_light:			; Ustawienie żółtego światła
	SETB P0.0			; Zgaś czerwone światło
	CLR P0.1			; Zapal żółte światło
	SETB P0.2			; Zgaś zielone światło
	RET

ORG 0150h
green_delay:				; Przeczekanie zielonego światła
	MOV TL0,#0xC1			; | Ustaw wartości timera
	MOV TH0,#0xF9			; |
	SETB TR0			; Rozpocznij odliczanie timera
	lcall unlock_lights_switch_button ; Odblokuj zmianę świateł przyciskiem
wait_green:
	JNB TF0, wait_green		; Czekaj aż czas zielonego światła upłynie
green_delay_ends:
	lcall lock_lights_switch_button	; Zablokuj zmianę świateł przyciskiem
	CLR TF0				; Wyzerowanie flagi przepełnienia
	CLR TR0				; Zatrzymaj odliczanie timera
	RET

yellow_delay:				; Przeczekanie żółtego światła
	MOV TL0,#0xBF			; | Ustaw wartości timera
	MOV TH0,#0xFE			; |
	SETB TR0			; Rozpocznij odliczanie timera
wait_yellow:
	JNB TF0, wait_yellow		; Czekaj aż czas żółtego światła upłynie
yellow_delay_ends:
	CLR TF0				; Wyzerowanie flagi przepełnienia
	CLR TR0 			; Zatrzymaj odliczanie timera
	RET

red_delay:				; Przeczekanie czerwonego światła
	MOV TL0,#0xE1			; | Ustaw wartości timera
	MOV TH0,#0xFC			; |
	SETB TR0			; Rozpocznij odliczanie timera
wait_red:
	JNB TF0, wait_red		; Czekaj aż czas czerwonego światła upłynie
red_delay_ends:
	CLR TF0				; Wyzerowanie flagi przepełnienia
	CLR TR0 			; Zatrzymaj odliczanie timera
	RET
END
