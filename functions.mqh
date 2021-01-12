//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//|          Newbar                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);
   if(last_time==0)
     {
      last_time=lastbar_time;
      return(false);
     }
   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//|           newbar with special timeframe                          |
//+------------------------------------------------------------------+
bool isNewBar(ENUM_TIMEFRAMES tf)
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),tf,SERIES_LASTBAR_DATE);
   if(last_time==0)
     {
      last_time=lastbar_time;
      return(false);
     }
   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| if price breakout priceleve, isLong is for uptrend    |
//+------------------------------------------------------------------+
bool BreakOut(double priceLevel, bool isLong, int index,ENUM_TIMEFRAMES timeframe) // it returns the pricelevel Breakout
  {

   double closeBar1         = iClose(_Symbol,timeframe,index);
   double openBar1          = iOpen(_Symbol,timeframe,index);
   double closeBar2         = iClose(_Symbol,timeframe,index+1);
   double body              = MathAbs(closeBar1 - openBar1) / 2;
   if(isLong)
     {
      double state   = (closeBar1 > openBar1) ? (body + openBar1) : (0);

      if(state  > priceLevel && state != 0)
        {
         return true;
        }
      if(closeBar2 < priceLevel)
         return false;
      if(closeBar1 < priceLevel)
         return false;
      return true;
     }
   if(!isLong)
     {
      double state   = (closeBar1 < openBar1) ? (openBar1 - body) : (0);

      if(state  < priceLevel && state != 0)
        {
         return true;
        }
      if(closeBar2 > priceLevel)
         return false;
      if(closeBar1 > priceLevel)
         return false;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
