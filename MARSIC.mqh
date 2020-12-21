//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Expert\ExpertSignal.mqh>
class Marsic : public CExpertSignal
  {
protected:

   CiMACD            m_MACD;
   CiRSI             m_RSI;
   CiIchimoku        m_Ichi;

   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse of the oscillator to required direction"
   int               m_pattern_2;      // model 2 "crossing of main and signal line"
   int               m_pattern_3;      // model 3 "crossing of main line an the zero level"
   int               m_pattern_4;      // model 4 "divergence of the oscillator and price"
   int               m_pattern_5;      // model 5 "double divergence of the oscillator and price"
   //--- variables


public:
                     Marsic(void);
                    ~Marsic(void);
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

   //virtual bool      CheckOpenLong(double &price, double &sl, double &tp, datetime &expiration);
   //virtual bool      CheckOpenShort(double &price, double &sl, double &tp, datetime &expiration);

protected:
   bool              InitMarsic(CIndicators *indicators);

   // ================================ Ichimoko Functions =============================================
   double            Kijunsen(int ind)                   { return(m_ichi.KijunSen(ind));           }
   double            Tenkansen(int ind)                  { return(m_ichi.TenkanSen(ind));          }
   double            DiffIchi(int ind)                   { return(Kijunsen(ind) - Tenkansen(ind)); }
   
   //================================= MACD Functions=================================================
   double            MainMACD(int ind)                   { return(m_MACD.Main(ind));               }
   double            SignalMACD(int ind)                 { return(m_MACD.Signal(ind));             }
   double            DiffMainMACD(int ind)               { return(Main(ind) - Main(ind + 1));      }
   double            DiffSignalMACD(int ind)             { return(SignalMACD(ind) - MainMACD(ind));}
   //================================= RSI  Functions ================================================
   double            MainRSI(int ind)                    { return(m_RSI.Main(ind);                 }
   bool              RSICondition(int ind)               { return((MainRSI(ind)>50?(true):(false));} //if RSI > 50 return true
  };
  
  
// ============================== Constructor ====================================================
Marsic::Marsic(void) :
   m_pattern_0(10),
   m_pattern_1(30),
   m_pattern_2(80),
   m_pattern_3(50),
   m_pattern_4(50),
   m_pattern_5(100)
  {
   m_used_series = USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE + USE_SERIES_OPEN;
  }
  
  
// ================================ Destructor ====================================================
Marsic::~Marsic(void)
  {
  }
//================================== ValidationSettings ============================================
bool Marsic::ValidationSettings(void)
  {
   if(!CExpertSignal::ValidationSettings())
      return(false);
   return(true);
  }


//================================== Create Indicators ==============================================
bool Marsic::InitIndicators(CIndicators *indicators)
  {
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
   if(!InitMarsic(indicators))
      return(false);
   return(true);
  }
// =================================== Initializiation Indicators ===================================
bool Marsic::InitMarsic(CIndicators *indicators)
  {
   if(!indicators.Add(GetPointer(m_Ichi)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(m_RSI)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
   if(!indicators.Add(GetPointer(m_MACD)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
      //*********************************************************

   if(!m_Ichi.Create(m_symbol.Name(), m_period,9,26,52))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!m_MACD.Create(m_symbol.Name(),m_period,12,26,9,MODE_CLOSE))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   if(!m_RSI.Create(m_symbol.Name(),m_period,14,MODE_CLOSE));
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   return(true);
  }

//===================================== LongCondition ========================================
int Marsic::LongCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(4))
     {
      result = m_pattern_4;
     }
   return result;
  }
//===================================== ShortCondition ========================================
int Marsic::ShortCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(4))
     {
      result = m_pattern_4;
     }
   return result;
  }


