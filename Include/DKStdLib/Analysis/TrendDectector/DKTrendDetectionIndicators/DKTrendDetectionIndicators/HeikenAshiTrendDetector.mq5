//=====================================================================
//	Индикатор тренда.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Индикатор тренда на основе индикатора Heiken Ashi."
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
//	Отсутствуют
//---------------------------------------------------------------------
double  TrendBuffer[];
//---------------------------------------------------------------------
//	Обработчик события инициализации:
//---------------------------------------------------------------------
int OnInit()
  {
//	Отображаемый индикаторный буфер:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,1);
   PlotIndexSetString(0,PLOT_LABEL,"HeikenAshiTrendDetector");

   return(0);
  }
//---------------------------------------------------------------------
//	Обработчик события необходимости пересчета индикатора:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int      start,i;
   double   open,close,ha_open,ha_close;

//	Определим начальный бар для расчета индикаторного буфера:
   if(_prev_calculated==0)
     {
      open=Open[0];
      close = Close[ 0 ];
      start = 1;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Цикл расчета значений индикаторного буфера:
   for(i=start; i<_rates_total; i++)
     {
      //	Цена открытия свечи Heiken Ashi:
      ha_open=(open+close)/2.0;

      //	Цена закрытия свечи Heiken Ashi:
      ha_close=(Open[i]+High[i]+Low[i]+Close[i])/4.0;

      TrendBuffer[i]=TrendDetector(ha_open,ha_close);

      open=ha_open;
      close=ha_close;
     }

   return(_rates_total);
  }
//---------------------------------------------------------------------
//	Определяет направление текущего тренда:
//---------------------------------------------------------------------
//	Возвращает:
//		-1 - тренд вниз;
//		+1 - тренд вверх;
//		 0 - тренд не определен;
//---------------------------------------------------------------------
int TrendDetector(double _open,double _close)
  {
   int trend_direction=0;

   if(_close>_open) // если свеча растущая, то тренд вверх
     {
      trend_direction=1;
     }
   else if(_close<_open) // если свеча падающая, то тренд вниз
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+
