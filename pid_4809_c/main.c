/*
 * pid_4809_c.c
 *
 * Created: 20/11/2024 12.57.04
 * Author : antti
 */ 

#include <avr/io.h>
#include <avr/delay.h>

#define ADC_CHANNEL 0	// Using AIN0 as the input

#define VREF_ADC0REFSEL_VDD_gc (0x1 << 4)

// Custom variables
const int PWM_PIN = 5;
const double MIN_VALUE = 0.0;
const double MAX_VALUE = 5.0;
int a_in, pwm_out;
unsigned long last_loop = 0;

// Controller variables
double sensed_output, control_signal;
double setpoint;
double Kp;	// proportional gain
double Ki;	// integral gain
double Kd;	// derivative gain
const int T = 10;			//sample time in milliseconds (ms)
unsigned long last_time;
double total_error, last_error;
int max_control;
int min_control;

void ADC_init(void) {
	
	ADC0.CTRLC = ADC_PRESC_DIV2_gc | VREF_ADC0REFSEL_VDD_gc;
	
	ADC0.MUXPOS = ADC_MUXPOS_AIN0_gc + ADC_CHANNEL;

	ADC0.CTRLA = ADC_ENABLE_bm;
}

void pwm_init() {
	// Configure TCA0 to operate in Single-Slope PWM mode
	TCA0.SINGLE.CTRLB = TCA_SINGLE_WGMODE_SINGLESLOPE_gc; // Single-slope PWM
	TCA0.SINGLE.PER = 255; // Set period for 8-bit resolution (0-255)

	// Enable Compare Channel 0 (PWM output on WO0)
	TCA0.SINGLE.CTRLB |= TCA_SINGLE_CMP0EN_bm;

	// Select clock source (prescaler = 64)
	TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV64_gc | TCA_SINGLE_ENABLE_bm;

	// Configure the corresponding pin (PA0 for WO0) as output
	PORTB.DIRSET |= PIN0_bm;
}

// Custom setup function
void setup() {
	ADC_init();
	pwm_init();

	max_control = MAX_VALUE;
	min_control = MIN_VALUE;
	
	Kp = 1.2;
	Ki = 0.2;
	Kd = 0;
	setpoint = 3;
}

void PID_Control() {

	unsigned long current_time = last_time + 10; //returns the number of milliseconds passed since the Arduino started running the program

	int delta_time = current_time - last_time; //delta time interval

	if (delta_time >= T) {

		double error = setpoint - sensed_output;

		total_error += error; //accumalates the error - integral term
		if (total_error >= max_control) total_error = max_control;
		else if (total_error <= min_control) total_error = min_control;

		double delta_error = error - last_error; //difference of error for derivative term

		control_signal = Kp * error + (Ki * T) * total_error + (Kd / T) * delta_error; //PID control compute
		if (control_signal >= max_control) control_signal = max_control;
		else if (control_signal <= min_control) control_signal = min_control;

		last_error = error;
		last_time = current_time;
	}
}

uint16_t ADC_read(void) {
	// Start a conversion
	ADC0.COMMAND = ADC_STCONV_bm;

	// Wait for the conversion to complete
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm));

	// Clear the interrupt flag
	ADC0.INTFLAGS |= ADC_RESRDY_bm;

	// Return the ADC result
	return ADC0.RES;
}

void analogWrite(uint8_t dutyCycle) {
	TCA0.SINGLE.CMP0 = dutyCycle; // Set duty cycle (0-255)
}

void loop() {
	a_in = ADC_read(); // Read current output voltage with ADC
	sensed_output = (double)a_in*5/1024; // Convert to volts
	
	PID_Control(); // Calls the PID function every T interval and outputs a control signal
	
	pwm_out = (unsigned int)(control_signal*255/5); // Convert 0...5 V to PWM 8-bit value (0...255)
	analogWrite(pwm_out);

}

int main() {
	setup();
	for (;;) {
		loop();
	}
}