;====================================================================================================
;@2019                                                                                              |
;AUTHOR     : HIZKIA WILLIAM EBEN                                                                  |
;PROGRAM    : MORSE CODE TRANSLATOR/PENERJEMAH KODE MORSE                                           |
;---------------------------------------------------------------------------------------------------|
;SKENARIO   :   1. USER DAPAT MEMILIH INGIN MENGENCODE ATAU MENDECODE KODE MORSE                    |
;                  USER CAN CHOOSE TO ENCODE OR DECODE MORSE CODE                                   |
;               2. JIKA USER MENGENCODE, USER MEMASUKAN STRING DAN PROGRAM MENAMPILKAN KODEMORSENYA |
;                  IF USER ENCODE, USER INPUT STRING AND PROGRAM WILL GIVE MORSE CODE AS OUTPUTS    |
;               3. JIKA USER MENDECODE, USER MEMASUKAN KODE MORSE DAN PROGRAM MENAMPILKAN STRING    |
;                  IF USER ENCODE, USER INPUT MORSE CODE AND PROGRAM WILL GIVE STRINGS AS OUTPUTS   |
;---------------------------------------------------------------------------------------------------|
;        MORSE CODE TRANSLATOR is a program to help user translate morse code to string             |
;                                   or string to morse code                                         |
;                                                                                                   |
;    Copyright (C) 2019 HIZKIA WILLIAM EBEN   |
;                                                                                                   |
;               This program is free software: you can redistribute it and/or modify                |
;               it under the terms of the GNU General Public License as published by                |
;               the Free Software Foundation, either version 3 of the License, or any               |
;               later version.                                                                      |
;                                                                                                   |
;               This program is distributed in the hope that it will be useful,                     |
;               but WITHOUT ANY WARRANTY; without even the implied warranty of                      |
;               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                       |
;               GNU General Public License for more details.                                        |
;===================================================================================================|
.MODEL COMPACT
 
;==================================================================
;====                      DATA SEGMENT                        ====  
;================================================================== 
.DATA
    
    ;================DECODE===============
    INPUT_DECODE DB 50 DUP (?)          ;RAW INPUT DARI USER
    INPUT_CHECKER DB 10 DUP (?)         ;INPUT PERBLOK HURUF YANG DIPISAH DENGAN SPASI, DARI INPUT_DECODE
    COUNT_DECODE_PERCHAR DB 00          ;CEK PANJANG DARI INPUT_CHECKER UNTUK BATASAN LOOP
    COUNT_DECODE DB 00                  ;CEK PANJANG TOTAL DARI INPUT_DECODE UNTUK LOOP BACA VARIABEL
    INDEX_DECODE DB 00                  ;UNTUK CEK NILAI INDEX KE BERAPA DARI INPUT
    CODES DB 00                         ;NILAI SPECIAL TIAP KARAKTER SETELAH PERHITUNGAN
    LENGTHS_DECODE DB 00                 ;PANJANG TOTAL DECODE UNTUK LOOP
    ;===============ENCODE================
    STOR DW 0                           ;VARIABEL UNTUK MENYIMPAN FREKUENSI BEEP
    LETTER DB 0                         ;UNTUK MENYIMPAN PERHURUF DARI INPUT
    INDEX DB 0                          ;CEK INDEX INPUT ENCODE
    COUNT DB 0                          ;HITUNG JUMLAH INPUTAN ENCODE SEBAGAI BATAS LOOP
    LENGTHS DB 0                        ;TOTAL PANJANG MORSE CODE PERCHAR
    INPUT  DB  50 dup(?)                ;VAR MENAMPUNG INPUT ENCODE BERUPA ARRAY
    ;===============STRINGS===============
    PRESS_ANY_KEY DB 13,10,13,10,"PRESS ANY KEY TO CONTINUE!$"
    STR_INPUT DB 13,"========================================="
        DB 13,10,"MESSAGE ENCODER (STRING => MORSE)" 
        DB 13,10,"========================================="
        DB 13,10,"Input the readable message to encrypt!"
        DB 13,10,"(In UPPERCASE)" 
        DB 13,10,10,"INPUT : ",13,10,"$"
    STR_INPUT_DECODE DB 13,"========================================="
        DB 13,10,"MESSAGE DECODER (MORSE => STRING)" 
        DB 13,10,"========================================="
        DB 13,10,"Input the Morse Code to translate!"
        DB 13,10,10,"INPUT : ",13,10,"$"
    STR_OUTPUT DB 13,10,"OUTPUT: ",13,10,"$"              
    STR_EMPTY DB "NO INPUT$"              
    MORSE_LISTS DB 13,"========================================="
        DB 13,10,"MORSE CODE TABLE" 
        DB 13,10,"========================================="
        DB 13,10,"A = .-"
        DB "    B = -..."
        DB "  C = -.-."
        DB "  D = -.."
        DB "   E = ."
        DB 13,10,"F = ..-."
        DB "  G = --."
        DB "   H = ...."
        DB "  I = .."
        DB "    J = .---"
        DB 13,10,"K = -.-"
        DB "   L = .-.."
        DB "  M = --"
        DB "    N = -."
        DB "    0 = ---"
        DB 13,10,"P = .--."
        DB "  Q = --.-"
        DB "  R = .-."
        DB "   S = ..."
        DB "   T = -"
        DB 13,10,"U = ..-"
        DB "   V = ...-"
        DB "  W = .--"
        DB "   X = -..-"
        DB "  Y = -.--"
        DB 13,10,"Z = --..$"
    HEADER DB           "======================================================="
           DB 13,10,    "||                                                   ||"
           DB 13,10,    "||               MORSE CODE TRANSLATOR               ||"  
           DB 13,10,    "||                                                   ||"
           DB 13,10,    "=======================================================$"
    SELECT DB 13,10,10, "                WELCOME TO THE PROGRAM!       "
           DB 13,10,10, "--------------------------- "
           DB 13,10,    "|MAIN MENU:               | "
           DB 13,10,    "|1.Encode                 | "
           DB 13,10,    "|2.Decode                 | "
           DB 13,10,    "|3.Show Morse code lists  | "
           DB 13,10,    "|4.Exit                   | "
           DB 13,10,    "--------------------------- "
           DB 13,10,    "Select your choice: $"
    
    
;==================================================================
;====                      CODE SEGMENT                        ====  
;==================================================================    
.CODE
.STARTUP
;==================================================================
;====                       MAIN MENU                          ====  
;==================================================================
    MAIN_MENU:     
    
    CALL CLEAR_SCREEN
    
    MOV AH, 9H
    MOV DX, OFFSET HEADER
    INT 21H  
    
    MOV AH, 9H
    MOV DX, OFFSET SELECT
    INT 21H  
    
    MOV AH, 1H
    INT 21H
    
    CMP AL, 31H
    JNE NOT_ENCODE
    JMP _ENCODE
    NOT_ENCODE:
    
    CMP AL, 32H
    JNE NOT_DECODE
    JMP _DECODE
    NOT_DECODE:
              
    CMP AL, 33H             
    JNE NOT_MORSECODE
    JMP _MORSECODE
    NOT_MORSECODE:
    
    CMP AL, 34H
    JNE NOT_REAL_EXIT
    JMP REAL_EXIT
    NOT_REAL_EXIT:
    JMP MAIN_MENU
;==================================================================
;====                          ENCODE                          ====  
;==================================================================
    _ENCODE:

    CALL CLEAR_SCREEN
    MOV AX, @DATA
    MOV DS, AX        
       
    CALL GETINPUT
    
    MOV AH, 9H
    MOV DX, OFFSET STR_OUTPUT
    INT 21H
                
    CHECK_INPUT:
        MOV SI, OFFSET INPUT
        MOV COUNT, 0 
        DEC LENGTHS
         
        LP:  
            MOV DL, [SI]
            MOV AL, DL 
            MOV LETTER, AL 
            CALL CHECK_LETTER
            INC INDEX
            INC COUNT           
            INC SI
            
            MOV BL, LENGTHS[0]     ;LOOP SEPANJANG INPUTNYA
            CMP COUNT, BL
            JNE NOT_EXIT1
            JMP EXIT1
            NOT_EXIT1:
             
            JMP LP
    GETINPUT:        
        MOV AH, 9H                ;PRINT "INPUT STRING"
        MOV DX, OFFSET STR_INPUT
        INT 21H                 
        
        MOV SI, OFFSET INPUT      ;UNTUK CEK VAR INPUT
        MOV LENGTHS, 0             ;UNTUK TAU PANJANG INPUTNYA
            
            LO:
                MOV AH,1H
                INT 21H 
                
                MOV [SI],AL
                INC SI
                INC LENGTHS
                
                CMP AL ,13     ;CEK KALO INPUTNYA ENTER, LOOPNYA BERES
                JE DONE     
                
                CMP AL, 8H     ;KALO KLIK BACKSPACE
                JE BACK
                
                JMP LO 
                BACK:          ;INTINYA, SI DAN LENGTHSNYA BERKURANG 2
                    CMP LENGTHS[0],1
                    JE LO  
                    CMP SI,48
                    JE LO
                    DEC SI
                    MOV AH, 2H
                    MOV DL, 20H
                    INT 21H   
                    MOV AH, 2H
                    MOV DL, 8H
                    INT 21H
                    DEC SI    
                    DEC LENGTHS
                    DEC LENGTHS
                    JMP LO 
                
            DONE:
                RET
 
    CHECK_LETTER:        
        CMP LETTER, "A"
        JNE NOT_PLAY_A
        JMP PLAY_A
        NOT_PLAY_A:
        CMP LETTER, "B"
        JNE NOT_PLAY_B
        JMP PLAY_B
        NOT_PLAY_B: 
        CMP LETTER, "C"
        JNE NOT_PLAY_C
        JMP PLAY_C
        NOT_PLAY_C:
        CMP LETTER, "D"
        JNE NOT_PLAY_D
        JMP PLAY_D
        NOT_PLAY_D:
        CMP LETTER, "E"
        JNE NOT_PLAY_E
        JMP PLAY_E
        NOT_PLAY_E:
        CMP LETTER, "F"
        JNE NOT_PLAY_F
        JMP PLAY_F
        NOT_PLAY_F:
        CMP LETTER, "G"
        JNE NOT_PLAY_G
        JMP PLAY_G
        NOT_PLAY_G:
        CMP LETTER, "H"
        JNE NOT_PLAY_H
        JMP PLAY_H
        NOT_PLAY_H:
        CMP LETTER, "I"
        JNE NOT_PLAY_I
        JMP PLAY_I
        NOT_PLAY_I:
        CMP LETTER, "J"
        JNE NOT_PLAY_J
        JMP PLAY_J
        NOT_PLAY_J:
        CMP LETTER, "K"
        JNE NOT_PLAY_K
        JMP PLAY_K
        NOT_PLAY_K:
        CMP LETTER, "L"
        JNE NOT_PLAY_L
        JMP PLAY_L
        NOT_PLAY_L:
        CMP LETTER, "M"
        JNE NOT_PLAY_M
        JMP PLAY_M
        NOT_PLAY_M:
        CMP LETTER, "N"
        JNE NOT_PLAY_N
        JMP PLAY_N
        NOT_PLAY_N:
        CMP LETTER, "O"
        JNE NOT_PLAY_O
        JMP PLAY_O
        NOT_PLAY_O:
        CMP LETTER, "P"
        JNE NOT_PLAY_P
        JMP PLAY_P
        NOT_PLAY_P:
        CMP LETTER, "Q"
        JNE NOT_PLAY_Q
        JMP PLAY_Q
        NOT_PLAY_Q:
        CMP LETTER, "R"
        JNE NOT_PLAY_R
        JMP PLAY_R
        NOT_PLAY_R:
        CMP LETTER, "S"
        JNE NOT_PLAY_S
        JMP PLAY_S
        NOT_PLAY_S:
        CMP LETTER, "T"
        JNE NOT_PLAY_T
        JMP PLAY_T
        NOT_PLAY_T:
        CMP LETTER, "U"
        JNE NOT_PLAY_U
        JMP PLAY_U
        NOT_PLAY_U:
        CMP LETTER, "V"
        JNE NOT_PLAY_V
        JMP PLAY_V
        NOT_PLAY_V:
        CMP LETTER, "W"
        JNE NOT_PLAY_W
        JMP PLAY_W
        NOT_PLAY_W:
        CMP LETTER, "X"
        JNE NOT_PLAY_X
        JMP PLAY_X
        NOT_PLAY_X:
        CMP LETTER, "Y"
        JNE NOT_PLAY_Y
        JMP PLAY_Y
        NOT_PLAY_Y:
        CMP LETTER, "Z"
        JNE NOT_PLAY_Z
        JMP PLAY_Z
        NOT_PLAY_Z:
        CMP LETTER, 13H ;JIKA STRING KOSONG
        JNE NOT_PLAY_KOSONG
        JMP PLAY_EMPTY     
        NOT_PLAY_KOSONG:
        CMP LETTER, 00H ;JIKA STRING KOSONG
        JNE NOT_PLAY_NULL
        JMP PLAY_EMPTY
        NOT_PLAY_NULL:
        CMP LETTER, 20H ;JIKA STRING KOSONG
        JNE NOT_PLAY_SPACE
        JMP PLAY_SPACE
        NOT_PLAY_SPACE:
        RET
        
        PLAY_A:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE
            CALL    DELAYS          ;DELAY
            RET                            
        PLAY_B:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_C:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF         
            CALL    DELAYS          ;DELAY
            RET        
        PLAY_D:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF         
            CALL    DELAYS          ;DELAY
            RET        
        PLAY_E:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET                           
        PLAY_F:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY      
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET                                       
        PLAY_G:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET     
            RET
        PLAY_H:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_I:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_J:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_K:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_L:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_M:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_N:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_O:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_P:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_Q:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_R:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_S:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_T:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_U:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_V:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_W:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_X:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_Y:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET
        PLAY_Z:           
            MOV     AX, 3043        ;NILAI SOL
            MOV     STOR, AX              
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPL           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    DELAYS          ;DELAY
            CALL    BEEPS           ;PUTAR NADA 
            CALL    BEEPSPACE       ;SPACE ANTAR HURUF
            CALL    DELAYS          ;DELAY
            RET               
        RET      
        PLAY_EMPTY:           
            MOV AH, 9H
            MOV DX, OFFSET STR_EMPTY
            INT 21H
            RET      
        PLAY_SPACE:           
            MOV AH, 2H
            MOV DL, " " 
            INT 21H
            RET             
       
        EXIT1:
        JMP EXT
        
        ;GENERATE SOUND
        BEEPS:
            MOV     AL, 0B6H        ;LOAD CONTROL
            OUT     43H, Al         ;SEND
            MOV     AX, STOR        ;MASUKAN FREKUENSI KE AX
            OUT     42H, AL         ;SEND LSB
            MOV     AL, AH          ;MOVE MSB KE AL
            OUT     42H, AL         ;SEND MSB
            IN      AL, 061H        ;DAPATKAN STATE PORT 61H
            OR      AL, 03H         ;NYALAKAN SPEAKER
            OUT     61H, AL         ;SPEAKER MENYALA
            CALL    DELAYS          ;DELAY
            AND     AL, 0FCH        ;MATIKAN SPEAKER
            OUT     61H, AL         ;SPEAKER MATI
            CALL    CLR_KEYB        ;PANGGIL FUNGSI CLEAR KEYBOARD
            MOV     AH, 2H
            MOV     DL, "."
            INT     21H
        RET                         ;RETURN    
        
        BEEPL:
            MOV     AL, 0B6H        ;LOAD CONTROL
            OUT     43H, Al         ;SEND
            MOV     AX, STOR        ;MASUKAN FREKUENSI KE AX
            OUT     42H, AL         ;SEND LSB
            MOV     AL, AH          ;MOVE MSB KE AL
            OUT     42H, AL         ;SEND MSB
            IN      AL, 061H        ;DAPATKAN STATE PORT 61H
            OR      AL, 03H         ;NYALAKAN SPEAKER
            OUT     61H, AL         ;SPEAKER MENYALA
            CALL    DELAYL          ;DELAY
            AND     AL, 0FCH        ;MATIKAN SPEAKER
            OUT     61H, AL         ;SPEAKER MATI
            CALL    CLR_KEYB        ;PANGGIL FUNGSI CLEAR KEYBOARD    
            MOV     AH, 2H
            MOV     DL,"-"
            INT     21H
        RET                         ;RETURN  
        
        BEEPSPACE:
            CALL    DELAYS          ;DELAY  
            MOV     AH, 2H
            MOV     DL, " "
            INT     21H
        RET                         ;RETURN    

        ;DELAY NADA
        DELAYS:
            MOV     AH, 00H         ;FUNGSI 0H - DAPATKAN SYSTEM TIMER
            INT     01AH            ;PANGIL ROM BIOS TIME-OF-DAY SERVICES
            ADD     DX, 2           ;MASUKAN NILAI DELAY
            MOV     BX, DX          ;STORE HASILNYA KE BX

        PZ:
            INT     01AH            ;PANGGIL ROM BIOS TIME-OF-DAY SERVICES
            CMP     DX, BX          ;COMPARE DENGAN BX, APAKAH SUDAH SELESAI DELAY ?
            JL      PZ              ;JIKA BELUM LOOPING
        RET                         ;RETURN              
        
        DELAYL:
            MOV     AH, 00H         ;FUNGSI 0H - DAPATKAN SYSTEM TIMER
            INT     01AH            ;PANGIL ROM BIOS TIME-OF-DAY SERVICES
            ADD     DX, 8           ;MASUKAN NILAI DELAY
            MOV     BX, DX          ;STORE HASILNYA KE BX

        PX:
            INT     01AH            ;PANGGIL ROM BIOS TIME-OF-DAY SERVICES
            CMP     DX, BX          ;COMPARE DENGAN BX, APAKAH SUDAH SELESAI DELAY ?
            JL      PX              ;JIKA BELUM LOOPING
        RET                         ;RETURN

        ;CLEAR KEYBOARD BUFFER
        CLR_KEYB:
            PUSH    ES                      ;SIMPAN ES
            PUSH    DI                      ;SIMPAN DI
            MOV     AX, 40H                 ;BIOS SEGMEN DIDALAM AX
            MOV     ES, AX                  ;TRANSFER KE ES
            MOV     AX, 1AH                 ;KEYBOARD POINTER DIDALAM AX
            MOV     DI, AX                  ;MASUKAN KE DI
            MOV     AX, 1EH                 ;KEYBOARD BUFFER MULAI DARI AX
            MOV     ES: WORD PTR [DI], AX   ;PINDAHKAN KE HEAD POINTER
            INC     DI                      ;PINDAHKAN POINTER KE KEYBOARD TAIL POINTER
            INC     DI                      
            MOV     ES: WORD PTR [DI], AX   ;PINDAHKAN KE TAIL POINTER
            POP     DI                      ;RESTORE DI
            POP     ES                      ;RESTORE ES
        RET                                 ;RETURN  
        CLEAR_SCREEN:                       ;PROC UNTUK MENGHAPUS LAYAR
            ;PUSHA
            MOV AH, 0H
            MOV AL, 3H
            INT 16
            ;POPA
        RET
;==================================================================
;====                          DECODE                          ====  
;==================================================================            
    _DECODE:
    MOV AX, 0000H
    MOV BX, 0000H
    MOV CX, 0000H
    MOV DX, 0000H
    MOV SI, 0000H
    MOV INPUT_DECODE, 0000H
    MOV INPUT_CHECKER, 0000H
    MOV COUNT_DECODE_PERCHAR, 0000H
    MOV COUNT_DECODE, 0000H
    MOV INDEX_DECODE, 0000H
    MOV CODES, 0000H
    MOV LENGTHS_DECODE, 0000H 
    
    CALL CLEAR_SCREEN
    CALL GETINPUT_DECODE 
    
    MOV AX, 0000H
    MOV AH, 9H
    MOV DX, OFFSET STR_OUTPUT
    INT 21H
    
    CALL CHECK_INPUT_DECODE
    GETINPUT_DECODE:
        MOV AH, 9H                ;PRINT "INPUT STRING"
        MOV DX, OFFSET STR_INPUT_DECODE
        INT 21H                    
       
        MOV SI, OFFSET INPUT_DECODE      ;UNTUK CEK VAR INPUT
        MOV LENGTHS_DECODE, 0             ;UNTUK TAU PANJANG INPUTNYA
            
            LZ:
                MOV AH,1H
                INT 21H 
                
                CMP AL ,13     ;CEK KALO INPUTNYA ENTER, LOOPNYA BERES
                JE DONE_DECODE ;DICEK TERLEBIH DAHULU SEBELUM ASSIGN AGAR ASCII ENTER TIDAK MASUK ARRAY
                
                MOV [SI],AL
                INC SI
                INC LENGTHS_DECODE 
                
                CMP AL, 8H     ;KALO KLIK BACKSPACE
                JE BACK_DECODE  
                
                
                JMP LZ
                BACK_DECODE:          ;INTINYA, SI DAN LENGTHS_DECODENYA BERKURANG 2
                    CMP LENGTHS_DECODE[0],0
                    JE LZ  
                    DEC SI
                    MOV AH, 2H
                    MOV DL, 20H
                    INT 21H   
                    MOV AH, 2H
                    MOV DL, 8H
                    INT 21H
                    DEC SI
                    DEC LENGTHS_DECODE
                    DEC LENGTHS_DECODE
                    JMP LZ
                    
            DONE_DECODE:
                MOV AL, 20H         ;SEMUA BLOK CODE PADA DONE_DECODE BERFUNGSI 
                MOV [SI],AL         ;MENAMBAH SPASI DAN ENTER SECARA OTOMATIS
                INC LENGTHS_DECODE  ;TUJUANNYA AGAR PROGRAM DAPAT MENGETAHUI BLOK MORSE CODE TERAKHIR
                INC SI
                MOV AL, 0DH
                MOV [SI],AL                
                INC LENGTHS_DECODE        
                RET 
    CHECK_INPUT_DECODE:
        MOV AX, @DATA
        MOV DS, AX
        LEA SI, INPUT_DECODE    
        MOV AX, 0H
        MOV AL, INDEX_DECODE[0]
        MOV SI, AX  
        MOV DI, 0
        MOV COUNT_DECODE_PERCHAR, 0 
         
        LD:  
            MOV DL, INPUT_DECODE[SI]
            CMP DL, 20H
            JE ONE_CHAR_DONE
            MOV INPUT_CHECKER[DI], DL 
            INC INDEX_DECODE
            INC COUNT_DECODE_PERCHAR           
            INC COUNT_DECODE
            INC SI
            INC DI     
            MOV BL, LENGTHS_DECODE[0]
            CMP COUNT_DECODE, BL
            JNE NOT_EXT
            JMP EXT
            NOT_EXT:
            JMP LD
            
            ONE_CHAR_DONE:
                INC INDEX_DECODE
                INC COUNT_DECODE
                CALL CHAR_CHECK
                 
            
    CHAR_CHECK:
        MOV SI, OFFSET INPUT_CHECKER
        LX:
            MOV DL, [SI]  
            INC SI
            CMP DL, 2EH
            JE DOT_DECODE
            CMP DL, 2DH
            JE STRIP_DECODE
            
            DOT_DECODE:           
                MOV AL, COUNT_DECODE_PERCHAR[0]
                MOV DL, 1
                MUL DL
                MOV DL, AL              
                MOV AL, COUNT_DECODE_PERCHAR[0]
                MUL DL
                ADD CODES, AL
                DEC COUNT_DECODE_PERCHAR
                CMP COUNT_DECODE_PERCHAR[0], 0
                JE DONE_PERCHAR
                JMP LX         
            STRIP_DECODE:           
                MOV AL, COUNT_DECODE_PERCHAR[0]
                MOV DL, 2
                MUL DL
                MOV DL, AL              
                MOV AL, COUNT_DECODE_PERCHAR[0]
                MUL DL
                ADD CODES, AL
                DEC COUNT_DECODE_PERCHAR
                CMP COUNT_DECODE_PERCHAR[0], 0
                JE DONE_PERCHAR
                JMP LX                
            DONE_PERCHAR:
                CMP CODES[0], 6
                JNE NOT_PRINT_A
                JMP PRINT_A
                NOT_PRINT_A:
                CMP CODES[0], 46
                JNE NOT_PRINT_B
                JMP PRINT_B
                NOT_PRINT_B:
                CMP CODES[0], 50
                JNE NOT_PRINT_C
                JMP PRINT_C
                NOT_PRINT_C:
                CMP CODES[0], 23
                JNE NOT_PRINT_D
                JMP PRINT_D
                NOT_PRINT_D:
                CMP CODES[0], 1
                JNE NOT_PRINT_E
                JMP PRINT_E
                NOT_PRINT_E:
                CMP CODES[0], 34
                JNE NOT_PRINT_F
                JMP PRINT_F
                NOT_PRINT_F: 
                CMP CODES[0], 27
                JNE NOT_PRINT_G
                JMP PRINT_G
                NOT_PRINT_G:      
                CMP CODES[0], 30
                JNE NOT_PRINT_H
                JMP PRINT_H
                NOT_PRINT_H: 
                CMP CODES[0], 5
                JNE NOT_PRINT_I
                JMP PRINT_I
                NOT_PRINT_I:
                CMP CODES[0], 44
                JNE NOT_PRINT_J
                JMP PRINT_J
                NOT_PRINT_J: 
                CMP CODES[0], 24
                JNE NOT_PRINT_K
                JMP PRINT_K
                NOT_PRINT_K: 
                CMP CODES[0], 39
                JNE NOT_PRINT_L
                JMP PRINT_L
                NOT_PRINT_L:      
                CMP CODES[0], 10
                JNE NOT_PRINT_M
                JMP PRINT_M
                NOT_PRINT_M: 
                CMP CODES[0], 9
                JNE NOT_PRINT_N
                JMP PRINT_N
                NOT_PRINT_N:
                CMP CODES[0], 28
                JNE NOT_PRINT_O
                JMP PRINT_O
                NOT_PRINT_O: 
                CMP CODES[0], 43
                JNE NOT_PRINT_P
                JMP PRINT_P
                NOT_PRINT_P: 
                CMP CODES[0], 56
                JNE NOT_PRINT_Q
                JMP PRINT_Q
                NOT_PRINT_Q:
                CMP CODES[0], 18
                JNE NOT_PRINT_R
                JMP PRINT_R
                NOT_PRINT_R: 
                CMP CODES[0], 14
                JNE NOT_PRINT_S
                JMP PRINT_S
                NOT_PRINT_S: 
                CMP CODES[0], 2
                JNE NOT_PRINT_T
                JMP PRINT_T
                NOT_PRINT_T:
                CMP CODES[0], 15
                JNE NOT_PRINT_U
                JMP PRINT_U
                NOT_PRINT_U:     
                CMP CODES[0], 31
                JNE NOT_PRINT_V
                JMP PRINT_V
                NOT_PRINT_V: 
                CMP CODES[0], 19
                JNE NOT_PRINT_W
                JMP PRINT_W
                NOT_PRINT_W:   
                CMP CODES[0], 47
                JNE NOT_PRINT_X
                JMP PRINT_X
                NOT_PRINT_X: 
                CMP CODES[0], 51
                JNE NOT_PRINT_Y
                JMP PRINT_Y
                NOT_PRINT_Y: 
                CMP CODES[0], 55
                JNE NOT_PRINT_Z
                JMP PRINT_Z
                NOT_PRINT_Z:   
                JMP PRINT_UNKNOWN     
 
    PRINT_A:
        MOV AH, 02H
        MOV DL, "A"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_B:
        MOV AH, 02H
        MOV DL, "B"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_C:
        MOV AH, 02H
        MOV DL, "C"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_D:
        MOV AH, 02H
        MOV DL, "D"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_E:
        MOV AH, 02H
        MOV DL, "E"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_F:
        MOV AH, 02H
        MOV DL, "F"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_G:
        MOV AH, 02H
        MOV DL, "G"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_H:
        MOV AH, 02H
        MOV DL, "H"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_I:
        MOV AH, 02H
        MOV DL, "I"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_J:
        MOV AH, 02H
        MOV DL, "J"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_K:
        MOV AH, 02H
        MOV DL, "K"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_L:
        MOV AH, 02H
        MOV DL, "L"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_M:
        MOV AH, 02H
        MOV DL, "M"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_N:
        MOV AH, 02H
        MOV DL, "N"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_O:
        MOV AH, 02H
        MOV DL, "O"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_P:
        MOV AH, 02H
        MOV DL, "P"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_Q:
        MOV AH, 02H
        MOV DL, "Q"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_R:
        MOV AH, 02H
        MOV DL, "R"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_S:
        MOV AH, 02H
        MOV DL, "S"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_T:
        MOV AH, 02H
        MOV DL, "T"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_U:
        MOV AH, 02H
        MOV DL, "U"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_V:
        MOV AH, 02H
        MOV DL, "V"                            
        INT 21H   
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_W:
        MOV AH, 02H
        MOV DL, "W"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_X:
        MOV AH, 02H
        MOV DL, "X"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE
    PRINT_Y:
        MOV AH, 02H
        MOV DL, "Y"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE 
    PRINT_Z:
        MOV AH, 02H
        MOV DL, "Z"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE   
    PRINT_UNKNOWN:
        MOV AH, 02H
        MOV DL, "?"                            
        INT 21H       
        MOV CODES[0], 0
        JMP CHECK_INPUT_DECODE         
    EXT: 
    MOV AH, 9H
    MOV DX, OFFSET PRESS_ANY_KEY
    INT 21H  
    
    MOV AH, 1H
    INT 21H
    
    JMP MAIN_MENU
;==================================================================
;====                 SHOW MORSE CODE LISTS                    ====  
;==================================================================     
    _MORSECODE:
            CALL CLEAR_SCREEN
            MOV AH, 9H
            MOV DX, OFFSET MORSE_LISTS
            INT 21H
            JMP EXT
            
    REAL_EXIT:    
    .EXIT
END