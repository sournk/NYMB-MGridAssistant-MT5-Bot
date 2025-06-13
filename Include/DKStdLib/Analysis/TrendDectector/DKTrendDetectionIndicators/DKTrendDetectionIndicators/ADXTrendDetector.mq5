//=====================================================================
//	Индикатор тренда.
//=====================================================================
//---------------------------------------------------------------------
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Индикатор тренда на основе индикатора ADX."
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
input int   PeriodADX=14;
input int   ADXTrendLevel=20;
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
int         indicator_handle=0;
//---------------------------------------------------------------------
//	Обработчик события инициализации:
//---------------------------------------------------------------------
int OnInit()
  {
//	Отображаемый индикаторный буфер:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,PeriodADX*2);
   PlotIndexSetString(0,PLOT_LABEL,"ADXTrendDetector( "+(string)PeriodADX+" )");

//	Создадим хэндл внешнего индикатора для дальнейшего обращения к нему:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ADX",PeriodADX);
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("Ошибка инициализации ADX, Код = ",GetLastError());
      return(-1);   // возвратим ненулевой код - инициализация прошла неудачно
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Обработчик события деинициализации:
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
//	Удалим хэндл индикатора:
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
   int start,i;

//	Если число баров на экране меньше, чем период ADX, то расчеты не возможны:
   if(_rates_total<PeriodADX*2)
     {
      return(0);
     }

//	Определим начальный бар для расчета индикаторного буфера:
   if(_prev_calculated==0)
     {
      start=PeriodADX*2;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Цикл расчета значений индикаторного буфера:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(_rates_total-i-1);
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
int TrendDetector(int _shift)
  {
   int      trend_direction=0;
   double   ADXBuffer[1];
   double   PlusDIBuffer[1];
   double   MinusDIBuffer[1];

//	Скопируем значения индикатора ADX в буферы:
   CopyBuffer(indicator_handle,0,_shift,1,ADXBuffer);
   CopyBuffer(indicator_handle,1,_shift,1,PlusDIBuffer);
   CopyBuffer(indicator_handle,2,_shift,1,MinusDIBuffer);

//	Если учитывается значение ADX ( сила тренда ):
   if(ADXTrendLevel>0)
     {
      if(ADXBuffer[0]<ADXTrendLevel)
        {
         return(trend_direction);
        }
     }

//	Проверяем положение +-DI относительно друг друга:
   if(PlusDIBuffer[0]>MinusDIBuffer[0])
     {
      trend_direction=1;
     }
   else if(PlusDIBuffer[0]<MinusDIBuffer[0])
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+