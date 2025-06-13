//=====================================================================
//	Индикатор тренда.
//=====================================================================
#include <MovingAverages.mqh>
//---------------------------------------------------------------------
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Индикатор тренда на основе скользящей средней."
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price	PRICE_CLOSE
#property indicator_minimum				-1.4
#property indicator_maximum				+1.4
//---------------------------------------------------------------------
#property indicator_buffers 	1
#property indicator_plots   	1
//---------------------------------------------------------------------
#property indicator_type1   	DRAW_HISTOGRAM
#property indicator_color1  	Red
#property indicator_width1		2
//---------------------------------------------------------------------
//	Внешние задаваемые параметры:
//---------------------------------------------------------------------
input int   MAPeriod=200;   // значение периода скользящей средней
//---------------------------------------------------------------------
//	Индикаторные буферы:
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
//	Обработчик события инициализации:
//---------------------------------------------------------------------
void OnInit()
  {
//	Отображаемый индикаторный буфер:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MAPeriod);
   PlotIndexSetString(0,PLOT_LABEL,"MATrendDetector( "+(string)MAPeriod+" )");
  }
//---------------------------------------------------------------------
//	Обработчик события необходимости пересчета индикатора:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int         start,i;

//	Если число баров на экране меньше, чем период усреднения, то расчеты невозможны:
   if(_rates_total<MAPeriod)
     {
      return(0);
     }

//	Определим начальный бар для расчета индикаторного буфера:
   if(_prev_calculated==0)
     {
      start=MAPeriod;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Цикл расчета значений индикаторного буфера:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(i,_price);
     }

   return(_rates_total);
  }
//---------------------------------------------------------------------
//	Определяет направление текущего тренда:
//---------------------------------------------------------------------
//	Возвращает:
//		-1 - тренд вниз;
//		+1 - тренд вверх;
//		 0 - тренд не пределен;
//---------------------------------------------------------------------
int TrendDetector(int _shift,const double &_price[])
  {
   double current_ma;
   int trend_direction=0;

   current_ma=SimpleMA(_shift,MAPeriod,_price);

   if(_price[_shift]>current_ma)
     {
      trend_direction=1;
     }
   else if(_price[_shift]<current_ma)
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+
