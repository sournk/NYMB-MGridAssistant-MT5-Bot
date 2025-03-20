//=====================================================================
//	Индикатор тренда.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.01"
#property description "Индикатор тренда на основе индикатора ZigZag."
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price	PRICE_CLOSE
#property indicator_minimum				-1.4
#property indicator_maximum				+1.4
//---------------------------------------------------------------------
#property indicator_buffers 	3
#property indicator_plots   	1
//---------------------------------------------------------------------
#property indicator_type1   	DRAW_HISTOGRAM
#property indicator_color1  	Black
#property indicator_width1		2
//---------------------------------------------------------------------
//	Внешние задаваемые параметры:
//---------------------------------------------------------------------
input int   ExtDepth=12;
input int   ExtDeviation= 5;
input int   ExtBackstep = 3;
//---------------------------------------------------------------------
double   TrendBuffer[];
double   ZigZagHighs[];   // верхние переломы зиг-зага
double   ZigZagLows[ ];   // нижние переломы зиг-зага
//---------------------------------------------------------------------
int      indicator_handle=0;
//---------------------------------------------------------------------
//	Обработчик события инициализации:
//---------------------------------------------------------------------
int OnInit()
  {
//	Отображаемый индикаторный буфер:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtDepth);
   PlotIndexSetString(0,PLOT_LABEL,"ZigZagTrendDetector( "
                      +(string)ExtDepth+", "
                      +(string)ExtDeviation+", "
                      +(string) ExtBackstep+" )");

//	Буферы для хранения переломов зиг-зага:
   SetIndexBuffer(1,ZigZagHighs,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ZigZagLows,INDICATOR_CALCULATIONS);

//	Создадим хэндл внешнего индикатора для дальнейшего обращения к нему:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ZigZag",ExtDepth,ExtDeviation,ExtBackstep);
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("Ошибка инициализации ZigZag, Код = ",GetLastError());
      return(-1);     // возвратим ненулевой код - инициализация прошла неудачно
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Обработчик события деинициализации индикатора:
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
//	Удалим хэндл индикатора зиг-зага:
   if(indicator_handle!=INVALID_HANDLE)
     {
      IndicatorRelease(indicator_handle);
     }
  }
//---------------------------------------------------------------------
//	Обработчик события необходимости пересчета индикатора:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int   start,i;

//	Если число баров на экране меньше, чем число бар для построения перелома зиг-зага, то расчеты невозможны:
   if(_rates_total<ExtDepth)
     {
      return(0);
     }

//	Определим начальный бар для расчета индикаторного буфера:
   if(_prev_calculated==0)
     {
      start=ExtDepth;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Скопируем верхние и нижние переломы зиг-зага в буферы:
   CopyBuffer(indicator_handle,1,0,_rates_total-_prev_calculated,ZigZagHighs);
   CopyBuffer(indicator_handle,2,0,_rates_total-_prev_calculated,ZigZagLows);

//	Цикл расчета значений индикаторного буфера:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(i);
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
double   ZigZagExtHigh[2];
double   ZigZagExtLow[2];
//---------------------------------------------------------------------
int TrendDetector(int _shift)
  {
   int   trend_direction=0;

//	Ищем последние четыре перелома зиг-зага:
   int   ext_high_count= 0;
   int   ext_low_count = 0;

   for(int i=_shift; i>=0; i--)
     {
      if(ZigZagHighs[i]>0.1)
        {
         if(ext_high_count<2)
           {
            ZigZagExtHigh[ext_high_count]=ZigZagHighs[i];
            ext_high_count++;
           }
        }
      else if(ZigZagLows[i]>0.1)
        {
         if(ext_low_count<2)
           {
            ZigZagExtLow[ext_low_count]=ZigZagLows[i];
            ext_low_count++;
           }
        }
      //	Если две пары экстремумов найдены, то цикл прерываем:
      if(ext_low_count==2 && ext_high_count==2)
        {
         break;
        }
     }

//	Если необходимое число экстремумов не найдено, то тренд определить не возможно:
   if(ext_low_count!=2 || ext_high_count!=2)
     {
      return(trend_direction);
     }

//	Проверим выполнение условий Доу:
   if(ZigZagExtHigh[0]>ZigZagExtHigh[1] && ZigZagExtLow[0]>ZigZagExtLow[1])
     {
      trend_direction=1;
     }
   else if(ZigZagExtHigh[0]<ZigZagExtHigh[1] && ZigZagExtLow[0]<ZigZagExtLow[1])
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+
