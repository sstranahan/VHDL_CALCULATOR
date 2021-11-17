// TODO: Check that operands are in range -128 <-> 127 -- error
//       Use timer interrupt to transmit clock signal
//       Output data on busses



/////////////////////////////////////////////////////////////////////////
///////////////////////       DEFINES       /////////////////////////////
/////////////////////////////////////////////////////////////////////////

#include <hidef.h>           /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <string.h>
#include <stdio.h>

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
///////////////////////   GLOBAL DEFINES    /////////////////////////////
/////////////////////////////////////////////////////////////////////////

#define LCD_DATA PORTK
#define LCD_CTRL PORTK
#define RS 0x01
#define EN 0x02

#define INPUT_OFFSET 40                                                                          

#define OP_KEYS PTH

#define A_BUS  PORTB
#define B_BUS  PTP
#define OPCODE PORTE    // High 4-bits only

/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
/////////////////////// FUNCTION PROTOTYPES /////////////////////////////
/////////////////////////////////////////////////////////////////////////

void initGPIO(void);

void initLCD(void);

unsigned char scanKeypad(void);

unsigned char scanOpKeypad(void);

void inputErr(void);

void printErr(void);

void printSuccess(void);

void writeDisplay(void);

void getData(void);

void outputData(void);

void processInput(int numCnt1);

void processInputs(int numCnt1, int numCnt2);

void processOp(unsigned char opIn);

void clearArr(void);

void writeIo(void);


////////////////////////////// UTILS ////////////////////////////////////

void MSDelay(unsigned int itime);

void COMWRT4(unsigned char);

void DATWRT4(unsigned char);

void clrDisp(void);

void clearInputArray(void);

void cursorReturn(void);

void incCursor(void);

/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
///////////////////////// GLOBAL VARIABLES //////////////////////////////
/////////////////////////////////////////////////////////////////////////

const unsigned char keypad[4][4] = {
'1','2','3','A',
'4','5','6','B',
'7','8','9','C',
'*','0','#','D'
};

const unsigned char opKeypad[4][4] = {
'+','-','*','_',
'S','D','A','O',
'N','n','X','I',
'E','L','R','r'
};


unsigned char dispArr[64] = {
'E', 'n', 't', 'e', 'r', ' ', 'D', 'a',        // Row 1 
't', 'a', ':', ' ', ' ', ' ', ' ', ' ',        // Row 1
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Row 2
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Row 2
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '         // Not displayed
};

const unsigned char errMsg[64] = {
'E', 'R', 'R', ':', ' ', 'I', 'n', 'v',
'a', 'l', 'i', 'd', ' ', 'I', 'n', 'p',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
'u', 't', '(', 's', ')', ' ', 'T', 'r',                                     
'y', ' ', 'a', 'g', 'a', 'i', 'n', ' ',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '         // Not displayed
};


const unsigned char successMsg[64] = {
'I', 'N', 'P', 'U', 'T', ' ', 'R', 'E',
'C', 'E', 'I', 'V', 'E', 'D', ' ', ' ',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',        // Not displayed
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',                                     
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '         // Not displayed
};


unsigned char column, row, opType, opSet, op;

int operand1, operand2;

/////////////////////////////////////////////////////////////////////////

void main(void){                          //OPEN MAIN
  
   
   initGPIO();                            // Initialize GPIO systems
   initLCD();                             // Initialize LCD module
   
   clearInputArray();
   
   writeDisplay();   
   
   while(1){
      
       // Init globals
       row = 0;
       column = 0;
       opType = 0;
       
       PORTB = 0x00;                       // CLEAR OPERAND1
       
       PTP = 0x00;                         // CLEAR OPERAND2
       
       OPCODE = OPCODE & 0x0F;             // CLEAR OPCODE
       
       PTM = PTM & 0xDF;                   // ENABLE LOW
       
       PTT = PTT & 0xFB;                   // CLOCK LOW

       clearArr();
       
       writeDisplay();

       getData();
       
       writeIo();
       
       MSDelay(10);                        // Hold enable line high
       
       PTT = PTT | 0x04;                   // CLOCK HI
       
       MSDelay(10);                        // Hold enable line high
       
       PTT = PTT & 0xFB;                   // CLOCK LOW  

   } 
}

/////////////////////////////////////////////////////////////////////////
////////////////////////  LOCAL FUNCTIONS  //////////////////////////////
/////////////////////////////////////////////////////////////////////////

void writeIo(void){
  
  A_BUS = operand1;
  
  B_BUS = operand2;
  
  switch(op){
  
    case '+' :
       OPCODE = OPCODE | 0x00;
       break;
    case '-' :
       OPCODE = OPCODE | 0x10;
       break;
    case '*' :
       OPCODE = OPCODE | 0x20;
       break;
    case '_' :
       OPCODE = OPCODE | 0x30;
       break;
    case 'S' :
       OPCODE = OPCODE | 0x40;
       break;
    case 'D' :
       OPCODE = OPCODE | 0x50;
       break;
    case 'A' :
       OPCODE = OPCODE | 0x60;
       break;
    case 'O' :
       OPCODE = OPCODE | 0x70;
       break;
    case 'N' :
       OPCODE = OPCODE | 0x80;
       break;
    case 'n' :
       OPCODE = OPCODE | 0x90;
       break;
    case 'X' :
       OPCODE = OPCODE | 0xA0;
       break;
    case 'I' :
       OPCODE = OPCODE | 0xB0;
       break;
    case 'E' :
       OPCODE = OPCODE | 0xC0;
       break;
    case 'L' :
       OPCODE = OPCODE | 0xD0;
       break;
    case 'R' :
       OPCODE = OPCODE | 0xE0;
       break;
    case 'r' : 
       OPCODE = OPCODE | 0x0F;
       break;
    default :
       break;
    
  }
  
  PTM = PTM | 0x20;    // Enable HI
  
  return; 

}



void getData(void){

  int i, numCnt1, numCnt2;
  
  unsigned char keyIn, opIn, opSet;
  
  unsigned char secondNum = 0;
  
  numCnt1 = 0;
  numCnt2 = 0;
  
  opIn = 0;
  opSet = 0;
  
  while(1){
  
    keyIn = scanKeypad();
 
    if (keyIn != 'A' && keyIn > '9' && keyIn != ' '){             // Invalid input error
      inputErr();
      return;   
    }
    
    if (keyIn != 'A' && keyIn < '0' && keyIn != ' '){             // Invalid input error
      inputErr();
      return;   
    }
    
    if (numCnt1 >= 4 || numCnt2 >= 4){            // Invalid input error - too many digits  --> Throwing when press 'A' ???
      inputErr();
      return;
    }    
    
    if (keyIn != ' ' && keyIn != 'A'){
      if (!secondNum){
        dispArr [INPUT_OFFSET + numCnt1] = keyIn;
        numCnt1++;
      } else{
        dispArr [INPUT_OFFSET + numCnt1 + 3 + numCnt2] = keyIn;
        numCnt2++;
      }
      
      writeDisplay();
    }
    
    
    if (opSet == 1){
    
      if (opType == 1){
      
          processOp(opIn);
          processInput(numCnt1);
          
          printSuccess();
          return;
      
      } else {
      
         if(keyIn == 'A'){
         
            if (numCnt2 != 0){
          
              processInputs(numCnt1, numCnt2);
              
              
              printSuccess();
              return;
          
            } 
         }
      }
    }
    

    if (numCnt1 != 0 && opSet != 1){                            // Don't scan for operator unless number entered
      
      opIn = scanOpKeypad();
    
      if (opIn != ' '){
      
        opSet = 1;
        
        processOp(opIn);
        
        dispArr[INPUT_OFFSET + numCnt1 + 1] = opIn;
         
        secondNum = 1;
        
        writeDisplay();
        
      }
    }
  }
}

void processInput(int numCnt1){
  
   switch (numCnt1){
        
     case 1:
       
       operand1 = dispArr[INPUT_OFFSET] - 48;
       break;
        
     case 2:
     
       operand1 = ((dispArr[INPUT_OFFSET] - 48) * 10) + (dispArr[INPUT_OFFSET + 1] - 48);
       break;
        
     case 3:
      
       operand1 = ((dispArr[INPUT_OFFSET] - 48) * 100) + ((dispArr[INPUT_OFFSET+ 1] - 48) * 10) + (dispArr[INPUT_OFFSET + 2] - 48) ;
       break;
      
   }
   
   if (operand1 < -128 || operand1 > 127){
      operand1 = 0;
      inputErr();
   }

   return; 

}

void processInputs(int numCnt1, int numCnt2){

   switch (numCnt1){
        
     case 1:
       
       operand1 = dispArr[INPUT_OFFSET] - 48;
       break;
        
     case 2:
     
       operand1 = ((dispArr[INPUT_OFFSET] - 48) * 10) + (dispArr[INPUT_OFFSET + 1] - 48);
       break;
        
     case 3:
      
       operand1 = ((dispArr[INPUT_OFFSET] - 48) * 100) + ((dispArr[INPUT_OFFSET+ 1] - 48) * 10) + (dispArr[INPUT_OFFSET + 2] - 48) ;
       break;
      
   }
   
   switch (numCnt1){
        
     case 1:
       
       operand2 = dispArr[INPUT_OFFSET + numCnt1 + 3] - 48;
       break;
        
     case 2:
     
       operand2 = ((dispArr[INPUT_OFFSET + numCnt1 + 3] - 48) * 10) + (dispArr[INPUT_OFFSET + numCnt1 + 3 + 1] - 48);
       break;
        
     case 3:
      
       operand2 = ((dispArr[INPUT_OFFSET + numCnt1 + 3] - 48) * 100) + ((dispArr[INPUT_OFFSET + numCnt1 + 3 + 1] - 48) * 10) + (dispArr[INPUT_OFFSET + numCnt1 + 3 + 2] - 48) ;
       break;
      
   }
   
   if (operand1 < -128 || operand1 > 127){
      operand1 = 0;
      inputErr();
   }
   
   if (operand2 < -128 || operand2 > 127){
      operand2 = 0;
      inputErr();
   }

   return;

}

void clearArr(void){

  int i;
  
  for (i = 0; i < 10; i++){
  
    dispArr[INPUT_OFFSET + i] = ' ';
  
  }

}

void processOp(unsigned char opIn){

  switch(opIn){
    
    case '+' :
      opType = 2;
      op = '+';
      break;
    case '-' :
      opType = 2;
      op = '-';
      break;
    case '*' :
      opType = 2;
      op = '*';
      break;
    case '_' :
      opType = 1;
      op = '_';
      break;
    case 'S' :
      opType = 1;
      op = 'S';
      break;
    case 'D' :
      opType = 1;
      op = 'D';
      break;
    case 'A' :
      opType = 2;
      op = 'A';
      break;
    case 'O' :
      opType = 2;
      op = 'O';
      break;
    case 'N' :
      opType = 2;
      op = 'N';
      break;
    case 'n' :
      opType = 2;
      op = 'n';
      break;
    case 'X' :
      opType = 2;
      op = 'X';
      break;
    case 'I' :
      opType = 1;
      op = 'I';
      break;
    case 'E' :
      opType = 1;
      op = 'E';
      break;
    case 'L' :
      opType = 1;
      op = 'L';
      break;
    case 'R' :
      opType = 1;
      op = 'R';
      break;
    case 'r' :
      opType = 1;
      op = 'r';
      break;
    default  :
      opType = 0;
      op = ' ';  
  }

  return;
  
}

void initGPIO(void){
  DDRB = 0xFF;                           // MAKE PORTB OUTPUT
  DDRJ = 0xFF;                           // PTJ as output for Dragon12+ LEDs
  DDRA = 0x0F;                           // MAKE ROWS INPUT AND COLUMNS OUTPUT
  DDRH = 0xF0;                           // MAKE ROWS OUTPUT AND COLUMNS INPUT
  DDRP = 0xFF;                           // PORTP Output
  DDRE |= 0xF0;                          // Top half output - Operand
  PTJ=0x0;                               // Allow the LEDs to dsiplay data on PORTB pins
  DDRP |=0x0F;                           // RGB LED OUTPUTS
  PTP |=0x0F;                            // TURN OFF 7SEG LED
  DDRK = 0xFF;                           // PORTK IS LCD MODULE
  DDRT |= 0x04;                          // PT2 - clock - output
  DDRM |= 0x20;                          // PM5 - enable - output
  
  return;
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
  COMWRT4(0x0C);   // Display set, disp on, cursor off, blink off
  MSDelay(1);
  COMWRT4(0x01);   // Clear display
  MSDelay(1);
  COMWRT4(0x80);   // set start posistion, home position
  MSDelay(1);
  
  return;
}


unsigned char scanKeypad(void){

   unsigned char keyIn = ' ';

   while(1){                              
                              
         PORTA = PORTA | 0x0F;            //COLUMNS SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
         
         if (row == 0x00){                //NO KEY PRESSED
            keyIn = ' ';
            break;
         }

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
         
      row = 0;                            //KEY NOT FOUND        
      break;                              //step out of while(1) loop to not get stuck
      
      }                                   //end while(1)

      if(row == 0x10){
         MSDelay(1);
         keyIn = (keypad[0][column]);     
 
      }
      else if(row == 0x20){
         MSDelay(1);
         keyIn = (keypad[1][column]);
 
      }
      else if(row == 0x40){
         MSDelay(1);
         keyIn = (keypad[2][column]);
 
      }
      else if(row == 0x80){
         MSDelay(1);
         keyIn = (keypad[3][column]);
 
      } 
      else if (row == 0x00){
         keyIn = ' ';
        
      }

      do{
         MSDelay(10);
         PORTA = PORTA | 0x0F;            //COLUMNS SET HIGH
         row = PORTA & 0xF0;              //READ ROWS
      }while(row != 0x00);                //MAKE SURE BUTTON IS NOT STILL HELD
  
      if (keyIn != ' '){
        
        return keyIn;
      }
      
   }                                      //CLOSE WHILE(1)
   
  return keyIn; 
      
}

unsigned char scanOpKeypad(void){

   unsigned char rowNum, colNum;

   unsigned char keyIn = ' ';
   
   OP_KEYS = 0x00;              // All rows low

   OP_KEYS |= 0x80;             // Set row1 high
   colNum = OP_KEYS & 0x0F;
   
   if(colNum != 0){             // Key in row1
     switch (colNum){      
     case 0x08 :
        keyIn = opKeypad[0][0];
        return keyIn;
     case 0x04 :
        keyIn = opKeypad[0][1];
        return keyIn;
     case 0x02 :
        keyIn = opKeypad[0][2];
        return keyIn;
     case 0x01 :
        keyIn = opKeypad[0][3];
        return keyIn;
     default:
        break;   
     }
   }
   
   OP_KEYS = 0x00;              // All rows low
   
   OP_KEYS |= 0x40;                       // Set row2 high
   colNum = OP_KEYS & 0x0F;
   
   if(colNum!= 0){             // Key in row2
     switch (colNum){      
     case 0x08 :
        return keyIn = opKeypad[1][0];
        break;
     case 0x04 :
        keyIn = opKeypad[1][1];
        return keyIn;
     case 0x02 :
        keyIn = opKeypad[1][2];
        return keyIn;
     case 0x01 :
        keyIn = opKeypad[1][3];
        return keyIn;
     default:
        break;   
     }
   }
   
   OP_KEYS = 0x00;              // All rows low
   
   OP_KEYS |= 0x20;                       // Set row3 high
   colNum = OP_KEYS & 0x0F;
   
   if(colNum != 0){             // Key in row3
     switch (colNum){
     case 0x08 :
        keyIn = opKeypad[2][0];
        return keyIn;
     case 0x04 :
        keyIn = opKeypad[2][1];
        return keyIn;
     case 0x02 :
        keyIn = opKeypad[2][2];
        return keyIn;
     case 0x01 :
        keyIn = opKeypad[2][3];
        return keyIn;
     default:
        break;   
     }
   }
   
   OP_KEYS = 0x00;              // All rows low
   
   OP_KEYS |= 0x10;                       // Set row4 high
   colNum = OP_KEYS & 0x0F;
   
   if(colNum != 0){             // Key in row5
     switch (colNum){
     case 0x08 :
        keyIn = opKeypad[3][0];
        return keyIn;
     case 0x04 :
        keyIn = opKeypad[3][1];
        return keyIn;
     case 0x02 :
        keyIn = opKeypad[3][2];
        return keyIn;
     case 0x01 :
        keyIn = opKeypad[3][3];
        return keyIn;
     default:
        break;   
     }
   }
   
  return keyIn;

}


void inputErr(void){
  
  clrDisp();
  printErr();
  clrDisp();
  clearInputArray();
  
  return;

}

void printErr(void){

  int i = 0;
  int idx = 0;
   
  for (idx = 0; idx < 4; idx++){           // Blink msg 4 times
    
    clrDisp();
      
    for (i = 0; i < 64; i++){
      
      DATWRT4(errMsg[i]);
          
    }
     
    MSDelay(100);
  }
  return;
}

void printSuccess(void){

  int i = 0;
  int idx = 0;
   
  for (idx = 0; idx < 4; idx++){           // Blink msg 4 times
    
    clrDisp();
      
    for (i = 0; i < 64; i++){
      
      DATWRT4(successMsg[i]);
          
    }
     
    MSDelay(100);
  }
  return;
}

void writeDisplay(void){  
  int i;
   
  clrDisp();
   
  for(i = 0; i < 64; i++){
              
    DATWRT4(dispArr[i]);                  // Write character to display
  }
  
  
  
  cursorReturn();                         // Cursor to home position
}

/////////////////////////////////////////////////////////////////////////


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
        MSDelay(5);
  }
  
void clrDisp(void){
  COMWRT4(0x01);   // Clear display
}

void clearInputArray(void){
  int i;
  for (i = 0; i < 4; i++){
    dispArr[i + INPUT_OFFSET] = ' ';
  }
}

void cursorReturn(void){

  COMWRT4(0x02);              // Return cursor home 

  return;
}

char* int2char3dig (unsigned int N){
  char charArray[3];
  
  sprintf(charArray, "%d", N);
  
  return charArray; 
}

void incCursor(void){

  COMWRT4(0x14);              // Move cursor right

  return;

}

/////////////////////////////////////////////////////////////////////////