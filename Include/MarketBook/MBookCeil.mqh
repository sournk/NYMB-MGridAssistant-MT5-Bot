//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include "Node.mqh"
#include "MarketBook.mqh"
#include "Node.mqh"
#include "MBookText.mqh"

#define BOOK_PRICE 0
#define BOOK_VOLUME 1

class CBookCeil : public CNode
{
private:
   long  m_ydist;
   long  m_xdist;
   int   m_index;
   int m_ceil_type;
   CBookText m_text;
   CMarketBook* m_book;
public:
   CBookCeil(int type, long x_dist, long y_dist, int index_mbook, CMarketBook* book);
   virtual void Show();
   virtual void Hide();
   virtual void Refresh();
   
};

CBookCeil::CBookCeil(int type, long x_dist, long y_dist, int index_mbook, CMarketBook* book)
{
   m_ydist = y_dist;
   m_xdist = x_dist;
   m_index = index_mbook;
   m_book = book;
   m_ceil_type = type;
}

void CBookCeil::Show()
{
   ObjectCreate(ChartID(), m_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_XDISTANCE, m_xdist);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_YDISTANCE, m_ydist);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_YSIZE, 16);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   m_text.Show();
   m_text.SetXDist(m_xdist+10);
   m_text.SetYDist(m_ydist+2);
   Refresh();
}

void CBookCeil::Refresh(void)
{
   ENUM_BOOK_TYPE type = m_book.MarketBook[m_index].type;
   long max_volume = 0;
   if(type == BOOK_TYPE_BUY || type == BOOK_TYPE_BUY_MARKET)
   {
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BGCOLOR, clrCornflowerBlue);
      max_volume = m_book.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   }
   else if(type == BOOK_TYPE_SELL || type == BOOK_TYPE_SELL_MARKET)
   {
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BGCOLOR, clrPink);
      max_volume = m_book.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   }
   else
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BGCOLOR, clrWhite);
   MqlBookInfo info = m_book.MarketBook[m_index];
   if(m_ceil_type == BOOK_PRICE)
      m_text.SetText(DoubleToString(info.price, Digits()));
   else if(m_ceil_type == BOOK_VOLUME)
      m_text.SetText((string)info.volume);
   if(m_ceil_type != BOOK_VOLUME)return;
   double delta = 1.0;
   if(max_volume > 0)
      delta = (info.volume/(double)max_volume);
   if(delta > 1.0)delta = 1.0;   
   long size = (long)(delta * 50.0);
   if(size == 0)size = 1;
   ObjectSetInteger(ChartID(), m_name, OBJPROP_XSIZE, size);
   ObjectSetInteger(ChartID(), m_name, OBJPROP_YDISTANCE, m_ydist);
}

void CBookCeil::Hide(void)
{
   OnHide();
   m_text.Hide();
   ObjectDelete(ChartID(),m_name);
}