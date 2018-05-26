

//+------------------------------------------------------------------+
//|                                     Moving avg strategy test.mq4 |
//|                                                          Isildur |
//+------------------------------------------------------------------+

extern int P_Long = 244;
extern int P_Short = 50;

extern int nr_buy = 0;
extern int nr_sell = 0;

extern int Order_sell_ticked;
extern int Order_buy_ticked;

void OnTick(){

//--------------------------------------------------------------- 2 --Orders accounting
int Total = nr_buy + nr_sell;
string Symb = Symbol();
//---------------------------------------------------------------------------------------


   bool goLong = False;
   bool goShort = False;
   //int Order_sell_ticked;
   //int Order_buy_ticked;


   double movingavgL = iMA(NULL,0,P_Long,0,MODE_SMA,PRICE_CLOSE,1);
   double movingavgS = iMA(NULL,0,P_Short,0,MODE_SMA,PRICE_CLOSE,1);
   if(movingavgS>movingavgL){
      goLong = True;
      goShort = False;
      }
   else {
      goLong = False;
      goShort = True;
      }
      
   while(goLong){
      if(nr_sell==1){
            bool resS;
            resS = OrderClose(Order_sell_ticked, 1.0, Ask, 30, clrRed ); 
            nr_sell--;
            if(resS){
               Alert("Order Sell closed.");
               }
            else Alert("Cant close sell!"); 
       }
      if(nr_buy<1){
         Order_buy_ticked = OrderSend(Symb,OP_BUY,1.0,Ask,2,Ask-(900000*Point),Ask+(900000*Point));
         nr_buy++;
         Total = nr_sell + nr_buy;
         if(Order_buy_ticked<0) { 
            Alert("OrderSend_buy failed with error #",GetLastError()); 
            } 
         else {
            Alert("OrderSend_buy placed successfully");
            //Alert("Number of sell/Total/buy is: ", nr_sell,"/",Total,"/",nr_buy);
            //Alert("avgL/avgS: ",movingavgL,"/",movingavgS);
            
            }
         }
       break;
      }
   
   while(goShort){
      if(nr_buy==1){
            bool resB;
            resB = OrderClose(Order_buy_ticked, 1.0, Bid, 30, clrRed ); 
            nr_buy--;
            if(resB){
              Alert("Order Buy closed.");
              }
            else Alert("Cant close Buy!");  
            
       }
      if(nr_sell<1){
         Order_sell_ticked = OrderSend(Symb,OP_SELL, 1.0, Bid, 4,Bid+(900000*Point),Bid-(900000*Point));
         nr_sell++;
         Total = nr_sell + nr_buy;
         if(Order_sell_ticked<0) { 
            Alert("OrderSend_sell failed with error #",GetLastError()); 
            } 
         else {
            Alert("OrderSend_sell placed successfully");
            //Alert("Number of sell/Total/buy is: ", nr_sell,"/",Total,"/",nr_buy);
            //Alert("avgL/avgS: ",movingavgL,"/",movingavgS);
            } 
         }
    break;
   }
return;
}


