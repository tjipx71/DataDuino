#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global start
.global burst

start:
  NOP;
  SBI DDRB, 0;              // 125
  SBI DDRB, 1;
  RET;

burst:
  LDI R19, 255;
  LDI R30, 0xFF;
  LDI R31, 0x06;
  ST Z, R19;
  
burst_2:
  CLI;                // Disable interrupts
  LDI R20, 250;
  CALL short_sync;    // 6 times short sync
  LDI R20, 251;
  CALL long_sync;     // 5 times long sync
  LDI R20, 251;
  CALL short_sync;    // 5 times long sync
  LDI R20, 200;
  CALL fotograma;     // 56 veces líneas de fondo

  LDI R18, 0x00;
  LDI R19, 0x08;

burst_3:
  MOV R30, R18;
  CALL leer;
  NOP;
  CALL fotograma_b;

  ADD R18, R19;
  BRCC burst_3;
  
  LDI R20, 200;        // 226 veces líneas de fondo
  CALL fotograma;

  LDI R30, 0xFF;
  LDI R31, 0x06;
  LDI R18, 255;
  LD R19, Z;
  ADD R19, R18;
  BRCC burst_4;
  ST Z, R19;
  
  
  JMP burst_2;                  // 125
burst_4:
  SEI;
  RET;

//-------------------------- SINCRONISMO CORTO, DEJA 5 CICLOS DE RELOJ
short_sync:                 // time = 437.5
  CBI PORTB, 0;             // 125
  CBI PORTB, 1;             // 125
  LDI R21, 250;             // 62.5 B = 250
  LDI R22, 1;               // C = 1
  NOP;
  
short_sync_1:               // (6-1)*250 + 312.5 = 1562.5
  ADD R21, R22;             // 62.5
  NOP
  BRCC short_sync_1;        // 125 if branch, else: 62.5
  NOP;                      // 62.5
  NOP;
//--------------------------
short_sync_2:               // time = 187.5
  SBI PORTB, 0;             // 125
  LDI R21, 140;              // B = 140

short_sync_3:               // time = (116-1)*250 + 312.5 = 28875
  ADD R21, R22;             // 62.5
  NOP;
  BRCC short_sync_3;        // 125 if branch, else: 62.5
  NOP;                      // 62.5
  NOP;

short_sync_4:               // time = 937.5 if branch: 187.5
  ADD R20, R22;             // 62.5
  BRCS short_sync_5;        // 125 if branch, else: 62.5
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  RJMP short_sync;          // 125
// Retorno
short_sync_5:
  RET;                      // 250

// 750 if not branch, else: 437.5

//-------------------------- SINCRONISMO LARGO, DEJA 5 CICLOS DE RELOJ
long_sync:               // time = 375
  CBI PORTB, 0;             // 125
  CBI PORTB, 1;             // 125
  LDI R22, 1;               // 62.5 C = 1
  LDI R21, 138;              // 62.5 B = 100

long_sync_1:               // time = (118-1)*250 + 375 = 29625
  ADD R21, R22;             // 62.5
  NOP;
  BRCC long_sync_1;        // 125 if branch, else: 62.5
  NOP;
  NOP;
  NOP;
  
//--------------------------
long_sync_2:                 // time = 250
  SBI PORTB, 0;             // 125
  LDI R21, 252;             // B = 252
  NOP;
  
long_sync_3:               // (4 - 1) * 250 + 250
  ADD R21, R22;             // 62.5
  NOP;
  BRCC long_sync_3;        // 125 if branch, else: 62.5
  NOP;
  
// ------------------------- 1250
long_sync_4:               //
  ADD R20, R22;             // 62.5
  BRCS long_sync_5;         // 125 if branch, else: 62.5
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  RJMP long_sync;           // 125
// Retorno
long_sync_5:
  RET;                      // 250

// 750 if not branch, else: 437.5


//----------------------------- FOTOGRAMA, DEJA 5 CICLOS DE RELOJ
fotograma:            // 375 nanosegundos
  CBI PORTB, 0;
  CBI PORTB, 1;
  LDI R22, 1;
  LDI R21, 242;

fotograma_1:          // Delay
  ADD R21, R22;       // (14 - 1) * 250 + 375 = 3625 nanosegundos
  NOP;
  BRCC fotograma_1;
  NOP;
  NOP;
  NOP;

fotograma_2:          // 187.5 nanosegundos
  SBI PORTB, 0;
  LDI R21, 225;

fotograma_3:          // Delay
  ADD R21, R22;       // (31 - 1) * 250 + 312.5 = 7812.5 nanosegundos
  NOP;
  BRCC fotograma_3;
  NOP;
  NOP;

fotograma_4:          // 312.5 nanosegundos
  SBI PORTB, 1;
  CBI PORTB, 0;
  LDI R21, 52;

fotograma_5:          // Delay
  ADD R21, R22;       // (204-1) * 250 + 187.5 = 50937.5 nanosegundos
  NOP;
  BRCC fotograma_5;

fotograma_6:          // 750 nanosegundos
  ADD R20, R22;             // 62.5
  BRCS fotograma_7;         // 125 if branch, else: 62.5
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  RJMP fotograma;           // 125

fotograma_7:          // 250 nanosegundos
  RET;                // Retorno

// 750 if not branch, else: 437.5


//----------------------------- FOTOGRAMA, DEJA 5 CICLOS DE RELOJ
fotograma_b:          // 375 nanosegundos
  CBI PORTB, 0;       // Pin de sincronismo
  CBI PORTB, 1;       // Pin de blanco
  LDI R22, 1;         // Variable incrementador
  LDI R21, 242;       // Número de iteraciones

fotograma_b_1:        // Delay
  ADD R21, R22;       // (14 - 1) * 250 + 375 = 3625 nanosegundos
  NOP;
  BRCC fotograma_b_1;
  NOP;
  NOP;
  NOP;

fotograma_b_2:        // 187.5 nanosegundos
  SBI PORTB, 0;       // Pin de sincronismo
  LDI R21, 225;       // Número de iteraciones

fotograma_b_3:        // Delay
  ADD R21, R22;       // (31 - 1) * 250 + 312.5 = 7812.5 nanosegundos
  NOP;
  BRCC fotograma_b_3;
  NOP;
  NOP;
// --- FONDO IZQUIERDO ---
fotograma_b_4:        // 312.5 nanosegundos
  SBI PORTB, 1;       // Pin de blanco
  CBI PORTB, 0;       // Pin de sincronismo
  LDI R21, 230;       // Número de iteraciones
  
fotograma_b_5:        //Delay
  ADD R21, R22;       // (26-1) * 250 + 312.5 = 6562.5 nanosegundos
  NOP;
  BRCC fotograma_b_5;
  NOP;
  NOP;

// --- PÍXELES DE PANTALLA ---
// 36000 nanosegundos
SBRC R23, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 2
SBRC R23, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 3
SBRC R23, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 4
SBRC R23, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 5
SBRC R23, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 6
SBRC R23, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 7
SBRC R23, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 8
SBRC R23, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R23, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 9
SBRC R24, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 10
SBRC R24, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 11
SBRC R24, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 12
SBRC R24, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 13
SBRC R24, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 14
SBRC R24, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 15
SBRC R24, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 16
SBRC R24, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R24, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 17
SBRC R25, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 18
SBRC R25, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 19
SBRC R25, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 20
SBRC R25, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 21
SBRC R25, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 22
SBRC R25, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 23
SBRC R25, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 24
SBRC R25, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R25, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 25
SBRC R26, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 26
SBRC R26, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 27
SBRC R26, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 28
SBRC R26, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 29
SBRC R26, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 30
SBRC R26, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 31
SBRC R26, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 32
SBRC R26, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R26, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 33
SBRC R27, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 34
SBRC R27, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 35
SBRC R27, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 36
SBRC R27, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 37
SBRC R27, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 38
SBRC R27, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 39
SBRC R27, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 40
SBRC R27, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R27, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 41
SBRC R28, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 42
SBRC R28, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 43
SBRC R28, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 44
SBRC R28, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 45
SBRC R28, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 46
SBRC R28, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 47
SBRC R28, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 48
SBRC R28, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R28, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 49
SBRC R29, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 50
SBRC R29, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 51
SBRC R29, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 52
SBRC R29, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 53
SBRC R29, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 54
SBRC R29, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 55
SBRC R29, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 56
SBRC R29, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R29, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 57
SBRC R30, 7;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 7;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 58
SBRC R30, 6;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 6;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 59
SBRC R30, 5;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 5;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 60
SBRC R30, 4;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 4;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 61
SBRC R30, 3;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 3;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 62
SBRC R30, 2;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 2;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 63
SBRC R30, 1;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 1;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
//           PIXEL 64
SBRC R30, 0;        //62.5 or 187.5
SBI PORTB, 0;       //125
SBRS R30, 0;        //62.5 or 187.5
CBI PORTB, 0;       //125
NOP;
NOP;
NOP;
NOP; //250
// --- FONDO DERECHO ---
  SBI PORTB, 0;       // 312.5 nanosegundos
  CBI PORTB, 1;
  LDI R21, 251;
fotograma_b_7:        // 1187.5 nanosegundos
  ADD R21, R22;
  NOP;
  BRCC fotograma_b_7;
// --- PIXEL 4 ---
  SBI PORTB, 0;       // 312.5 nanosegundos
  CBI PORTB, 1;
  LDI R21, 231;
fotograma_b_8:        // 6187.5 nanosegundos
  ADD R21, R22;
  NOP;
  BRCC fotograma_b_8;
                      // 375 nanosegundos
  NOP;
  NOP;
  NOP;
  NOP;
  
  NOP;
  NOP;

fotograma_b_9:        // 750 nanosegundos / 432.5 nanosegundos
  ADD R20, R22;             // 62.5
  BRCS fotograma_b_10;         // 125 if branch, else: 62.5
  NOP;
  NOP;
  NOP;
  NOP;
  
  NOP;
  NOP;
  NOP;
  NOP;
  JMP fotograma_b;    // 125

fotograma_b_10:       // 250 nanosegundos
  RET;                // Retorno


//------------------- LECTURA DE MEMORIA DE VIDEO, (DEJA 5 CICLOS DE RELOJ)
// Tiempo total: 
leer:                 // 375 nanosegundos
  CBI PORTB, 0;       // Pin de sincronismo por defecto
  CBI PORTB, 1;       // Pin de blanco por defecto
  LDI R22, 1;         // Número para incrementar otros registros
  LDI R21, 242;       // Número de iteraciones

leer_1:               // Delay
  ADD R21, R22;       // (14 - 1) * 250 + 375 = 3625 nanosegundos
  NOP;
  BRCC leer_1;
  NOP;
  NOP;
  NOP;

leer_2:               // 187.5 nanosegundos
  SBI PORTB, 0;       // Pin de sincronismo
  LDI R21, 225;       // Número de iteraciones para el delay

leer_3:               // Delay
  ADD R21, R22;       // (31 - 1) * 250 + 312.5 = 7812.5 nanosegundos
  NOP;
  BRCC leer_3;
  NOP;
  NOP;

leer_4:               // 312.5 nanosegundos
  SBI PORTB, 1;       // Pin de blanco
  CBI PORTB, 0;       // Pin de sincronismo
  LDI R21, 56;        // Número de iteraciones para el delay

leer_5:               // Delay
  ADD R21, R22;       // (200-1) * 250 + 250 = 50000 nanosegundos
  NOP;
  BRCC leer_5;
  NOP;

leer_6:               // 1375 nanosegundos
  LDI R31, 0x07       // Registro alto Z
  LD R23, Z+;         // Píxeles 1-8
  LD R24, Z+;         // Píxeles 9-16
  LD R25, Z+;         // Píxeles 17-24
  LD R26, Z+;         // Píxeles 25-32
  LD R27, Z+;         // Píxeles 33-40
  LD R28, Z+;         // Píxeles 41-48
  LD R29, Z+;         // Píxeles 49-56
  LD R30, Z;          // Píxeles 57-64
  LDI R20, 251;       // Registro 20, 5 iteraciones
  RET;                // Retorno
