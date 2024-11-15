#include <avr/io.h>
#include <avr/pgmspace.h>

#define ARRAY_SIZE 256          // Tamaño de memoria de video
#define ARRAY_START_ADDR 0X0700 // Dirección de memoria de video

volatile uint8_t* VideoRAM = (volatile uint8_t*)ARRAY_START_ADDR; // Puntero volátil

const uint8_t font_table[192] PROGMEM = {
  0x00, 0x00, 0x00, 0x44, 0x40, 0x40, 0xAA, 0x00, 0x00, 0xAE, 0xAE, 0xA0, 0x6C, 0xE6, 0xC0, 0x82,
  0x48, 0x20, 0x4A, 0x4A, 0x60, 0x44, 0x00, 0x00, 0x48, 0x88, 0x40, 0x42, 0x22, 0x40, 0xA4, 0xA0,
  0x00, 0x04, 0xE4, 0x00, 0x00, 0x48, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0x40, 0x22, 0x48, 0x80,
  0xEA, 0xAA, 0xE0, 0x4C, 0x44, 0xE0, 0xE2, 0xE8, 0xE0, 0xE2, 0xE2, 0xE0, 0xAA, 0xE2, 0x20, 0xE8,
  0xE2, 0xE0, 0xE8, 0xEA, 0xE0, 0xE2, 0x48, 0x80, 0xEA, 0xEA, 0xE0, 0xEA, 0xE2, 0xE0, 0x04, 0x04,
  0x00, 0x04, 0x04, 0x40, 0x24, 0x84, 0x20, 0x0E, 0x0E, 0x00, 0x84, 0x24, 0x80, 0xE2, 0x60, 0x40,
  0xEE, 0x8A, 0xE0, 0x4A, 0xEA, 0xA0, 0xCA, 0xCA, 0xC0, 0x68, 0x88, 0x60, 0xCA, 0xAA, 0xC0, 0xE8,
  0xC8, 0xE0, 0xE8, 0xC8, 0x80, 0xE8, 0xAA, 0xE0, 0xAA, 0xEA, 0xA0, 0xE4, 0x44, 0xE0, 0xE2, 0x2A,
  0x60, 0xAA, 0xCA, 0xA0, 0x88, 0x88, 0xE0, 0xAE, 0xAA, 0xA0, 0xCA, 0xAA, 0xA0, 0x4A, 0xAA, 0x40,
  0xEA, 0xE8, 0x80, 0xEA, 0xAE, 0x20, 0xEA, 0xCA, 0xA0, 0x68, 0xE2, 0xC0, 0xE4, 0x44, 0x40, 0xAA,
  0xAA, 0xE0, 0xAA, 0xAA, 0x40, 0xAA, 0xAE, 0xA0, 0xAA, 0x4A, 0xA0, 0xAA, 0xE4, 0x40, 0xE2, 0x48,
  0xE0, 0xC8, 0x88, 0xC0, 0x88, 0x42, 0x20, 0x62, 0x22, 0x60, 0x4A, 0x00, 0x00, 0x00, 0x00, 0xE0
};

const char line1[] PROGMEM = "HOLA COMO ESTAS!";
const char line2[] PROGMEM = "ESPERO QUE ESTES BIEN";
const char line3[] PROGMEM = "FINAL DEL MENSAJE.";
const char line4[] PROGMEM = "P.U.T.A.        PRINGAO!        UNICORNIOS EN   TANGA, AHI      ARRIBA!";
const char line5[] PROGMEM = "G.A.T.O.        GATO            ASADO CON       TABASCO Y       OREGANO";

extern "C"{
  void start();
  void burst();
}

void setup() {
  // put your setup code here, to run once:
  clear_screen();
  start();
}

void loop() {
  // put your main code here, to run repeatedly:
  print_screen(line1);
  print_screen(line2);
  print_screen(line3);
  print_screen(line4);
  print_screen(line5);
}

void character(uint8_t letter, uint8_t pos){
  letter = letter * 3;
  bool swap = (pos & 1) == 1;
  pos = 48 * ((int)(pos >> 1) / 8) + ((pos >> 1) % 8);

  if(swap){
    for (uint8_t i = 0; i < 3; i ++){
      VideoRAM[pos + (16 * i)] = (VideoRAM[pos + (16 * i)] & 0xF0) | (pgm_read_byte(&font_table[letter + i]) & 0xF0) >> 4;
      VideoRAM[pos + ((16 * i) + 8)] = (VideoRAM[pos + ((16 * i) + 8)] & 0xF0) | (pgm_read_byte(&font_table[letter + i]) & 0x0F);
    }
  } else {
    for (uint8_t i = 0; i < 3; i ++){
      VideoRAM[pos + (16 * i)] = (VideoRAM[pos + (16 * i)] & 0x0F) | (pgm_read_byte(&font_table[letter + i]) & 0xF0);
      VideoRAM[pos + ((16 * i) + 8)] = (VideoRAM[pos + ((16 * i) + 8)] & 0x0F) | (pgm_read_byte(&font_table[letter + i]) & 0x0F) << 4;
    }
  }
}

void clear_screen(){
  for (uint16_t i = 0; i < 256; i++) {
    VideoRAM[i] = 0;
  }
}

void print_screen(const char* str) {
    clear_screen();
    // Get the length of the string in PROGMEM
    uint8_t length = strlen_P(str); // strlen_P gets the length of the string in PROGMEM

    for (uint8_t i = 0; i < length; i++) {
        // Read each byte from PROGMEM, subtract 32, and call character()
        character(pgm_read_byte(&str[i]) - 32, i);
    }
    burst();
}
