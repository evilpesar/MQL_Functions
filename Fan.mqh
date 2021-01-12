//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_INIT_PHASE
  {
   INIT_PHASE_FIRST      = 0,          // start phase (only Init(...) can be called)
   INIT_PHASE_TUNING     = 1,          // phase of tuning (set in Init(...))
   INIT_PHASE_VALIDATION = 2,          // phase of checking of parameters(set in ValidationSettings(...))
   INIT_PHASE_COMPLETE   = 3           // end phase (set in InitIndicators(...))
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class line
  {
protected:
   ENUM_INIT_PHASE   init_phase;
   double            toe_price;
   double            center_price;
   datetime          toe_date;
   datetime          center_date;
   double            TiltCalculate();
   ENUM_TIMEFRAMES   timeframe;
public:
   void              Init();
   double            GetPrice(int bar);
   double            Get618(int bar);
   double            Get382(int bar);
   double            Get500(int bar);
   double            GetToePrice()                          { return toe_price;                 } // return left corner bar number
   double            GetCenterPrice()                       { return center_price;              } // return right corner bar number
   int               FirstBarOftheDay();
   bool              SetParammeters(double ToePrice, double CenterPrice, datetime ToeDate, datetime CenterDate, ENUM_TIMEFRAMES tf);

                     line(void);
                    ~line(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void line::line(void) : toe_price(0.0),
   center_price(0.0),
   toe_date(NULL),
   center_date(NULL),
   timeframe(PERIOD_H1)

  {
   init_phase = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void line::~line(void) {}
//+------------------------------------------------------------------+
int line::FirstBarOftheDay(void)
  {
   datetime now = iTime(_Symbol, timeframe, 0);
   datetime temp = now - (now % 86400);
   int fbd = iBarShift(_Symbol, timeframe, temp);
   return fbd;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool line::SetParammeters(double ToePrice, double CenterPrice, datetime ToeDate, datetime CenterDate, ENUM_TIMEFRAMES tf)
  {
   if(ToePrice == 0.0)
     {
      Print(__FUNCTION__, ": wrong ToePrice");
      return false;
     }
   if(CenterPrice == 0.0)
     {
      Print(__FUNCTION__, ": wrong CenterPrice");
      return false;
     }
   if(CenterDate == NULL)
     {
      Print(__FUNCTION__, ": wrong CenterDate");
      return false;
     }
   if(ToeDate == NULL)
     {
      Print(__FUNCTION__, ": wrong ToeDate");
      return false;
     }
   toe_price = ToePrice ;
   center_price = CenterPrice;
   toe_date = ToeDate;
   center_date = CenterDate;
   init_phase = 1;
   timeframe = tf;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void line::Init(void)
  {
   if(init_phase != 0)
      return;
   timeframe = PERIOD_H1;
   int h , l;
   int firsBarOfTheDay = FirstBarOftheDay();
   l = iLowest(_Symbol,0,MODE_LOW,23,firsBarOfTheDay);
   h = iHighest(_Symbol,0,MODE_HIGH,23,firsBarOfTheDay);
   double lowest_price = iLow(_Symbol,0,l);
   double highest_price = iHigh(_Symbol,0,h);
   datetime high_time = iTime(_Symbol,0,h);
   datetime low_time = iTime(_Symbol,0,l);
   double high_candle_0 = iHigh(_Symbol,0,firsBarOfTheDay);
   double low_candle_0 = iLow(_Symbol,0,firsBarOfTheDay);
   datetime date_candle_0 = iTime(_Symbol,0,firsBarOfTheDay);
   Print("Candle number ",firsBarOfTheDay," is the first candle of the day");
   Print("Highest price of these day is  ",highest_price);
   Print("low the first candle of the day is equal ",low_candle_0);
   if(!SetParammeters(highest_price,low_candle_0,high_time,date_candle_0,PERIOD_H1))
      Print("cant set parameters");
   Print("its here");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double line::TiltCalculate(void)
  {
   if(init_phase == 0)
     {
      Print(__FUNCTION__, " : You did not set Parameters");
      return 100000;
     }
   double y = toe_price - center_price;
   double x = iBarShift(_Symbol, timeframe, toe_date) - iBarShift(_Symbol, timeframe, center_date);
//Print(y/x);
   return (y / x);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double line::GetPrice(int bar)
  {
   if(init_phase == 0)
     {
      Print(__FUNCTION__, " : You did not set Parameters");
      return 0.0;
     }
   double x = iBarShift(_Symbol, timeframe, toe_date) - bar;
   double y1 = toe_price;
   double y2 =  y1 - (TiltCalculate() * x);
   return y2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double line::Get618(int bar)
  {
   if(init_phase == 0)
     {
      Print(__FUNCTION__, " : You did not set Parameters");
      return 0.0;
     }
   double x = iBarShift(_Symbol, timeframe, toe_date) - bar;
   double y1 = toe_price;
   double y2 =  y1 - (TiltCalculate() * x * 0.382);
   return y2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double line::Get382(int bar)
  {
   if(init_phase == 0)
     {
      Print(__FUNCTION__, " : You did not set Parameters");
      return 0.0;
     }
   double x = iBarShift(_Symbol, timeframe, toe_date) - bar;
   double y1 = toe_price;
   double y2 =  y1 - (TiltCalculate() * x * 0.618);
   return y2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double line::Get500(int bar)
  {
   if(init_phase == 0)
     {
      Print(__FUNCTION__, " : You did not set Parameters");
      return 0.0;
     }
   double x = iBarShift(_Symbol, timeframe, toe_date) - bar;
   double y1 = toe_price;
   double y2 =  y1 - (TiltCalculate() * x * 0.5);
   return y2;
  }
//+------------------------------------------------------------------+
