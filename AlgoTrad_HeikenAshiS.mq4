//--------------------------------------------------------------------
// AlgoTrad_HeikenAshiS.mq4
// The code should be used for educational purpose only.
//--------------------------------------------------------------------
#property copyright "Dr Marjo Kaci @ 2017"
#property link      "===to be determined==="
//--------------------------------------------------------------- 1 --

//Things that need to be taken in consideration before running this EA
// 1. Its build so that the timeframe, the underlying instrument are the ones it is attached to. Its best way also for if we want
// to try it on different instruments.
// 2. It takes only one position at a time
// 3. Need to add some time filters.(necessary!!!)
// 4. If there is an open position. do not apply trading criteria(just stop the prog from running)



// Extern variables  are like input variables, can be used for the optimisation 
// but they have also the carecteristic that can be modified during the program execution.

                                  
extern double StopLoss;     // SL for an opened order
extern double TakeProfit;      // Take profit for an opened order
//extern int    Period_MA_1=11;      // Period of MA 1
//extern int    Period_MA_2=31;      // Period of MA 2
extern double Rastvor    =28.0;    // Distance between MAs
extern double Lots       =0.1;     // Strictly set amount of lots
extern double Prots      =0.07;    // Percent of free margin but is used only when Lots is 0
extern double ordercriteria;                   // min price level of  reversion
extern bool Opn_S=False;                     // Criterion for opening Sell
extern int NumberBars;


//extern double MinCand;    

bool Work=true;                    // EA will work.
string Symb;                       // Security name
double 
StopLossL,
TakeProfitL;

//--------------------------------------------------------------- 2 --
//void OnTick(void) 
void OnTick()
// to work i need to use int start but it gives errors in comiling. Its prob related with the passage to mql5
// in order not to get the errors i can use the void OnStart(). In this way it can not be backtested or attached to graph.


  {
   int
   Total,                           // Amount of orders in a window 
   Tip=-1,                          // Type of selected order (B=0,S=1)
   Ticket;                          // Order number
   double
   //MA_1_t,                          // Current MA_1 value
   //MA_2_t,                          // Current MA_2 value
   //Lot,                             // Amount of lots in a selected order
   Lts,                             // Amount of lots in an opened order
   Min_Lot,                         // Minimal amount of lots
   Step,                            // Step of lot size change
   Free,                            // Current free margin
   One_Lot;                         // Price of one lot
   //Price,                           // Price of a selected order

   //NumberBars;
   bool
   Ans  =false,                     // Server response after closing
//   Cls_B=false,                     // Criterion for closing Buy
//   Cls_S=false,                     // Criterion for closing Sell
   Opn_B=false;                     // Criterion for opening Buy
   //Opn_S=false;                     // Criterion for opening Sell
//--------------------------------------------------------------- 3 --
   
//--------------------------------------------------------------- 4 --
   // Orders accounting: Counts the number of orders in variable Total
   Symb=Symbol();                               // Security name
   Total=0;                                     // Amount of orders
   for(int i=1; i<=OrdersTotal(); i++)          // Loop through orders
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // If there is the next one
        {                                       // Analyzing orders:
         if (OrderSymbol()!=Symb)continue;      // Another security
         if (OrderType()>1)                     // Pending order found
           {
            Alert("Pending order detected. EA doesn't work.");
            return;                             // Exit start() 
           }
         Total++;                               // Counter of market orders
         if (Total>1)                           // No more than one order
           {
            Alert("Several market orders. EA doesn't work.");
            return;                             // Exit start()
           }
         // Dont need the below info
         /*
         Ticket=OrderTicket();                  // Number of selected order
         Tip   =OrderType();                    // Type of selected order
         Price =OrderOpenPrice();               // Price of selected order
         SL    =OrderStopLoss();                // SL of selected order
         TP    =OrderTakeProfit();              // TP of selected order
         Lot   =OrderLots();                    // Amount of lots
        */
        }
     }
//--------------------------------------------------------------- 5 --
// Trading criteria

// HA constructed by:
// CloseHA = (Open + Max + Min + Close)/4
// OpenHA = (OpenHA[1] + CloseHA[1])/2   it looks impossible to me!!!!!!!!!!
// MaxHA = Maximum(Max,OpenHA,CloseHA)
// MinHA = Minimum(Min,OpenHA,CloseHA)


// The trading criteria are thease: 
// 1. Trend well defined(7 candels)
// 2. Inversion of trend(2 candels)
// 3. Buy/Sell if price bigger or lower the inversion max or min.

// double val=iCustom(NULL,0,"SampleInd",13,1,0);
// I have defined some functions in the end to calculate the closeHA, openHA, maxHA, minHA with the possibility of specifing the shift.



//To check values of HA
//Print("CloseHA",closeHa(1),"OpenHA",openHa(1),"max",maxHa(1),"min",minHa(1));

// Conditions for an up trend (I could use filters, like a trend filter to use this method only in a up trend.)

//Case 1 : 2Cand Inversion trend and 7 candel initial trend up.
if ( (~Opn_S) && (closeHa(10) > openHa(10)) && (closeHa(9) > openHa(9)) && (closeHa(8) > openHa(8)) && (closeHa(7) > openHa(7)) && (closeHa(6) > openHa(6)) 
      && (closeHa(5) > openHa(5)) && (closeHa(4) > openHa(4)) && (closeHa(3) < openHa(3))&& (closeHa(2) < openHa(2)) && (closeHa(1) > openHa(1)) )
 {                                         
      
           
      //Print("2/7");
      // MinCand =  MathMin( minHa(2),  minHa(3)); This could also work but 1. U have to declare the variable 2. It works only for 2 value max, here its ok but below not.
      double MinCand2[2];
      MinCand2[0]=minHa(2);
      MinCand2[1]=minHa(3);
      ordercriteria = MinCand2[ArrayMinimum(MinCand2,WHOLE_ARRAY,0)];
      
      double S_L2[10]; //2+8
      for(i=0; i<=9;i++){
         S_L2[i]=maxHa(i+2);
      }
      StopLossL=S_L2[ArrayMaximum(S_L2,WHOLE_ARRAY,0)];
      //TakeProfitL=NormalizeDouble(Bid-(StopLossL-Bid),Digits);
      
            
      NumberBars=Bars;
      Opn_S=true;                               // Criterion for opening Sell
      //Cls_B=true;                               // Criterion for closing Buy
           
 }
 //Case 2: 3Cand Inversion trend and 7 candel initial trend up.
else if ((~Opn_S) &&(closeHa(11) > openHa(11)) && (closeHa(10) > openHa(10)) && (closeHa(9) > openHa(9)) && (closeHa(8) > openHa(8)) && (closeHa(7) > openHa(7)) 
         && (closeHa(6) > openHa(6)) && (closeHa(5) > openHa(5)) && (closeHa(4) < openHa(4)) && (closeHa(3) < openHa(3))&& (closeHa(2) < openHa(2))
         && (closeHa(1) > openHa(1)) )
 {                                         
      
      //Print("3/7");
      //MinCand =  MathMin( minHa(2),minHa(3),minHa(4));
      double MinCand3[3];
      MinCand3[0]=minHa(2);
      MinCand3[1]=minHa(3);
      MinCand3[2]=minHa(4);
      ordercriteria = MinCand3[ArrayMinimum(MinCand3,WHOLE_ARRAY,0)];
      
      double S_L3[11]; //3+8
      for(i=0; i<=10;i++){
         S_L3[i]=maxHa(i+2);
      }
      StopLossL=S_L3[ArrayMaximum(S_L3,WHOLE_ARRAY,0)];
      //TakeProfitL=NormalizeDouble(Bid-(StopLossL-Bid),Digits);
      
      NumberBars=Bars;
      Opn_S=true;                               // Criterion for opening Sell
      //Cls_B=true;                               // Criterion for closing Buy
                                    // Criterion for closing Buy
 }
//Case 3: 4Cand Inversion trend and 7 candel initial trend up.
else if ((~Opn_S) &&(closeHa(12) > openHa(12)) && (closeHa(11) > openHa(11)) && (closeHa(10) > openHa(10)) && (closeHa(9) > openHa(9)) && (closeHa(8) > openHa(8))
         && (closeHa(7) > openHa(7)) && (closeHa(6) > openHa(6)) && (closeHa(5) < openHa(5)) && (closeHa(4) < openHa(4)) && (closeHa(3) < openHa(3))
         && (closeHa(2) < openHa(2)) && (closeHa(1) > openHa(1)) )
 {                                         
      
      //Print("4/7");
      //MinCand =  MathMin(minHa(2),minHa(3),minHa(4),minHa(5));
      double MinCand4[4];
      MinCand4[0]=minHa(2);
      MinCand4[1]=minHa(3);
      MinCand4[2]=minHa(4);
      MinCand4[3]=minHa(5);
      
      ordercriteria = MinCand4[ArrayMinimum(MinCand4,WHOLE_ARRAY,0)];
      
      
      double S_L4[12]; //4+8
      for(i=0; i<=11;i++){
         S_L4[i]=maxHa(i+2);
      }
      StopLossL=S_L4[ArrayMaximum(S_L4,WHOLE_ARRAY,0)];
      //TakeProfitL=NormalizeDouble(Bid-(StopLossL-Bid),Digits);
       
      NumberBars=Bars; 
      Opn_S=true;                               // Criterion for opening Sell
      //Cls_B=true;                               // Criterion for closing Buy
      
 } 
 //Case 4: 5Cand Inversion trend and 7 candel initial trend up.
else if ((~Opn_S) &&(closeHa(13) > openHa(13)) && (closeHa(12) > openHa(12)) && (closeHa(11) > openHa(11)) && (closeHa(10) > openHa(10)) && (closeHa(9) > openHa(9)) 
         && (closeHa(8) > openHa(8)) && (closeHa(7) > openHa(7)) && (closeHa(6) < openHa(6)) && (closeHa(5) < openHa(5)) && (closeHa(4) < openHa(4)) 
         && (closeHa(3) < openHa(3))&& (closeHa(2) < openHa(2)) && (closeHa(1) > openHa(1)) )
 {                                         
      //Print("5/7");
      double MinCand5[5];
      MinCand5[0]=minHa(2);
      MinCand5[1]=minHa(3);
      MinCand5[2]=minHa(4);
      MinCand5[3]=minHa(5);
      MinCand5[4]=minHa(6);
      
      ordercriteria = MinCand5[ArrayMinimum(MinCand5,WHOLE_ARRAY,0)];
      
      
      double S_L5[13]; //5+8
      for(i=0; i<=12;i++){
         S_L5[i]=maxHa(i+2);
      }
      StopLossL=S_L5[ArrayMaximum(S_L5,WHOLE_ARRAY,0)];
      //TakeProfitL=NormalizeDouble(Bid-(StopLossL-Bid),Digits);
       
      NumberBars=Bars;  
      Opn_S=true;                               // Criterion for opening Sell
      //Cls_B=true;                               // Criterion for closing Buy
      
 } 

 //Case 5: 6Cand Inversion trend and 7 candel initial trend up.
else if ((~Opn_S) &&(closeHa(14) > openHa(14)) && (closeHa(13) > openHa(13)) && (closeHa(12) > openHa(12)) && (closeHa(11) > openHa(11)) && (closeHa(10) > openHa(10))
          && (closeHa(9) > openHa(9)) && (closeHa(8) > openHa(8)) && (closeHa(7) < openHa(7)) && (closeHa(6) < openHa(6)) && (closeHa(5) < openHa(5)) 
          && (closeHa(4) < openHa(4)) && (closeHa(3) < openHa(3))&& (closeHa(2) < openHa(2)) && (closeHa(1) > openHa(1)) )
 {                                         
      
      //Print("6/7");
      double MinCand6[6];
      MinCand6[0]=minHa(2);
      MinCand6[1]=minHa(3);
      MinCand6[2]=minHa(4);
      MinCand6[3]=minHa(5);
      MinCand6[4]=minHa(6);
      MinCand6[5]=minHa(7);
            
      ordercriteria = MinCand6[ArrayMinimum(MinCand6,WHOLE_ARRAY,0)];
      
      
      double S_L6[14]; //6+8
      for(i=0; i<=13;i++){
         S_L6[i]=maxHa(i+2);
      }
      StopLossL=S_L6[ArrayMaximum(S_L6,WHOLE_ARRAY,0)];
      //TakeProfitL=NormalizeDouble(Bid-(StopLossL-Bid),Digits);
       
        
      Opn_S=true;                               // Criterion for opening Sell
      //Cls_B=true;                               // Criterion for closing Buy
      NumberBars=Bars;
 }

//Case 6: 7Cand Inversion trend and 7 candel initial trend up.
else if ((~Opn_S) && (closeHa(14) > openHa(14)) && (closeHa(13) > openHa(13)) && (closeHa(12) > openHa(12)) && (closeHa(11) > openHa(11)) && (closeHa(10) > openHa(10)) && (closeHa(9) > openHa(9)) && (closeHa(8) > openHa(8)) && (closeHa(7) < openHa(7)) && (closeHa(6) < openHa(6)) && (closeHa(5) < openHa(5)) && (closeHa(4) < openHa(4)) && (closeHa(3) < openHa(3))&& (closeHa(2) < openHa(2)) && (closeHa(1) > openHa(1)) )
 {                                         
      
      //Print("7/7");
      double MinCand7[7];
      MinCand7[0]=minHa(2);
      MinCand7[1]=minHa(3);
      MinCand7[2]=minHa(4);
      MinCand7[3]=minHa(5);
      MinCand7[4]=minHa(6);
      MinCand7[5]=minHa(7);
      MinCand7[6]=minHa(8);
            
      ordercriteria = MinCand7[ArrayMinimum(MinCand7,WHOLE_ARRAY,0)];
      
      
      double S_L7[15]; //7+8
      for(i=0; i<=14;i++){
         S_L7[i]=maxHa(i+2);
      }
      StopLossL=S_L7[ArrayMaximum(S_L7,WHOLE_ARRAY,0)];
      //TakeProfitL=NormalizeDouble(Bid-(StopLossL-Bid),Digits);
      
      NumberBars=Bars;  
      Opn_S=true;                               // Criterion for opening Sell
      //Cls_B=true;                               // Criterion for closing Buy
   }   
 
  
//--------------------------------------------------------------- 6 --

//--------------------------------------------------------------- 7 --
  // Order value
   RefreshRates();                              // Refresh rates
   Min_Lot=MarketInfo(Symb,MODE_MINLOT);        // Minimal number of lots 
   Free   =AccountFreeMargin();                 // Free margin
   One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);// Price of 1 lot
   Step   =MarketInfo(Symb,MODE_LOTSTEP);       // Step is changed

   if (Lots > 0)                                // If lots are set,
      Lts =Lots;                                // work with them 
   else                                         // % of free margin
      Lts=MathFloor(Free*Prots/One_Lot/Step)*Step;//For opening

   if(Lts < Min_Lot) Lts=Min_Lot;               // Not less than minimal
   if (Lts*One_Lot > Free)                      // Lot larger than free
     {
      Alert(" Not enough money for ", Lts," ëîòîâ");
      return;                                   // Exit start()
     }
//--------------------------------------------------------------- 8 --
   // Opening orders
   while(Opn_S)              // it will look for a position to take as long as Opn_S = TRUE
     {
        // Close while loop after some time 8 candels
        
        if (Bars>=(NumberBars+8) && Total==0){
        Alert("Bars=",Bars,"NumberBars=",NumberBars,". Looking for new criteria...");
        Opn_S=False;
        ordercriteria=0;
        return;
        NumberBars=0;
        };
               
             
        RefreshRates();
        
                    //first it check that we have no orders open(since the system acepts only one order at a time) and that we have a buy condition
                    
                    /*
                     if (Total==0 && Opn_B==true)              // No new orders +
                       {                                       // criterion for opening buy
                        RefreshRates();                        // Refresh rates
                        SL=Bid - New_Stop(StopLoss)*Point;     // Calculating SL of opened
                        TP=Bid + New_Stop(TakeProfit)*Point;   // Calculating TP of opened
                        Alert("Attempt to open Buy. Waiting for response..");
                        Ticket=OrderSend(Symb,OP_BUY,Lts,Ask,2,SL,TP);//Opening Buy
                        if (Ticket > 0)                        // Success :)
                          {
                           Alert ("Opened order Buy ",Ticket);
                           return;                             // Exit start()
                          }
                        if (Fun_Error(GetLastError())==1)      // Processing errors
                           continue;                           // Retrying
                        return;                                // Exit start()
                       }
                     */
                     
                     
                     
                     if (Total==0 && Opn_S==true && ordercriteria!=0)              // No opened orders + criterion for opening Sell
                       {
                       //ObjectCreate ("Arrow",OBJ_ARROW,0,TimeCurrent(),Bid-Point*80);
                       //ObjectSet ("Arrow",OBJPROP_COLOR,Green);
                       //ObjectSet ("Arrow",OBJPROP_BGCOLOR,Green);
                     
                       
                       RefreshRates();
                       Print("Bid= ",DoubleToString(Bid,5)," Min_ordercriteria=",DoubleToString(ordercriteria,5));
                                             
                       if (Bid <= ordercriteria)
                         { Print("Bid smaller than ordercriteria");
                                                                
                           RefreshRates();                        // Refresh rates
                           //StopLoss = 300*Point;
                           //TakeProfit = 300*Point;
                           //SL=Ask + StopLoss; //*Point;     // Calculating SL of opened
                           //TP=Ask - TakeProfit;//*Point;   // Calculating TP of opened
                           TakeProfitL=Bid-(StopLossL-Bid);
                           Print("StopLoss= ",DoubleToString(StopLossL,5),"TakeProfit= ",DoubleToString(TakeProfitL,5),"Bid= ","Bid= ",DoubleToString(Bid,5));
                                                      
                           Alert("Attempt to open Sell. Waiting for response..");
                           Ticket=OrderSend(Symb,OP_SELL,Lts,Bid,3,StopLossL,TakeProfitL,clrRed);//Opening Sell
                           if (Ticket > 0)                        // Success :)
                             {
                              Alert ("Opened order Sell ",Ticket);
                              Opn_S=false;                        // set the sell condition back to as it was, so that it can look for new conditions
                              ordercriteria=0;
                              return;                             // Exit start()
                             }
                           if (Fun_Error(GetLastError())==1)      // Processing errors
                              continue;                           // Retrying
                           return;                                // Exit start()
                         }
                       }
                       break;
                 }
          //else       break;                                    //Exit while
         
//--------------------------------------------------------------- 9 --
   return;                                      // Exit start()
  }
//-------------------------------------------------------------- 10 --
int Fun_Error(int Error)                        // Function of processing
  {
   switch(Error)
     {                                          // Not crucial errors           
      case  4: Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 135:Alert("Price changed. Trying once again..");
         RefreshRates();                        // Refresh rates
         return(1);                             // Exit the function
      case 136:Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)           // Till a new tick
            Sleep(1);                           // Pause in the loop
         return(1);                             // Exit the function
      case 137:Alert("Broker is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 146:Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                            // Simple solution
         return(1);                             // Exit the function
         // Critical errors
      case  2: Alert("Common error.");
         return(0);                             // Exit the function
      case  5: Alert("Old terminal version.");
         Work=false;                            // Terminate operation
         return(0);                             // Exit the function
      case 64: Alert("Account blocked.");
         Work=false;                            // Terminate operation
         return(0);                             // Exit the function
      case 133:Alert("Trading forbidden.");
         return(0);                             // Exit the function
      case 134:Alert("Not enough money to execute operation.");
         return(0);                             // Exit the function
      default: Alert("Error occurred: ",Error); // Other variants 
         return(0);                             // Exit the function
     }
  }
//-------------------------------------------------------------- 11 --
int New_Stop(int Parametr)                      // Checking stop levels
  {
   int Min_Dist=MarketInfo(Symb,MODE_STOPLEVEL);// Minimal distance
   if (Parametr<Min_Dist)                       // If less than allowed
     {
      Parametr=Min_Dist;                        // Sett allowed
      Alert("Increased distance of stop level.");
     }
   return(Parametr);                            // Returning value
  }
//-------------------------------------------------------------- 12 --

double closeHa(int h)
 {

double val=iCustom(NULL,0,"Heiken Ashi",3,h);
// Null if for attached symbol of terminal
// 0 Is for  timeframe of graph
// Then the name of the indicator
// Then you can add imput parameters of indicator if you want to change them. Eliminate like in my case if you dont want to change
// Line index
// h is the Shift 

return(val);

 }
 
 
 double openHa(int h)
 {

   double val=iCustom(NULL,0,"Heiken Ashi",2,h);

   return(val);
 }

 double maxHa(int h)
 {

   double val=iCustom(NULL,0,"Heiken Ashi",0,h);

   return(val);
 }

 double minHa(int h)
 {

   double val=iCustom(NULL,0,"Heiken Ashi",1,h);

   return(val);
 }
//-------------------------------------------------------------- 13 --