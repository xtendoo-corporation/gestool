#include "hbclass.ch"

#define CRLF                        chr( 13 ) + chr( 10 )

#define OFN_PATHMUSTEXIST            0x00000800
#define OFN_NOCHANGEDIR              0x00000008
#define OFN_ALLOWMULTISELECT         0x00000200
#define OFN_EXPLORER                 0x00080000     // new look commdlg
#define OFN_LONGNAMES                0x00200000     // force long names for 3.x modules
#define OFN_ENABLESIZING             0x00800000

#define __porcentajeIVA__            1.21

//---------------------------------------------------------------------------//

Function Inicio()

   ArticulosICG():New()

   msgInfo( "Proceso finalizado")

Return ( nil )

//---------------------------------------------------------------------------//

CLASS ArticulosICG

   DATA nView

   DATA cTarifa              INIT  "00 Netos T/4 al 30 margen "
   DATA aTarifa              INIT  {}

   DATA hTarifa              INIT  {   {  "00 Netos T/4 al 30 margen ",; 
                                          {  "Factor descuento 1" => 2,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.80,;
                                             "Descuento 2" => 20,;
                                             "Factor descuento 3" => 1.60,;
                                             "Descuento 3" => 20,;
                                             "Factor descuento 4" => 1.30,;
                                             "Descuento 4" => 35,;
                                             "Factor descuento 5" => 1.25,;
                                             "Descuento 5" => 37.5,;
                                             "Factor descuento 6" => 1.20,;
                                             "Descuento 6" => 40 } },;
					{  "01 Andel Filtros T1=T2 ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1,;
                                             "Descuento 2" => 0,;
                                             "Factor descuento 3" => 0.60,;
                                             "Descuento 3" => 40,;
                                             "Factor descuento 4" => 0.45,;
                                             "Descuento 4" => 55,;
                                             "Factor descuento 5" => 0.43,;
                                             "Descuento 5" => 57,;
                                             "Factor descuento 6" => 0.40,;
                                             "Descuento 6" => 60 } },;
					{  "02 Netos Margen Normal 150-50-40-30-20-10 ",; 
                                          {  "Factor descuento 1" => 3,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.50,;
                                             "Descuento 2" => 25,;
                                             "Factor descuento 3" => 1.40,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 1.30,;
                                             "Descuento 4" => 35,;
                                             "Factor descuento 5" => 1.20,;
                                             "Descuento 5" => 40,;
                                             "Factor descuento 6" => 1.10,;
                                             "Descuento 6" => 45 } },;
					{  "6 Junta homcinetica Neto*3 ",; 
                                          {  "Factor descuento 1" => 3,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 2,;
                                             "Descuento 2" => 33,;
                                             "Factor descuento 3" => 1.75,;
                                             "Descuento 3" => 41.5,;
                                             "Factor descuento 4" => 1.30,;
                                             "Descuento 4" => 56.5,;
                                             "Factor descuento 5" => 1.20,;
                                             "Descuento 5" => 60,;
                                             "Factor descuento 6" => 1.15,;
                                             "Descuento 6" => 61.65 } },;
					{  "15 LUK 53% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.85,;
                                             "Descuento 2" => 15,;
                                             "Factor descuento 3" => 0.70,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 0.58,;
                                             "Descuento 4" => 42,;
                                             "Factor descuento 5" => 0.55,;
                                             "Descuento 5" => 45,;
                                             "Factor descuento 6" => 0.50,;
                                             "Descuento 6" => 50 } },;
					{  "19 COJALI DTO 1 40% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.90,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 0.85,;
                                             "Descuento 3" => 15,;
                                             "Factor descuento 4" => 0.78,;
                                             "Descuento 4" => 22,;
                                             "Factor descuento 5" => 0.75,;
                                             "Descuento 5" => 25,;
                                             "Factor descuento 6" => 0.70,;
                                             "Descuento 6" => 30 } },;
					{  "20 Jbm 40% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.90,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 0.85,;
                                             "Descuento 3" => 15,;
                                             "Factor descuento 4" => 0.75,;
                                             "Descuento 4" => 25,;
                                             "Factor descuento 5" => 0.70,;
                                             "Descuento 5" => 30,;
                                             "Factor descuento 6" => 0.65,;
                                             "Descuento 6" => 35 } },;
					{  "23 Surglass 53% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.85,;
                                             "Descuento 2" => 15,;
                                             "Factor descuento 3" => 0.75,;
                                             "Descuento 3" => 25,;
                                             "Factor descuento 4" => 0.60,;
                                             "Descuento 4" => 40,;
                                             "Factor descuento 5" => 0.55,;
                                             "Descuento 5" => 45,;
                                             "Factor descuento 6" => 0.53,;
                                             "Descuento 6" => 47 } },;
					{  "24 Bottari 50% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.75,;
                                             "Descuento 2" => 15,;
                                             "Factor descuento 3" => 0.75,;
                                             "Descuento 3" => 20,;
                                             "Factor descuento 4" => 0.65,;
                                             "Descuento 4" => 25,;
                                             "Factor descuento 5" => 0.60,;
                                             "Descuento 5" => 25,;
                                             "Factor descuento 6" => 0.55,;
                                             "Descuento 6" => 30 } },;
					{  "27 Dayco Scooter 50% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.90,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 0.80,;
                                             "Descuento 3" => 20,;
                                             "Factor descuento 4" => 0.65,;
                                             "Descuento 4" => 35,;
                                             "Factor descuento 5" => 0.63,;
                                             "Descuento 5" => 37,;
                                             "Factor descuento 6" => 0.57,;
                                             "Descuento 6" => 43 } },;
					{  "33 Luk Embragues 57% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.80,;
                                             "Descuento 2" => 20,;
                                             "Factor descuento 3" => 0.70,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 0.55,;
                                             "Descuento 4" => 45,;
                                             "Factor descuento 5" => 0.50,;
                                             "Descuento 5" => 50,;
                                             "Factor descuento 6" => 0.48,;
                                             "Descuento 6" => 52 } },;
					{  "34 Trw 67% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.75,;
                                             "Descuento 2" => 25,;
                                             "Factor descuento 3" => 0.60,;
                                             "Descuento 3" => 40,;
                                             "Factor descuento 4" => 0.43,;
                                             "Descuento 4" => 57,;
                                             "Factor descuento 5" => 0.40,;
                                             "Descuento 5" => 60,;
                                             "Factor descuento 6" => 0.38,;
                                             "Descuento 6" => 62 } },;
					{  "37 Carbureibar 45% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.90,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 0.85,;
                                             "Descuento 3" => 15,;
                                             "Factor descuento 4" => 0.72,;
                                             "Descuento 4" => 28,;
                                             "Factor descuento 5" => 0.68,;
                                             "Descuento 5" => 32,;
                                             "Factor descuento 6" => 0.63,;
                                             "Descuento 6" => 37 } },;
					{  "44 Mdr 55% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.85,;
                                             "Descuento 2" => 15,;
                                             "Factor descuento 3" => 0.70,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 0.58,;
                                             "Descuento 4" => 42,;
                                             "Factor descuento 5" => 0.55,;
                                             "Descuento 5" => 45,;
                                             "Factor descuento 6" => 0.53,;
                                             "Descuento 6" => 47 } },;
					{  "59 OJO Costo+neto ",; 
                                          {  "Factor descuento 1" => 2,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.80,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 1.60,;
                                             "Descuento 3" => 20,;
                                             "Factor descuento 4" => 1.30,;
                                             "Descuento 4" => 35,;
                                             "Factor descuento 5" => 1.25,;
                                             "Descuento 5" => 37.5,;
                                             "Factor descuento 6" => 1.20,;
                                             "Descuento 6" => 40 } },;
					{  "60 Andel transmisiones 58% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.85,;
                                             "Descuento 2" => 15,;
                                             "Factor descuento 3" => 0.75,;
                                             "Descuento 3" => 25,;
                                             "Factor descuento 4" => 0.55,;
                                             "Descuento 4" => 45,;
                                             "Factor descuento 5" => 0.53,;
                                             "Descuento 5" => 47,;
                                             "Factor descuento 6" => 0.50,;
                                             "Descuento 6" => 50 } },;
					{  "61 Andel T1=T2 dto 58% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1,;
                                             "Descuento 2" => 0,;
                                             "Factor descuento 3" => 0.75,;
                                             "Descuento 3" => 25,;
                                             "Factor descuento 4" => 0.55,;
                                             "Descuento 4" => 45,;
                                             "Factor descuento 5" => 0.53,;
                                             "Descuento 5" => 47,;
                                             "Factor descuento 6" => 0.50,;
                                             "Descuento 6" => 50 } },;
					{  "67 Trw direcciones 48% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.90,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 0.80,;
                                             "Descuento 3" => 20,;
                                             "Factor descuento 4" => 0.70,;
                                             "Descuento 4" => 30,;
                                             "Factor descuento 5" => 0.65,;
                                             "Descuento 5" => 35,;
                                             "Factor descuento 6" => 0.60,;
                                             "Descuento 6" => 40 } },;
					{  "68 Rinder Rotativos 32% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.95,;
                                             "Descuento 2" => 5,;
                                             "Factor descuento 3" => 0.90,;
                                             "Descuento 3" => 10,;
                                             "Factor descuento 4" => 0.85,;
                                             "Descuento 4" => 15,;
                                             "Factor descuento 5" => 0.83,;
                                             "Descuento 5" => 17,;
                                             "Factor descuento 6" => 0.80,;
                                             "Descuento 6" => 20 } },;
					{  "69 Ngk 61% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.80,;
                                             "Descuento 2" => 20,;
                                             "Factor descuento 3" => 0.65,;
                                             "Descuento 3" => 35,;
                                             "Factor descuento 4" => 0.50,;
                                             "Descuento 4" => 50,;
                                             "Factor descuento 5" => 0.48,;
                                             "Descuento 5" => 52,;
                                             "Factor descuento 6" => 0.45,;
                                             "Descuento 6" => 55 } },;
					{  "70 Poleas 68.72% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.75,;
                                             "Descuento 2" => 25,;
                                             "Factor descuento 3" => 0.60,;
                                             "Descuento 3" => 40,;
                                             "Factor descuento 4" => 0.38,;
                                             "Descuento 4" => 62,;
                                             "Factor descuento 5" => 0.36,;
                                             "Descuento 5" => 64,;
                                             "Factor descuento 6" => 0.34,;
                                             "Descuento 6" => 66 } },;
					{  "77 Aurilis 40% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.95,;
                                             "Descuento 2" => 5,;
                                             "Factor descuento 3" => 0.90,;
                                             "Descuento 3" => 10,;
                                             "Factor descuento 4" => 0.8,;
                                             "Descuento 4" => 20,;
                                             "Factor descuento 5" => 0.75,;
                                             "Descuento 5" => 25,;
                                             "Factor descuento 6" => 0.70,;
                                             "Descuento 6" => 30 } },;	
					{  "82 Snr rodamientos 78% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.65,;
                                             "Descuento 2" => 35,;
                                             "Factor descuento 3" => 0.55,;
                                             "Descuento 3" => 45,;
                                             "Factor descuento 4" => 0.30,;
                                             "Descuento 4" => 70,;
                                             "Factor descuento 5" => 0.28,;
                                             "Descuento 5" => 72,;
                                             "Factor descuento 6" => 0.26,;
                                             "Descuento 6" => 74 } },;
                                       {  "84 fAE 59% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.80,;
                                             "Descuento 2" => 20,;
                                             "Factor descuento 3" => 0.70,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 0.53,;
                                             "Descuento 4" => 47,;
                                             "Factor descuento 5" => 0.50,;
                                             "Descuento 5" => 50,;
                                             "Factor descuento 6" => 0.47,;
                                             "Descuento 6" => 53 } },;
					{  "85 Dayco correas 74% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.65,;
                                             "Descuento 2" => 35,;
                                             "Factor descuento 3" => 0.55,;
                                             "Descuento 3" => 45,;
                                             "Factor descuento 4" => 0.35,;
                                             "Descuento 4" => 65,;
                                             "Factor descuento 5" => 0.33,;
                                             "Descuento 5" => 67,;
                                             "Factor descuento 6" => 0.30,;
                                             "Descuento 6" => 70 } },;
                    {  "86 ANGLOREC 50% ",; 
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.90,;
                                             "Descuento 2" => 10,;
                                             "Factor descuento 3" => 0.80,;
                                             "Descuento 3" => 20,;
                                             "Factor descuento 4" => 0.67,;
                                             "Descuento 4" => 33,;
                                             "Factor descuento 5" => 0.65,;
                                             "Descuento 5" => 35,;
                                             "Factor descuento 6" => 0.60,;
                                             "Descuento 6" => 40 } },;
					{  "87 Costo+margen baterias ",;
                                          {  "Factor descuento 1" => 2,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.35,;
                                             "Descuento 2" => 33,;
                                             "Factor descuento 3" => 1.35,;
                                             "Descuento 3" => 33,;
                                             "Factor descuento 4" => 1.20,;
                                             "Descuento 4" => 40,;
                                             "Factor descuento 5" => 1.15,;
                                             "Descuento 5" => 43,;
                                             "Factor descuento 6" => 1.10,;
                                             "Descuento 6" => 45 } },;
					{  "88 Andel escobillas 65% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.75,;
                                             "Descuento 2" => 25,;
                                             "Factor descuento 3" => 0.60,;
                                             "Descuento 3" => 40,;
                                             "Factor descuento 4" => 0.45,;
                                             "Descuento 4" => 55,;
                                             "Factor descuento 5" => 0.43,;
                                             "Descuento 5" => 57,;
                                             "Factor descuento 6" => 0.40,;
                                             "Descuento 6" => 60 } },;
					{  "89 Textar pastillas 75% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.60,;
                                             "Descuento 2" => 40,;
                                             "Factor descuento 3" => 0.50,;
                                             "Descuento 3" => 50,;
                                             "Factor descuento 4" => 0.32,;
                                             "Descuento 4" => 68,;
                                             "Factor descuento 5" => 0.30,;
                                             "Descuento 5" => 70,;
                                             "Factor descuento 6" => 0.28,;
                                             "Descuento 6" => 72 } },;
					{  "90 Conti Correa+rodillo 65% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.75,;
                                             "Descuento 2" => 25,;
                                             "Factor descuento 3" => 0.65,;
                                             "Descuento 3" => 35,;
                                             "Factor descuento 4" => 0.46,;
                                             "Descuento 4" => 54,;
                                             "Factor descuento 5" => 0.44,;
                                             "Descuento 5" => 56,;
                                             "Factor descuento 6" => 0.42,;
                                             "Descuento 6" => 58 } },;
					{  "91 Purflux con * 68.98% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.75,;
                                             "Descuento 2" => 25,;
                                             "Factor descuento 3" => 0.6,;
                                             "Descuento 3" => 40,;
                                             "Factor descuento 4" => 0.4,;
                                             "Descuento 4" => 60,;
                                             "Factor descuento 5" => 0.38,;
                                             "Descuento 5" => 62,;
                                             "Factor descuento 6" => 0.35,;
                                             "Descuento 6" => 65 } },;
					{  "92 Dayco  79.15% ",;
                                          {  "Factor descuento 1" => 1,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 0.6,;
                                             "Descuento 2" => 40,;
                                             "Factor descuento 3" => 0.5,;
                                             "Descuento 3" => 50,;
                                             "Factor descuento 4" => 0.27,;
                                             "Descuento 4" => 73,;
                                             "Factor descuento 5" => 0.25,;
                                             "Descuento 5" => 75,;
                                             "Factor descuento 6" => 0.23,;
											 "Descuento 6" => 77 } },; 
    				{  "99 OJO Cascos Netos+30% ",;
                                          {  "Factor descuento 1" => 1.3,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.3,;
                                             "Descuento 2" => 0,;
                                             "Factor descuento 3" => 1.3,;
                                             "Descuento 3" => 0,;
                                             "Factor descuento 4" => 1.3,;
                                             "Descuento 4" => 0,;
                                             "Factor descuento 5" => 1.30,;
                                             "Descuento 5" => 0,;
                                             "Factor descuento 6" => 1.30,;
                                             "Descuento 6" => 0 } },;
                    {  "100 OJO Netos especiales ",;
                                          {  "Factor descuento 1" => 2,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.6,;
                                             "Descuento 2" => 20,;
                                             "Factor descuento 3" => 1.4,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 1.15,;
                                             "Descuento 4" => 42.50,;
                                             "Factor descuento 5" => 1.10,;
                                             "Descuento 5" => 45,;
                                             "Factor descuento 6" => 1.10,;
                                             "Descuento 6" => 45 } },;
               		{  "101 OJO Netos JBM Herramientas ",;
                                          {  "Factor descuento 1" => 2,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 1.25,;
                                             "Descuento 2" => 37.5,;
                                             "Factor descuento 3" => 1.25,;
                                             "Descuento 3" => 37.5,;
                                             "Factor descuento 4" => 1.15,;
                                             "Descuento 4" => 42.5,;
                                             "Factor descuento 5" => 1.15,;
                                             "Descuento 5" => 42.5,;
                                             "Factor descuento 6" => 1.10,;
                                             "Descuento 6" => 45 } },;  
					{  "102 PLACAS DE MATRICULAS ",;
                                          {  "Factor descuento 1" => 4,;
                                             "Descuento 1" => 0,;
                                             "Factor descuento 2" => 3.25,;
                                             "Descuento 2" => 15,;
                                             "Factor descuento 3" => 2.50,;
                                             "Descuento 3" => 30,;
                                             "Factor descuento 4" => 2.25,;
                                             "Descuento 4" => 35,;
                                             "Factor descuento 5" => 2.25,;
                                             "Descuento 5" => 35,;
                                             "Factor descuento 6" => 2.25,;
                                             "Descuento 6" => 35 } }; 											 
					                                    }    

   DATA cPrecio            INIT "P.V.P."
   DATA aPrecio            INIT { "P.V.P.", "Costo" }                                                                    

   DATA oOleExcel
   
   DATA nRow
   DATA nLineaComienzo     INIT  2

   DATA cCodigoArticulo    INIT  ""
   DATA cDescipcionArticulo
   DATA crefprov
   DATA cCodigoBarrasArticulo
   DATA cSustituyeA
   DATA cSustituidoPor
   DATA cDescipcionCasco
   DATA cReferenciaCasco
   DATA cFechaCreacion

   DATA nPrecioCosto
   DATA nPrecioCasco

   DATA nLitros

   DATA nPrecioVigor       INIT  0
   DATA nDescuentoVigor    INIT  0
   DATA nPrecioVenta1      INIT  0
   DATA nPrecioVentaIVA1   INIT  0
   DATA nPrecioVenta2      INIT  0
   DATA nPrecioVentaIVA2   INIT  0
   DATA nPrecioVenta3      INIT  0
   DATA nPrecioVentaIVA3   INIT  0
   DATA nPrecioVenta4      INIT  0
   DATA nPrecioVentaIVA4   INIT  0
   DATA nPrecioVenta5      INIT  0
   DATA nPrecioVentaIVA5   INIT  0
   DATA nPrecioVenta6      INIT  0
   DATA nPrecioVentaIVA6   INIT  0

   DATA cFamilia
   DATA cFamilia1
   DATA cFamilia2
   DATA cFamilia3
   DATA cFamilia4

   DATA aFichero

   METHOD New()               CONSTRUCTOR

   METHOD Dialog()

   METHOD showDescuentos()

   METHOD AddFichero()  

   METHOD OpenFiles()
   METHOD CloseFiles()        INLINE ( D():DeleteView( ::nView ) )

   METHOD ProcessFile()

   METHOD ProcessRow()

   METHOD AppendArticulo()
      METHOD SetArticulo()

   METHOD updateDescription()

   METHOD AppendEscandallo()
      METHOD setEscandallo()
   METHOD DeleteEscandallo()

   METHOD AppendCodigosBarras()
      METHOD SetCodigosBarras()

   METHOD getReferenciaCasco()

   METHOD GetRange()
   METHOD GetNumeric()

   METHOD getTarifa()

   METHOD factorDescuento1()  INLINE ::getTarifa( "Factor descuento 1" )
   METHOD descuento1()        INLINE ::getTarifa( "Descuento 1" )
   METHOD factorDescuento2()  INLINE ::getTarifa( "Factor descuento 2" )
   METHOD descuento2()        INLINE ::getTarifa( "Descuento 2" )
   METHOD factorDescuento3()  INLINE ::getTarifa( "Factor descuento 3" )
   METHOD descuento3()        INLINE ::getTarifa( "Descuento 3" )
   METHOD factorDescuento4()  INLINE ::getTarifa( "Factor descuento 4" )
   METHOD descuento4()        INLINE ::getTarifa( "Descuento 4" )
   METHOD factorDescuento5()  INLINE ::getTarifa( "Factor descuento 5" )
   METHOD descuento5()        INLINE ::getTarifa( "Descuento 5" )
   METHOD factorDescuento6()  INLINE ::getTarifa( "Factor descuento 6" )
   METHOD descuento6()        INLINE ::getTarifa( "Descuento 6" )

   METHOD lEscandallos()      INLINE ( !empty( ::cDescipcionCasco ) .or. ::nLitros > 0 )

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS ArticulosICG

   local cFichero

	if !::Dialog() 
		Return ( Self )
	end if 

   ::AddFichero()
   if empty( ::aFichero )
      Return ( Self )
   end if 

   if !::showDescuentos()
      Return ( Self )
   end if 

   if !::OpenFiles()
		Return ( Self )
	end if 

   for each cFichero in ::aFichero
      if !empty(cFichero)
         msgRun( "Procesando hoja de calculo " + cFichero, "Espere", {|| ::ProcessFile( cFichero ) } )
      end if 
   next 

   ::CloseFiles()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD Dialog() CLASS ArticulosICG

   local oDlg
   local oBtn
   local aTarifa
   local bTarifa       := { | u | if( pCount () == 0, ::cTarifa, ::cTarifa := u ) }
   local bPrecio       := { | u | if( pCount () == 0, ::cPrecio, ::cPrecio := u ) }

   ::aTarifa           := {}

   for each aTarifa in ::hTarifa
      aAdd( ::aTarifa, aTarifa[ 1 ] )
   next

   oDlg                 := TDialog():New( 5, 5, 15, 40, "Importacion ICG" )

   TSay():New( 1, 1, {|| "Tarifa" }, oDlg )      

   TCombobox():New( 1, 4, bTarifa, ::aTarifa, 100, 14, oDlg )      

   TSay():New( 2, 1, {|| "Precio" }, oDlg )      

   TCombobox():New( 2, 4, bPrecio, ::aPrecio, 100, 14, oDlg )      

   TButton():New( 3, 4, "&Aceptar", oDlg, {|| ( oDlg:End(1) ) }, 40, 12 )

   TButton():New( 3, 12, "&Cancel", oDlg, {|| oDlg:End() }, 40, 12 )

   oDlg:Activate( , , , .t. )

Return ( oDlg:nResult == 1 )

//---------------------------------------------------------------------------//

METHOD showDescuentos()

   local cTexto
   local cFichero

   cTexto         := ""

   for each cFichero in ::aFichero
      if !empty( cFichero )
         cTexto   += "Fichero a procesar " + cFichero + CRLF
      end if 
   next 

   cTexto         += replicate( "-", 40 ) + CRLF
   cTexto         += "Factor descuento 1 : (" + cValtoChar( ::factorDescuento1() ) + ") > " + alltrim( cValtoChar( ::descuento1() ) ) + "%" + CRLF
   cTexto         += "Factor descuento 2 : (" + cValtoChar( ::factorDescuento2() ) + ") > " + alltrim( cValtoChar( ::descuento2() ) ) + "%" + CRLF
   cTexto         += "Factor descuento 3 : (" + cValtoChar( ::factorDescuento3() ) + ") > " + alltrim( cValtoChar( ::descuento3() ) ) + "%" + CRLF
   cTexto         += "Factor descuento 4 : (" + cValtoChar( ::factorDescuento4() ) + ") > " + alltrim( cValtoChar( ::descuento4() ) ) + "%" + CRLF
   cTexto         += "Factor descuento 5 : (" + cValtoChar( ::factorDescuento5() ) + ") > " + alltrim( cValtoChar( ::descuento5() ) ) + "%" + CRLF
   cTexto         += "Factor descuento 6 : (" + cValtoChar( ::factorDescuento6() ) + ") > " + alltrim( cValtoChar( ::descuento6() ) ) + "%" 

Return ( msgYesNo( cTexto, "Valores" ) )   

//---------------------------------------------------------------------------//

METHOD AddFichero() CLASS ArticulosICG

   local i
   local cFile
   local aFile
   local nFlag    := nOr( OFN_PATHMUSTEXIST, OFN_NOCHANGEDIR, OFN_ALLOWMULTISELECT, OFN_EXPLORER, OFN_LONGNAMES )

   ::aFichero     := cGetFile( "All | *.xlsx", "Seleccione los ficheros a importar", "*.xlsx" , , .f., .t., nFlag )

   /*cFile          := cGetFile( "All | *.xls", "Seleccione los ficheros a importar", "*.xls" , , .f., .t., nFlag )
   cFile          := Left( cFile, At( Chr( 0 ) + Chr( 0 ), cFile ) - 1 )

   if !Empty( cFile ) //.or. Valtype( cFile ) == "N"

      cFile       := StrTran( cFile, Chr( 0 ), "," )
      aFile       := hb_aTokens( cFile, "," )

      if Len( aFile ) > 1

         for i := 2 to Len( aFile )
            aFile[ i ] := aFile[ 1 ] + "\" + aFile[ i ]
         next

         aDel( aFile, 1, .t. )

      endif

      if IsArray( aFile )

         for i := 1 to Len( aFile )
            aAdd( ::aFichero, aFile[ i ] ) // if( SubStr( aFile[ i ], 4, 1 ) == "\", aFileDisc( aFile[i] ) + "\" + aFileName( aFile[ i ] ), aFile[ i ] ) )
         next

      else

         aAdd( ::aFichero, aFile )

      endif

   end if*/

RETURN ( ::aFichero )

//---------------------------------------------------------------------------//

METHOD OpenFiles() CLASS ArticulosICG

   local oError
   local oBlock
   local lOpenFiles     := .t.

   oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::nView           := D():CreateView()

      D():Articulos( ::nView )

      D():ArticulosCodigosBarras( ::nView ) 
      ( D():ArticulosCodigosBarras( ::nView ) )->( ordsetfocus( "cArtBar" ) )

      D():Get( "ArtKit", ::nView )  
      ( D():Get( "ArtKit", ::nView ) )->( ordsetfocus( "cCodRef" ) )

      D():Get( "Ruta", ::nView )

      D():Get( "Agentes", ::nView )

   RECOVER USING oError

      lOpenFiles        := .f.

      msgStop( "Imposible abrir todas las bases de datos" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( lOpenFiles )

//---------------------------------------------------------------------------//

METHOD ProcessFile( cFichero ) CLASS ArticulosICG

   local oError
   local oBlock

   oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   CursorWait()

      ::oOleExcel                        := TOleExcel():New( "Importando hoja de excel", "Conectando...", .f. )

      ::oOleExcel:oExcel:Visible         := .f.
      ::oOleExcel:oExcel:DisplayAlerts   := .f.
      ::oOleExcel:oExcel:WorkBooks:Open( cFichero )

      ::oOleExcel:oExcel:WorkSheets( 1 ):Activate()   //Hojas de la hoja de calculo

      /*
      Recorremos la hoja de calculo--------------------------------------------
      */

      SysRefresh()

      for ::nRow := ::nLineaComienzo to 65536

         msgWait( "Procesando linea " + str(::nRow), "", 0.0001 )

         /*
         Si no encontramos mas líneas nos salimos------------------------------
         */

         ::cCodigoArticulo                := ::GetRange( "A" )
         if empty( ::cCodigoArticulo )
            exit
         end if 

         ::cDescipcionArticulo            := ::GetRange( "B" )
		 ::crefprov						  := ::getrange( "C" ) 	
         ::cCodigoBarrasArticulo          := ::GetRange( "E" )
         ::cSustituyeA                    := ::GetRange( "S" )
         ::cSustituidoPor                 := ::GetRange( "T" )
         ::nPrecioVigor                   := ::GetNumeric( "F" )
         ::nDescuentoVigor                := ::GetNumeric( "O" )
         ::cFamilia1                      := ::GetRange( "H" )
         ::cFamilia2                      := ::GetRange( "I" )
         ::cFamilia3                      := ::GetRange( "J" )
         ::cFamilia4                      := ::GetRange( "K" )
         ::cFechaCreacion                 := ::GetRange( "G" )
         ::cDescipcionCasco               := ::GetRange( "R" )
         ::nPrecioCasco                   := ::GetNumeric( "N" )
         ::nLitros                        := ::GetNumeric( "U" )

         // Extraccion de texto ** EXTINGUIDA **

         ::updateDescription()

         // Proces las lineas         
         
         ::ProcessRow()

         // procesa el registro de la base de datos

         ::AppendArticulo()

         ::AppendCodigosBarras()

         if ::lEscandallos()
            ::DeleteEscandallo()
            ::AppendEscandallo()
         end if 
         
      next

      // Cerramos la conexion con el objeto oOleExcel-----------------------------

      ::oOleExcel:oExcel:WorkBooks:Close() 
      ::oOleExcel:oExcel:Quit()
      ::oOleExcel:oExcel:DisplayAlerts   := .t.

      ::oOleExcel:End()

      Msginfo( "Porceso finalizado con exito" )

   CursorWE()

   RECOVER USING oError

      msgStop( "Imposible importar datos de excel" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD updateDescription() CLASS ArticulosICG

//	if "** EXTINGUIDA **" $ ::cDescipcionArticulo
//		::cDescipcionArticulo := alltrim( strtran( ::cDescipcionArticulo, "** EXTINGUIDA **", "" ) )
//		::cDescipcionArticulo += space(1) + "** EXTINGUIDA **"
//	end if
	
	if "SUSTITUIDA" $ ::cDescipcionArticulo
//		::cDescipcionArticulo := alltrim( strtran( ::cDescipcionArticulo, "** EXTINGUIDA **", "" ) )
		::cDescipcionArticulo := ::crefprov += space(1) + ::cDescipcionArticulo
	end if
	

Return ( nil )

//---------------------------------------------------------------------------//

METHOD ProcessRow() CLASS ArticulosICG

   ::nPrecioCosto       := ::nPrecioVigor - ( ::nPrecioVigor * ::nDescuentoVigor / 100 )

   if ::cPrecio == "Costo"
      ::nPrecioVigor    := ::nPrecioCosto
   end if 

   ::nPrecioVenta1      := ::nPrecioVigor * ::factorDescuento1()
   ::nPrecioVentaIVA1   := ::nPrecioVenta1 * __porcentajeIVA__
   
   ::nPrecioVenta2      := ::nPrecioVigor * ::factorDescuento2()
   ::nPrecioVentaIVA2   := ::nPrecioVenta2 * __porcentajeIVA__

   ::nPrecioVenta3      := ::nPrecioVigor * ::factorDescuento3()
   ::nPrecioVentaIVA3   := ::nPrecioVenta3 * __porcentajeIVA__

   ::nPrecioVenta4      := ::nPrecioVigor * ::factorDescuento4()
   ::nPrecioVentaIVA4   := ::nPrecioVenta4 * __porcentajeIVA__

   ::nPrecioVenta5      := ::nPrecioVigor * ::factorDescuento5()
   ::nPrecioVentaIVA5   := ::nPrecioVenta5 * __porcentajeIVA__

   ::nPrecioVenta6      := ::nPrecioVigor * ::factorDescuento6()
   ::nPrecioVentaIVA6   := ::nPrecioVenta6 * __porcentajeIVA__

   ::cFamilia           := ""
   if !empty( ::cFamilia1 )
      ::cFamilia        += alltrim( ::cFamilia1 ) 
   end if 
   if !empty( ::cFamilia2 )
      ::cFamilia        += "." + alltrim( ::cFamilia2 ) 
   end if 
   if !empty( ::cFamilia3 )
      ::cFamilia        += "." + alltrim( ::cFamilia3 )
   end if 
   if !empty( ::cFamilia4 )
      ::cFamilia        += "." + alltrim( ::cFamilia4 ) 
   end if 

Return ( nil )

//------------------------------------------------------------------------

METHOD AppendArticulo()

   if ( D():Articulos( ::nView ) )->( dbseek( ::cCodigoArticulo ) )
      if ( D():Articulos( ::nView ) )->( dbrlock() )
         ::SetArticulo()
         ( D():Articulos( ::nView ) )->( dbunlock() )
      end if
   else
      if ( D():Articulos( ::nView ) )->( dbappend() )
         ::SetArticulo()
         ( D():Articulos( ::nView ) )->( dbunlock() )
      end if 
   end if 

return ( nil )

//------------------------------------------------------------------------

METHOD SetArticulo()

   local oError
   local oBlock

   oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      SysRefresh()

      ( D():Articulos( ::nView ) )->Codigo      := ::cCodigoArticulo
      ( D():Articulos( ::nView ) )->Nombre      := ::cDescipcionArticulo
      ( D():Articulos( ::nView ) )->TipoIva     := "G"
      ( D():Articulos( ::nView ) )->CodeBar     := ::cCodigoBarrasArticulo
      ( D():Articulos( ::nView ) )->pVenta1     := ::nPrecioVenta1
      ( D():Articulos( ::nView ) )->pVenta2     := ::nPrecioVenta2
      ( D():Articulos( ::nView ) )->pVenta3     := ::nPrecioVenta3
      ( D():Articulos( ::nView ) )->pVenta4     := ::nPrecioVenta4
      ( D():Articulos( ::nView ) )->pVenta5     := ::nPrecioVenta5
      ( D():Articulos( ::nView ) )->pVenta6     := ::nPrecioVenta6
      ( D():Articulos( ::nView ) )->pVtaIVA1    := ::nPrecioVentaIVA1
      ( D():Articulos( ::nView ) )->pVtaIVA2    := ::nPrecioVentaIVA2
      ( D():Articulos( ::nView ) )->pVtaIVA3    := ::nPrecioVentaIVA3
      ( D():Articulos( ::nView ) )->pVtaIVA4    := ::nPrecioVentaIVA4
      ( D():Articulos( ::nView ) )->pVtaIVA5    := ::nPrecioVentaIVA5
      ( D():Articulos( ::nView ) )->pVtaIVA6    := ::nPrecioVentaIVA6

      ( D():Articulos( ::nView ) )->lBnf1       := .t.
      ( D():Articulos( ::nView ) )->lBnf2       := .t.
      ( D():Articulos( ::nView ) )->lBnf3       := .t.
      ( D():Articulos( ::nView ) )->lBnf4       := .t.
      ( D():Articulos( ::nView ) )->lBnf5       := .t.
      ( D():Articulos( ::nView ) )->lBnf6       := .t.
      
      ( D():Articulos( ::nView ) )->Benef1      := ( ::nPrecioVenta1 / ::nPrecioCosto * 100 ) - 100
      ( D():Articulos( ::nView ) )->Benef2      := ( ::nPrecioVenta2 / ::nPrecioCosto * 100 ) - 100
      ( D():Articulos( ::nView ) )->Benef3      := ( ::nPrecioVenta3 / ::nPrecioCosto * 100 ) - 100
      ( D():Articulos( ::nView ) )->Benef4      := ( ::nPrecioVenta4 / ::nPrecioCosto * 100 ) - 100
      ( D():Articulos( ::nView ) )->Benef5      := ( ::nPrecioVenta5 / ::nPrecioCosto * 100 ) - 100
      ( D():Articulos( ::nView ) )->Benef6      := ( ::nPrecioVenta6 / ::nPrecioCosto * 100 ) - 100

      ( D():Articulos( ::nView ) )->pCosto      := ::nPrecioCosto
      ( D():Articulos( ::nView ) )->Familia     := ::cFamilia
      ( D():Articulos( ::nView ) )->cCodSus     := ::cSustituyeA
      ( D():Articulos( ::nView ) )->cCodPor     := ::cSustituidoPor
      ( D():Articulos( ::nView ) )->lNotVta     := .t.
      ( D():Articulos( ::nView ) )->lMsgvta     := .t.
      ( D():Articulos( ::nView ) )->lMsgMov     := .t.
      ( D():Articulos( ::nView ) )->lMsgSer     := .t.
      if !empty( ::cDescipcionCasco )
	( D():Articulos( ::nView ) )->lMosCom   := !empty( ::cDescipcionCasco ) 
      end if
      ( D():Articulos( ::nView ) )->lKitArt     := ::lEscandallos()
      ( D():Articulos( ::nView ) )->lKitAsc     := ::lEscandallos()
      
      if !empty( ::cDescipcionCasco )
         ( D():Articulos( ::nView ) )->mComent  := "Ref. casco " + alltrim( ::cDescipcionCasco ) + " por valor de " + alltrim( transform( ::nPrecioCasco * 1.3, "99999999,99" ) ) + " euros" 
      end if 

      ( D():Articulos( ::nView ) )->LastChg     := stod( ::cFechaCreacion )
      ( D():Articulos( ::nView ) )->dFecChg     := date()

   RECOVER USING oError
      
      msgStop( "Imposible almacenar registro en base de datos" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( nil )

//------------------------------------------------------------------------

METHOD AppendCodigosBarras()

   local cCodigo  := padr( ::cCodigoArticulo, 18 ) + padr( ::cCodigoBarrasArticulo, 20 ) 

   if ( D():ArticulosCodigosBarras( ::nView ) )->( dbseek( cCodigo ) )
      if ( D():ArticulosCodigosBarras( ::nView ) )->( dbrlock() )
         ::SetCodigosBarras()
         ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )
      end if
   else
      if ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )
         ::SetCodigosBarras()
         ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )
      end if 
   end if 

return ( nil )

//------------------------------------------------------------------------

METHOD SetCodigosBarras()

   local oError
   local oBlock

   oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      SysRefresh()

      ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt      := ::cCodigoArticulo
      ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar      := ::cCodigoBarrasArticulo

   RECOVER USING oError
      
      msgStop( "Imposible almacenar registro en base de datos" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( nil )

//------------------------------------------------------------------------

METHOD getReferenciaCasco()

   local cReferenciaCasco     := ""

   if !empty(::cDescipcionCasco) 
      if D():seekInOrd( D():Articulos( ::nView ), ::cDescipcionCasco, "Nombre" )
         cReferenciaCasco     := ( D():Articulos( ::nView ) )->Codigo
      end if 
   end if 

Return ( cReferenciaCasco )

//-----------------------------------------------------------------------------

METHOD AppendEscandallo()

   local cCodigo  

   if empty( ::cDescipcionCasco )
      ::cReferenciaCasco   := "1"
   else 
      ::cReferenciaCasco   := ::getReferenciaCasco()
   end if 

   if empty( ::nLitros )
      ::nLitros            := 1
   end if 

   cCodigo                 := Padr( ::cCodigoArticulo, 18 ) + Padr( ::cReferenciaCasco, 18 )

   if ( D():Asociado( ::nView ) )->( dbseek( cCodigo ) )
      if ( D():Asociado( ::nView ) )->( dbrlock() )
         ::setEscandallo()
         ( D():Asociado( ::nView ) )->( dbunlock() )
      end if
   else
      if ( D():Asociado( ::nView ) )->( dbappend() )
         ::setEscandallo()
         ( D():Asociado( ::nView ) )->( dbunlock() )
      end if 
   end if 

return ( nil )

//------------------------------------------------------------------------

METHOD DeleteEscandallo()

   local cCodigo
   local cNombre
   local nRecAnt           := ( D():Asociado( ::nView ) )->( Recno() )
   local nOrdAnt           := ( D():Asociado( ::nView ) )->( OrdSetFocus( "CCODART" ) )

   cCodigo                 := Padr( ::cCodigoArticulo, 18 )

   if ( D():Asociado( ::nView ) )->( dbseek( cCodigo ) )

      while ( D():Asociado( ::nView ) )->CCODART == cCodigo .and. !( D():Asociado( ::nView ) )->( Eof() )

         cNombre := ArticulosModel():getNombre( ( D():Asociado( ::nView ) )->cRefAsc )

         MsgWait( "Borrando escandallo: "+ AllTrim( cNombre ), "Eliminando escandallo", 0.1 )

         if At( "CASCO", upper( cNombre ) ) != 0 .or. At( "CASCOS", upper( cNombre ) ) != 0
            MsgWait( "Borrando escandallo: "+ AllTrim( cNombre ), "Eliminando escandallo", 0.1 )
            ( D():Asociado( ::nView ) )->( dbDelete() )
            ( D():Asociado( ::nView ) )->( dbSkip() )
         else
            ( D():Asociado( ::nView ) )->( dbSkip() )
         end if

      end while

   end if

   ( D():Asociado( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():Asociado( ::nView ) )->( dbGoto( nRecAnt ) )

return ( nil )

//------------------------------------------------------------------------

METHOD setEscandallo()

   ( D():Asociado( ::nView ) )->cCodArt     := ::cCodigoArticulo
   ( D():Asociado( ::nView ) )->cRefAsc     := ::cReferenciaCasco
   ( D():Asociado( ::nView ) )->cDesAsc     := retFld( ::cReferenciaCasco, D():Articulos( ::nView ), "Nombre" ) 
   ( D():Asociado( ::nView ) )->nUndAsc     := ::nLitros

Return ( nil )

//------------------------------------------------------------------------

METHOD GetRange( cColumn )

   local oError
   local oBlock
   local uValue
   local cValue   := ""

   //oBlock         := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   //BEGIN SEQUENCE

   uValue         := ::oOleExcel:oExcel:ActiveSheet:Range( cColumn + lTrim( Str( ::nRow ) ) ):Value
   if Valtype( uValue ) == "C"
      cValue      := alltrim( uValue )
   end if 

   /*RECOVER USING oError

      msgStop( "Imposible obtener columna de excel" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )*/

Return ( cValue )

//---------------------------------------------------------------------------//

METHOD GetNumeric( cColumn )

   local oError
   local oBlock
   local uValue
   local nValue   := 0

   oBlock         := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   uValue         := ::oOleExcel:oExcel:ActiveSheet:Range( cColumn + lTrim( Str( ::nRow ) ) ):Value

   if Valtype( uValue ) == "C"
      nValue      := Val( StrTran( uValue, ",", "." ) )
   end if 

   if Valtype( uValue ) == "N"
      nValue      := uValue
   end if 

   RECOVER USING oError

      msgStop( "Imposible obtener columna de excel" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( nValue ) 

//------------------------------------------------------------------------

METHOD getTarifa( cKey )  

   local nTarifa  := 0
   local nPos     := aScan( ::hTarifa, {|a| alltrim( a[ 1 ] ) == alltrim( ::cTarifa ) } )
   if nPos != 0
      nTarifa     := hGet( ::hTarifa[ nPos, 2 ], cKey )
   end if 

Return ( nTarifa )

//------------------------------------------------------------------------