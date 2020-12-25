//===================================================================================================================================
//===================================================================================================================================
//===================================================================================================================================
//==================================               Class Trendline            =======================================================
//===================================================================================================================================
//===================================================================================================================================
#include <ChartObjects\ChartObjectsLines.mqh>
#include <MyFiles\Zigzag.mqh>
#include <Indicators\Oscilators.mqh>
class TrendLine  // For use this Class u need to set [Set_Toe_Center()] function and then use [Create()],[Set_ZigZag_Params()] functions
  {
protected:
   CChartObjectTrend my_trend ;
   int               m_toe_bar;
   int               m_center_bar;
   datetime          date_toe;
   datetime          date_center;
   double            m_value;
   bool              is_ascending;
   int               z_depth;
   int               z_dev;
   int               z_stp;
   int               z_toe;
   int               z_center;
   string            trnd_name;

   CZigZag           m_zigzag;
   CiATR             m_atr;
   bool              BreakOut(double priceLevel, int index) ;
public:

   //                Setting Parameters of Zigzag
   void              Set_ZigZag_Params(int depth, int deviation, int backsteps)   { z_depth = depth; z_dev = deviation;  z_stp = backsteps;  }
   void              Set_Toe_Center(int center, int toe)   { z_toe = toe; z_center = center;   } // This function Sets which extermums u want to select to use for trendline
   //                Get Params
   int               GetToeBar()                            { return m_toe_bar;                 } // return left corner bar number
   int               GetCenterBar()                         { return m_center_bar;              } // return right corner bar number
   double            GetToePrice()                          { return Value(m_toe_bar);          } // return left corner bar price 
   double            GetCenterPrice()                       { return Value(m_center_bar);       } // return right corner bar price 
   double            Value();       //---------------------------------------------------------------return the current value of trendline
   double            Value(int bar);//---------------------------------------------------------------return the  value of trendline in specific place
   
   void              OptimizedPoints();
   
   bool              Create(int startBar, int secondBar); //First we should init Class with 2 point of Trend Line
   void              Create();                            // Init trendline based on toe and center 
   bool              Create(datetime startDate, datetime secondDate); //First we should init Class with 2 point of Trend Line

   void              Extend();
   void              Draw();                               //Draw the line

   void              Refresh();                             //Refresh the points
                     TrendLine(void);
                    ~TrendLine(void);
  };
//========================================================================
TrendLine::TrendLine(void): z_depth(12), z_dev(5), z_stp(3), z_toe(1), z_center(3)
  {

  }
//========================================================================
TrendLine::~TrendLine(void)
  {
   ObjectDelete(0, trnd_name);
  }
//========================================================================
double TrendLine::Value(void)
  {
   double result;
   double diff_x = m_toe_bar - m_center_bar ;
   double y_source = (!is_ascending) ? (iLow(_Symbol, 0, m_toe_bar)) : (iHigh(_Symbol, 0, m_toe_bar));
   double y_touch = (!is_ascending) ? (iLow(_Symbol, 0, m_center_bar)) : (iHigh(_Symbol, 0, m_center_bar));
   double diff_y = y_source - y_touch;
   result = y_touch - ((m_center_bar / diff_x) * diff_y);
   return result;
  }
//========================================================================
bool TrendLine::Create(int startBar, int secondBar)
  {
   if(startBar <= 0 || secondBar <= 0)
     {
      printf("Init Error");
      return(false);
     }
   m_toe_bar = startBar;
   m_center_bar = secondBar ;
   if(iHighest(_Symbol, 0, MODE_HIGH, 2, startBar - 1) > iHigh(_Symbol, 0, startBar))
      is_ascending = true;
   else
      is_ascending = false;
   date_toe = iTime(_Symbol, 0, m_toe_bar);
   date_center = iTime(_Symbol, 0, m_center_bar);
   return true;
  }
//========================================================================
bool TrendLine::Create(datetime startDate, datetime secondDate)
  {
   if(startDate <= 0 || secondDate <= 0)
     {
      printf("Init Error");
      return(false);
     }
   m_toe_bar = iBarShift(_Symbol, 0, startDate);
   m_center_bar = iBarShift(_Symbol, 0, secondDate) ;
   if(iHighest(_Symbol, 0, MODE_HIGH, 4, m_toe_bar - 2) == m_toe_bar)
      is_ascending = false;
   else
      is_ascending = true;
   date_toe = startDate;
   date_center = secondDate;
   return true;
  }
//========================================================================
void TrendLine::Refresh(void)
  {
   if(date_toe == NULL || date_center == NULL)
     {
      printf("Init Error");
     }
   m_toe_bar = iBarShift(_Symbol, 0, date_toe);
   m_center_bar = iBarShift(_Symbol, 0, date_center);

  }
//========================================================================
void TrendLine::Draw(void)
  {
   double price0;
   double price1;
   if(is_ascending)
     {
      price0     = iHigh(_Symbol, 0, m_toe_bar);
      price1     = iHigh(_Symbol, 0, m_center_bar);
     }
   else
     {
      price0     = iLow(_Symbol, 0, m_toe_bar);
      price1     = iLow(_Symbol, 0, m_center_bar);
     }
   ObjectCreate(0, trnd_name, OBJ_TREND, 0, date_toe, price0, date_center, price1);
   ObjectSetInteger(0, trnd_name, OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, trnd_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, trnd_name, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, trnd_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, trnd_name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, trnd_name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, trnd_name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, trnd_name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, trnd_name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, trnd_name, OBJPROP_ZORDER, 0);
   ChartRedraw();
  }
//========================================================================
void TrendLine::Create(void)
  {
   m_zigzag.Create(_Symbol, z_depth, z_dev, z_stp);
   trnd_name            = IntegerToString(MathRand());
   date_toe             = m_zigzag.ExtremumTime(z_toe)     ;
   date_center          = m_zigzag.ExtremumTime(z_center)  ;
   m_toe_bar            = iBarShift(_Symbol, 0, date_toe)    ;
   m_center_bar         = iBarShift(_Symbol, 0, date_center) ;
   double toe_price     = iHigh(_Symbol, 0, m_toe_bar)       ;
   double z_price       = m_zigzag.ExtremumValue(z_toe)    ;
   if(z_price == toe_price)
      is_ascending = true;
   else
      is_ascending = false;
   date_toe = iTime(_Symbol, 0, m_toe_bar);
   date_center = iTime(_Symbol, 0, m_center_bar);
   m_atr.Create(_Symbol, 0, 14);
  }
//========================================================================
void TrendLine::Extend(void) //This func Extend trendline if Price got lower or higher than our trendline but didnt breakout
  {
   m_atr.Refresh();

   int toe = iBarShift(_Symbol, 0, date_toe) - 1;
   int center = iBarShift(_Symbol, 0, date_center) - 1;
   m_toe_bar            = iBarShift(_Symbol, 0, date_toe)    ;
   m_center_bar         = iBarShift(_Symbol, 0, date_center) ;
   double high_toe      = iHigh(_Symbol, 0, m_toe_bar);
   double low_toe       = iLow(_Symbol, 0, m_toe_bar);
   double atr = m_atr.Main(m_toe_bar) * 0.5;
   for(int i = center; i > 2; i--)
     {
      if(is_ascending && iHigh(_Symbol, 0, i) > Value(i))
        {
         m_center_bar = i;
         date_center = iTime(_Symbol, 0, i);
         ObjectDelete(0, trnd_name);
         Draw();
         ChartRedraw();
        }
      if(!is_ascending && iLow(_Symbol, 0, i) < Value(i))
        {
         m_center_bar = i;
         date_center = iTime(_Symbol, 0, i);
         ObjectDelete(0, trnd_name);
         Draw();
         ChartRedraw();
        }
     }

   for(int i = toe; i > center + 1; i--)
     {
      
      //double body = 0.15 * (iHigh(_Symbol, 0, i) -  iLow(_Symbol, 0, i));
      if(is_ascending && iHigh(_Symbol, 0, i) - atr > Value(i))
        {
         m_toe_bar = i;
         date_toe = iTime(_Symbol, 0, i);
         ObjectDelete(0, trnd_name);
         Draw();
         ChartRedraw();
        }
      if(!is_ascending && iLow(_Symbol, 0, i) + atr < Value(i))
        {
         m_toe_bar = i;
         date_toe = iTime(_Symbol, 0, i);
         ObjectDelete(0, trnd_name);
         Draw();
         ChartRedraw();
        }
     }
  }
//========================================================================
bool TrendLine::BreakOut(double priceLevel, int index) // it returns if the pricelevel Breakout in specific bar
  {
   double closeBar1         = iClose(_Symbol, 0, index);
   double openBar1          = iOpen(_Symbol, 0, index);
   double closeBar2         = iClose(_Symbol, 0, index + 1);
   double body              = MathAbs(closeBar1 - openBar1) / 2;
   if(is_ascending)
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
   if(!is_ascending)
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
//========================================================================
double TrendLine::Value(int bar)  // This func Return the Trendline value on specific bar
  {
   double result;
   double diff_x = m_toe_bar - m_center_bar ;
   double y_source = (!is_ascending) ? (iLow(_Symbol, 0, m_toe_bar)) : (iHigh(_Symbol, 0, m_toe_bar));
   double y_touch = (!is_ascending) ? (iLow(_Symbol, 0, m_center_bar)) : (iHigh(_Symbol, 0, m_center_bar));
   double diff_y = y_source - y_touch;
   double xdiff2 = m_center_bar - bar ;
   result = y_touch - ((xdiff2 / diff_x) * diff_y);
   return result;
  }

//===================================================================================================================================
//===================================================================================================================================
//===================================================================================================================================
//===================================      Class All_Trendlines       ===============================================================
//===================================================================================================================================
//===================================================================================================================================
//===================================================================================================================================
 class trends : public TrendLine
   {
 protected:
      
 public:
                      trends(void);
                     ~trends(void);
   };
  
  
  
  
//===================================================================================================================================
//===================================================================================================================================
//===================================================================================================================================
//================================                 Class Pattern              =======================================================
//===================================================================================================================================
//===================================================================================================================================
//===================================================================================================================================
class Pattern
  {
private:
   TrendLine         trnd1;
   TrendLine         trnd2;
   CiATR             m_atr;
public:
   void              initTrend(int trnd1_center = 0, int trnd1_toe = 2, int trnd2_center = 1, int trnd2_toe = 3);
   void              initZigZag(int depth = 12, int dev = 5, int stp = 3)            {trnd1.Set_ZigZag_Params(depth, dev, stp);}
   bool              ValidationSetting();
   void              onTicks()                                                         {trnd1.Extend(); trnd2.Extend();}
   string            PatternValue();
                     Pattern(void);
                    ~Pattern(void);
  };
//========================================================================
// ============== This Function
//========================================================================
void Pattern::initTrend(int trnd1_center = 0, int trnd1_toe = 2, int trnd2_center = 1, int trnd2_toe = 3)
  {
   m_atr.Create(_Symbol, 0, 14);
   trnd1.Set_Toe_Center(trnd1_center, trnd1_toe);
   trnd2.Set_Toe_Center(trnd2_center, trnd2_toe);
   trnd1.Create();
   trnd2.Create();
   trnd1.Draw();
   trnd2.Draw();
   Print(PatternValue());
   //double Ask           = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   //m_atr.Refresh();
   //double  atr          = m_atr.Main(1) ;
   //int counter = 5;
   //while(trnd1.Value() >= Ask + (3 * atr) || counter == 0)
   //   {
   //      trnd1.Set_Toe_Center(trnd1_center, trnd1_toe);
   //      trnd1.Create();
   //      trnd1.Draw();
   //      counter--;
   //   }
  }
//========================================================================
//==== This Function return type of our patterns based on 2 trends =======
string Pattern::PatternValue(void)
  {
   m_atr.Refresh();
   double  atr          = m_atr.Main(1) * 0.5;
   int x = trnd1.GetToeBar();
   int y = trnd1.GetCenterBar();
   double a, b, c, d;
   b                    = trnd1.GetToePrice();
   a                    = trnd2.Value(x);
   d                    = trnd1.GetCenterPrice();
   c                    = trnd2.Value(y);
   trnd1.Extend();
   trnd2.Extend();
//Print("a  = ",a," b  = ",b," c  = ",c," d  = ",d);

//---------   a > c  ---------     ------  b > d
   if((a > c + atr && a - atr > c) && (b > d + atr && b - atr > d))
      return "Descending Channel";
   if((a < c - atr && a + atr < c) && (b < d - atr && b + atr < d))
      return "Ascending Channel";
   if((a < c - atr && a + atr < c) && (b > d + atr && b - atr > d))
      return "Falling Wedge";
   if((a > c + atr && a - atr > c) && (b < d - atr && b + atr < d))
      return "Opening Triangle";
   if((a > c + atr && a - atr > c) && (b+atr >=d  &&  b - atr <=d))
      return "Descending Triangle";
   return "nothing";
  }
//========================================================================
Pattern :: Pattern()
  {
//initZigZag();
//initTrend();
  }
//========================================================================
Pattern::~Pattern(void)
  {}
//===================================================================================================================================
 