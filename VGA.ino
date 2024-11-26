#include <avr/io.h>


const int analog_pin = A0;                  // Pin analógico de entrada
const int warning_pin = 3;                  // Pin de advertencia - sobrevoltaje
uint8_t v_act = 0;                          // Voltaje actual
uint8_t v_max = 0;                          // Voltaje máximo
uint8_t v_min = 255;                        // Voltaje mínimo
uint8_t v_trs = 0;                          // Voltaje umbral (sobrepasar activa la advertencia)
uint8_t v_rms = 0;                          // Voltaje media cuadrática
uint16_t sample_count = 0;                  // Número de muestras tomadas
uint32_t v_sum = 0;                         // Suma de voltajes

extern "C"{                                 // Declaración de funciones escritas en ensamblador
  void start();                             // Inicialización de pines para la generación de video
  void burst(uint8_t a);                    // Generar video por ((256 - n) / 60) segundos
}

void setup() {
  start();
  sampling_initialize();
}

void loop() {
  clear_screen();
  take_sample();
  show_result();
  burst(16);
}
