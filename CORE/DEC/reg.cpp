#include "reg.h"
#include <systemc.h>

void reg::reading_adresses()
{
    RADR1_VALID.write(false) ;
    RADR2_VALID.write(false) ;
    wait(3) ;

    while(1)
    {

//----------------------------------------Reading Port 2 :-----------------------------------

        if(RADR1.read() == 0 && RADR1_VALID == 1)
        {
            // r0 is the constant registrer equal to 0, can't be modify
        }
        if(RADR1.read() == 1 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG1.read()) ;
            REG1_VALID.write(0) ;
        }
        if(RADR1.read() == 2 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG2.read()) ;
            REG2_VALID.write(0) ;
        }
        if(RADR1.read() == 3 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG3.read()) ;
            REG3_VALID.write(0) ;
        }
        if(RADR1.read() == 4 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG4.read()) ;
            REG4_VALID.write(0) ;
        }
        if(RADR1.read() == 5 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG5.read()) ;
            REG5_VALID.write(0) ;
        }
        if(RADR1.read() == 6 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG6.read()) ;
            REG6_VALID.write(0) ;
        }
        if(RADR1.read() == 7 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG7.read()) ;
            REG7_VALID.write(0) ;
        }
        if(RADR1.read() == 8 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG8.read()) ;
            REG8_VALID.write(0) ;
        }
        if(RADR1.read() == 9 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG9.read()) ;
            REG9_VALID.write(0) ;
        }
        if(RADR1.read() == 10 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG10.read()) ;
            REG10_VALID.write(0) ;
        }
        if(RADR1.read() == 11 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG11.read()) ;
            REG11_VALID.write(0) ;
        }
        if(RADR1.read() == 12 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG12.read()) ;
            REG12_VALID.write(0) ;
        }
        if(RADR1.read() == 13 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG13.read()) ;
            REG13_VALID.write(0) ;
        }
        if(RADR1.read() == 14 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG14.read()) ;
            REG14_VALID.write(0) ;
        }
        if(RADR1.read() == 15 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG15.read()) ;
            REG15_VALID.write(0) ;
        }
        if(RADR1.read() == 16 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG16.read()) ;
            REG16_VALID.write(0) ;
        }
        if(RADR1.read() == 17 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG17.read()) ;
            REG17_VALID.write(0) ;
        }
        if(RADR1.read() == 18 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG18.read()) ;
            REG18_VALID.write(0) ;
        }
        if(RADR1.read() == 19 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG19.read()) ;
            REG19_VALID.write(0) ;
        }
        if(RADR1.read() == 20 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG20.read()) ;
            REG20_VALID.write(0) ;
        }
        if(RADR1.read() == 21 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG21.read()) ;
            REG21_VALID.write(0) ;
        }
        if(RADR1.read() == 22 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG22.read()) ;
            REG22_VALID.write(0) ;
        }
        if(RADR1.read() == 23 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG23.read()) ;
            REG23_VALID.write(0) ;
        }
        if(RADR1.read() == 24 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG24.read()) ;
            REG24_VALID.write(0) ;
        }
        if(RADR1.read() == 25 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG25.read()) ;
            REG25_VALID.write(0) ;
        }
        if(RADR1.read() == 26 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG26.read()) ;
            REG26_VALID.write(0) ;
        }
        if(RADR1.read() == 27 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG27.read()) ;
            REG27_VALID.write(0) ;
        }
        if(RADR1.read() == 28 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG28.read()) ;
            REG28_VALID.write(0) ;
        }
        if(RADR1.read() == 29 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG29.read()) ;
            REG29_VALID.write(0) ;
        }
        if(RADR1.read() == 30 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG30.read()) ;
            REG30_VALID.write(0) ;
        }
        if(RADR1.read() == 31 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG31.read()) ;
            REG31_VALID.write(0) ;
        }
        if(RADR1.read() == 32 && RADR1_VALID == 1)
        {
            RADR1_DATA.write(REG32.read()) ;
            REG32_VALID.write(0) ;
        }

//----------------------------------------Reading Port 2 :-----------------------------------
        if(RADR2.read() == 0 && RADR2_VALID == 1)
        {
            // r0 is the constant registrer equal to 0, can't be modify
        }
        if(RADR2.read() == 1 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG1.read()) ;
            REG1_VALID.write(0) ;
        }
        if(RADR2.read() == 2 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG2.read()) ;
            REG2_VALID.write(0) ;
        }
        if(RADR2.read() == 3 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG3.read()) ;
            REG3_VALID.write(0) ;
        }
        if(RADR2.read() == 4 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG4.read()) ;
            REG4_VALID.write(0) ;
        }
        if(RADR2.read() == 5 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG5.read()) ;
            REG5_VALID.write(0) ;
        }
        if(RADR2.read() == 6 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG6.read()) ;
            REG6_VALID.write(0) ;
        }
        if(RADR2.read() == 7 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG7.read()) ;
            REG7_VALID.write(0) ;
        }
        if(RADR2.read() == 8 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG8.read()) ;
            REG8_VALID.write(0) ;
        }
        if(RADR2.read() == 9 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG9.read()) ;
            REG9_VALID.write(0) ;
        }
        if(RADR2.read() == 10 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG10.read()) ;
            REG10_VALID.write(0) ;
        }
        if(RADR2.read() == 11 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG11.read()) ;
            REG11_VALID.write(0) ;
        }
        if(RADR2.read() == 12 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG12.read()) ;
            REG12_VALID.write(0) ;
        }
        if(RADR2.read() == 13 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG13.read()) ;
            REG13_VALID.write(0) ;
        }
        if(RADR2.read() == 14 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG14.read()) ;
            REG14_VALID.write(0) ;
        }
        if(RADR2.read() == 15 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG15.read()) ;
            REG15_VALID.write(0) ;
        }
        if(RADR2.read() == 16 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG16.read()) ;
            REG16_VALID.write(0) ;
        }
        if(RADR2.read() == 17 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG17.read()) ;
            REG17_VALID.write(0) ;
        }
        if(RADR2.read() == 18 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG18.read()) ;
            REG18_VALID.write(0) ;
        }
        if(RADR2.read() == 19 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG19.read()) ;
            REG19_VALID.write(0) ;
        }
        if(RADR2.read() == 20 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG20.read()) ;
            REG20_VALID.write(0) ;
        }
        if(RADR2.read() == 21 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG21.read()) ;
            REG21_VALID.write(0) ;
        }
        if(RADR2.read() == 22 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG22.read()) ;
            REG22_VALID.write(0) ;
        }
        if(RADR2.read() == 23 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG23.read()) ;
            REG23_VALID.write(0) ;
        }
        if(RADR2.read() == 24 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG24.read()) ;
            REG24_VALID.write(0) ;
        }
        if(RADR2.read() == 25 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG25.read()) ;
            REG25_VALID.write(0) ;
        }
        if(RADR2.read() == 26 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG26.read()) ;
            REG26_VALID.write(0) ;
        }
        if(RADR2.read() == 27 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG27.read()) ;
            REG27_VALID.write(0) ;
        }
        if(RADR2.read() == 28 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG28.read()) ;
            REG28_VALID.write(0) ;
        }
        if(RADR2.read() == 29 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG29.read()) ;
            REG29_VALID.write(0) ;
        }
        if(RADR2.read() == 30 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG30.read()) ;
            REG30_VALID.write(0) ;
        }
        if(RADR2.read() == 31 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG31.read()) ;
            REG31_VALID.write(0) ;
        }
        if(RADR2.read() == 32 && RADR2_VALID == 1)
        {
            RADR2_DATA.write(REG32.read()) ;
            REG32_VALID.write(0) ;
        }
        
        
    READ_PC_VALID.write(REG32_VALID.read()) ;

    }

}

void reg::writing_adresse()
{
    RADR1_VALID.write(false) ;
    RADR2_VALID.write(false) ;

    REG0.write(0) ;
    REG1.write(0) ;
    REG2.write(0) ;
    REG3.write(0) ;
    REG4.write(0) ;
    REG5.write(0) ;
    REG6.write(0) ;
    REG7.write(0) ;
    REG8.write(0) ;
    REG9.write(0) ;
    REG10.write(0) ;
    REG11.write(0) ;
    REG12.write(0) ;
    REG13.write(0) ;
    REG14.write(0) ;
    REG15.write(0) ;
    REG16.write(0) ;
    REG17.write(0) ;
    REG18.write(0) ;
    REG19.write(0) ;
    REG20.write(0) ;
    REG21.write(0) ;
    REG22.write(0) ;
    REG23.write(0) ;
    REG24.write(0) ;
    REG25.write(0) ;
    REG26.write(0) ;
    REG27.write(0) ;
    REG28.write(0) ;
    REG29.write(0) ;
    REG30.write(0) ;
    REG31.write(0) ;
    REG32.write(0) ;

    wait(3) ;

    while(1)
    {
        if(WADR1.read() == 0 && WADR1_VALID == 1)
        {
            // r0 is the constant registrer equal to 0, can't be modify
        }
        if(WADR1.read() == 1 && WADR1_VALID == 1)
        {
            REG1.write(WADR1_DATA.read()) ;
            REG1_VALID.write(1) ;
        }
        if(WADR1.read() == 2 && WADR1_VALID == 1)
        {
            REG2.write(WADR1_DATA.read()) ;
            REG2_VALID.write(1) ;
        }
        if(WADR1.read() == 3 && WADR1_VALID == 1)
        {
            REG3.write(WADR1_DATA.read()) ;
            REG3_VALID.write(1) ;
        }
        if(WADR1.read() == 4 && WADR1_VALID == 1)
        {
            REG4.write(WADR1_DATA.read()) ;
            REG4_VALID.write(1) ;
        }
        if(WADR1.read() == 5 && WADR1_VALID == 1)
        {
            REG5.write(WADR1_DATA.read()) ;
            REG5_VALID.write(1) ;
        }
        if(WADR1.read() == 6 && WADR1_VALID == 1)
        {
            REG6.write(WADR1_DATA.read()) ;
            REG6_VALID.write(1) ;
        }
        if(WADR1.read() == 7 && WADR1_VALID == 1)
        {
            REG7.write(WADR1_DATA.read()) ;
            REG7_VALID.write(1) ;
        }
        if(WADR1.read() == 8 && WADR1_VALID == 1)
        {
            REG8.write(WADR1_DATA.read()) ;
            REG8_VALID.write(1) ;
        }
        if(WADR1.read() == 9 && WADR1_VALID == 1)
        {
            REG9.write(WADR1_DATA.read()) ;
            REG9_VALID.write(1) ;
        }
        if(WADR1.read() == 10 && WADR1_VALID == 1)
        {
            REG10.write(WADR1_DATA.read()) ;
            REG10_VALID.write(1) ;
        }
        if(WADR1.read() == 11 && WADR1_VALID == 1)
        {
            REG11.write(WADR1_DATA.read()) ;
            REG11_VALID.write(1) ;
        }
        if(WADR1.read() == 12 && WADR1_VALID == 1)
        {
            REG12.write(WADR1_DATA.read()) ;
            REG12_VALID.write(1) ;
        }
        if(WADR1.read() == 13 && WADR1_VALID == 1)
        {
            REG13.write(WADR1_DATA.read()) ;
            REG13_VALID.write(1) ;
        }
        if(WADR1.read() == 14 && WADR1_VALID == 1)
        {
            REG14.write(WADR1_DATA.read()) ;
            REG14_VALID.write(1) ;
        }
        if(WADR1.read() == 15 && WADR1_VALID == 1)
        {
            REG15.write(WADR1_DATA.read()) ;
            REG15_VALID.write(1) ;
        }
        if(WADR1.read() == 16 && WADR1_VALID == 1)
        {
            REG16.write(WADR1_DATA.read()) ;
            REG16_VALID.write(1) ;
        }
        if(WADR1.read() == 17 && WADR1_VALID == 1)
        {
            REG17.write(WADR1_DATA.read()) ;
            REG17_VALID.write(1) ;
        }
        if(WADR1.read() == 18 && WADR1_VALID == 1)
        {
            REG18.write(WADR1_DATA.read()) ;
            REG18_VALID.write(1) ;
        }
        if(WADR1.read() == 19 && WADR1_VALID == 1)
        {
            REG19.write(WADR1_DATA.read()) ;
            REG19_VALID.write(1) ;
        }
        if(WADR1.read() == 20 && WADR1_VALID == 1)
        {
            REG20.write(WADR1_DATA.read()) ;
            REG20_VALID.write(1) ;
        }
        if(WADR1.read() == 21 && WADR1_VALID == 1)
        {
            REG21.write(WADR1_DATA.read()) ;
            REG21_VALID.write(1) ;
        }
        if(WADR1.read() == 22 && WADR1_VALID == 1)
        {
            REG22.write(WADR1_DATA.read()) ;
            REG22_VALID.write(1) ;
        }
        if(WADR1.read() == 23 && WADR1_VALID == 1)
        {
            REG23.write(WADR1_DATA.read()) ;
            REG23_VALID.write(1) ;
        }
        if(WADR1.read() == 24 && WADR1_VALID == 1)
        {
            REG24.write(WADR1_DATA.read()) ;
            REG24_VALID.write(1) ;
        }
        if(WADR1.read() == 25 && WADR1_VALID == 1)
        {
            REG25.write(WADR1_DATA.read()) ;
            REG25_VALID.write(1) ;
        }
        if(WADR1.read() == 26 && WADR1_VALID == 1)
        {
            REG26.write(WADR1_DATA.read()) ;
            REG26_VALID.write(1) ;
        }
        if(WADR1.read() == 27 && WADR1_VALID == 1)
        {
            REG27.write(WADR1_DATA.read()) ;
            REG27_VALID.write(1) ;
        }
        if(WADR1.read() == 28 && WADR1_VALID == 1)
        {
            REG28.write(WADR1_DATA.read()) ;
            REG28_VALID.write(1) ;
        }
        if(WADR1.read() == 29 && WADR1_VALID == 1)
        {
            REG29.write(WADR1_DATA.read()) ;
            REG29_VALID.write(1) ;
        }
        if(WADR1.read() == 30 && WADR1_VALID == 1)
        {
            REG30.write(WADR1_DATA.read()) ;
            REG30_VALID.write(1) ;
        }
        if(WADR1.read() == 31 && WADR1_VALID == 1)
        {
            REG31.write(WADR1_DATA.read()) ;
            REG31_VALID.write(1) ;
        }
        if(WADR1.read() == 32 && WADR1_VALID == 1)
        {
            REG32.write(WADR1_DATA.read()) ;
            REG32_VALID.write(1) ;
        }
    }
}

void reg::pc_in()
{
    wait(3) ;

    while(1)
    {
        if(INC_PC_VALID.read() == 1)
        {
            REG32.write(REG32.read() + 4) ;
        }
    }
}