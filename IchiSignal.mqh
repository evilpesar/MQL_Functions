//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Expert\ExpertSignal.mqh>
class IchiSignal : public CExpertSignal
  {
protected:
   CiIchimoku        m_Ichi;

   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse of the oscillator to required direction"
public:
                     IchiSignal(void);
                    ~IchiSignal(void);
   void              Pattern_0(int value)              { m_pattern_0 = value;             }
   void              Pattern_1(int value)              { m_pattern_1 = value;             }
   virtual bool      ValidationSettings(void);
   virtual bool      InitIndicators(CIndicators *indicators);
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   bool              InitIchiSignal(CIndicators *indicators);

   // ================================ Ichimoko Functions =============================================
   double            Kijunsen(int ind)                   { return(m_Ichi.KijunSen(ind));           }
   double            Tenkansen(int ind)                  { return(m_Ichi.TenkanSen(ind));          }
   double            DiffIchi(int ind)                   { return(Kijunsen(ind) - Tenkansen(ind)); }
   double            Chiko(int ind)                      { return(m_Ichi.ChinkouSpan(ind));        }
   double            SenkoA(int ind)                     { return(m_Ichi.SenkouSpanA(ind));        }
   double            SenkoB(int ind)                     { return(m_Ichi.SenkouSpanB(ind));        }

   bool              PriceBreakKumo(int index, bool isLong);
   bool              BreakOut(double priceLevel, bool isLong, int index);
   bool              ConditionLong();
   bool              ConditionShort();

  };


// ============================== Constructor ====================================================
IchiSignal::IchiSignal(void) :
   m_pattern_0(10),
   m_pattern_1(30)
  {
   m_used_series = USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE + USE_SERIES_OPEN;
  }


// ================================ Destructor ====================================================
IchiSignal::~IchiSignal(void)
  {
  }
//================================== ValidationSettings ============================================
bool IchiSignal::ValidationSettings(void)
  {
   if(!CExpertSignal::ValidationSettings())
      return(false);
   return(true);
  }


//================================== Create Indicators ==============================================
bool IchiSignal::InitIndicators(CIndicators *indicators)
  {
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
   if(!InitIchiSignal(indicators))
      return(false);
   return(true);
  }
// =================================== Initializiation Indicators ===================================
bool IchiSignal::InitIchiSignal(CIndicators *indicators)
  {
   if(!indicators.Add(GetPointer(m_Ichi)))
     {
      printf(__FUNCTION__ + ": error adding object");
      return(false);
     }
//*********************************************************

   if(!m_Ichi.Create(m_symbol.Name(), m_period, 9, 26, 52))
     {
      printf(__FUNCTION__ + ": error initializing object");
      return(false);
     }
   return(true);
  }

//===================================== LongCondition ========================================
int IchiSignal::LongCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(0) && ConditionLong())
     {
      result = m_pattern_0;

      Print("Result ichi long =", result);
     }
   return result;
  }
//===================================== ShortCondition ========================================
int IchiSignal::ShortCondition(void)
  {
   int result = 0;
   if(IS_PATTERN_USAGE(0) && ConditionShort())
     {
      result = m_pattern_0;

      Print("Result ichi short =", result);
     }
   return result;
  }

// ===================================================================================================
bool IchiSignal::ConditionLong(void)
  {
   m_Ichi.Refresh();
   int idx = StartIndex();
   if(DiffIchi(idx) > 0)
      return false;
   if(PriceBreakKumo(idx, true))
      return false;
//for(int i = idx; i < 7; i++) // we should have a cross in late  7 bars
//   if(DiffIchi(i) < 0 && DiffIchi(i + 1) >= 0)
//     {
//      return true;
//      Print("Ichi Long OK");
//     }
   return true;
  }
// ====================================================================================================
bool IchiSignal::ConditionShort(void)
  {
   m_Ichi.Refresh();
   int idx = StartIndex();
   if(DiffIchi(idx) < 0)
      return false;
   if(PriceBreakKumo(idx, false))
      return false;
   return true;
//for(int i = idx; i < 7; i++) // we should have a cross in late  7 bars
//   if(DiffIchi(i) > 0 && DiffIchi(i + 1) <= 0)
//     {
//      return true;
//      Print("Ichi Short OK");
//     }
//return false;
  }
//+------------------------------------------------------------------+
bool IchiSignal :: PriceBreakKumo(int index, bool isLong)
  {
   double senkA               = SenkoA(index);
   double senkB               = SenkoB(index);
   double price               = Close(index);
   if(isLong)
     {
      if(senkA > senkB)
         return false;
      if(BreakOut(senkB, true, index))
         return true;
      //if(Colse(index) > SenkoB(index) && Close(index + 1) > SenkoB(index + 1))
      //   return true;
      return false;
     }
   else
     {
      if(senkA < senkB)
         return false;
      if(BreakOut(senkB, false, index))
         return true;
      return false;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IchiSignal::BreakOut(double priceLevel, bool isLong, int index) // it returns the pricelevel Breakout
  {
   double closeBar1         = Close(index);
   double openBar1          = Open(index);
   double closeBar2         = Close(index + 1);
   double body   = MathAbs(closeBar1 - openBar1) / 2;
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
