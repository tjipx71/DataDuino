void clear_screen(){
  for (uint16_t i = 0; i<512; i++){
    VideoRAM[i] = 0;
  }
}

void print_screen(String str, uint8_t offset) {
    // Get the length of the string in PROGMEM
    uint8_t len = str.length(); // strlen_P gets the length of the string in PROGMEM

    for (uint8_t i = 0; i < len; i++) {
        // Read each byte from PROGMEM, subtract 32, and call character()
        type_screen(str[i] - 32, i + offset);
    }
}

void type_screen(uint8_t chr, uint16_t pos){
  chr = chr * 3;
  bool swap = (pos & 1) == 1;
  pos = 96 * ((int)(pos >> 1) / 16) + ((pos >> 1) % 16);

  if(swap){
    for(uint8_t i = 0; i<3; i++){
      VideoRAM[pos + (32 * i)] = (VideoRAM[pos + (32 * i)] & 0x0F) | ((pgm_read_byte(&font_table[chr + i]) & 0xF0));
      VideoRAM[pos + (32 * i) + 16] = (VideoRAM[pos + (32 * i) + 16] & 0x0F) | ((pgm_read_byte(&font_table[chr + i]) & 0x0F) << 4);
    }
  } else {

    for(uint8_t i = 0; i<3; i++){
      VideoRAM[pos + (32 * i)] = (VideoRAM[pos + (32 * i)] & 0xF0) | ((pgm_read_byte(&font_table[chr + i]) & 0xF0) >> 4);
      VideoRAM[pos + (32 * i) + 16] = (VideoRAM[pos + (32 * i) + 16] & 0xF0) | (pgm_read_byte(&font_table[chr + i]) & 0x0F);
    }
  }
}

void colocar_caballo(){
  for (uint8_t i = 0; i < 16; i++){
    VideoRAM[192 + (i * 16)] = pgm_read_byte(&caballo[(2 * i)]);
    VideoRAM[192 + (i * 16) + 1] = pgm_read_byte(&caballo[(2 * i) + 1]);
  }
}
