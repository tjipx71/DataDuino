const int analogPin = A0;      // Pin de entrada para el potenciómetro
const int ledPin = 3;          // Pin de salida para el LED de alerta
const float voltageMax = 5.0;  // Voltaje máximo de entrada (en voltios)
const int resolution = 255;    // Resolución de 8 bits (0-255)
const int limitSamples = 1024; // Límite de muestras
const float thresholdVoltage = 4.0; // Umbral de voltaje para activar la alerta
const unsigned long sampleInterval = 1000; // Intervalo de muestreo en milisegundos (1s)

int samples[limitSamples];    // Almacén para las muestras de 8 bits
int sampleCount = 0;          // Contador de muestras

void setup() {
  Serial.begin(9600);         // Inicializar comunicación serial
  pinMode(analogPin, INPUT);  // Configurar el pin de entrada
  pinMode(ledPin, OUTPUT);    // Configurar el pin del LED como salida
  digitalWrite(ledPin, LOW);  // Asegurarse de que el LED está apagado al inicio
}

void loop() {
  if (sampleCount < limitSamples) {
    // Leer el valor analógico (0-1023) y convertir a 8 bits (0-255)
    int analogValue = analogRead(analogPin); 
    int signal8bit = map(analogValue, 0, 1023, 0, resolution);
    float voltage = (signal8bit / float(resolution)) * voltageMax;

    // Guardar la muestra en el arreglo
    samples[sampleCount] = signal8bit;
    sampleCount++;

    // Mostrar el valor de la señal en la consola serial
    Serial.print("Muestra ");
    Serial.print(sampleCount);
    Serial.print(": Valor 8 bits = ");
    Serial.print(signal8bit);
    Serial.print("\tVoltaje = ");
    Serial.print(voltage);
    Serial.println(" V");

    // Verificar si el voltaje sobrepasa el límite
    if (voltage > thresholdVoltage) {
      Serial.println("ALERTA: Voltaje sobrepasado");
      digitalWrite(ledPin, HIGH);  // Encender el LED
    } else {
      digitalWrite(ledPin, LOW);   // Apagar el LED si está bajo el umbral
    }

    // Esperar el intervalo de muestreo antes de la próxima lectura
    delay(sampleInterval);
  } else {
    // Si alcanzamos el límite de muestras, calcular estadísticas
    int max_value = 0;
    int min_value = 255;
    int sum_values = 0;

    for (int i = 0; i < sampleCount; i++) {
      max_value = max(max_value, samples[i]);
      min_value = min(min_value, samples[i]);
      sum_values += samples[i];
    }

    // Calcular voltajes correspondientes
    float max_voltage = (max_value / float(resolution)) * voltageMax;
    float min_voltage = (min_value / float(resolution)) * voltageMax;
    float average_voltage = (sum_values / float(sampleCount) / resolution) * voltageMax;

    // Imprimir resultados finales
    Serial.println("Resultados del procesamiento de señales:");
    Serial.print("Voltaje Máximo: ");
    Serial.print(max_voltage);
    Serial.println(" V");
    Serial.print("Voltaje Mínimo: ");
    Serial.print(min_voltage);
    Serial.println(" V");
    Serial.print("Voltaje Promedio: ");
    Serial.print(average_voltage);
    Serial.println(" V");

    // Reiniciar el contador de muestras para empezar de nuevo
    sampleCount = 0;
  }
}
