
DATA SEGMENT
LED     DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H
        DB 7FH, 67H, 77H, 7CH, 39H, 5EH, 79H, 71H
POINTER DB 00H
FUTURE_SINGLE DB 0AH ;PRIMARY VALUE IS A
FUTURE_TENS   DB 0AH ;PRIMARY VALUE IS A
CURRENT_SINGLE DB 0H
CURRENT_TENS DB 3H
SENTENCE1 DB 'Please input the last time of a round:','$'
SENTENCE2 DB 0DH, 0AH, 'Now the music is on.', 0DH, 0AH, '$'
SENTENCE3 DB 0DH, 0AH, 'STATE 1: THE CURRENT STATE IS KEPT', 0DH, 0AH, '$'
SENTENCE4 DB 0DH, 0AH, 'STATE 2: YELLOW TWINKLING', 0DH, 0AH, '$'

MUSIC_ON DB 1
MUSIC_START DB 0
MUSIC_PTR DW 0
BUFFER DB 256 DUP(0)
FILE_PATH DB 'MUSIC1.WAV','$',00
FILE_HANDLE DW 0
SIZE_ DB 0
VOL DB 255

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
        MOV AL, 81H
        OUT DX, AL
        MOV CH, 3
        MOV CL, 0
        MOV DH, 0
INOUT:
        PUSH DX
        CMP CH, 0
        JNE CONT1
        CMP CL, 4
        JL  CONT0
        CMP CL, 6
        JG  CONT1
        CMP DH, 30
        JG  CONT1
        CALL DARK 
        JMP CONT2
CONT0:
        CALL YELLOW
        JMP CONT2
CONT1:
        CALL SHINE
CONT2:
        ;DISPLAY THE SECOND DIGIT (FROM RIGHT TO LEFT)
        MOV AL, 20H
        MOV DX, 0E48AH
        OUT DX, AL
        MOV AL, CH
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E488H
        OUT DX, AL
        CALL DELAY

        ;DISPLAY THE FOURTH DIGIT
        MOV DX, 0E48AH
        MOV AL, 80H
        OUT DX, AL
        MOV AL, CH
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E488H
        OUT DX, AL
        CALL DELAY

       ;DISPLAY THE FIRST DIGIT
        MOV DX, 0E48AH
        MOV AL, 10H
        OUT DX, AL
        MOV AL, CL
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E488H
        OUT DX, AL
        CALL DELAY
        JMP CONT3
SYMBOL:
        JMP INOUT
CONT3:
        ;DISPLAY THE THIRD DIGIT
        MOV DX, 0E48AH
        MOV AL, 40H
        OUT DX, AL
        MOV AL, CL
        MOV BX, OFFSET LED
        XLAT
        MOV DX, 0E488H
        OUT DX, AL
        CALL DELAY
        POP DX
        INC DH
CONT8:
        MOV AH, 1
        INT 16H
        JZ TO_TO_TO_JX
        MOV AH, 7H
        INT 21H
        CMP AL, 1BH
        JNE CONT6
        MOV AH, 4CH
        INT 21H
CONT6:
	    CMP AL, 2BH
        JE  KEEP_ON ; + KEEP THE CURRENT STATE
	    CMP AL, 2DH
        JE  TWINKLE ; - TWINKLE
	    CMP AL, 4DH
	    JNE CONT6_THEN
        MOV DX, OFFSET SENTENCE2
        MOV AH, 9
        INT 21H
CONT9: 
	    CALL AUDIO_OUTPUT
	    MOV AH, 1
	    INT 16H
	    JNZ TO_CONT8
	    JMP CONT9
TO_CONT8:
	    MOV AH, 7H
	    INT 21H
        MOV DX, OFFSET SENTENCE1
        MOV AH, 9
        INT 21H
	    JMP CONT8
	;one possible plan is to add two functions:"* SWITCH TO THE OTHER STATE" and "/ KEEP ALL LEDS DARK"
    
CONT6_THEN:
        CMP AL, 30H
        JL TO_JX
        CMP AL, 39H
        JG TO_JX
        SUB AL, 30H
        CMP FUTURE_TENS, 0AH
        JNE TO_CHANGE_SINGLE
        MOV FUTURE_TENS, AL
        JMP TO_JX
TO_TO_TO_JX:
        JMP TO_TO_JX
KEEP_ON:
        PUSH AX
        PUSH DX
        MOV DX, OFFSET SENTENCE3
        MOV AH, 9
        INT 21H
KEEP_ON_S:
        CMP CH, 0H
        JNE KEEP_ON_N
        CMP CL, 3
        JG KEEP_ON_N
        CALL YELLOW
        JMP KEEP_ON_O
KEEP_ON_N:
        CALL SHINE
KEEP_ON_O:
        MOV AH, 1
        INT 16H
        JZ KEEP_ON_S
        MOV AH, 7H
        INT 21H
        CALL DARK
        MOV DX, OFFSET SENTENCE1
        MOV AH, 9
        INT 21H
        POP DX
        POP AX
        JMP JX
TO_CHANGE_SINGLE:
        JMP CHANGE_SINGLE
TO_TO_JX:
        JMP TO_JX
TWINKLE:
        PUSH CX
        PUSH DX
        PUSH AX
        MOV DX, OFFSET SENTENCE4
        MOV AH, 9
        INT 21H
        MOV DH, 0H
TWINKLE_LOOP:
        CMP DH, 30
        JL TWINKLE_DARK
        CALL YELLOW_TWINKLE
        JMP TWINKLE_THEN
TWINKLE_DARK:
        CALL ALL_DARK
TWINKLE_THEN:
        CMP DH, 3AH
        JNE TWINKLE_INC
        MOV DH, 0H
        JMP TWINKLE_O
TWINKLE_INC:
        INC DH
        JMP TWINKLE_O
TO_JX:
        JMP JX
TWINKLE_O:
        CALL DELAY
        CALL DELAY
        CALL DELAY
        CALL DELAY
        MOV AH, 1
        INT 16H
        JZ  TWINKLE_LOOP
        MOV AH, 7H
        INT 21H
        MOV DX, OFFSET SENTENCE1
        MOV AH, 9
        INT 21H
        POP AX
        POP DX
        POP CX
        JMP JX
TO_SYMBOL:
        JMP SYMBOL
CHANGE_SINGLE:
        MOV FUTURE_SINGLE, AL
        MOV CH, FUTURE_TENS
        MOV CL, FUTURE_SINGLE
        MOV FUTURE_TENS, 0AH
        MOV FUTURE_SINGLE, 0AH
        MOV CURRENT_TENS, CH
        MOV CURRENT_SINGLE, CL
        PUSH DX
        PUSH AX
        MOV AH, 02H
        MOV DL, CURRENT_TENS
        ADD DL, 30H
        INT 21H
        MOV DL, CURRENT_SINGLE
        ADD DL, 30H
        INT 21H
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
        JNE TO_SYMBOL ;JUMP TO THE NEXT LOOP
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
        MOV CL, CURRENT_SINGLE
        MOV CH, CURRENT_TENS
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

YELLOW_TWINKLE PROC NEAR
        PUSH DX
        PUSH AX
        MOV  DX, 0E489H
        MOV  AL, 42H
        OUT DX, AL
        POP AX
        POP DX
        RET
YELLOW_TWINKLE ENDP

ALL_DARK PROC NEAR
        PUSH DX
        PUSH AX
        MOV DX, 0E489H
        MOV AL, 0H
        OUT DX, AL
        POP AX
        POP DX
        RET
ALL_DARK ENDP

GET_SAMPLE PROC NEAR
        MOV BX,[MUSIC_PTR]
        INC [MUSIC_PTR]
        MOV AL,[BUFFER+BX]
        PUSH AX
        INC BX
        CMP BL,[SIZE_]
        JNE GET_SAMPLE_RET
        CMP BX,128
        JNE FILE_END
        CALL READ_FILE
        CMP [SIZE_],0
        JE FILE_END
        JMP GET_SAMPLE_RET
FILE_END:
        MOV AH,42H
        MOV BX,[FILE_HANDLE]
        MOV CX,0
        MOV DX,44
        MOV AL,0
        INT 21H
        CALL READ_FILE
GET_SAMPLE_RET:
        POP AX
        RET
GET_SAMPLE ENDP

AUDIO_OUTPUT PROC NEAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        CMP [MUSIC_ON],1
        JNE AUDIO_RET
        CMP [MUSIC_START],1
        JNE START_MUSIC
        MOV DX,0E48AH
        IN AL,DX
        AND AL,1
        CMP AL,1
        JNE AUDIO_RET
        
PLAY_MUSIC:
        MOV DX,0E483H
        MOV AL,01010000B
        OUT DX,AL
        
        MOV DX,0E481H
        
        MOV AL,115
        OUT DX,AL        
        
        CALL GET_SAMPLE

        PUSH AX
        MOV DX,0E498H
        IN AL,DX
        MOV BL,AL
        POP AX
        MOV [VOL],BL
        MUL BL
        MOV BL,255
        DIV BL
        MOV DX,0E490H
        OUT DX,AL
        MOV DX,0E498H
        OUT DX,AL
        JMP AUDIO_RET
START_MUSIC:

        MOV DX,0E498H
        OUT DX,AL

        MOV AH,3DH
        MOV DX,OFFSET FILE_PATH
        MOV AL,0
        INT 21H			
        JC ERROR
        MOV [FILE_HANDLE],AX    ;OPEN FILE

        MOV AH,3FH
        LEA DX,BUFFER
        MOV CX,44
        MOV BX,[FILE_HANDLE]
        INT 21H
        JC ERROR
        
        MOV [MUSIC_PTR],0
        MOV [MUSIC_START],1
        JMP PLAY_MUSIC
        
AUDIO_RET:
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
AUDIO_OUTPUT ENDP

READ_FILE PROC NEAR
        MOV AH,3FH
        LEA DX,BUFFER
        MOV CX,128
        MOV BX,[FILE_HANDLE]
        INT 21H
        JC ERROR
        MOV [SIZE_],AL
        MOV [MUSIC_PTR],0
        RET
ERROR:
READ_FILE ENDP
CODE ENDS
END START