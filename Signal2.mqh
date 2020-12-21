//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Expert\ExpertSignal.mqh>
class Signal2 : public CExpertSignal
  {
protected:
   CiMA              ma8;           // object-oscillator
   CiMA              ma32;
   CiMA              ma98;
   CiMA              ma200;
   CiStochastic      stoch;
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
                     Signal2(void);
                    ~Signal2(void);
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
   //virtual bool      CheckOpenLong(double &price, double &sl, double &tp, datetime &expiration);
   //virtual bool      CheckOpenShort(double &price, double &sl, double &tp, datetime &expiration);

protected:
   //--- method of initialization of the oscillator
   bool              InitSignal2(CIndicators *indicators);
   //bool              BreakOut(double priceLevel, bool isLong, int index);
   //--- methods of getting data
   double            MA_8(int ind)                    { return(ma8.Main(ind));}
   double            MA_32(int ind)                   { return(ma32.Main(ind));}
   double            MA_98(int ind)                   { return(ma98.Main(ind));}
   double            MA_200(int ind)                  { return(ma200.Main(ind));}
   double            Stoch(int ind)                   { return(stoch.Main(ind));}


  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
Signal2::Signal2(void) :
   m_pattern_0(10),
   m_pattern_1(30),
   m_pattern_2(80),
   m_pattern_3(50),
   m_pattern_4(24),
   m_pattern_5(100)
  {
//--- initialization of protected data
   m_used_series = USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE + USE_SERIES_OPEN;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
Signal2::~Signal2(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool Signal2::ValidationSettings(void)
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
bool Signal2::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MACD oscilator
   if(!InitSignal2(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MACD oscillators.                                     |
//+------------------------------------------------------------------+
bool Signal2::InitSignal2(CIndicators *indicators)
  {
//--- add object to collection
   ENUM_TIMEFRAMES _tf = PERIOD_M15;
   if(!indicators.Add(GetPointer(stoch)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma8)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma32)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma98)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(ma200)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
//--- initialize object

   if(!ma8.Create(m_symbol.Name(), _tf, 8, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma32.Create(m_symbol.Name(), _tf, 32, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma98.Create(m_symbol.Name(), _tf, 98, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!ma200.Create(m_symbol.Name(), _tf, 200, 0, MODE_EMA, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!stoch.Create(m_symbol.Name(), _tf, 5, 3, 3, MODE_SMA, STO_LOWHIGH))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int Signal2::LongCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(4) && CheckRowsMa())
     {
      result = m_pattern_4;
     }
   return result;
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int Signal2::ShortCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(4) && CheckRowsMaShort())
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
bool Signal2::CheckRowsMaShort(void)
  {
   ma8.Refresh();
   ma32.Refresh();
   ma98.Refresh();
   ma200.Refresh();
   stoch.Refresh();
   int idx = StartIndex();
   if(MA_8(idx) < MA_32(idx) && MA_32(idx) < MA_98(idx) && MA_98(idx) < MA_200(idx) && Stoch(idx) > 80)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool Signal2::CheckRowsMa(void)
  {
   ma8.Refresh();
   ma32.Refresh();
   ma98.Refresh();
   ma200.Refresh();
   stoch.Refresh();
   int idx = StartIndex();
   if(MA_8(idx) > MA_32(idx) && MA_32(idx) > MA_98(idx) && MA_98(idx) > MA_200(idx) && Stoch(idx) < 20)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
