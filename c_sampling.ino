void sampling_initialize(){
  Serial.begin(9600);         // Inicializar comunicación serial
  pinMode(analog_pin, INPUT);  // Configurar el pin de entrada
  pinMode(warning_pin, OUTPUT);    // Configurar el pin del LED como salida
  digitalWrite(warning_pin, LOW);  // Asegurarse de que el LED está apagado al inicio

}

void take_sample() {
  if (sample_count < 1024) {
    v_act = map(analogRead(analog_pin), 0, 1023, 0, 255);

    v_sum = v_sum + (v_act * v_act);
    samples[sample_count] = v_act;
    sample_count++;

    if (v_act > v_max) {                // Voltaje máximo
      v_max = v_act;
    }

    if (v_act < v_min) {                // Voltaje mínimo
      v_min = v_act;
    }

    v_rms = uint8_t(sqrt(v_sum / sample_count));  // Voltaje RMS

    // Verificar si el voltaje sobrepasa el límite
    if (v_act > v_trs) {
      digitalWrite(warning_pin, HIGH);  // Encender el LED
    } else {
      digitalWrite(warning_pin, LOW);   // Apagar el LED si está bajo el umbral
    }
  }
}

void show_result(){
  print_screen(msg[0] + char((v_max / 255.0) * 5), 0);
  print_screen(msg[1] + char((v_min / 255.0) * 5), 32);
  print_screen(msg[2] + char((v_act / 255.0) * 5), 16);
  print_screen(msg[3] + char((v_rms / 255.0) * 5), 48);
  print_screen(msg[4] + char((v_trs / 255.0) * 5), 64);
  print_screen(msg[5] + char(sample_count), 80);
  print_screen(msg[6], 112);
  delay(100);
  Serial.print(pgm_read_word(msg[0]) + char((v_max / 255.0) * 5));
  Serial.print("\t" + pgm_read_word(msg[1]) + char((v_min / 255.0) * 5));
  Serial.print("\t" + pgm_read_word(msg[2]) + char((v_rms / 255.0) * 5));
  Serial.print("\t" + pgm_read_word(msg[3]) + char((v_act / 255.0) * 5));
  Serial.print("\t" + pgm_read_word(msg[4]) + char((v_trs / 255.0) * 5));
  delay(100);
}
