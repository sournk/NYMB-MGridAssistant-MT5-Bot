//=====================================================================
//	Индикатор тренда.
//=====================================================================
//---------------------------------------------------------------------
#include <MovingAverages.mqh>
//---------------------------------------------------------------------
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Индикатор тренда на основе веера скользящих средних."
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
#property indicator_color1  	Black
#property indicator_width1		2
//---------------------------------------------------------------------
//	Внешние задаваемые параметры:
//---------------------------------------------------------------------
input int   MA1Period = 200; // значение периода старшей скользящей средней
input int   MA2Period = 50;  // значение периода средей скользящей средней
input int   MA3Period = 21;  // значение периода младшей скользящей средней
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
//	Обработчик события инициализации:
//---------------------------------------------------------------------
void OnInit()
  {
//	Отображаемый индикаторный буфер:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MA1Period);
   PlotIndexSetString(0,PLOT_LABEL,"FanTrendDetector( "+(string)MA1Period+
                      ", "+(string)MA2Period+", "+(string) MA3Period+" )");
  }
//---------------------------------------------------------------------
//	Обработчик события необходимости пересчета индикатора:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int start,i,max_period;

//	Если число баров на экране меньше, чем период усреднения, то расчеты не возможны:
   if(_rates_total<MA1Period)
     {
      return(0);
     }

//	Определим начальный бар для расчета индикаторного буфера:
   if(_prev_calculated==0)
     {
      start=MA1Period;
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
   double current_ma1,current_ma2,current_ma3;
   int trend_direction=0;

   current_ma1 = SimpleMA( _shift, MA1Period, _price );
   current_ma2 = SimpleMA( _shift, MA2Period, _price );
   current_ma3 = SimpleMA( _shift, MA3Period, _price );

   if(current_ma3>current_ma2 && current_ma2>current_ma1)
     {
      trend_direction=1;
     }
   else if(current_ma3<current_ma2 && current_ma2<current_ma1)
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+