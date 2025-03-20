//+------------------------------------------------------------------+
//|                                           CDKChartObjectFibo.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsFibo.mqh>

class CDKChartObjectFibo : public CChartObjectFibo
{
public:
   bool Attach(string name)
   {
      return CChartObjectFibo::Attach(ChartID(),name,0,2);
   }
   double LevelPrice(const int level_index)
   {
      double first = Price(0); 
      double last  = Price(1);
      double range = fabs(first-last);
      double fib   = range * LevelValue(level_index);
      if(first<last)
         return NormalizeDouble(last-fib,_Digits);
      return NormalizeDouble(last+fib,_Digits);
   }
   
   void SetLevelNumber(const int _cnt) {
     ObjectSetInteger(0, Name(), OBJPROP_LEVELS, _cnt); // Set number of level
   }
   
   void SetLevel(const int _idx, const double _level, const string _label, const color _clr = 0) {
    ObjectSetDouble(0, Name(), OBJPROP_LEVELVALUE, _idx, _level);
    ObjectSetString(0, Name(), OBJPROP_LEVELTEXT, _idx, _label);
    
    if(_clr != 0)
      ObjectSetInteger(0, Name(), OBJPROP_LEVELCOLOR, _idx, _clr);       
   }
};