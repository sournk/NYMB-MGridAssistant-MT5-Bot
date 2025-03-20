//+------------------------------------------------------------------+
//|                                               TestMarketBook.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Trade\MarketBook.mqh>     // �������� ����� CMarketBook
CMarketBook Book(Symbol());         // �������������� ����� ������� ������������

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
   Book.Refresh();                                                   // ��������� ��������� �������.
   /* �������� �������� ������������� ���������� */
   int total=(int)Book.InfoGetInteger(MBOOK_DEPTH_TOTAL);            // �������� ����� ������� �������
   int total_ask = (int)Book.InfoGetInteger(MBOOK_DEPTH_ASK);        // �������� ���������� ������� ������� �� �������
   int total_bid = (int)Book.InfoGetInteger(MBOOK_DEPTH_BID);        // �������� ���������� ������� ������� �� �������
   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // �������� ������ ������ �����������
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // �������� ������ ������ ������

   /* ������� �������� ���������� */
   printf("����� ������� �������: "+(string)total);
   printf("���������� ������� ������� �� �������: "+(string)total_ask);
   printf("���������� ������� ������� �� �������: "+(string)total_bid);
   printf("������ ������� ������: "+(string)best_ask);
   printf("������ ������� �����������: "+(string)best_bid);
   
   /* �������� �������� ���������� double */
   double best_ask_price = Book.InfoGetDouble(MBOOK_BEST_ASK_PRICE); // �������� ������ ���� �����������
   double best_bid_price = Book.InfoGetDouble(MBOOK_BEST_BID_PRICE); // �������� ������ ���� ������
   double last_ask = Book.InfoGetDouble(MBOOK_LAST_ASK_PRICE);       // �������� ������ ���� �����������
   double last_bid = Book.InfoGetDouble(MBOOK_LAST_BID_PRICE);       // �������� ������ ���� ������
   double avrg_spread = Book.InfoGetDouble(MBOOK_AVERAGE_SPREAD);    // �������� ������� ����� �� ����� ������ ������� ���
   
   /* ������� ���� � ����� */
   printf("������ ���� ������: " + DoubleToString(best_ask_price, Digits()));
   printf("������ ���� �����������: " + DoubleToString(best_bid_price, Digits()));
   printf("������ ���� ������: " + DoubleToString(last_ask, Digits()));
   printf("������ ���� �����������: " + DoubleToString(last_bid, Digits()));
   printf("������� �����: " + DoubleToString(avrg_spread, Digits()));
  }
//+------------------------------------------------------------------+