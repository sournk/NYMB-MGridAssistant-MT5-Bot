//+------------------------------------------------------------------+
//|                                               CDKAllowedTime.mqh |
//|                                                  Denis Kislitsyn |
//|                               https://kislitsyn.me/personal/algo |
//+------------------------------------------------------------------+

#include <Object.mqh>
#include <Generic\HashMap.mqh>
#include <Arrays\ArrayObj.mqh>

#include "..\Common\DKDatetime.mqh"
#include "..\Common\CDKString.mqh"

enum ENUM_EMPTY_INTERVAL_MODE {
  EMPTY_INTERVAL_MODE_ALLOWED,
  EMPTY_INTERVAL_MODE_NOT_ALLOWED
};

class CDKTimeInt : public CObject {
public:
  datetime From;
  datetime To;

  void Init(string _interval_str) {
    CDKString str;
    str.Assign(_interval_str);
    CArrayString arr;
    str.Split("-", arr);
    From = (arr.Total() > 0) ? StringToTime(arr.At(0)) : 0;
    To = (arr.Total() > 1) ? StringToTime(arr.At(1)) : 0;
  }
  
  bool IsFree() {
    return From == 0 && To == 0;
  }
  
  bool IsTimeIn(const datetime _dt) {
    return IsTimeAfterUpdatedTimeToToday(_dt, From) && !IsTimeAfterUpdatedTimeToToday(_dt, To);
  }
};

class CDKAllowedTime {
protected:
  CHashMap<uint, CArrayObj*> TimeInt;
public:
  ENUM_EMPTY_INTERVAL_MODE   EmptyIntervalMode;
  
  // Constructor & init
  void                       CDKAllowedTime::CDKAllowedTime(void):
                               EmptyIntervalMode(EMPTY_INTERVAL_MODE_ALLOWED) 
                             {};
  void                       CDKAllowedTime::~CDKAllowedTime(void);
  
  int                        CDKAllowedTime::AddIntervalObj(const uint _day_of_week, CDKTimeInt* _time_int);
  int                        CDKAllowedTime::AddIntervalStr(const uint _day_of_week, string _str, const string _sep=";");
  
 
  void                       CDKAllowedTime::AddIntervalObjForAllWeek(CDKTimeInt* _time_int, const uint _start_day_of_week = 0, const uint _end_day_of_week = 6);
  void                       CDKAllowedTime::AddIntervalStrForAllWeek(string _str, const string _sep=";", const uint _start_day_of_week = 0, const uint _end_day_of_week = 6);
  
  void                       CDKAllowedTime::ClearIntervals(const uint _day_of_week);
  void                       CDKAllowedTime::ClearIntervalsAll();

  bool                       CDKAllowedTime::IsTimeAllowed(const datetime _dt);
  bool                       CDKAllowedTime::IsTimeCurrentAllowed();
};

//+------------------------------------------------------------------+
//| Destrictor
//+------------------------------------------------------------------+
void CDKAllowedTime::~CDKAllowedTime(void) {
  ClearIntervalsAll();
}

//+------------------------------------------------------------------+
//| Add CTimeInt to day_of_week
//| Return cnt of time intervals for _day_of_week
//+------------------------------------------------------------------+
int CDKAllowedTime::AddIntervalObj(const uint _day_of_week, CDKTimeInt* _time_int) {
  CArrayObj* arr;
  if(!TimeInt.TryGetValue(_day_of_week, arr)){
    arr = new CArrayObj();
    TimeInt.Add(_day_of_week, arr);
  }

  arr.Add(_time_int); 
  return arr.Total();
}

//+------------------------------------------------------------------+
//| Parse and add string with intervals
//| Return cnt of time intervals for _day_of_week
//+------------------------------------------------------------------+
int CDKAllowedTime::AddIntervalStr(const uint _day_of_week, string _str, const string _sep=";") {
  CDKString str;
  str.Assign(_str);
  CArrayString arr;
  str.Split(_sep, arr);
  
  int cnt = 0;
  for(int i=0;i<arr.Total();i++) {
    CDKTimeInt* time_int = new CDKTimeInt();
    time_int.Init(arr.At(i));
    cnt = AddIntervalObj(_day_of_week, time_int);
  }
  
  return cnt;
}

//+------------------------------------------------------------------+
//| Add CTimeInt to all days of week 0-6
//+------------------------------------------------------------------+
void CDKAllowedTime::AddIntervalObjForAllWeek(CDKTimeInt* _time_int, const uint _start_day_of_week = 0, const uint _end_day_of_week = 6) {
  for(uint i=_start_day_of_week;i<=_end_day_of_week;i++)
    AddIntervalObj(i, _time_int);
}

//+------------------------------------------------------------------+
//| Parse and add string with intervals to all days of week 0-6
//+------------------------------------------------------------------+
void CDKAllowedTime::AddIntervalStrForAllWeek(string _str, const string _sep=";", const uint _start_day_of_week = 0, const uint _end_day_of_week = 6) {
  for(uint i=_start_day_of_week;i<=_end_day_of_week;i++)
    AddIntervalStr(i, _str, _sep);
}


//+------------------------------------------------------------------+
//| Clear all intervals
//+------------------------------------------------------------------+
void CDKAllowedTime::ClearIntervals(const uint _day_of_week) {
  CArrayObj* arr;
  if(TimeInt.TryGetValue(_day_of_week, arr))
    arr.Clear();
}

//+------------------------------------------------------------------+
//| Clear all intervals 
//+------------------------------------------------------------------+
void CDKAllowedTime::ClearIntervalsAll() {
  uint key[];
  CArrayObj* val[];
  TimeInt.CopyTo(key, val);
  for(int i=0;i<ArraySize(val);i++) {
    val[i].Clear();
    delete val[i];   
  }
  
  TimeInt.Clear();
}

//+------------------------------------------------------------------+
//| Is _dt allowed time?
//+------------------------------------------------------------------+
bool CDKAllowedTime::IsTimeAllowed(const datetime _dt) {
  MqlDateTime dt_mql;
  TimeToStruct(_dt, dt_mql);
  
  CArrayObj* arr;
  if(!TimeInt.TryGetValue(dt_mql.day_of_week, arr))
    return EmptyIntervalMode == EMPTY_INTERVAL_MODE_ALLOWED;
  
  for(int i=0;i<arr.Total();i++) {
    CDKTimeInt* time_int = arr.At(i);
    if(time_int.IsTimeIn(_dt))
      return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//| Is TimeCurrent() allowed time?
//+------------------------------------------------------------------+
bool CDKAllowedTime::IsTimeCurrentAllowed() {
  return IsTimeAllowed(TimeCurrent());
}