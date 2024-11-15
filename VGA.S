#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global start
.global burst

//---------------- USO DE REGISTROS
//---------------------------------
// R18: Incrementador, siempre valdrá 1
// R19: Looper delay
// R20: Looper para sincronización horizontal
// R21: Looper para líneas de píxeles
// R22: NO EN USO
// R23: Valor píxel
// R26: Registro X bajo (puntero píxel)
// R27: Registro X alto (puntero píxel)
// R28: Regsitro Y bajo (puntero temporal)
// R29: Registro Y alto (puntero temporal)
// --------------------------------
// --------------------------------


start:

  SBI DDRB, 0;    // sincronismo horizontal
  SBI DDRB, 1;    // sincronismo vertical
  LDI R18, 255;   // TODOS LOS BITS DE PUERTO D: VIDEO
  OUT DDRD, R18;
  RET;

burst:
  CLI;
  MOV R22, R24;
  LDI R18, 1;
  CALL v_sync_0;
  RET;

//---------------- SINCRONIZACIÓN VERTICAL
//----------------------------------------
v_sync_0:         // VARIABLES INICIALES
  SBI PORTB, 1;   // 125
  LDI R21, 224;   // 62.5

v_sync_1:         // LINEAS CON DATO - OKAY
  LDI R20, 249;   // 62.5
  
  CALL h_sync_color_0;  // 250
  ADIW R26, 16;   // 62.5
  NOP;            // 62.5
  ADD R21, R18;   // 62.5
  BRCC v_sync_1;  // 125b 62.5nb

  LDI R20, 0;     // LINEAS EN BLANCO 62.5
  
  CALL h_sync_0;  // 250 LINEAS EN BLANCO - OKAY
  SBI PORTB, 1;   // 125
  LDI R20, 246;   // 62.5
  NOP;            // 62.5
  NOP;            // 62.5
  NOP;            // 62.5
  
  CALL h_sync_0;  // 250 FRONTAL - OKAY
  NOP;            // 62.5
  LDI R26, 0;     // 62.5 VOLVER A CARGAR REGISTRO X PARA GENERAR PÍXELES NUEVAMENTE
  LDI R27, 6;     // 62.5
  CBI PORTB, 1;   // 125
  LDI R20, 254;   // 62.5
  
  CALL h_sync_0;  // 250 SINCRONISMO - OKAY
  
  ADD R22, R18;   // 62.5
  BRCS v_sync_f;  // 62.5
  NOP;            // 62.5
  
  SBI PORTB, 1;   // 125
  LDI R20, 223;   // 62.5
  
  CALL h_sync_0;  // 250 TRASERO - OKAY
  //ADD R21, R18;
  //BRCC v_sync_0;
  RJMP v_sync_0;  // 125
  
v_sync_f:
  RET;            // 250
//----------------------------------------
//----------------------------------------


//----------------- SINCRONIZACIÓN HORIZONTAL
//-------------------------------------------
h_sync_0:         // Inicio, zona visible: 500 + (133*187.5) = 25437.5ns
  SBI PORTB, 0;
  LDI R18, 1;
  LDI R19, 122;

h_sync_1:         // Delay visible: (133*187.5) + 250
  ADD R19, R18;
  BRCC h_sync_1;
  LDI R19, 253;
  NOP;

h_sync_2:         // Delay Frontal: (2*187.5) + 250 = 625ns
  ADD R19, R18;
  BRCC h_sync_2;
  LDI R19, 237
  NOP;

  CBI PORTB, 0;   // Tiempo incluido en la siguiente etiqueta

h_sync_3:         // Delay sincronización: (18*187.5) + 312.5 = 3812.5ns
  ADD R19, R18;
  BRCC h_sync_3;
  LDI R19, 252
  NOP;
  NOP;
  
  SBI PORTB, 0;   // Tiempo incluido en la siguiente etiqueta

h_sync_4:         // Delay trasero: 1000 + 875 = 1875ns 
  ADD R19, R18
  BRCC h_sync_4;
  NOP;
  NOP;

  ADD R20, R18;   // Incrementar R20: 62.5
  BRCS h_sync_f;  // Si acarreo terminar rutina: 125B 62.5NB
  LDI R19, 252;   // Si no acarreo comenzar delay 2: 62.5

h_sync_5:         // Delay trasero2: 562.5 + 312.5 = 875ns
  ADD R19, R18;
  BRCC h_sync_5;
  NOP;
  RJMP h_sync_0;  // 125B 62.5NB

h_sync_f:         // 250
  RET;
//-------------------------------------------
//-------------------------------------------

//----------------- SINCRONIZACIÓN HORIZONTAL CON COLOR
//-----------------------------------------------------
h_sync_color_0:   // 375
  SBI PORTB, 0;   // 125
  CBI PORTD, 7;   // 125
  MOV R28, R26;   // 62.5  Y = X
  MOV R29, R27;   // 62.5

h_sync_color_1:   // 24000 ns
  LD R23, Y+;   // Píxel 1  BYTE 1
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 2
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 3
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 4
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 5
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 6
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 7
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 8
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 9
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 10
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 11
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 12
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 13
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 14
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 15
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;
  LD R23, Y+;   // Píxel 1  BYTE 16
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 2
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 3
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 4
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 5
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 6
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 7
  NOP;
  OUT PORTD, R23;
  ADD R23, R23;   // Píxel 8
  NOP;
  OUT PORTD, R23;

  CBI PORTD, 7;   // 1062.5ns
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;
  NOP;

  NOP;
  NOP;
  
  LDI R19, 254;

h_sync_color_2:         // Delay Frontal: (2*187.5) + 250 = 625ns
  ADD R19, R18;
  BRCC h_sync_color_2;
  LDI R19, 237
  NOP;

  CBI PORTB, 0;   // Tiempo incluido en la siguiente etiqueta

h_sync_color_3:         // Delay sincronización: (18*187.5) + 312.5 = 3812.5ns
  ADD R19, R18;
  BRCC h_sync_color_3;
  LDI R19, 252
  NOP;
  NOP;
  
  SBI PORTB, 0;   // Tiempo incluido en la siguiente etiqueta

h_sync_color_4:         // Delay trasero: 1000 + 875 = 1875ns 
  ADD R19, R18
  BRCC h_sync_color_4;
  NOP;
  NOP;

  ADD R20, R18;   // Incrementar R20: 62.5
  BRCS h_sync_color_f;  // Si acarreo terminar rutina: 125B 62.5NB
  LDI R19, 252;   // Si no acarreo comenzar delay 2: 62.5

h_sync_color_5:         // Delay trasero2: 562.5 + 312.5 = 875ns
  ADD R19, R18;
  BRCC h_sync_color_5;
  NOP;
  RJMP h_sync_color_0;  // 125B 62.5NB

h_sync_color_f:         // 250
  RET;
//-------------------------------------------
//-------------------------------------------
