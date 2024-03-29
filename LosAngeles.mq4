//マイライブラリー
#include <MyLib.mqh>

//マジックナンバー
#define MAGIC 20094040
#define COMMENT "BBCross1"

//外部パラメータ
extern double Lots = 0.1;
extern double Slippage = 3;

//エントリー関数
extern int BBPeriod = 20; //BB期間
extern int BBDev = 2; //標準偏差
int EntrySignal(int magic)
{
   //オープンポジションの計算
   double pos = MyCurrentOrders(MY_OPENPOS, magic);
   
   //BBの計算
   double bbU1 = iBands(NULL, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bbL1 = iBands(NULL, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_LOWER,0);
   
   //MACDの計算
   double signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   double macd = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   
   //一目均衡表の計算
   double senkou1 = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANA, -26);
   double senkou2 = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANB, -26);
   
   int ret = 0;
   //買いシグナル
   if(pos<=0 && bbU1 < Close[0] && macd > signal && senkou1 > senkou2)
      ret = 1;
   //売りシグナル
   if(pos >= 0 && bbL1 > Close[0] && macd < signal && senkou1 < senkou2)
      ret = -1;
      
   return(ret);
}

//エクジット関数
int ExitSignal(int magic)
{
   //オープンポジションの計算
   double pos = MyCurrentOrders(MY_OPENPOS, magic);
   
   //BBの計算
   double bbU1 = iBands(NULL, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bbL1 = iBands(NULL, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_LOWER,0);
   
   //MACDの計算
   double signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   double macd = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   
   //一目均衡表の計算
   double senkou1 = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANA, -26);
   double senkou2 = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANB, -26);

   
   //決済シグナル
   int end = 0;
   //買い決済シグナル
   if(pos > 0 && macd < signal)
      end = 1;
      //売り決済シグナル
   if(pos < 0 && macd > signal)
      end = -1;
      
   return(end);

}

//注文送信関数
bool MyOrderSendSL(int type, double lots, double price, int slippage, int slpips, int tppips, string comment, int magic)
{
   int mult = 1;
   if(Digits == 3 || Digits == 5 ) mult = 10;
   slippage *= mult;
   if(type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) mult *= -1;
   
   double sl = 0, tp = 0;
   if(slpips > 0) sl = price-slpips*Point*mult;
   if(tppips > 0) tp = price+tppips*Point*mult;
   
   return(MyOrderSend(type, lots, price, slippage, sl, tp, comment, magic));
}

//スタート関数
int start()
{

   //エントリーシグナル
   int sig_entry = EntrySignal(MAGIC);
   
   //買い注文
   if(sig_entry > 0)
   {
      
      MyOrderSend(OP_BUY, Lots, Ask, Slippage, 0, 0, COMMENT, MAGIC);
      
   }
   //売り注文
   if(sig_entry < 0)
   {
      
      MyOrderSend(OP_SELL, Lots, Bid, Slippage, 0, 0, COMMENT, MAGIC);
   }
   
   //決済シグナル
   int sig_exit = ExitSignal(MAGIC);
   
   //決済注文
   if(sig_exit > 0)
   {
      MyOrderClose(Slippage, MAGIC);
   }
   
   if(sig_exit < 0)
   {
      MyOrderClose(Slippage, MAGIC);
   }
   
//   MyTrailingStop(TSPoint, MAGIC);   
    
      
   
   return(0);
}
   
   