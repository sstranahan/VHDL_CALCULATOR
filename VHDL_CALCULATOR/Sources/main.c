/////////////////////////////////////////////////////////////////////////
///////////////////////       DEFINES       /////////////////////////////
/////////////////////////////////////////////////////////////////////////

#include <hidef.h>           /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
///////////////////////   GLOBAL DEFINES    /////////////////////////////
/////////////////////////////////////////////////////////////////////////

#define LCD_DATA PORTK
#define LCD_CTRL PORTK
#define RS 0x01
#define EN 0x02

/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
/////////////////////// FUNCTION PROTOTYPES /////////////////////////////
/////////////////////////////////////////////////////////////////////////

void initGPIO(void);

void initLCD(void);

void MSDelay(unsigned int itime);

void COMWRT4(unsigned char);

void DATWRT4(unsigned char);

/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
///////////////////////// GLOBAL VARIABLES //////////////////////////////
/////////////////////////////////////////////////////////////////////////

const unsigned char keypad[4][4] =
{
'1','2','3','A',
'4','5','6','B',
'7','8','9','C',
'*','0','#','D'
};

unsigned char column,row;

/////////////////////////////////////////////////////////////////////////

void main(void){                          //OPEN MAIN
   
   initGPIO();                            // Initialize GPIO systems
   initLCD();                             // Initialize LCD module       
   
   // Main task waits for any key to be pressed
   
   while(1){                              
      do{                                 
         PORTA = PORTA | 0x0F;            //COLUMNS SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
      }while(row == 0x00);                //WAIT UNTIL KEY PRESSED //CLOSE do1


   // Secondary task determines location of key pressed
   
      do{                                 
         do{                              
            MSDelay(1);                   
            row = PORTA & 0xF0;           //READ ROWS
         }while(row == 0x00);             //CHECK FOR KEY PRESS //CLOSE do3
         
         MSDelay(10);                     //WAIT FOR DEBOUNCE
         row = PORTA & 0xF0;
      }while(row == 0x00);                //FALSE KEY PRESS //CLOSE do2

      while(1){                           //OPEN while(1)
         PORTA &= 0xF0;                   //CLEAR COLUMN
         PORTA |= 0x01;                   //COLUMN 0 SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
         if(row != 0x00){                 //KEY IS IN COLUMN 0
            column = 0;
            break;                        //BREAK OUT OF while(1)
         }
         
         PORTA &= 0xF0;                   //CLEAR COLUMN
         PORTA |= 0x02;                   //COLUMN 1 SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
         if(row != 0x00){                 //KEY IS IN COLUMN 1
            column = 1;
            break;                        //BREAK OUT OF while(1)
         }

         PORTA &= 0xF0;                   //CLEAR COLUMN
         PORTA |= 0x04;                   //COLUMN 2 SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
         if(row != 0x00){                 //KEY IS IN COLUMN 2
            column = 2;
            break;                        //BREAK OUT OF while(1)
         }
         
         PORTA &= 0xF0;                   //CLEAR COLUMN
         PORTA |= 0x08;                   //COLUMN 3 SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
         if(row != 0x00){                 //KEY IS IN COLUMN 3
            column = 3;
            break;                        //BREAK OUT OF while(1)
         }
         
         row = 0;                         //KEY NOT FOUND
         
      break;                              //step out of while(1) loop to not get stuck
      
      }                                   //end while(1)

      if(row == 0x10){
         MSDelay(1);
         DATWRT4(keypad[0][column]);     
 
      }
      else if(row == 0x20){
         MSDelay(1);
         DATWRT4(keypad[1][column]);
 
      }
      else if(row == 0x40){
         MSDelay(1);
         DATWRT4(keypad[2][column]);
 
      }
      else if(row == 0x80){
         MSDelay(1);
         DATWRT4(keypad[3][column]);
 
      }

      do{
         MSDelay(15);
         PORTA = PORTA | 0x0F;            //COLUMNS SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
      }while(row != 0x00);                //MAKE SURE BUTTON IS NOT STILL HELD
   }                                      //CLOSE WHILE(1)
}



void initGPIO(void){
  DDRB = 0xFF;                           // MAKE PORTB OUTPUT
  DDRJ |=0x02;                           // ENABLE LED
  DDRA = 0x0F;                           // MAKE ROWS INPUT AND COLUMNS OUTPUT
  PTJ &=~0x02;                           // ACTIVATE LED ARRAY ON PORT B
  DDRP |=0x0F;                           // RGB LED OUTPUTS
  PTP |=0x0F;                            // TURN OFF 7SEG LED
  DDRK = 0xFF;                           // PORTK IS LCD MODULE
}

void initLCD(void){
  DDRK = 0xFF;   
  COMWRT4(0x33);   // reset sequence provided by data sheet
  MSDelay(1);
  COMWRT4(0x32);   // reset sequence provided by data sheet
  MSDelay(1);
  COMWRT4(0x28);   // Function set to four bit data length
                   // 2 line, 5 x 7 dot format
  MSDelay(1);
  COMWRT4(0x06);   // entry mode set, increment, no shift
  MSDelay(1);
  COMWRT4(0x0E);   // Display set, disp on, cursor on, blink off
  MSDelay(1);
  COMWRT4(0x01);   // Clear display
  MSDelay(1);
  COMWRT4(0x80);   // set start posistion, home position
  MSDelay(1);
}


/////////////////////////////////////////////////////////////////////////
//////////////////////// UTILITY FUNCTIONS //////////////////////////////
/////////////////////////////////////////////////////////////////////////

void MSDelay(unsigned int itime){
unsigned int i; unsigned int j;
   for(i=0;i<itime;i++)
      for(j=0;j<4000;j++);
}

void COMWRT4(unsigned char command){
        
        unsigned char x;
        
        x = (command & 0xF0) >> 2;        // shift high nibble to center of byte for Pk5-Pk2
        LCD_DATA =LCD_DATA & ~0x3C;       // clear bits Pk5-Pk2
        LCD_DATA = LCD_DATA | x;          // sends high nibble to PORTK
        MSDelay(1);
        LCD_CTRL = LCD_CTRL & ~RS;        // set RS to command (RS=0)
        MSDelay(1);
        LCD_CTRL = LCD_CTRL | EN;         // set enable
        MSDelay(5);
        LCD_CTRL = LCD_CTRL & ~EN;        // unset enable to capture command
        MSDelay(15);                      // wait
        x = (command & 0x0F)<< 2;         // shift low nibble to center of byte for Pk5-Pk2
        LCD_DATA =LCD_DATA & ~0x3C;       // clear bits Pk5-Pk2
        LCD_DATA =LCD_DATA | x;           // send low nibble to PORTK
        LCD_CTRL = LCD_CTRL | EN;         // set enable
        MSDelay(5);
        LCD_CTRL = LCD_CTRL & ~EN;        // unset enable to capture command
        MSDelay(15);
  }

void DATWRT4(unsigned char data){
        
        unsigned char x;
               
        x = (data & 0xF0) >> 2;
        LCD_DATA =LCD_DATA & ~0x3C;                     
        LCD_DATA = LCD_DATA | x;
        MSDelay(1);
        LCD_CTRL = LCD_CTRL | RS;
        MSDelay(1);
        LCD_CTRL = LCD_CTRL | EN;
        MSDelay(1);
        LCD_CTRL = LCD_CTRL & ~EN;
        MSDelay(5);
       
        x = (data & 0x0F)<< 2;
        LCD_DATA =LCD_DATA & ~0x3C;                     
        LCD_DATA = LCD_DATA | x;
        LCD_CTRL = LCD_CTRL | EN;
        MSDelay(1);
        LCD_CTRL = LCD_CTRL & ~EN;
        MSDelay(15);
  }

/////////////////////////////////////////////////////////////////////////