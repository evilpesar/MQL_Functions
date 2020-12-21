//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Expert\ExpertSignal.mqh>
class MACDSignal : public CExpertSignal
  {
protected:

   CiMACD            m_MACD;

   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse of the oscillator to required direction"

public:
                     MACDSignal(void);
                    ~MACDSignal(void);
   void              Pattern_0(int value)              { m_pattern_0 = value;             }
   void              Pattern_1(int value)              { m_pattern_1 = value;             }

   virtual bool      ValidationSettings(void);
   virtual bool      InitIndicators(CIndicators *indicators);
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);


protected:
   bool              InitMACDSignal(CIndicators *indicators);
   //================================= MACD Functions=================================================
   double            Main(int ind)                   { return(m_MACD.Main(ind));               }
   double            Signal(int ind)                 { return(m_MACD.Signal(ind));             }
   double            DiffMain(int ind)               { return(Main(ind) - Main(ind + 1));      }
   double            DiffMainSignal(int ind)         { return(Main(ind) - Signal(ind));}
   bool              ConditionLong();
   bool              ConditionShort();
  };


// ============================== Constructor ====================================================
MACDSignal::MACDSignal(void) :
   m_pattern_0(10),
   m_pattern_1(30)
  {
   m_used_series = USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE + USE_SERIES_OPEN;
  }


// ================================ Destructor ====================================================
MACDSignal::~MACDSignal(void)
  {
  }
//================================== ValidationSettings ============================================
bool MACDSignal::ValidationSettings(void)
  {
   if(!CExpertSignal::ValidationSettings())
      return(false);
   return(true);
  }


//================================== Create Indicators ==============================================
bool MACDSignal::InitIndicators(CIndicators *indicators)
  {
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
   if(!InitMACDSignal(indicators))
      return(false);
   return(true);
  }
// =================================== Initializiation Indicators ===================================
bool MACDSignal::InitMACDSignal(CIndicators *indicators)
  {
   if(!indicators.Add(GetPointer(m_MACD)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
//*********************************************************
   if(!m_MACD.Create(m_symbol.Name(), m_period, 12, 26, 9, MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   return(true);
  }

//===================================== LongCondition ========================================
int MACDSignal::LongCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(0) && ConditionLong())
     {
      result = m_pattern_0;
      Print("MACD long = ", result);
     }
   return result;
  }
//===================================== ShortCondition ========================================
int MACDSignal::ShortCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(0) && ConditionShort())
     {
      result = m_pattern_0;
      Print("MACD short = ", result);
     }
   return result;
  }
//===================================== LongCondition ========================================
bool MACDSignal::ConditionLong(void)
  {
   m_MACD.Refresh();
   int idx = StartIndex();
   if(Signal(idx) > Main(idx))
      return false;
   if(Main(idx) < 0)
      return false;
   return true;
//for(int i = idx; i < 7; i++) // we should have a MACD change phase in late  7 bars
//   if(Main(i) > 0 && Main(i + 1) < 0)
//     {
//      return true;
//      Print("MACD Long OK");
//     }
//return false;
  }
//===================================== ShortCondition ========================================
bool MACDSignal::ConditionShort(void)
  {
   m_MACD.Refresh();
   int idx = StartIndex();
   if(Signal(idx) < Main(idx))
      return false;
   if(Main(idx) > 0)
      return false;
   return true;
//for(int i = idx; i < 7; i++) // we should have a MACD change phase in late  7 bars
//   if(Main(i) < 0 && Main(i + 1) > 0)
//     {
//      return true;
//      Print("MACD Short OK");
//     }
//return false;
  }
//+------------------------------------------------------------------+
