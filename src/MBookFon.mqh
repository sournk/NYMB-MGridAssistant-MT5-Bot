//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include "Node.mqh"
#include "MBookCeil.mqh"
#include "MarketBook.mqh"

class CBookLine : public CNode
{
private:
   long m_ydist;
public:
   CBookLine(long y){m_ydist = y;}
   virtual void Show()
   {
      ObjectCreate(ChartID(),     m_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_YDISTANCE, m_ydist);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_XDISTANCE, 13);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_YSIZE, 3);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_XSIZE, 108);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BGCOLOR, clrBlack);
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   }
};

class CBookFon : public CNode
{
private:
   CMarketBook* m_book;
   CBookLine* m_line;
public:
   CBookFon(CMarketBook* book);
   void CreateCeils();
   virtual void Show();
   
};
CBookFon::CBookFon(CMarketBook *book)
{
   m_book = book;
   
}
CBookFon::Show(void)
{
   ObjectCreate(ChartID(), m_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_YDISTANCE, 13);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_XDISTANCE, 6);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_XSIZE, 116);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_BGCOLOR, clrWhite);
   int total = (int)m_book.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_YSIZE, total*15+16);
   CreateCeils();
   
   OnShow();
}

void CBookFon::CreateCeils()
{
   int total = (int)m_book.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   for(int i = 0; i < total; i++)
   {
      CBookCeil* Ceil = new CBookCeil(0, 12, i*15+20, i, m_book);
      CBookCeil* CeilVol = new CBookCeil(1, 63, i*15+20, i, m_book);
      m_elements.Add(Ceil);
      m_elements.Add(CeilVol);
      Ceil.Show();
      CeilVol.Show();
   }
   long best_bid = m_book.InfoGetInteger(MBOOK_BEST_BID_INDEX);
   long y = best_bid*15+19;
   m_elements.Add(new CBookLine(y));
}