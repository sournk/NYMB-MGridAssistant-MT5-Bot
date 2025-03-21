//+------------------------------------------------------------------+
//|                                                   MarketBook.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#define LAST_ASK_INDEX 0
#define LAST_BID_INDEX m_depth_total-1
//+------------------------------------------------------------------+
//| Side of MarketBook.                                              |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_SIDE
{
   MBOOK_ASK,                    // Ask side
   MBOOK_BID                     // Bid (offer) side
};
//+------------------------------------------------------------------+
//| Market Book info integer properties.                             |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_INFO_INTEGER
{
   MBOOK_BEST_ASK_INDEX,         // Best ask index
   MBOOK_BEST_BID_INDEX,         // Best bid index
   MBOOK_LAST_ASK_INDEX,         // Last (worst) ask index
   MBOOK_LAST_BID_INDEX,         // Last (worst) bid index
   MBOOK_DEPTH_ASK,              // Depth of ask side
   MBOOK_DEPTH_BID,              // Depth of bid side
   MBOOK_DEPTH_TOTAL,            // Total depth
   MBOOK_MAX_ASK_VOLUME,         // Max ask volume
   MBOOK_MAX_ASK_VOLUME_INDEX,   // Max ask volume index
   MBOOK_MAX_BID_VOLUME,         // Max bid volume
   MBOOK_MAX_BID_VOLUME_INDEX,   // Max bid volume index
   MBOOK_ASK_VOLUME_TOTAL,       // Total volume on Ask side of MarketBook
   MBOOK_BID_VOLUME_TOTAL,       // Total volume on Bid side of MarketBook
   MBOOK_BUY_ORDERS,             // Total orders on sell
   MBOOK_SELL_ORDERS,            // Total orders on buy
   
};
//+------------------------------------------------------------------+
//| Market Book info double properties.                              |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_INFO_DOUBLE
{
   MBOOK_BEST_ASK_PRICE,         // Best ask price,
   MBOOK_BEST_BID_PRICE,         // Best bid price,
   MBOOK_LAST_ASK_PRICE,         // Last (worst) ask price, 
   MBOOK_LAST_BID_PRICE,         // Last (worst) bid price,
   MBOOK_AVERAGE_SPREAD,         // Average spread for work time
   MBOOK_OPEN_INTEREST,          // Current Open Interest of Market
   MBOOK_BUY_ORDERS_VOLUME,      // Total volume of sell orders
   MBOOK_SELL_ORDERS_VOLUME,     // Total volume of buy orders
}; 

class CMarketBook;

class CBookCalculation
{
private:
   int m_max_ask_index;         // Индекс максимального объема спроса
   long m_max_ask_volume;       // Объем максимального спроса
   
   int m_max_bid_index;         // Индекс максимального объема предложения
   long m_max_bid_volume;       // Объем максимального предложения
   
   long m_sum_ask_volume;       // Суммарный объем спроса в стакане
   long m_sum_bid_volume;       // Суммарный объем предложения в стакане.
   
   bool m_calculation;          // Флаг, указывающий что все необходимые расчеты произведены
   CMarketBook* m_book;         // Указатель на стакан цен
   
   void Calculation(void)
   {
      // FOR ASK SIDE
      int begin = (int)m_book.InfoGetInteger(MBOOK_LAST_ASK_INDEX);
      int end = (int)m_book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);
      //m_ask_best_index
      for(int i = begin; i <= end && begin !=-1; i++)
      {
         if(m_book.MarketBook[i].volume > m_max_ask_volume)
         {
            m_max_ask_index = i;
            m_max_ask_volume = m_book.MarketBook[i].volume;
         }
         m_sum_ask_volume += m_book.MarketBook[i].volume;
      }
      // FOR BID SIDE
      begin = (int)m_book.InfoGetInteger(MBOOK_BEST_BID_INDEX);
      end = (int)m_book.InfoGetInteger(MBOOK_LAST_BID_INDEX);
      for(int i = begin; i <= end && begin != -1; i++)
      {
         if(m_book.MarketBook[i].volume > m_max_bid_volume)
         {
            m_max_bid_index = i;
            m_max_bid_volume = m_book.MarketBook[i].volume;
         }
         m_sum_bid_volume += m_book.MarketBook[i].volume;
      }
      m_calculation = true;
   }
   
public:
   CBookCalculation(CMarketBook* book)
   {
      Reset();
      m_book = book;
   }
   
   void Reset()
   {
      m_max_ask_volume = 0.0;
      m_max_bid_volume = 0.0;
      m_max_ask_index = -1;
      m_max_bid_index = -1;
      m_sum_ask_volume = 0;
      m_sum_bid_volume = 0;
      m_calculation = false;
   }
   int GetMaxVolAskIndex()
   {
      if(!m_calculation)
         Calculation();
      return m_max_ask_index;
   }
   
   long GetMaxVolAsk()
   {
      if(!m_calculation)
         Calculation();
      return m_max_ask_volume;
   }
   int GetMaxVolBidIndex()
   {
      if(!m_calculation)
         Calculation();
      return m_max_bid_index;
   }
   
   long GetMaxVolBid()
   {
      if(!m_calculation)
         Calculation();
      return m_max_bid_volume;
   }
   long GetAskVolTotal()
   {
      if(!m_calculation)
         Calculation();
      return m_sum_ask_volume;
   }
   long GetBidVolTotal()
   {
      if(!m_calculation)
         Calculation();
      return m_sum_bid_volume;
   }
};

class CMarketBook
{
protected:
   string      m_symbol;                 // Market Book symbol
   int         m_depth_total;            // Market depth total
   bool        m_available;              // True if market book available, otherwise false
   double      m_spread_sum;             // Accumulation spread;
   int         m_count_refresh;          // Count call CMarketBook::Refresh()
                  /* Indexes fields*/
   int         m_best_ask_index;         // Best ask index
   int         m_best_bid_index;         // Best bid index
   void        SetBestAskAndBidIndex(void);
   bool        FindBestBid(void);
   CBookCalculation Calculation;
   
public:
   MqlBookInfo MarketBook[];             // Array of market book
   MqlTick     LastTick;
               CMarketBook();
               CMarketBook(string symbol);
   long        InfoGetInteger(ENUM_MBOOK_INFO_INTEGER property);
   double      InfoGetDouble(ENUM_MBOOK_INFO_DOUBLE property);
   void        Refresh(void);
   bool        IsAvailable(void);
   bool        SetMarketBookSymbol(string symbol);
   string      GetMarketBookSymbol(void);
   double      GetDeviationByVol(long vol, ENUM_MBOOK_SIDE side);
   long        GetVolByDeviation(double deviation, ENUM_MBOOK_SIDE side);
   double      Last();
};

//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
CMarketBook::CMarketBook(void) : Calculation(GetPointer(this))
{
   SetMarketBookSymbol(Symbol());
}
//+------------------------------------------------------------------+
//| Create Market Book and set symbol for it.                        |
//+------------------------------------------------------------------+
CMarketBook::CMarketBook(string symbol) : Calculation(GetPointer(this))
{
   SetMarketBookSymbol(symbol);
}

//+------------------------------------------------------------------+
//| Get symbol for market book.                                      |
//+------------------------------------------------------------------+
string CMarketBook::GetMarketBookSymbol(void)
{
   return m_symbol;
}
//+------------------------------------------------------------------+
//| Set symbol for market book.                                      |
//+------------------------------------------------------------------+
bool CMarketBook::SetMarketBookSymbol(string symbol)
{
   ArrayResize(MarketBook, 0);
   m_available = false;
   m_best_ask_index = -1;
   m_best_bid_index = -1;
   m_depth_total = 0;
   bool isSelect = SymbolSelect(symbol, true);
   if(isSelect)
      m_symbol = symbol;
   else
   {
      if(!SymbolSelect(m_symbol, true) && SymbolSelect(Symbol(), true))
         m_symbol = Symbol();
   }
   if(isSelect) 
      MarketBookAdd(m_symbol);
   Refresh();
   return isSelect;
}
//+------------------------------------------------------------------+
//| Refresh Market Book.                                             |
//+------------------------------------------------------------------+
void CMarketBook::Refresh(void)
{
   m_available = MarketBookGet(m_symbol, MarketBook);
   SymbolInfoTick(Symbol(), LastTick);
   m_depth_total = ArraySize(MarketBook);
   SetBestAskAndBidIndex();
   if(m_depth_total == 0)
      return;
   m_count_refresh++;
   if(m_best_ask_index != -1 && m_best_bid_index != -1)
      m_spread_sum += MarketBook[m_best_ask_index].price-MarketBook[m_best_bid_index].price;
   Calculation.Reset();
}
//+------------------------------------------------------------------+
//| Возвращает цену Last, если последний тик был ассоциирован с      |
//| покупкой или продажей                                            |
//+------------------------------------------------------------------+
/*double CMarketBook::Last(void)
{
   bool is_buy = (m_last_tick.flags & TICK_FLAG_BUY) == TICK_FLAG_BUY;
}*/
//+------------------------------------------------------------------+
//| Return true if market book is available, otherwise return false  |
//+------------------------------------------------------------------+
bool CMarketBook::IsAvailable(void)
{
   return m_available;
}
//+------------------------------------------------------------------+
//| Find best ask and bid indexes and set this indexes for           |
//| m_best_ask_index and m_best_bid field                            |
//+------------------------------------------------------------------+
void CMarketBook::SetBestAskAndBidIndex(void)
{
   if(!FindBestBid())
   {
      //Find best ask by slow full search
      m_best_ask_index = -1;
      int bookSize = ArraySize(MarketBook);   
      for(int i = 0; i < bookSize; i++)
      {
         if((MarketBook[i].type == BOOK_TYPE_BUY) || (MarketBook[i].type == BOOK_TYPE_BUY_MARKET))
         {
            m_best_ask_index = i-1;
            FindBestBid();
            break;
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Fast find best bid by best ask                                   |
//+------------------------------------------------------------------+
bool CMarketBook::FindBestBid(void)
{
   m_best_bid_index = -1;
   bool isBestAsk = m_best_ask_index >= 0 && m_best_ask_index < m_depth_total &&
                    (MarketBook[m_best_ask_index].type == BOOK_TYPE_SELL ||
                    MarketBook[m_best_ask_index].type == BOOK_TYPE_SELL_MARKET);
   if(!isBestAsk && m_best_ask_index != -1)return false;
   int bestBid = m_best_ask_index+1;
   bool isBestBid = bestBid >= 0 && bestBid < m_depth_total &&
                    (MarketBook[bestBid].type == BOOK_TYPE_BUY ||
                    MarketBook[bestBid].type == BOOK_TYPE_BUY_MARKET);
   if(isBestBid)
   {
      m_best_bid_index = bestBid;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Get integer property by ENUM_MBOOK_INFO_INTEGER modifier         |
//+------------------------------------------------------------------+
long CMarketBook::InfoGetInteger(ENUM_MBOOK_INFO_INTEGER property)
{
   switch(property)
   {
      case MBOOK_BEST_ASK_INDEX:
         return m_best_ask_index;
      case MBOOK_BEST_BID_INDEX:
         return m_best_bid_index;
      case MBOOK_LAST_ASK_INDEX:
         if(m_best_ask_index == -1)
            return -1;
         else
            return LAST_ASK_INDEX;
      case MBOOK_LAST_BID_INDEX:
         if(m_best_bid_index == -1)
            return -1;
         else
            return LAST_BID_INDEX;
      case MBOOK_DEPTH_TOTAL:
         return m_depth_total;
      case MBOOK_DEPTH_BID:
         return (m_depth_total - m_best_bid_index);
      case MBOOK_DEPTH_ASK:
         return m_best_bid_index;
      case MBOOK_MAX_ASK_VOLUME:
         return Calculation.GetMaxVolAsk();
      case MBOOK_MAX_ASK_VOLUME_INDEX:
         return Calculation.GetMaxVolAskIndex();
      case MBOOK_MAX_BID_VOLUME:
         return Calculation.GetMaxVolBid();
      case MBOOK_MAX_BID_VOLUME_INDEX:
         return Calculation.GetMaxVolBidIndex();
      case MBOOK_BUY_ORDERS:
         return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_BUY_ORDERS);
      case MBOOK_SELL_ORDERS:
         return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_SELL_ORDERS);
      case MBOOK_ASK_VOLUME_TOTAL:
         return Calculation.GetAskVolTotal();
      case MBOOK_BID_VOLUME_TOTAL:
         return Calculation.GetBidVolTotal();
   }
   return 0;
}
//+------------------------------------------------------------------+
//| Get double property by ENUM_MBOOK_INFO_DOUBLE modifier           |
//+------------------------------------------------------------------+
double CMarketBook::InfoGetDouble(ENUM_MBOOK_INFO_DOUBLE property)
{
   switch(property)
   {
      case MBOOK_BEST_ASK_PRICE:
         return MarketBook[m_best_ask_index].price;
      case MBOOK_BEST_BID_PRICE:
         return MarketBook[m_best_bid_index].price;
      case MBOOK_LAST_ASK_PRICE:
         return MarketBook[LAST_ASK_INDEX].price;
      case MBOOK_LAST_BID_PRICE:
         return MarketBook[LAST_BID_INDEX].price;
      case MBOOK_AVERAGE_SPREAD:
         return (m_spread_sum/m_count_refresh);
      case MBOOK_BUY_ORDERS_VOLUME:
         return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_BUY_ORDERS_VOLUME);
      case MBOOK_SELL_ORDERS_VOLUME:
         return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_SELL_ORDERS_VOLUME);
      case MBOOK_OPEN_INTEREST:
         return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_INTEREST);
   }
   return 0.0;  
}

//+------------------------------------------------------------------+
//| Get deviation value by volume. Return 0.0 if deviation is        |
//| infinity (insufficient liquidity)                                |
//+------------------------------------------------------------------+
double CMarketBook::GetDeviationByVol(long vol, ENUM_MBOOK_SIDE side)
{
   if(ArraySize(MarketBook) == 0)return DBL_MAX;
   int best_ask = (int)InfoGetInteger(MBOOK_BEST_ASK_INDEX);
   int last_ask = (int)InfoGetInteger(MBOOK_LAST_ASK_INDEX); 
   int best_bid = (int)InfoGetInteger(MBOOK_BEST_BID_INDEX);
   int last_bid = (int)InfoGetInteger(MBOOK_LAST_BID_INDEX);
   double avrg_price = 0.0;
   long volume_exe = vol;
   if(side == MBOOK_ASK)
   {
      for(int i = best_ask; i >= last_ask; i--)
      {
         long currVol = MarketBook[i].volume < volume_exe ?
                        MarketBook[i].volume : volume_exe ;   
         avrg_price += currVol * MarketBook[i].price;
         volume_exe -= MarketBook[i].volume;
         if(volume_exe <= 0)break;
      }
   }
   else
   {
      for(int i = best_bid; i <= last_bid; i++)
      {
         long currVol = MarketBook[i].volume < volume_exe ?
                        MarketBook[i].volume : volume_exe ;   
         avrg_price += currVol * MarketBook[i].price;
         volume_exe -= MarketBook[i].volume;
         if(volume_exe <= 0)break;
      }
   }
   if(volume_exe > 0)
      return DBL_MAX;
   avrg_price/= (double)vol;
   double deviation = 0.0;
   if(side == MBOOK_ASK)
      deviation = avrg_price - MarketBook[best_ask].price;
   else
      deviation = MarketBook[best_bid].price - avrg_price;
   return deviation;
}

//+------------------------------------------------------------------+
//| Get deviation value by volume. Return 0.0 if deviation is        |
//| infinity (insufficient liquidity)                                |
//+------------------------------------------------------------------+
long CMarketBook::GetVolByDeviation(double deviation, ENUM_MBOOK_SIDE side) {
  if(ArraySize(MarketBook) == 0)
    return 0;

  int best_ask = (int)InfoGetInteger(MBOOK_BEST_ASK_INDEX);
  int last_ask = (int)InfoGetInteger(MBOOK_LAST_ASK_INDEX); 
  double best_ask_price = MarketBook[best_ask].price;
  int best_bid = (int)InfoGetInteger(MBOOK_BEST_BID_INDEX);
  int last_bid = (int)InfoGetInteger(MBOOK_LAST_BID_INDEX);
  double best_bid_price = MarketBook[best_bid].price;
  
  double sum_exe = 0.0;
  long vol_exe = 0;
  if(side == MBOOK_ASK) {
    for(int i = best_ask; i >= last_ask; i--) {
      sum_exe += MarketBook[i].volume*MarketBook[i].price;
     
      if(vol_exe+MarketBook[i].volume > 0) {
        double avg_price = sum_exe/(vol_exe+MarketBook[i].volume);
        double dev_curr = MathAbs(avg_price-best_ask_price);
        if(dev_curr > deviation)
          break;
      }
       
      vol_exe += MarketBook[i].volume;
    }
  }
  else {
    for(int i = best_bid; i <= last_bid; i++)  {
      sum_exe += MarketBook[i].volume*MarketBook[i].price;
     
      if(vol_exe+MarketBook[i].volume > 0) {
        double avg_price = sum_exe/(vol_exe+MarketBook[i].volume);
        double dev_curr = MathAbs(avg_price-best_bid_price);
        if(dev_curr > deviation)
          break;
      }
      
      vol_exe += MarketBook[i].volume;
    }
  }
  
  return vol_exe;
}