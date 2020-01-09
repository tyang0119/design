/*
 * main.c
 *
 *  Created on: 
 *      Author: 
 */

//AXI GPIO driver
#include "xgpio.h"

//send data over UART
#include "xil_printf.h"

#include "math.h"

//information about AXI peripherals
#include "xparameters.h"
#define BUFF_SIZE 61
#define SAMPLE_SIZE 1000
struct circBuff {
	int firstElement;
	int count;
	signed short inputs[BUFF_SIZE];
};

signed short coeff[BUFF_SIZE] = {0xFFE3, 0xFFE6, 0xFFEA, 0xFFFD, 0x001F, 0x0045, 0x005E, 0x0058, 0x0029, 0xFFD4, 0xFF70, 0xFF25, 0xFF1A, 0xFF6D, 0x0019, 0x00F6, 0x01B8, 0x0207, 0x019D, 0x006A, 0xFEA4, 0xFCCF, 0xFB9F, 0xFBC7, 0xFDC4, 0x01AB, 0x0710, 0x0D15, 0x1295, 0x1670, 0x17D2, 0x1670, 0x1295, 0x0D15, 0x0710, 0x01AB, 0xFDC4, 0xFBC7, 0xFB9F, 0xFCCF, 0xFEA4, 0x006A, 0x019D, 0x0207, 0x01B8, 0x00F6, 0x0019, 0xFF6D, 0xFF1A, 0xFF25, 0xFF70, 0xFFD4, 0x0029, 0x0058, 0x005E, 0x0045, 0x001F, 0xFFFD, 0xFFEA, 0xFFE6, 0xFFE3};
signed short pass_inputs[SAMPLE_SIZE] = {0x2E6A, 0x54F6, 0x6D1B, 0x72C1, 0x64F3, 0x4609, 0x1B3F, 0xEBD6, 0xBFD9, 0x9EBC, 0x8E1B, 0x90CA, 0xA652, 0xCB0E, 0xF8C4, 0x27B4, 0x4FE9, 0x6A92, 0x732A, 0x683C, 0x4BA4, 0x2238, 0xF300, 0xC5FC, 0xA2CD, 0x8F6B, 0x8F1F, 0xA1F5, 0xC4BD, 0xF190, 0x20D6, 0x4A8A, 0x679D, 0x731E, 0x6B1C, 0x50F2, 0x290F, 0xFA36, 0xCC59, 0xA73D, 0x912D, 0x8DE6, 0x9DF7, 0xBEA7, 0xEA6A, 0x19D6, 0x44E1, 0x643F, 0x729E, 0x6D90, 0x55EF, 0x2FBC, 0x0173, 0xD2EA, 0xAC06, 0x935E, 0x8D21, 0x9A5C, 0xB8D3, 0xE35A, 0x12BC, 0x3EF2, 0x607C, 0x71AB, 0x6F95, 0x5A95, 0x363A, 0x08AD, 0xD9A9, 0xB124, 0x95FD, 0x8CCF, 0x9728, 0xB347, 0xDC67, 0x0B90, 0x38C3, 0x5C57, 0x7044, 0x7129, 0x5EDF, 0x3C80, 0x0FE0, 0xE08E, 0xB692, 0x9908, 0x8CF2, 0x945E, 0xAE08, 0xD598, 0x0458, 0x325B, 0x57D5, 0x6E6C, 0x724B, 0x62C9, 0x4289, 0x1702, 0xE794, 0xBC4A, 0x9C7A, 0x8D89, 0x9200, 0xA91C, 0xCEF3, 0xFD1B, 0x2BC0, 0x52FB, 0x6C24, 0x72F9, 0x6650, 0x484F, 0x1E0D, 0xEEB2, 0xC246, 0xA051, 0x8E94, 0x9011, 0xA488, 0xC881, 0xF5E1, 0x24F9, 0x4DCC, 0x6970, 0x7333, 0x6970, 0x4DCC, 0x24F9, 0xF5E1, 0xC881, 0xA488, 0x9011, 0x8E94, 0xA051, 0xC246, 0xEEB2, 0x1E0D, 0x484F, 0x6650, 0x72F9, 0x6C24, 0x52FB, 0x2BC0, 0xFD1B, 0xCEF3, 0xA91C, 0x9200, 0x8D89, 0x9C7A, 0xBC4A, 0xE794, 0x1702, 0x4289, 0x62C9, 0x724B, 0x6E6C, 0x57D5, 0x325B, 0x0458, 0xD598, 0xAE08, 0x945E, 0x8CF2, 0x9908, 0xB692, 0xE08E, 0x0FE0, 0x3C80, 0x5EDF, 0x7129, 0x7044, 0x5C57, 0x38C3, 0x0B90, 0xDC67, 0xB347, 0x9728, 0x8CCF, 0x95FD, 0xB124, 0xD9A9, 0x08AD, 0x363A, 0x5A95, 0x6F95, 0x71AB, 0x607C, 0x3EF2, 0x12BC, 0xE35A, 0xB8D3, 0x9A5C, 0x8D21, 0x935E, 0xAC06, 0xD2EA, 0x0173, 0x2FBC, 0x55EF, 0x6D90, 0x729E, 0x643F, 0x44E1, 0x19D6, 0xEA6A, 0xBEA7, 0x9DF7, 0x8DE6, 0x912D, 0xA73D, 0xCC59, 0xFA36, 0x290F, 0x50F2, 0x6B1C, 0x731E, 0x679D, 0x4A8A, 0x20D6, 0xF190, 0xC4BD, 0xA1F5, 0x8F1F, 0x8F6B, 0xA2CD, 0xC5FC, 0xF300, 0x2238, 0x4BA4, 0x683C, 0x732A, 0x6A92, 0x4FE9, 0x27B4, 0xF8C4, 0xCB0E, 0xA652, 0x90CA, 0x8E1B, 0x9EBC, 0xBFD9, 0xEBD6, 0x1B3F, 0x4609, 0x64F3, 0x72C1, 0x6D1B, 0x54F6, 0x2E6A, 0x0000, 0xD196, 0xAB0A, 0x92E5, 0x8D3F, 0x9B0D, 0xB9F7, 0xE4C1, 0x142A, 0x4027, 0x6144, 0x71E5, 0x6F36, 0x59AE, 0x34F2, 0x073C, 0xD84C, 0xB017, 0x956E, 0x8CD6, 0x97C4, 0xB45C, 0xDDC8, 0x0D00, 0x3A04, 0x5D33, 0x7095, 0x70E1, 0x5E0B, 0x3B43, 0x0E70, 0xDF2A, 0xB576, 0x9863, 0x8CE2, 0x94E4, 0xAF0E, 0xD6F1, 0x05CA, 0x33A7, 0x58C3, 0x6ED3, 0x721A, 0x6209, 0x4159, 0x1596, 0xE62A, 0xBB1F, 0x9BC1, 0x8D62, 0x9270, 0xAA11, 0xD044, 0xFE8D, 0x2D16, 0x53FA, 0x6CA2, 0x72DF, 0x65A4, 0x472D, 0x1CA6, 0xED44, 0xC10E, 0x9F84, 0x8E55, 0x906B, 0xA56B, 0xC9C6, 0xF753, 0x2657, 0x4EDC, 0x6A03, 0x7331, 0x68D8, 0x4CB9, 0x2399, 0xF470, 0xC73D, 0xA3A9, 0x8FBC, 0x8ED7, 0xA121, 0xC380, 0xF020, 0x1F72, 0x496E, 0x66F8, 0x730E, 0x6BA2, 0x51F8, 0x2A68, 0xFBA8, 0xCDA5, 0xA82B, 0x9194, 0x8DB5, 0x9D37, 0xBD77, 0xE8FE, 0x186C, 0x43B6, 0x6386, 0x7277, 0x6E00, 0x56E4, 0x310D, 0x02E5, 0xD440, 0xAD05, 0x93DC, 0x8D07, 0x99B0, 0xB7B1, 0xE1F3, 0x114E, 0x3DBA, 0x5FAF, 0x716C, 0x6FEF, 0x5B78, 0x377F, 0x0A1F, 0xDB07, 0xB234, 0x9690, 0x8CCD, 0x9690, 0xB234, 0xDB07, 0x0A1F, 0x377F, 0x5B78, 0x6FEF, 0x716C, 0x5FAF, 0x3DBA, 0x114E, 0xE1F3, 0xB7B1, 0x99B0, 0x8D07, 0x93DC, 0xAD05, 0xD440, 0x02E5, 0x310D, 0x56E4, 0x6E00, 0x7277, 0x6386, 0x43B6, 0x186C, 0xE8FE, 0xBD77, 0x9D37, 0x8DB5, 0x9194, 0xA82B, 0xCDA5, 0xFBA8, 0x2A68, 0x51F8, 0x6BA2, 0x730E, 0x66F8, 0x496E, 0x1F72, 0xF020, 0xC380, 0xA121, 0x8ED7, 0x8FBC, 0xA3A9, 0xC73D, 0xF470, 0x2399, 0x4CB9, 0x68D8, 0x7331, 0x6A03, 0x4EDC, 0x2657, 0xF753, 0xC9C6, 0xA56B, 0x906B, 0x8E55, 0x9F84, 0xC10E, 0xED44, 0x1CA6, 0x472D, 0x65A4, 0x72DF, 0x6CA2, 0x53FA, 0x2D16, 0xFE8D, 0xD044, 0xAA11, 0x9270, 0x8D62, 0x9BC1, 0xBB1F, 0xE62A, 0x1596, 0x4159, 0x6209, 0x721A, 0x6ED3, 0x58C3, 0x33A7, 0x05CA, 0xD6F1, 0xAF0E, 0x94E4, 0x8CE2, 0x9863, 0xB576, 0xDF2A, 0x0E70, 0x3B43, 0x5E0B, 0x70E1, 0x7095, 0x5D33, 0x3A04, 0x0D00, 0xDDC8, 0xB45C, 0x97C4, 0x8CD6, 0x956E, 0xB017, 0xD84C, 0x073C, 0x34F2, 0x59AE, 0x6F36, 0x71E5, 0x6144, 0x4027, 0x142A, 0xE4C1, 0xB9F7, 0x9B0D, 0x8D3F, 0x92E5, 0xAB0A, 0xD196, 0x0000, 0x2E6A, 0x54F6, 0x6D1B, 0x72C1, 0x64F3, 0x4609, 0x1B3F, 0xEBD6, 0xBFD9, 0x9EBC, 0x8E1B, 0x90CA, 0xA652, 0xCB0E, 0xF8C4, 0x27B4, 0x4FE9, 0x6A92, 0x732A, 0x683C, 0x4BA4, 0x2238, 0xF300, 0xC5FC, 0xA2CD, 0x8F6B, 0x8F1F, 0xA1F5, 0xC4BD, 0xF190, 0x20D6, 0x4A8A, 0x679D, 0x731E, 0x6B1C, 0x50F2, 0x290F, 0xFA36, 0xCC59, 0xA73D, 0x912D, 0x8DE6, 0x9DF7, 0xBEA7, 0xEA6A, 0x19D6, 0x44E1, 0x643F, 0x729E, 0x6D90, 0x55EF, 0x2FBC, 0x0173, 0xD2EA, 0xAC06, 0x935E, 0x8D21, 0x9A5C, 0xB8D3, 0xE35A, 0x12BC, 0x3EF2, 0x607C, 0x71AB, 0x6F95, 0x5A95, 0x363A, 0x08AD, 0xD9A9, 0xB124, 0x95FD, 0x8CCF, 0x9728, 0xB347, 0xDC67, 0x0B90, 0x38C3, 0x5C57, 0x7044, 0x7129, 0x5EDF, 0x3C80, 0x0FE0, 0xE08E, 0xB692, 0x9908, 0x8CF2, 0x945E, 0xAE08, 0xD598, 0x0458, 0x325B, 0x57D5, 0x6E6C, 0x724B, 0x62C9, 0x4289, 0x1702, 0xE794, 0xBC4A, 0x9C7A, 0x8D89, 0x9200, 0xA91C, 0xCEF3, 0xFD1B, 0x2BC0, 0x52FB, 0x6C24, 0x72F9, 0x6650, 0x484F, 0x1E0D, 0xEEB2, 0xC246, 0xA051, 0x8E94, 0x9011, 0xA488, 0xC881, 0xF5E1, 0x24F9, 0x4DCC, 0x6970, 0x7333, 0x6970, 0x4DCC, 0x24F9, 0xF5E1, 0xC881, 0xA488, 0x9011, 0x8E94, 0xA051, 0xC246, 0xEEB2, 0x1E0D, 0x484F, 0x6650, 0x72F9, 0x6C24, 0x52FB, 0x2BC0, 0xFD1B, 0xCEF3, 0xA91C, 0x9200, 0x8D89, 0x9C7A, 0xBC4A, 0xE794, 0x1702, 0x4289, 0x62C9, 0x724B, 0x6E6C, 0x57D5, 0x325B, 0x0458, 0xD598, 0xAE08, 0x945E, 0x8CF2, 0x9908, 0xB692, 0xE08E, 0x0FE0, 0x3C80, 0x5EDF, 0x7129, 0x7044, 0x5C57, 0x38C3, 0x0B90, 0xDC67, 0xB347, 0x9728, 0x8CCF, 0x95FD, 0xB124, 0xD9A9, 0x08AD, 0x363A, 0x5A95, 0x6F95, 0x71AB, 0x607C, 0x3EF2, 0x12BC, 0xE35A, 0xB8D3, 0x9A5C, 0x8D21, 0x935E, 0xAC06, 0xD2EA, 0x0173, 0x2FBC, 0x55EF, 0x6D90, 0x729E, 0x643F, 0x44E1, 0x19D6, 0xEA6A, 0xBEA7, 0x9DF7, 0x8DE6, 0x912D, 0xA73D, 0xCC59, 0xFA36, 0x290F, 0x50F2, 0x6B1C, 0x731E, 0x679D, 0x4A8A, 0x20D6, 0xF190, 0xC4BD, 0xA1F5, 0x8F1F, 0x8F6B, 0xA2CD, 0xC5FC, 0xF300, 0x2238, 0x4BA4, 0x683C, 0x732A, 0x6A92, 0x4FE9, 0x27B4, 0xF8C4, 0xCB0E, 0xA652, 0x90CA, 0x8E1B, 0x9EBC, 0xBFD9, 0xEBD6, 0x1B3F, 0x4609, 0x64F3, 0x72C1, 0x6D1B, 0x54F6, 0x2E6A, 0x0000, 0xD196, 0xAB0A, 0x92E5, 0x8D3F, 0x9B0D, 0xB9F7, 0xE4C1, 0x142A, 0x4027, 0x6144, 0x71E5, 0x6F36, 0x59AE, 0x34F2, 0x073C, 0xD84C, 0xB017, 0x956E, 0x8CD6, 0x97C4, 0xB45C, 0xDDC8, 0x0D00, 0x3A04, 0x5D33, 0x7095, 0x70E1, 0x5E0B, 0x3B43, 0x0E70, 0xDF2A, 0xB576, 0x9863, 0x8CE2, 0x94E4, 0xAF0E, 0xD6F1, 0x05CA, 0x33A7, 0x58C3, 0x6ED3, 0x721A, 0x6209, 0x4159, 0x1596, 0xE62A, 0xBB1F, 0x9BC1, 0x8D62, 0x9270, 0xAA11, 0xD044, 0xFE8D, 0x2D16, 0x53FA, 0x6CA2, 0x72DF, 0x65A4, 0x472D, 0x1CA6, 0xED44, 0xC10E, 0x9F84, 0x8E55, 0x906B, 0xA56B, 0xC9C6, 0xF753, 0x2657, 0x4EDC, 0x6A03, 0x7331, 0x68D8, 0x4CB9, 0x2399, 0xF470, 0xC73D, 0xA3A9, 0x8FBC, 0x8ED7, 0xA121, 0xC380, 0xF020, 0x1F72, 0x496E, 0x66F8, 0x730E, 0x6BA2, 0x51F8, 0x2A68, 0xFBA8, 0xCDA5, 0xA82B, 0x9194, 0x8DB5, 0x9D37, 0xBD77, 0xE8FE, 0x186C, 0x43B6, 0x6386, 0x7277, 0x6E00, 0x56E4, 0x310D, 0x02E5, 0xD440, 0xAD05, 0x93DC, 0x8D07, 0x99B0, 0xB7B1, 0xE1F3, 0x114E, 0x3DBA, 0x5FAF, 0x716C, 0x6FEF, 0x5B78, 0x377F, 0x0A1F, 0xDB07, 0xB234, 0x9690, 0x8CCD, 0x9690, 0xB234, 0xDB07, 0x0A1F, 0x377F, 0x5B78, 0x6FEF, 0x716C, 0x5FAF, 0x3DBA, 0x114E, 0xE1F3, 0xB7B1, 0x99B0, 0x8D07, 0x93DC, 0xAD05, 0xD440, 0x02E5, 0x310D, 0x56E4, 0x6E00, 0x7277, 0x6386, 0x43B6, 0x186C, 0xE8FE, 0xBD77, 0x9D37, 0x8DB5, 0x9194, 0xA82B, 0xCDA5, 0xFBA8, 0x2A68, 0x51F8, 0x6BA2, 0x730E, 0x66F8, 0x496E, 0x1F72, 0xF020, 0xC380, 0xA121, 0x8ED7, 0x8FBC, 0xA3A9, 0xC73D, 0xF470, 0x2399, 0x4CB9, 0x68D8, 0x7331, 0x6A03, 0x4EDC, 0x2657, 0xF753, 0xC9C6, 0xA56B, 0x906B, 0x8E55, 0x9F84, 0xC10E, 0xED44, 0x1CA6, 0x472D, 0x65A4, 0x72DF, 0x6CA2, 0x53FA, 0x2D16, 0xFE8D, 0xD044, 0xAA11, 0x9270, 0x8D62, 0x9BC1, 0xBB1F, 0xE62A, 0x1596, 0x4159, 0x6209, 0x721A, 0x6ED3, 0x58C3, 0x33A7, 0x05CA, 0xD6F1, 0xAF0E, 0x94E4, 0x8CE2, 0x9863, 0xB576, 0xDF2A, 0x0E70, 0x3B43, 0x5E0B, 0x70E1, 0x7095, 0x5D33, 0x3A04, 0x0D00, 0xDDC8, 0xB45C, 0x97C4, 0x8CD6, 0x956E, 0xB017, 0xD84C, 0x073C, 0x34F2, 0x59AE, 0x6F36, 0x71E5, 0x6144, 0x4027, 0x142A, 0xE4C1, 0xB9F7, 0x9B0D, 0x8D3F, 0x92E5, 0xAB0A, 0xD196, 0x0000};
signed short stop_inputs[SAMPLE_SIZE] = {0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000, 0x4EDC, 0x72F9, 0x58C3, 0x0E70, 0xBC4A, 0x8ED7, 0x9EBC, 0xE35A, 0x377F, 0x6D90, 0x683C, 0x2A68, 0xD598, 0x97C4, 0x9270, 0xC881, 0x1CA6, 0x6144, 0x7129, 0x43B6, 0xF190, 0xA73D, 0x8D07, 0xB124, 0x0000};
signed short delay_inputs[SAMPLE_SIZE] = {0x17B7, 0x2E6A, 0x4320, 0x54F6, 0x6328, 0x6D1B, 0x7261, 0x72C1, 0x6E37, 0x64F3, 0x575D, 0x4609, 0x31B4, 0x1B3F, 0x039E, 0xEBD6, 0xD4EB, 0xBFD9, 0xAD86, 0x9EBC, 0x941C, 0x8E1B, 0x8CFC, 0x90CA, 0x995B, 0xA652, 0xB721, 0xCB0E, 0xE141, 0xF8C4, 0x1097, 0x27B4, 0x3D1D, 0x4FE9, 0x5F48, 0x6A92, 0x714B, 0x732A, 0x701A, 0x683C, 0x5BE8, 0x4BA4, 0x3822, 0x2238, 0x0AD7, 0xF300, 0xDBB7, 0xC5FC, 0xB2BD, 0xA2CD, 0x96DC, 0x8F6B, 0x8CCD, 0x8F1F, 0x9646, 0xA1F5, 0xB1AB, 0xC4BD, 0xDA58, 0xF190, 0x0966, 0x20D6, 0x36DD, 0x4A8A, 0x5B07, 0x679D, 0x6FC2, 0x731E, 0x718C, 0x6B1C, 0x6016, 0x50F2, 0x3E56, 0x290F, 0x1205, 0xFA36, 0xE2A7, 0xCC59, 0xB841, 0xA73D, 0x9A05, 0x912D, 0x8D13, 0x8DE6, 0x939C, 0x9DF7, 0xAC85, 0xBEA7, 0xD395, 0xEA6A, 0x022C, 0x19D6, 0x3065, 0x44E1, 0x566A, 0x643F, 0x6DC9, 0x729E, 0x728B, 0x6D90, 0x63E3, 0x55EF, 0x444C, 0x2FBC, 0x1921, 0x0173, 0xE9B4, 0xD2EA, 0xBE0E, 0xAC06, 0x9D96, 0x935E, 0x8DCD, 0x8D21, 0x9160, 0x9A5C, 0xA7B3, 0xB8D3, 0xCCFF, 0xE35A, 0xFAEF, 0x12BC, 0x29BC, 0x3EF2, 0x5175, 0x607C, 0x6B60, 0x71AB, 0x7317, 0x6F95, 0x674B, 0x5A95, 0x49FD, 0x363A, 0x2024, 0x08AD, 0xF0D8, 0xD9A9, 0xC41E, 0xB124, 0xA18B, 0x95FD, 0x8EFA, 0x8CCF, 0x8F93, 0x9728, 0xA33B, 0xB347, 0xC69C, 0xDC67, 0xF3B8, 0x0B90, 0x22E9, 0x38C3, 0x4C2F, 0x5C57, 0x688B, 0x7044, 0x732E, 0x7129, 0x6A4B, 0x5EDF, 0x4F63, 0x3C80, 0x2706, 0x0FE0, 0xF80B, 0xE08E, 0xCA6A, 0xB692, 0xA5DE, 0x9908, 0x909A, 0x8CF2, 0x8E38, 0x945E, 0x9F20, 0xAE08, 0xC073, 0xD598, 0xEC8D, 0x0458, 0x1BF3, 0x325B, 0x469B, 0x57D5, 0x654C, 0x6E6C, 0x72D1, 0x724B, 0x6CDF, 0x62C9, 0x5479, 0x4289, 0x2DC0, 0x1702, 0xFF47, 0xE794, 0xD0EC, 0xBC4A, 0xAA8D, 0x9C7A, 0x92AA, 0x8D89, 0x8D50, 0x9200, 0x9B66, 0xA91C, 0xBA8B, 0xCEF3, 0xE576, 0xFD1B, 0x14E0, 0x2BC0, 0x40C1, 0x52FB, 0x61A7, 0x6C24, 0x7200, 0x72F9, 0x6F05, 0x6650, 0x5939, 0x484F, 0x344D, 0x1E0D, 0x0683, 0xEEB2, 0xD79E, 0xC246, 0xAF92, 0xA051, 0x9529, 0x8E94, 0x8CDB, 0x9011, 0x9813, 0xA488, 0xB4E9, 0xC881, 0xDE79, 0xF5E1, 0x0DB8, 0x24F9, 0x3AA4, 0x4DCC, 0x5D9F, 0x6970, 0x70BC, 0x7333, 0x70BC, 0x6970, 0x5D9F, 0x4DCC, 0x3AA4, 0x24F9, 0x0DB8, 0xF5E1, 0xDE79, 0xC881, 0xB4E9, 0xA488, 0x9813, 0x9011, 0x8CDB, 0x8E94, 0x9529, 0xA051, 0xAF92, 0xC246, 0xD79E, 0xEEB2, 0x0683, 0x1E0D, 0x344D, 0x484F, 0x5939, 0x6650, 0x6F05, 0x72F9, 0x7200, 0x6C24, 0x61A7, 0x52FB, 0x40C1, 0x2BC0, 0x14E0, 0xFD1B, 0xE576, 0xCEF3, 0xBA8B, 0xA91C, 0x9B66, 0x9200, 0x8D50, 0x8D89, 0x92AA, 0x9C7A, 0xAA8D, 0xBC4A, 0xD0EC, 0xE794, 0xFF47, 0x1702, 0x2DC0, 0x4289, 0x5479, 0x62C9, 0x6CDF, 0x724B, 0x72D1, 0x6E6C, 0x654C, 0x57D5, 0x469B, 0x325B, 0x1BF3, 0x0458, 0xEC8D, 0xD598, 0xC073, 0xAE08, 0x9F20, 0x945E, 0x8E38, 0x8CF2, 0x909A, 0x9908, 0xA5DE, 0xB692, 0xCA6A, 0xE08E, 0xF80B, 0x0FE0, 0x2706, 0x3C80, 0x4F63, 0x5EDF, 0x6A4B, 0x7129, 0x732E, 0x7044, 0x688B, 0x5C57, 0x4C2F, 0x38C3, 0x22E9, 0x0B90, 0xF3B8, 0xDC67, 0xC69C, 0xB347, 0xA33B, 0x9728, 0x8F93, 0x8CCF, 0x8EFA, 0x95FD, 0xA18B, 0xB124, 0xC41E, 0xD9A9, 0xF0D8, 0x08AD, 0x2024, 0x363A, 0x49FD, 0x5A95, 0x674B, 0x6F95, 0x7317, 0x71AB, 0x6B60, 0x607C, 0x5175, 0x3EF2, 0x29BC, 0x12BC, 0xFAEF, 0xE35A, 0xCCFF, 0xB8D3, 0xA7B3, 0x9A5C, 0x9160, 0x8D21, 0x8DCD, 0x935E, 0x9D96, 0xAC06, 0xBE0E, 0xD2EA, 0xE9B4, 0x0173, 0x1921, 0x2FBC, 0x444C, 0x55EF, 0x63E3, 0x6D90, 0x728B, 0x729E, 0x6DC9, 0x643F, 0x566A, 0x44E1, 0x3065, 0x19D6, 0x022C, 0xEA6A, 0xD395, 0xBEA7, 0xAC85, 0x9DF7, 0x939C, 0x8DE6, 0x8D13, 0x912D, 0x9A05, 0xA73D, 0xB841, 0xCC59, 0xE2A7, 0xFA36, 0x1205, 0x290F, 0x3E56, 0x50F2, 0x6016, 0x6B1C, 0x718C, 0x731E, 0x6FC2, 0x679D, 0x5B07, 0x4A8A, 0x36DD, 0x20D6, 0x0966, 0xF190, 0xDA58, 0xC4BD, 0xB1AB, 0xA1F5, 0x9646, 0x8F1F, 0x8CCD, 0x8F6B, 0x96DC, 0xA2CD, 0xB2BD, 0xC5FC, 0xDBB7, 0xF300, 0x0AD7, 0x2238, 0x3822, 0x4BA4, 0x5BE8, 0x683C, 0x701A, 0x732A, 0x714B, 0x6A92, 0x5F48, 0x4FE9, 0x3D1D, 0x27B4, 0x1097, 0xF8C4, 0xE141, 0xCB0E, 0xB721, 0xA652, 0x995B, 0x90CA, 0x8CFC, 0x8E1B, 0x941C, 0x9EBC, 0xAD86, 0xBFD9, 0xD4EB, 0xEBD6, 0x039E, 0x1B3F, 0x31B4, 0x4609, 0x575D, 0x64F3, 0x6E37, 0x72C1, 0x7261, 0x6D1B, 0x6328, 0x54F6, 0x4320, 0x2E6A, 0x17B7, 0x0000, 0xE849, 0xD196, 0xBCE0, 0xAB0A, 0x9CD8, 0x92E5, 0x8D9F, 0x8D3F, 0x91C9, 0x9B0D, 0xA8A3, 0xB9F7, 0xCE4C, 0xE4C1, 0xFC62, 0x142A, 0x2B15, 0x4027, 0x527A, 0x6144, 0x6BE4, 0x71E5, 0x7304, 0x6F36, 0x66A5, 0x59AE, 0x48DF, 0x34F2, 0x1EBF, 0x073C, 0xEF69, 0xD84C, 0xC2E3, 0xB017, 0xA0B8, 0x956E, 0x8EB5, 0x8CD6, 0x8FE6, 0x97C4, 0xA418, 0xB45C, 0xC7DE, 0xDDC8, 0xF529, 0x0D00, 0x2449, 0x3A04, 0x4D43, 0x5D33, 0x6924, 0x7095, 0x7333, 0x70E1, 0x69BA, 0x5E0B, 0x4E55, 0x3B43, 0x25A8, 0x0E70, 0xF69A, 0xDF2A, 0xC923, 0xB576, 0xA4F9, 0x9863, 0x903E, 0x8CE2, 0x8E74, 0x94E4, 0x9FEA, 0xAF0E, 0xC1AA, 0xD6F1, 0xEDFB, 0x05CA, 0x1D59, 0x33A7, 0x47BF, 0x58C3, 0x65FB, 0x6ED3, 0x72ED, 0x721A, 0x6C64, 0x6209, 0x537B, 0x4159, 0x2C6B, 0x1596, 0xFDD4, 0xE62A, 0xCF9B, 0xBB1F, 0xA996, 0x9BC1, 0x9237, 0x8D62, 0x8D75, 0x9270, 0x9C1D, 0xAA11, 0xBBB4, 0xD044, 0xE6DF, 0xFE8D, 0x164C, 0x2D16, 0x41F2, 0x53FA, 0x626A, 0x6CA2, 0x7233, 0x72DF, 0x6EA0, 0x65A4, 0x584D, 0x472D, 0x3301, 0x1CA6, 0x0511, 0xED44, 0xD644, 0xC10E, 0xAE8B, 0x9F84, 0x94A0, 0x8E55, 0x8CE9, 0x906B, 0x98B5, 0xA56B, 0xB603, 0xC9C6, 0xDFDC, 0xF753, 0x0F28, 0x2657, 0x3BE2, 0x4EDC, 0x5E75, 0x6A03, 0x7106, 0x7331, 0x706D, 0x68D8, 0x5CC5, 0x4CB9, 0x3964, 0x2399, 0x0C48, 0xF470, 0xDD17, 0xC73D, 0xB3D1, 0xA3A9, 0x9775, 0x8FBC, 0x8CD2, 0x8ED7, 0x95B5, 0xA121, 0xB09D, 0xC380, 0xD8FA, 0xF020, 0x07F5, 0x1F72, 0x3596, 0x496E, 0x5A22, 0x66F8, 0x6F66, 0x730E, 0x71C8, 0x6BA2, 0x60E0, 0x51F8, 0x3F8D, 0x2A68, 0x1373, 0xFBA8, 0xE40D, 0xCDA5, 0xB965, 0xA82B, 0x9AB4, 0x9194, 0x8D2F, 0x8DB5, 0x9321, 0x9D37, 0xAB87, 0xBD77, 0xD240, 0xE8FE, 0x00B9, 0x186C, 0x2F14, 0x43B6, 0x5573, 0x6386, 0x6D56, 0x7277, 0x72B0, 0x6E00, 0x649A, 0x56E4, 0x4575, 0x310D, 0x1A8A, 0x02E5, 0xEB20, 0xD440, 0xBF3F, 0xAD05, 0x9E59, 0x93DC, 0x8E00, 0x8D07, 0x90FB, 0x99B0, 0xA6C7, 0xB7B1, 0xCBB3, 0xE1F3, 0xF97D, 0x114E, 0x2862, 0x3DBA, 0x506E, 0x5FAF, 0x6AD7, 0x716C, 0x7325, 0x6FEF, 0x67ED, 0x5B78, 0x4B17, 0x377F, 0x2187, 0x0A1F, 0xF248, 0xDB07, 0xC55C, 0xB234, 0xA261, 0x9690, 0x8F44, 0x8CCD, 0x8F44, 0x9690, 0xA261, 0xB234, 0xC55C, 0xDB07, 0xF248, 0x0A1F, 0x2187, 0x377F, 0x4B17, 0x5B78, 0x67ED, 0x6FEF, 0x7325, 0x716C, 0x6AD7, 0x5FAF, 0x506E, 0x3DBA, 0x2862, 0x114E, 0xF97D, 0xE1F3, 0xCBB3, 0xB7B1, 0xA6C7, 0x99B0, 0x90FB, 0x8D07, 0x8E00, 0x93DC, 0x9E59, 0xAD05, 0xBF3F, 0xD440, 0xEB20, 0x02E5, 0x1A8A, 0x310D, 0x4575, 0x56E4, 0x649A, 0x6E00, 0x72B0, 0x7277, 0x6D56, 0x6386, 0x5573, 0x43B6, 0x2F14, 0x186C, 0x00B9, 0xE8FE, 0xD240, 0xBD77, 0xAB87, 0x9D37, 0x9321, 0x8DB5, 0x8D2F, 0x9194, 0x9AB4, 0xA82B, 0xB965, 0xCDA5, 0xE40D, 0xFBA8, 0x1373, 0x2A68, 0x3F8D, 0x51F8, 0x60E0, 0x6BA2, 0x71C8, 0x730E, 0x6F66, 0x66F8, 0x5A22, 0x496E, 0x3596, 0x1F72, 0x07F5, 0xF020, 0xD8FA, 0xC380, 0xB09D, 0xA121, 0x95B5, 0x8ED7, 0x8CD2, 0x8FBC, 0x9775, 0xA3A9, 0xB3D1, 0xC73D, 0xDD17, 0xF470, 0x0C48, 0x2399, 0x3964, 0x4CB9, 0x5CC5, 0x68D8, 0x706D, 0x7331, 0x7106, 0x6A03, 0x5E75, 0x4EDC, 0x3BE2, 0x2657, 0x0F28, 0xF753, 0xDFDC, 0xC9C6, 0xB603, 0xA56B, 0x98B5, 0x906B, 0x8CE9, 0x8E55, 0x94A0, 0x9F84, 0xAE8B, 0xC10E, 0xD644, 0xED44, 0x0511, 0x1CA6, 0x3301, 0x472D, 0x584D, 0x65A4, 0x6EA0, 0x72DF, 0x7233, 0x6CA2, 0x626A, 0x53FA, 0x41F2, 0x2D16, 0x164C, 0xFE8D, 0xE6DF, 0xD044, 0xBBB4, 0xAA11, 0x9C1D, 0x9270, 0x8D75, 0x8D62, 0x9237, 0x9BC1, 0xA996, 0xBB1F, 0xCF9B, 0xE62A, 0xFDD4, 0x1596, 0x2C6B, 0x4159, 0x537B, 0x6209, 0x6C64, 0x721A, 0x72ED, 0x6ED3, 0x65FB, 0x58C3, 0x47BF, 0x33A7, 0x1D59, 0x05CA, 0xEDFB, 0xD6F1, 0xC1AA, 0xAF0E, 0x9FEA, 0x94E4, 0x8E74, 0x8CE2, 0x903E, 0x9863, 0xA4F9, 0xB576, 0xC923, 0xDF2A, 0xF69A, 0x0E70, 0x25A8, 0x3B43, 0x4E55, 0x5E0B, 0x69BA, 0x70E1, 0x7333, 0x7095, 0x6924, 0x5D33, 0x4D43, 0x3A04, 0x2449, 0x0D00, 0xF529, 0xDDC8, 0xC7DE, 0xB45C, 0xA418, 0x97C4, 0x8FE6, 0x8CD6, 0x8EB5, 0x956E, 0xA0B8, 0xB017, 0xC2E3, 0xD84C, 0xEF69, 0x073C, 0x1EBF, 0x34F2, 0x48DF, 0x59AE, 0x66A5, 0x6F36, 0x7304, 0x71E5, 0x6BE4, 0x6144, 0x527A, 0x4027, 0x2B15, 0x142A, 0xFC62, 0xE4C1, 0xCE4C, 0xB9F7, 0xA8A3, 0x9B0D, 0x91C9, 0x8D3F, 0x8D9F, 0x92E5, 0x9CD8, 0xAB0A, 0xBCE0, 0xD196, 0xE849, 0x0000};
signed short outputs[SAMPLE_SIZE];


void initFilter(struct circBuff *buff);
void addItem(struct circBuff *buff, int inputPos);
signed short filter(struct circBuff *buff, int outputIndex);

int main() {
	struct circBuff buff;

	initFilter(&buff);

	volatile unsigned int *reg0 = (unsigned int *) 0x44a00000;
	*reg0 = 0x3;
	int i;
	for (i = 0; i < SAMPLE_SIZE; i++) {
			addItem(&buff, i);
			outputs[i] = filter(&buff, i);
	}
	*reg0 = 0x0;

	for (int j = 0; j < SAMPLE_SIZE; j++) {
		xil_printf("%d\n", outputs[j]);
	}
}

void initFilter(struct circBuff *buff) {
	buff->firstElement = 0;
	buff->count = 0;
	int i;
	for (i = 0; i < BUFF_SIZE; i++) {
		buff->inputs[i] = 0;
	}
	return;
}

void addItem(struct circBuff *buff, int inputPos) {
	buff->inputs[buff->firstElement] = delay_inputs[inputPos];
	buff->firstElement++;
	if(buff->firstElement > BUFF_SIZE - 1) {
		buff->firstElement = 0;
	}
	if(buff->count < BUFF_SIZE) {
		buff->count++;
	}
}

signed short filter(struct circBuff *buff,  int outputIndex) {
	int accum = 0;
	if (buff->count < BUFF_SIZE) {
		int items_iterator = buff->count-1;
		for (int i = 0; i < buff->count; i++) {
			accum += ((int) buff->inputs[items_iterator])*(coeff[i]);
			items_iterator--;
		}
	} else {
		int buff_iterator = buff->firstElement;
		int coeff_iterator = BUFF_SIZE-1;

		for (int i = 0; i < BUFF_SIZE; i++) {
			accum += ((int) buff->inputs[buff_iterator])*(coeff[coeff_iterator]);
			buff_iterator++;
			coeff_iterator--;
			if (buff_iterator > BUFF_SIZE - 1) {
				buff_iterator = 0;
			}
		}
	}
	return (short)((accum + 0x4000) >> 15);
}
