//+------------------------------------------------------------------+
//|                                               TestMarketBook.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Trade\MarketBook.mqh>     // Включаем класс CMarketBook
CMarketBook Book(Symbol());         // Инициализируем класс текущем инструментом

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   PrintMbookInfo();
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Print MarketBook Info                                            |
//+------------------------------------------------------------------+
void PrintMbookInfo()
  {
   Book.Refresh();                                                   // Обновляем состояние стакана.
   /* Получаем основную цилочисленную статистику */
   int total=(int)Book.InfoGetInteger(MBOOK_DEPTH_TOTAL);            // Получаем общую глубину стакана
   int total_ask = (int)Book.InfoGetInteger(MBOOK_DEPTH_ASK);        // Получаем количество ценовых уровней на продажу
   int total_bid = (int)Book.InfoGetInteger(MBOOK_DEPTH_BID);        // Получаем количество ценовых уровней на покупку
   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Получаем лучший индекс предложения
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Получаем лучший индекс спроса

   /* Выводим основную статистику */
   printf("ОБЩАЯ ГЛУБИНА СТАКАНА: "+(string)total);
   printf("КОЛИЧЕСТВО ЦЕНОВЫХ УРОВНЕЙ НА ПРОДАЖУ: "+(string)total_ask);
   printf("КОЛИЧЕСТВО ЦЕНОВЫХ УРОВНЕЙ НА ПОКУПКУ: "+(string)total_bid);
   printf("ИНДЕКС ЛУЧШЕГО СПРОСА: "+(string)best_ask);
   printf("ИНДЕКС ЛУЧШЕГО ПРЕДЛОЖЕНИЯ: "+(string)best_bid);
   
   /* Получаем основную статистику double */
   double best_ask_price = Book.InfoGetDouble(MBOOK_BEST_ASK_PRICE); // Получаем лучшию цену предложения
   double best_bid_price = Book.InfoGetDouble(MBOOK_BEST_BID_PRICE); // Получаем лучшую цену спроса
   double last_ask = Book.InfoGetDouble(MBOOK_LAST_ASK_PRICE);       // Получаем худшую цену предложения
   double last_bid = Book.InfoGetDouble(MBOOK_LAST_BID_PRICE);       // Получаем худшую цену спроса
   double avrg_spread = Book.InfoGetDouble(MBOOK_AVERAGE_SPREAD);    // Получаем средний спред за время работы стакана цен
   
   /* Выводим цены и спред */
   printf("ЛУЧШАЯ ЦЕНА СПРОСА: " + DoubleToString(best_ask_price, Digits()));
   printf("ЛУЧШАЯ ЦЕНА ПРЕДЛОЖЕНИЯ: " + DoubleToString(best_bid_price, Digits()));
   printf("ХУДШАЯ ЦЕНА СПРОСА: " + DoubleToString(last_ask, Digits()));
   printf("ХУДШАЯ ЦЕНА ПРЕДЛОЖЕНИЯ: " + DoubleToString(last_bid, Digits()));
   printf("СРЕДНИЙ СПРЕД: " + DoubleToString(avrg_spread, Digits()));
  }
//+------------------------------------------------------------------+