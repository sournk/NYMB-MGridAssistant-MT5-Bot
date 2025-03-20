//=====================================================================
//	Эксперт на индикаторе тренда ADXTrendDetector.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Эксперт на индикаторе тренда ADXTrendDetector."
//---------------------------------------------------------------------
//	Подключаемые библиотеки:
//---------------------------------------------------------------------
#include <Trade\Trade.mqh>
//---------------------------------------------------------------------
//	Внешние задаваемые параметры:
//---------------------------------------------------------------------
input double  Lots=0.1;
input int     PeriodADX=14;
input int     ADXTrendLevel=20;
//---------------------------------------------------------------------
int           indicator_handle=0;
//---------------------------------------------------------------------
//	Обработчик события инициализации:
//---------------------------------------------------------------------
int OnInit()
  {
//	Создадим хэндл внешнего индикатора для дальнейшего обращения к нему:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ADXTrendDetector",PeriodADX,ADXTrendLevel);

//	Если инициализация прошла неудачно, то возвратим ненулевой код:
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("Ошибка инициализации ADXTrendDetector, Код = ",GetLastError());
      return(-1);
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Обработчик события де-инициализации:
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
//	Обработчик события о поступлении нового тика по текущему символу:
//---------------------------------------------------------------------
int   current_signal=0;
int   prev_signal=0;
bool  is_first_signal=true;
//---------------------------------------------------------------------
void OnTick()
  {
//	Ждем начала нового бара:
   if(CheckNewBar()!=1)
     {
      return;
     }

//	Получим сигнал на открытие/закрытие позиции:
   current_signal=GetSignal();
   if(is_first_signal==true)
     {
      prev_signal=current_signal;
      is_first_signal=false;
     }

//	Выберем позицию по текущему символу:
   if(PositionSelect(Symbol())==true)
     {
      //	Проверим, не надо ли закрыть противоположную позицию:
      if(CheckPositionClose(current_signal)==1)
        {
         return;
        }
     }

//	Проверяем наличие сигнала на BUY:
   if(CheckBuySignal(current_signal,prev_signal)==1)
     {
      CTrade   trade;
      trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,Lots,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0);
     }

//	Проверяем наличие сигнала на SELL:
   if(CheckSellSignal(current_signal,prev_signal)==1)
     {
      CTrade   trade;
      trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,Lots,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0);
     }

//	Сохраним текущий сигнал:
   prev_signal=current_signal;
  }
//---------------------------------------------------------------------
//	Проверим, не надо ли закрыть позицию:
//---------------------------------------------------------------------
//	возвращает:
//		0 - открытой позиции нет;
//		1 - позиция уже открыта в направлении сигнала;
//---------------------------------------------------------------------
int CheckPositionClose(int _signal)
  {
   long position_type=PositionGetInteger(POSITION_TYPE);

   if(_signal==1)
     {
      //	Если уже открыта позиция BUY, то возврат:
      if(position_type==(long)POSITION_TYPE_BUY)
        {
         return(1);
        }
     }

   if(_signal==-1)
     {
      //	Если уже открыта позиция SELL, то возврат:
      if(position_type==(long)POSITION_TYPE_SELL)
        {
         return(1);
        }
     }

//	Закрытие позиции:
   CTrade   trade;
   trade.PositionClose(Symbol(),10);

   return(0);
  }
//---------------------------------------------------------------------
//	Проверка наличия сигнала на BUY:
//---------------------------------------------------------------------
//	возвращает:
//		0 - сигнала нет;
//		1 - есть сигнал на BUY;
//---------------------------------------------------------------------
int CheckBuySignal(int _curr_signal,int _prev_signal)
  {
//	Проверим, было ли изменение направления сигнала на BUY:
   if(( _curr_signal==1 && _prev_signal==0) || (_curr_signal==1 && _prev_signal==-1))
     {
      return(1);
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Проверка наличия сигнала на SELL:
//---------------------------------------------------------------------
//	возвращает:
//		0 - сигнала нет;
//		1 - есть сигнал на SELL;
//---------------------------------------------------------------------
int CheckSellSignal(int _curr_signal,int _prev_signal)
  {
//	Проверим, было ли изменение направления сигнала на SELL:
   if(( _curr_signal==-1 && _prev_signal==0) || (_curr_signal==-1 && _prev_signal==1))
     {
      return(1);
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Получение сигнала на открытие/закрытие позиции:
//---------------------------------------------------------------------
int GetSignal()
  {
   double      trend_direction[1];

//	Получаем сигнал из индикатора тренда:
   ResetLastError();
   if(CopyBuffer(indicator_handle,0,0,1,trend_direction)!=1)
     {
      Print("Ошибка копирования CopyBuffer, Код = ",GetLastError());
      return(0);
     }

   return(( int)trend_direction[0]);
  }
//---------------------------------------------------------------------
//	Возвращает признак появления нового бара:
//---------------------------------------------------------------------
//	- если возвращает 1, то есть новый	бар;
//---------------------------------------------------------------------
int CheckNewBar()
  {
   MqlRates      current_rates[1];

   ResetLastError();
   if(CopyRates(Symbol(),Period(),0,1,current_rates)!=1)
     {
      Print("Ошибка копирования CopyRates, Код = ",GetLastError());
      return(0);
     }

   if(current_rates[0].tick_volume>1)
     {
      return(0);
     }

   return(1);
  }
//+------------------------------------------------------------------+
