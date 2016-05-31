
DATA SEGMENT
LED     DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H
        DB 7FH, 67H, 77H, 7CH, 39H, 5EH, 79H, 71H
POINTER DB 00H
FUTURESINGLE DB 0AH ;PRIMARY VALUE IS A
FUTURETENS   DB 0AH ;PRIMARY VALUE IS A
SENTENCE1 DB 'Please input the last time of a round:','$'
SENTENCE2 DB 'This input is illegal!','$'
DATA ENDS
CODE SEGMENT
   ASSUME CS:CODE, DS:DATA
START:
        MOV AX, DATA
        MOV DS, AX
        MOV DX, OFFSET SENTENCE1
        MOV AH, 9H
        INT 21H
        MOV DX, 0E48BH
        MOV AL, 80H
        OUT DX, AL
        MOV CH, 3
        MOV CL, 0
        MOV DH, 0H
INOUT:
        PUSH DX
        CMP CH, 0
        JNE CONT1
        CMP CL, 4
        JL  CONT0
        CMP CL, 6
        JG  CONT2
        CMP DH, 30
        JG CONT1
		CALL DARK 
        JMP CONT2
CONT0:
        CALL YELLOW
        JMP CONT2
CONT1:
        CALL SHINE
CONT2:
        ;DISPLAY THE SECOND DIGIT (FROM RIGHT TO LEFT)
        MOV AL, 2H
        MOV DX, 0E488H
        OUT DX, AL
        MOV AL, CH
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E48AH
        OUT DX, AL
        CALL DELAY

        ;DISPLAY THE FOURTH DIGIT
        MOV DX, 0E488H
        MOV AL, 20H
        OUT DX, AL
        MOV AL, CH
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E48AH
        OUT DX, AL
        CALL DELAY

       ; MAYBE THESE THREE SENTENCES SHOULDN'T BE HERE
       ; MOV DX, 0E489H
       ; MOV AL, 33
       ; OUT DX, AL

       ;DISPLAY THE FIRST DIGIT
       ;MOV AL, BL
        MOV DX, 0E488H
       ;OUT DX, AL
        MOV BL, 1H
        MOV AL, BL
        OUT DX, AL
		PUSH BX
        MOV AL, CL
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E48AH
        OUT DX, AL
        CALL DELAY
        JMP CONT3
SYMBOL:
        JMP INOUT
CONT3:
        ;DISPLAY THE THIRD DIGIT
		POP BX
       ; MOV AL, BL
        MOV DX, 0E488H
       ; OUT DX, AL
        MOV BL, 10H
        MOV AL, BL
        OUT DX, AL
		PUSH BX
        MOV AL, CL
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E48AH
        OUT DX, AL
        CALL DELAY
		POP BX
        POP DX
        INC DH
        MOV AH, 1
        INT 16H
        JZ JX
        MOV AH, 7H
        INT 21H
        CMP AL, 1BH
        JNE CONT6
        MOV AH, 4CH
        INT 21H
CONT6:
		CMP AL, 2BH
		JE  KEEP_ON ;KEEP THE CURRENT STATE
		CMP AL, 2DH
		JE  TWINKLE ;TWINKLE
		CMP AL, 2AH
		JE  SWITCH  ;SWITCH TO THE OTHER STATE
		CMP AL, 2FH
		JE  OFF     ;KEEP ALL LEDS DARK
        CMP AL, 30H
        JL JX
        CMP AL, 39H
        JG JX
        SUB AL, 30H
        CMP FUTURETENS, 0AH
        JNE CHANGESINGLE
        MOV FUTURETENS, AL
        JMP JX
KEEP_ON:
		CMP CH, 0H
		JNE KEEP_ON_N
		CMP CL, 3
		JE KEEP_ON_N
		CALL YELLOW
		JMP KEEP_ON_O
KEEP_ON_N:
		CALL SHINE
KEEP_ON_O:
		MOV AH, 1
		INT 16H
		JZ KEEP_ON
		MOV AH, 7H
        INT 21H
        JMP JX
TWINKLE:
		PUSH CX
		PUSH DX
		MOV DH, 0H
TWINKLE_LOOP:
		CMP DH, 30
		JLE TWINKLE_DARK
		CALL YELLOW
		JMP TWINKLE_THEN
TWINKLE_DARK:
		CALL DARK
TWINKLE_THEN:
		CMP DH, 3AH
		JNE TWINKLE_INC
		MOV DH, 0H
		JMP TWINKLE_O
TWINKLE_INC:
		INC DH
TWINKLE_O:
		MOV AH, 1
		INT 16H
		JZ  TWINKLE
		MOV AH, 7H
        INT 21H
        POP DX
        POP CX
        JMP JX
        
CHANGESINGLE:
        MOV FUTURESINGLE, AL
        MOV CH, FUTURETENS
        MOV CL, FUTURESINGLE
        MOV FUTURETENS, 0AH
        MOV FUTURESINGLE, 0AH
        PUSH DX
        PUSH AX
        MOV DL, 0DH
        MOV AH, 2
        INT 21H
        MOV DL, 0AH
        MOV AH, 2
        INT 21H
        MOV DX, OFFSET SENTENCE1
        MOV AH, 9
        INT 21H
        POP AX
        POP DX
JX:
       ;PROCESS CARRY BITS
        CMP DH, 3AH
        JNE SYMBOL ;JUMP TO THE NEXT LOOP
        CMP CL, 0H
        JE SINGLEDIGIT
        DEC CL
        JMP WWAIT
SINGLEDIGIT:
        CMP CH, 0H
        JE TENS
        DEC CH
        MOV CL, 9H
        JMP WWAIT
TENS:
        MOV CL, 0H
        MOV CH, 3H
        CMP POINTER, 0H
        JE CHANGETO1
        MOV POINTER, 0H
        JMP WWAIT
CHANGETO1:
        MOV POINTER, 1H
WWAIT:
        MOV DH, 0H
        JMP INOUT

DELAY PROC NEAR
        PUSH AX
        PUSH CX
        PUSH DX
        MOV AH, 86H
        MOV CX, 0
        MOV DX, 500H ;SHORTER THAN NECESSARY WHEN TESTING
        INT 15H
JJ:
        POP DX
        POP CX
        POP AX
        RET
DELAY ENDP

SHINE PROC NEAR
        ;GREEN 
        PUSH DX
        PUSH AX
        MOV DX, 0E489H
        CMP POINTER, 0H
        JNE PP
        MOV AL, 81H
        JMP NPP
PP:
        MOV AL, 24H
NPP:
        OUT DX, AL
        POP AX
        POP DX
        RET
SHINE ENDP

YELLOW PROC NEAR
        PUSH DX
        PUSH AX
        MOV DX, 0E489H
        CMP POINTER, 0H
        JE CONT5
        MOV AL, 44H
        JMP NCONT5
CONT5:
        MOV AL, 82H
NCONT5:
        OUT DX, AL
        POP AX
        POP DX
        RET
YELLOW ENDP

DARK PROC NEAR
        ;ALL GREEN LEDS ARE DARK
        PUSH DX
        PUSH AX
        MOV DX, 0E489H
        CMP POINTER, 0H
        JE CONT4
        MOV AL, 4H
        JMP NCONT4
CONT4:
        MOV AL, 80H
NCONT4:
        OUT DX, AL
        POP AX
        POP DX
        RET
DARK ENDP
CODE ENDS
END START
