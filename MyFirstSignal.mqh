//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Expert\ExpertSignal.mqh>
class FirstSignal : public CExpertSignal
  {
protected:
   CiMA              ma8_H4;           // object-oscillator
   CiMA              ma32_H4;
   CiMA              ma98_H4;
   CiMA              ma200_H4;
   CiStochastic      stoch;

   CiMA              ma8_M15;           // object-oscillator
   CiMA              ma32_M15;
   CiMA              ma98_M15;
   CiMA              ma200_M15;

   //--- adjusted parameters
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse of the oscillator to required direction"
   int               m_pattern_2;      // model 2 "crossing of main and signal line"
   int               m_pattern_3;      // model 3 "crossing of main line an the zero level"
   int               m_pattern_4;      // model 4 "divergence of the oscillator and price"
   int               m_pattern_5;      // model 5 "double divergence of the oscillator and price"
   //--- variables


public:
                     FirstSignal(void);
                    ~FirstSignal(void);
   //--- methods of setting adjustable parameters

   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)              { m_pattern_0 = value;             }
   void              Pattern_1(int value)              { m_pattern_1 = value;             }
   void              Pattern_2(int value)              { m_pattern_2 = value;             }
   void              Pattern_3(int value)              { m_pattern_3 = value;             }
   void              Pattern_4(int value)              { m_pattern_4 = value;             }
   void              Pattern_5(int value)              { m_pattern_5 = value;             }
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
   bool              CheckRowsMa();
   bool              CheckRowsMaShort();
   bool              CheckM15();
   bool              CheckM15Short();

   //virtual bool      CheckOpenLong(double &price, double &sl, double &tp, datetime &expiration);
   //virtual bool      CheckOpenShort(double &price, double &sl, double &tp, datetime &expiration);

protected:
   //--- method of initialization of the oscillator
   bool              InitFirstSignal(CIndicators *indicators);
   //bool              BreakOut(double priceLevel, bool isLong, int index);
   //--- methods of getting data
   double            MA_8_H4(int ind)                    { return(ma8_H4.Main(ind));}
   double            MA_32_H4(int ind)                   { return(ma32_H4.Main(ind));}
   double            MA_98_H4(int ind)                   { return(ma98_H4.Main(ind));}
   double            MA_200_H4(int ind)                  { return(ma200_H4.Main(ind));}
   double            Stoch(int ind)                   { return(stoch.Main(ind));}
   double            MA_8_M15(int ind)                    { return(ma8_M15.Main(ind));}
   double            MA_32_M15(int ind)                   { return(ma32_M15.Main(ind));}
   double            MA_98_M15(int ind)                   { return(ma98_M15.Main(ind));}
   double            MA_200_M15(int ind)                  { return(ma200_M15.Main(ind));}
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
FirstSignal::FirstSignal(void) :
   m_pattern_0(10),
   m_pattern_1(30),
   m_pattern_2(80),
   m_pattern_3(50),
   m_pattern_4(50),
   m_pattern_5(100)
  {
//--- initialization of protected data
   m_used_series = USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE + USE_SERIES_OPEN;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
FirstSignal::~FirstSignal(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool FirstSignal::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool FirstSignal::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MACD oscilator
   if(!InitFirstSignal(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MACD oscillators.                                     |
//+------------------------------------------------------------------+
bool FirstSignal::InitFirstSignal(CIndicators *indicators)
  {
//--- add object to collection
   ENUM_TIMEFRAMES _tf = PERIOD_H4;
   ENUM_TIMEFRAMES _tf2 = PERIOD_M15;

   if(!indicators.Add(GetPointer(ma8_H4)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(stoch)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma32_H4)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma98_H4)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma200_H4)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }

//===============================================
   if(!indicators.Add(GetPointer(ma8_M15)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma32_M15)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma98_M15)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma200_M15)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
//==================================================
//--- initialize object

   if(!ma8_H4.Create(m_symbol.Name(), _tf, 8, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma32_H4.Create(m_symbol.Name(), _tf, 32, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma98_H4.Create(m_symbol.Name(), _tf, 98, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma200_H4.Create(m_symbol.Name(), _tf, 200, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!stoch.Create(m_symbol.Name(), _tf2, 5, 3, 3, MODE_SMA, STO_LOWHIGH))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
//==========================================================================

   if(!ma8_M15.Create(m_symbol.Name(), _tf2, 9, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma32_M15.Create(m_symbol.Name(), _tf2, 20, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma98_M15.Create(m_symbol.Name(), _tf2, 98, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma200_M15.Create(m_symbol.Name(), _tf2, 200, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }

//==========================================================================
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int FirstSignal::LongCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(4) && CheckRowsMa() && CheckM15())
     {
      result = m_pattern_4;
     }
   return result;
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int FirstSignal::ShortCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(4) && CheckRowsMaShort() && CheckM15Short())
     {
      result = m_pattern_4;
     }
   return result;
  }

//****************************************************************************************************************
//================================================================================================================

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FirstSignal::CheckRowsMaShort(void)
  {
   ma8_H4.Refresh();
   ma32_H4.Refresh();
   ma98_H4.Refresh();
   ma200_H4.Refresh();
   stoch.Refresh();
   int idx = StartIndex();
   for(int i = 1; i < 3; i++)
      if((MA_8_H4(idx + i) > MA_32_H4(idx) || MA_32_H4(idx + i) > MA_98_H4(idx + i) /*|| MA_98_H4(idx + i) > MA_200_H4(idx + i) */|| Close(idx + 1) > MA_8_H4(idx + 1)))
         return false;
   return true;
  }
//+------------------------------------------------------------------+
bool FirstSignal::CheckRowsMa(void)
  {
   ma8_H4.Refresh();
   ma32_H4.Refresh();
   ma98_H4.Refresh();
   ma200_H4.Refresh();
   int idx = StartIndex();
   for(int i = 1; i < 3; i++)
      if((MA_8_H4(idx + i) < MA_32_H4(idx) || MA_32_H4(idx + i) < MA_98_H4(idx + i) /*|| MA_98_H4(idx + i) < MA_200_H4(idx + i) */|| Close(idx + 1) < MA_8_H4(idx + 1)))
         return false;
   return true;
  }
//+------------------------------------------------------------------+
bool FirstSignal::CheckM15(void)
  {
   ma8_H4.Refresh();
   ma32_H4.Refresh();
   ma98_H4.Refresh();
   ma200_H4.Refresh();
   stoch.Refresh();
   int idx = StartIndex();
//if(Stoch(idx + 1) > 20 && Stoch(idx) > 20)
//   return false;
   for(int i = 1; i < 4; i++)
      if(MA_200_M15(idx + 1) > MA_98_M15(idx + 1))
         return false;
   if(MA_8_M15(idx + 1) > MA_32_M15(idx + 1) && MA_8_M15(idx + 2) > MA_32_M15(idx + 2))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
bool FirstSignal::CheckM15Short(void)
  {
   ma8_H4.Refresh();
   ma32_H4.Refresh();
   ma98_H4.Refresh();
   ma200_H4.Refresh();
   stoch.Refresh();
   int idx = StartIndex();
//if(Stoch(idx+1) < 80 && Stoch(idx) < 80)
//   return false;
//for(int i = 1; i < 9; i++)
//   if(MA_200_M15(idx+1) < MA_98_M15(idx+1) || MA_98_M15(idx+1) < MA_32_M15(idx+1))
//     return false;
   for(int i = 1; i < 4; i++)
      if(MA_200_M15(idx + 1) < MA_98_M15(idx + 1))
         return false;
   if(MA_8_M15(idx + 1) < MA_32_M15(idx + 1) && MA_8_M15(idx + 2) < MA_32_M15(idx + 2))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
