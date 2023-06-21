#include <stdio.h>
#include <system.h>
#include <unistd.h>
#include <sys/alt_alarm.h>
#include <altera_avalon_pio_regs.h>

#define Init	0x500 // 0b10100000000
#define React	0x400 // 0b10000000000
#define Enable	0x100 // 0b00100000000

#define LINE1	0x80
#define LINE2	0xC0

void lcd_data (alt_u8 data){
	int my_data = Init | data;
	int clear = React | data;
	IOWR(LCD_BASE,0,my_data);
	usleep(10000);
	IOWR(LCD_BASE,0,clear);
}

void lcd_cmd(alt_u8 data){
	int my_data = Enable | data;
	IOWR(LCD_BASE,0,my_data);
	usleep(10000);
	IOWR(LCD_BASE,0,data);
}

void lcd_DisplayString(alt_u8 no_line, char str[]){
	lcd_cmd(no_line);
	for(int i = 0; str[i]!=0; i++){
		lcd_data(str[i]);
	}
}
void PWM(int data){
	IOWR(H_BRIDGE_BASE,0,data);
}

void lcd_init()
{
	lcd_cmd(0x38); // Function Set: 8-bit, 2 Line, 5x7 Dots
	lcd_cmd(0x0C); // Display on Cursor off
	lcd_cmd(0x06); // Entry mode
	lcd_cmd(0x01); // Clear Display
}
alt_u32 lcd_callback(void* context){
	alt_u32 sw = IORD(SWITCH_BASE,0);
	static  int on_off =0;
	if (sw == 0x01) {
		if(!on_off){
			lcd_DisplayString(LINE1," HELLO WORLD !!!");
			on_off = 1;
		}
		else{
			lcd_cmd(0x01);
			on_off = 0;
		}
	}
return alt_ticks_per_second();
}

/*alt_u32 h_bridge_callback(void* context){
	alt_u32 sw = IORD(SWITCH_BASE,0);
	static int act_deact = 0;
	switch(sw){
		case 0x02:
			if (!act_deact){
				PWM(0b110);
				act_deact = 1;
			}
			else{
				PWM(0b100);
				act_deact = 0;
			}
		default:
			PWM(0b100);
			act_deact = 0;
	}
	return alt_ticks_per_second();
}*/

int main(){
	float Duty_cycle = 1;
	int freq = 1000;
	static alt_alarm alarm1; //alarm2;
	lcd_init();
	alt_alarm_start(&alarm1, alt_ticks_per_second(),lcd_callback, NULL);
//	alt_alarm_start(&alarm2, alt_ticks_per_second(),h_bridge_callback, NULL);
  while(1){
	  if (IORD(SWITCH_BASE,0) == 0x02){
	  		  lcd_init();
	  		  lcd_DisplayString(LINE1,"Duty cycle: 100%");
	  		  lcd_DisplayString(LINE2,"Frequency : 1khZ");
	  		  while(IORD(SWITCH_BASE,0) == 0x02){
		  		  PWM(0b110);
		  		  usleep((float)freq*Duty_cycle);
		  		  PWM(0b100);
		  		  usleep((float)freq*(1.0-Duty_cycle));
	  		  }
	  	  }
	  else if (IORD(SWITCH_BASE,0) == 0x04){
	  		  	lcd_init();
	  		  	lcd_DisplayString(LINE1,"Duty cycle: 75%");
	  		  	lcd_DisplayString(LINE2,"Frequency : 1khZ");
	  		  	while(IORD(SWITCH_BASE,0) == 0x04){
	  			  	PWM(0b110);
	  			  	usleep((float)freq*Duty_cycle*0.75);
	  			 	PWM(0b100);
	  			 	usleep((float)freq*(1.0-Duty_cycle*0.75));
	  		  	}
	  }
	  // INVERSE
	  else if (IORD(SWITCH_BASE,0) == 0x08){
	  	  		  	lcd_init();
	  	  		  	lcd_DisplayString(LINE1,"Duty cycle: 75%");
	  	  		  	lcd_DisplayString(LINE2,"Frequency : 1khZ");
	  	  		  	while(IORD(SWITCH_BASE,0) == 0x08){
	  	  			  	PWM(0b101);
	  	  			  	usleep((float)freq*Duty_cycle*0.75);
	  	  			 	PWM(0b100);
	  	  			 	usleep((float)freq*(1.0-Duty_cycle*0.75));
	  	  		  	}
	  }
  }
  return 0;
}
