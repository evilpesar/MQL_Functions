//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Expert\ExpertSignal.mqh>
class RSISignal : public CExpertSignal
  {
protected:
   CiRSI             m_RSI;
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   
public:
                     RSISignal(void);
                    ~RSISignal(void);
   void              Pattern_0(int value)              { m_pattern_0 = value;             }
   virtual bool      ValidationSettings(void);
   virtual bool      InitIndicators(CIndicators *indicators);
   
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   bool              InitRSISignal(CIndicators *indicators);

   //******************************* RSI  Functions **********************************************
   double            MainRSI(int ind)                    { return(m_RSI.Main(ind));                 }
   bool              RSICondition(int ind)               { return((MainRSI(ind)>50?(true):(false)));} //if RSI > 50 return true
  };
  
  
// ============================== Constructor ====================================================
RSISignal::RSISignal(void) :
   m_pattern_0(10)
  {
   m_used_series = USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE + USE_SERIES_OPEN;
  }
  
  
// ================================ Destructor ====================================================
RSISignal::~RSISignal(void)
  {
  }
//================================== ValidationSettings ============================================
bool RSISignal::ValidationSettings(void)
  {
   if(!CExpertSignal::ValidationSettings())
      return(false);
   return(true);
  }


//================================== Create Indicators ==============================================
bool RSISignal::InitIndicators(CIndicators *indicators)
  {
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
   if(!InitRSISignal(indicators))
      return(false);
   return(true);
  }
// =================================== Initializiation Indicators ===================================
bool RSISignal::InitRSISignal(CIndicators *indicators)
  {

   if(!indicators.Add(GetPointer(m_RSI)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
      //*********************************************************
   if(!m_RSI.Create(m_symbol.Name(),m_period,14,MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   return(true);
  }

//===================================== LongCondition ========================================
int RSISignal::LongCondition(void)
  {
   int result = 0;
   int idx = StartIndex();
   if(IS_PATTERN_USAGE(0) && RSICondition(idx))
     {
      result = m_pattern_0;
     }
   return result;
  }
//===================================== ShortCondition ========================================
int RSISignal::ShortCondition(void)
  {
   int result = 0;
   int idx = StartIndex();
   if(IS_PATTERN_USAGE(0) && !RSICondition(idx))
     {
      result = m_pattern_0;
     }
   return result;
  }


