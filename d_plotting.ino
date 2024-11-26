void real_time_plot(){
  clear_screen();
  
  if (sample_count < 129){
    for (uint8_t i = 0; i < sample_count; i++){
      VideoRAM[496 - (map(samples[i], 0, 255, 0, 31) * 16) + (int)i/8] |= 0x01 << (i % 8);
    }
  }
}
