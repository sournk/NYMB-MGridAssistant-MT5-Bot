//+------------------------------------------------------------------+
//|                                                     Database.mqh |
//|                                                       MoT Studio |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MoT Studio"
#property link      "https://www.mql5.com"
#property version   "1.00"


/*
使用说明
1.打开数据库
CDatabase db(filepath) //读写
CDatabase db(filepath,flag) //自定义标识

2.查询
int v;
double d;
string s;
CDatabaseRequest req = db.Query("select * from table");
req.GetInteger(0, v);
int v2 = req.GetIntegerOrDefault("aa");

int v;
double d;
string s;
bool rc = db.QueryFirst<int, double, string>(v, d, s, "select a,b,c from table");
int v[];
double d[];
string s[];
bool rc = db.Query<int, double, string>(v, d, s, "select a,b,c from table");


3.执行
   db.Execute(sql);//完整的sql
   CDatabaseSentece *s = db.BeginExecute("insert int xxx values(?,?,?);");//模式赋值，个人觉得没什么用

4.事务
   db.BeginTransaction();
   db.Rollback();
   db.Commit();

特别说明：
   SQLite的锁是粗粒度的文件锁，如果多表共用一个数据库，需要注意同步问题。
   a.本类中的类，不建议定义全局变量，否则容易出现5605错误
   b.query后应取出数据，尽早释放，以免其它连接无法获得reserved锁
   c.尽量在事务中Execute，可以规避一些5605错误


5.CDatabaseTable 一个数据表封装
   a.实现版本控制
   创建version表记录各表的版本
   在Constructor中设置
   SqlCreateTable 各版本的Create table sql;
   SqlMoveRecord  迁移sql
   例如 SqlCreateTable[0] = "create table xxx (id);" SqlCreateTable[1] = "create table xxx (id,name);"
   SqlMoveRecord[1] = "insert into xxx (id) select id from sqlitestudio_temp_table";//注意中间均是sqlitestudio_temp_table
   b.封装了getproperty 和 setproperty
   如 GetInteger(id);
   c.提供OnPropertyChange;


DBNULL
数值类会设为0，string 为NULL
*/

#ifdef DATABSE_ENABLE_WRITE_MUTEX
/*Mutex 数据库写入锁*/
#import "kernel32.dll"
ulong CreateMutexW(ulong lpMutexAttributes, bool bInitialOwner, string lpName);
bool ReleaseMutex(ulong mMutex);
bool CloseHandle(ulong hObject);
uint WaitForSingleObject(long hHandle, uint dwMilliseconds);
#import
#endif




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDatabaseRequestCore
  {
public:
   int               mDbHandle;
   int               mHandle;
   bool              mIsReaded;
   string            mSQL;
   int               mError;
public:
                     CDatabaseRequestCore(int dbhandle, string sql);
                    ~CDatabaseRequestCore(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabaseRequestCore::CDatabaseRequestCore(int dbhandle, string sql)
  {
   mDbHandle = dbhandle;
   mSQL = sql;
   mHandle = DatabasePrepare(dbhandle, sql);
   if(mHandle == INVALID_HANDLE)
      mError = GetLastError();

#ifdef _DEBUG
   PrintFormat("New Query    %d: %s", mHandle, sql);
#endif
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabaseRequestCore::~CDatabaseRequestCore(void)
  {
   if(mHandle != INVALID_HANDLE)
      DatabaseFinalize(mHandle);

#ifdef _DEBUG
   PrintFormat("Query Closed %d: %s", mHandle, mSQL);
#endif

   mHandle = INVALID_HANDLE;
   mDbHandle = INVALID_HANDLE;
  }



//+------------------------------------------------------------------+
//| Query                                                            |
//+------------------------------------------------------------------+
class CDatabaseRequest
  {
private:
   CDatabaseRequestCore* mRequest;
public:
                     CDatabaseRequest(CDatabaseRequestCore* req) :mRequest(req) {}
                    ~CDatabaseRequest(void) { delete mRequest; }

   void              operator=(CDatabaseRequestCore* req) {if(CheckPointer(mRequest) == POINTER_DYNAMIC) delete mRequest; mRequest = req; }
public:
   bool              IsAvaliable() const { return mRequest.mHandle != INVALID_HANDLE; }

   bool              IsReaded() { return mRequest.mIsReaded; }

   bool              Read() { bool rd = DatabaseRead(mRequest.mHandle); if(!rd) mRequest.mError = GetLastError(); if(!mRequest.mIsReaded) mRequest.mIsReaded = rd; return rd; }

   template<typename T>
   bool              Read(T& obj) { mRequest.mIsReaded = true; return DatabaseReadBind(mRequest.mHandle, obj); }

   //template<typename T>
   //bool              Bind(int index,T val) {return DatabaseBind(mRequest.mHandle,index,val);}

   //template<typename T>
   //bool              BindArray(int index,T& val[]) {return DatabaseBindArray(mRequest.mHandle,index,val);}

   void              Close() { DatabaseFinalize(mRequest.mHandle); mRequest.mHandle = INVALID_HANDLE; }

   int               ColumnsCount() { return DatabaseColumnsCount(mRequest.mHandle); }

   string            ColumnName(int column) { string name = NULL; DatabaseColumnName(mRequest.mHandle, column, name); return name; }

   ENUM_DATABASE_FIELD_TYPE   ColumnType(int column) { return DatabaseColumnType(mRequest.mHandle, column); }

   int               ColumnSize(int column) { return DatabaseColumnSize(mRequest.mHandle, column); }

   int               GetColumnIndex(string field);

   template<typename T>
   T                 CDatabaseRequest::GetValueOrDefault(int findex = 0);

   template<typename T>
   bool              CDatabaseRequest::GetValue(T& val, int findex = 0);
   bool              CDatabaseRequest::GetValue(int& val, int findex = 0) { return IsAvaliable() ? GetInteger(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(uint& val, int findex = 0) { return IsAvaliable() ? GetInteger(findex, val) : false; }

   bool              CDatabaseRequest::GetValue(short& val, int findex = 0) { return IsAvaliable() ? GetShort(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(ushort& val, int findex = 0) { return IsAvaliable() ? GetShort(findex, val) : false; }

   bool              CDatabaseRequest::GetValue(char& val, int findex = 0) { return IsAvaliable() ? GetChar(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(uchar& val, int findex = 0) { return IsAvaliable() ? GetChar(findex, val) : false; }

   bool              CDatabaseRequest::GetValue(long& val, int findex = 0) { return IsAvaliable() ? GetLong(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(ulong& val, int findex = 0) { return IsAvaliable() ? GetLong(findex, val) : false; }

   bool              CDatabaseRequest::GetValue(datetime& val, int findex = 0) { return IsAvaliable() ? GetTime(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(float& val, int findex = 0)  { return IsAvaliable() ? GetFloat(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(double& val, int findex = 0) { return IsAvaliable() ? GetDouble(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(bool& val, int findex = 0) { return IsAvaliable() ? GetBoolean(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(color& val, int findex = 0) { return IsAvaliable() ? GetInteger(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(string& val, int findex = 0) { return IsAvaliable() ? GetString(findex, val) : false; }
   bool              CDatabaseRequest::GetValue(char& val[], int findex = 0) { return IsAvaliable() ? GetBlob(findex, val) : false; }

   string            GetStringOrDefault(string field, string defval = NULL);
   string            GetStringOrDefault(int index, string defval = NULL);
   bool              GetString(string field, string& val);
   bool              GetString(int index, string& val);

   bool              GetBooleanOrDefault(string field, bool defaultval = false);
   bool              GetBooleanOrDefault(int index, bool defaultval = false);
   bool              GetBoolean(string field, bool& val);
   bool              GetBoolean(int index, bool& val);

   int               GetIntegerOrDefault(string field, const int defaultval = 0);
   int               GetIntegerOrDefault(int index, const int defaultval = 0);
   bool              GetInteger(string field, int& val);
   bool              GetInteger(int index, int& val);


   short             GetShortOrDefault(string field, const short defaultval = 0) { return (short)GetIntegerOrDefault(field, defaultval); }
   short             GetShortOrDefault(int index, const short defaultval = 0) { return (short)GetIntegerOrDefault(index, defaultval); }
   bool              GetShort(string field, short& val) { int v; bool r = GetInteger(field, v); val = (short)v; return r;}
   bool              GetShort(int index, short& val) { int v; bool r = GetInteger(index, v); val = (short)v; return r;}


   char              GetCharOrDefault(string field, const char defaultval = 0) { return (char)GetIntegerOrDefault(field, defaultval); }
   char              GetCharOrDefault(int index, const char defaultval = 0) { return (char)GetIntegerOrDefault(index, defaultval); }
   bool              GetChar(string field, char& val) { int v; bool r = GetInteger(field, v); val = (char)v; return r;}
   bool              GetChar(int index, char& val) { int v; bool r = GetInteger(index, v); val = (char)v; return r;}


   long              GetLongOrDefault(string field, long defaultval = 0);
   long              GetLongOrDefault(int index, long defaultval = 0);
   bool              GetLong(string field, long& val);
   bool              GetLong(int index, long& val);

   double            GetDoubleOrDefault(string field, double defaultval = 0);
   double            GetDoubleOrDefault(int index, double defaultval = 0);
   bool              GetDouble(string field, double& val);
   bool              GetDouble(int index, double& val);

   float             GetFloatOrDefault(string field, float defaultval = 0) { return (float)GetDoubleOrDefault(field, defaultval); }
   float             GetFloatOrDefault(int index, float defaultval = 0) { return (float)GetDoubleOrDefault(index, defaultval); }
   bool              GetFloat(string field, float& val) { double v; bool r = GetDouble(field, v); val = (float)v; return r;}
   bool              GetFloat(int index, float& val) { double v; bool r = GetDouble(index, v); val = (float)v; return r;}

   ulong             GetTicket(string field) { return GetLongOrDefault(field); }

   //返回数组大小
   bool              GetBlob(string field, char& data[]);
   bool              GetBlob(int index, char& data[]);

   datetime          GetTimeOrDefault(string field, datetime defaultval = 0);
   datetime          GetTimeOrDefault(int index, datetime defaultval = 0);
   bool              GetTime(string field, datetime& val);
   bool              GetTime(int index, datetime& val);

   ENUM_TIMEFRAMES   GetTimeFrame(string field) { int val = GetIntegerOrDefault(field); return val == 0 ? _Period : (ENUM_TIMEFRAMES)val; }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseRequest::GetColumnIndex(string field)
  {
   if(mRequest.mHandle == INVALID_HANDLE || !mRequest.mIsReaded)
      return -1;

   int total = DatabaseColumnsCount(mRequest.mHandle);
   for(int i = 0; i < total; i++)
     {
      string nm;
      if(DatabaseColumnName(mRequest.mHandle, i, nm) && nm == field)
         return i;
     }
   return -1;
  }

template<typename T>
T CDatabaseRequest::GetValueOrDefault(int findex=0)
  {
   T val;
   ZeroMemory(val);
   if(!IsAvaliable())
      return val;

   string n = typename(T);
   if(n == "double" || n == "float")
     {
      double d = 0;
      GetDouble(findex, d);

      return (T)d;
     }
   else
      if(n == "long" || n == "ulong")
        {
         long d = 0;
         GetLong(findex, d);

         return (T)d;
        }
      else
         if(n == "int" || n == "bool" || n == "uint" || n == "enum" || n == "char" || n == "short" || n == "color" || n == "uchar" || n == "ushort")
           {
            int d = 0;
            GetInteger(findex, d);

            return (T)d;
           }
         else
            if(n == "string")
              {
               string d = NULL;
               GetString(findex, d);

               return (T)d;
              }
            else
               if(n == "datetime")
                 {
                  datetime d = 0;
                  GetTime(findex, d);
                  return (T)d;
                 }


   return val;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool CDatabaseRequest::GetValue(T& val, int findex = 0)
  {
   ZeroMemory(val);
   if(!IsAvaliable())
      return false;

   if(!IsReaded())
      Read();

   ENUM_DATABASE_FIELD_TYPE type = ColumnType(findex);
   switch(type)
     {
      case DATABASE_FIELD_TYPE_NULL:
      case DATABASE_FIELD_TYPE_INVALID:
      case DATABASE_FIELD_TYPE_BLOB:
         return false;

      case DATABASE_FIELD_TYPE_INTEGER:
        {
         int d = 0;
         bool r = GetInteger(findex, d);
         val = (T)d;
         return r;
        }

      case DATABASE_FIELD_TYPE_FLOAT:
        {
         double d = 0;
         bool r = GetDouble(findex, d);
         val = (T)d;
         return r;
        }

      case DATABASE_FIELD_TYPE_TEXT:
        {
         string d;
         bool r = GetString(findex, d);
         val = (T)d;
         return r;
        }
      default:
         return false;
     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabaseRequest::GetStringOrDefault(string field, string defval = NULL)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return defval;

   string val = "";
   return DatabaseColumnText(mRequest.mHandle, idx, val) ? val : defval;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabaseRequest::GetStringOrDefault(int idx, string defval = NULL)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;

   if(idx < 0)
      return defval;

   string val = "";
   return DatabaseColumnText(mRequest.mHandle, idx, val) ? val : defval;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetString(string field, string& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   return DatabaseColumnText(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetString(int idx, string& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   return DatabaseColumnText(mRequest.mHandle, idx, val);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool CDatabaseRequest::GetStrings(string field, string& vals[])
//  {
////如果没有开始读，则自动读第一条
//   if(!mRequest.mIsReaded && !Read())
//      return false;
//
//   int idx = GetColumnIndex(field);
//   if(idx < 0)
//      return false;
//
//   ArrayResize(vals, 0, 10);
//   do
//     {
//      string val;
//
//      if(!DatabaseColumnText(mRequest.mHandle, idx, val))
//         return false;
//
//      ArrayResize(vals, ArraySize(vals) + 1);
//      vals[ArraySize(vals) - 1] = val;
//     }
//   while(Read());
//
//   return true;
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseRequest::GetIntegerOrDefault(string field, int defval = 0)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return defval;

   int val;
   return DatabaseColumnInteger(mRequest.mHandle, idx, val) ? val : defval;
  }
  
int CDatabaseRequest::GetIntegerOrDefault(int idx, int defval = 0)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;
 
   if(idx < 0)
      return defval;

   int val;
   return DatabaseColumnInteger(mRequest.mHandle, idx, val) ? val : defval;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetInteger(string field, int& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   return DatabaseColumnInteger(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetInteger(int idx, int& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   return DatabaseColumnInteger(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool CDatabaseRequest::GetIntegers(string field, int& vals[])
//  {
////如果没有开始读，则自动读第一条
//   if(!mRequest.mIsReaded && !Read())
//      return false;
//
//   int idx = GetColumnIndex(field);
//   if(idx < 0)
//      return false;
//
//   ArrayResize(vals, 0, 10);
//   do
//     {
//      int val;
//
//      if(!DatabaseColumnInteger(mRequest.mHandle, idx, val))
//         return false;
//
//      ArrayResize(vals, ArraySize(vals) + 1);
//      vals[ArraySize(vals) - 1] = val;
//     }
//   while(Read());
//
//   return true;
//  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CDatabaseRequest::GetLongOrDefault(string field, long defval = NULL)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return defval;

   long val;
   return DatabaseColumnLong(mRequest.mHandle, idx, val) ? val : defval;
  }


long CDatabaseRequest::GetLongOrDefault(int idx, long defval = NULL)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;
 
   if(idx < 0)
      return defval;

   long val;
   return DatabaseColumnLong(mRequest.mHandle, idx, val) ? val : defval;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetLong(string field, long& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   return DatabaseColumnLong(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetLong(int idx, long& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   return DatabaseColumnLong(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CDatabaseRequest::GetTimeOrDefault(string field, datetime defaultval = 0)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defaultval;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return defaultval;

   ENUM_DATABASE_FIELD_TYPE type = ColumnType(idx);

   datetime time;
   if(type == DATABASE_FIELD_TYPE_INTEGER && DatabaseColumnLong(mRequest.mHandle, idx, time))
      return time;

   string str;
   if(type == DATABASE_FIELD_TYPE_TEXT && DatabaseColumnText(mRequest.mHandle, idx, str))
      return StringToTime(str);

   return defaultval;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CDatabaseRequest::GetTimeOrDefault(int idx, datetime defaultval = 0)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defaultval;

   if(idx < 0)
      return defaultval;

   ENUM_DATABASE_FIELD_TYPE type = ColumnType(idx);

   datetime time;
   if(type == DATABASE_FIELD_TYPE_INTEGER && DatabaseColumnLong(mRequest.mHandle, idx, time))
      return time;

   string str;
   if(type == DATABASE_FIELD_TYPE_TEXT && DatabaseColumnText(mRequest.mHandle, idx, str))
      return StringToTime(str);

   return defaultval;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetTime(string field, datetime& time)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   ENUM_DATABASE_FIELD_TYPE type = ColumnType(idx);

   if(type == DATABASE_FIELD_TYPE_INTEGER && DatabaseColumnLong(mRequest.mHandle, idx, time))
      return true;

   string str;
   if(type == DATABASE_FIELD_TYPE_TEXT && DatabaseColumnText(mRequest.mHandle, idx, str))
     {
      time = StringToTime(str);
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetTime(int idx, datetime& time)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   ENUM_DATABASE_FIELD_TYPE type = ColumnType(idx);

   if(type == DATABASE_FIELD_TYPE_INTEGER && DatabaseColumnLong(mRequest.mHandle, idx, time))
      return true;

   string str;
   if(type == DATABASE_FIELD_TYPE_TEXT && DatabaseColumnText(mRequest.mHandle, idx, str))
     {
      time = StringToTime(str);
      return true;
     }

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool CDatabaseRequest::GetTimes(string field, datetime& vals[])
//  {
////如果没有开始读，则自动读第一条
//   if(!mRequest.mIsReaded && !Read())
//      return false;
//
//   int idx = GetColumnIndex(field);
//   if(idx < 0)
//      return false;
//
//   ENUM_DATABASE_FIELD_TYPE type = ColumnType(idx);
//   ArrayResize(vals, 0, 10);
//   do
//     {
//      datetime time = 0;
//      if(type == DATABASE_FIELD_TYPE_INTEGER)
//         time = DatabaseColumnLong(mRequest.mHandle, idx, time) ? time : 0;
//      string str;
//      if(type == DATABASE_FIELD_TYPE_TEXT)
//         time = DatabaseColumnText(mRequest.mHandle, idx, str) ? StringToTime(str) : 0;
//
//      ArrayResize(vals, ArraySize(vals) + 1);
//      vals[ArraySize(vals) - 1] = time;
//     }
//   while(Read());
//
//   return true;
//  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetBooleanOrDefault(string field, bool defval = false)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return defval;

   int val;
   return DatabaseColumnInteger(mRequest.mHandle, idx, val) ? val > 0 : defval;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetBoolean(string field, bool& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   int v = 0;
   bool r = DatabaseColumnInteger(mRequest.mHandle, idx, v);
   val = v;
   return r;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetBoolean(int idx, bool& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   int v = 0;
   bool r = DatabaseColumnInteger(mRequest.mHandle, idx, v);
   val = v;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDatabaseRequest::GetDoubleOrDefault(string field, double defval = 0.000000)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return defval;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return defval;

   double val;
   return DatabaseColumnDouble(mRequest.mHandle, idx, val) ? val : defval;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetDouble(string field, double& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   return DatabaseColumnDouble(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetDouble(int idx, double& val)
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   return DatabaseColumnDouble(mRequest.mHandle, idx, val);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetBlob(string field,char &val[])
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   int idx = GetColumnIndex(field);
   if(idx < 0)
      return false;

   return (bool)DatabaseColumnBlob(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseRequest::GetBlob(int idx,char &val[])
  {
//如果没有开始读，则自动读第一条
   if(!mRequest.mIsReaded && !Read())
      return false;

   if(idx < 0)
      return false;

   return (bool)DatabaseColumnBlob(mRequest.mHandle, idx, val);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDatabaseSentenceCore
  {
public:
   int               mHandle;
   int               mIndex;
   int               mError;

public:
                     CDatabaseSentenceCore(int dbhandle, string sql) { mHandle = DatabasePrepare(dbhandle, sql); if(mHandle == INVALID_HANDLE) mError = GetLastError(); }
                    ~CDatabaseSentenceCore(void) { if(mHandle != INVALID_HANDLE) DatabaseFinalize(mHandle); mHandle = INVALID_HANDLE; }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDatabaseSentence
  {
private:
   CDatabaseSentenceCore* mSentence;
public:
                     CDatabaseSentence(CDatabaseSentenceCore* c) :mSentence(c) {}
                    ~CDatabaseSentence(void) { delete mSentence; }

public:
   template <typename T>
   int               Bind(int index, T value) { return DatabaseBind(mSentence.mHandle, index, value) ? ERR_SUCCESS : GetLastError(); }

   template <typename T>
   int               Bind(T value) { return DatabaseBind(mSentence.mHandle, mSentence.mIndex++, value) ? ERR_SUCCESS : GetLastError(); }

   int               Execute();
  };



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseSentence::Execute(void)
  {
   if(DatabaseRead(mSentence.mHandle))
      return ERR_SUCCESS;
   int rc = GetLastError();
   return rc == ERR_DATABASE_NO_MORE_DATA ? ERR_SUCCESS : rc;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDatabase
  {
private:
   string            mdbPath;
   int               mHandle;
   uint              mFlag;
   bool              mIsReadonly;
   bool              mTransactionBegin;

   string            mMutexName;
   ulong             mMutex;


private:
   //返回size-1
   template<typename T>
   int               ArrayAppend(T& arr[]) { int sz = ArrayResize(arr, ArraySize(arr)+1); return sz == -1 ? -1 : sz - 1;}
public:
                     CDatabase(string db, uint flag = DATABASE_OPEN_CREATE | DATABASE_OPEN_READWRITE);
                    ~CDatabase(void);

   bool              IsAvaliable() const { return mHandle != INVALID_HANDLE; }

   bool              HasTable(string tab) const { return DatabaseTableExists(mHandle, tab); }

   bool              Miggrate(string migdb = NULL);

   int               Execute(string sql);

   int               ExecuteForce(string sql, uint ms = 500);

   CDatabaseSentenceCore* BeginExecute(string sql);

   CDatabaseRequestCore* Query(string sql);

   //////////////////////////////////////////////////////////////////////


   template<typename T>
   bool              CDatabase::QueryFirstObject(T& val, string sql);


   template<typename T>
   bool              QueryObjects(T& val[], string sql);


   template<typename T>
   bool              QueryFirst(T& v, string sql);
   template<typename T>
   bool              Query(T& val[], string sql);

   template<typename T1, typename T2>
   bool              QueryFirst(T1& v1, T2& v2, string sql);
   template<typename T1, typename T2>
   bool              Query(T1& v1[], T2& v2[], string sql);

   template<typename T1, typename T2, typename T3>
   bool              QueryFirst(T1& v1, T2& v2, T3& v3, string sql);
   template<typename T1, typename T2, typename T3>
   bool              Query(T1& v1[], T2& v2[], T3& v3[], string sql);

   template<typename T1, typename T2, typename T3, typename T4>
   bool              QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, string sql);
   template<typename T1, typename T2, typename T3, typename T4>
   bool              Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], string sql);

   template<typename T1, typename T2, typename T3, typename T4, typename T5>
   bool              QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, string sql);
   template<typename T1, typename T2, typename T3, typename T4, typename T5>
   bool              Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], string sql);

   template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6>
   bool              QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, T6& v6, string sql);
   template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6>
   bool              Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], T6& v6[], string sql);

   template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7>
   bool              QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, T6& v6, T7& v7, string sql);
   template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7>
   bool              Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], T6& v6[], T7& v7[], string sql);

   template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8>
   bool              QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, T6& v6, T7& v7, T8& v8, string sql);
   template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8>
   bool              Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], T6& v6[], T7& v7[], T8& v8[], string sql);




   //////////////////////////////////////////////////////////////////////
   int               BeginTransaction();

   int               Commit();

   int               Rollback();

   void              Close();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabase::CDatabase(string db, uint flag) :mFlag(flag)
  {
   mIsReadonly = false;
   mTransactionBegin = false;
   mdbPath = db;


#ifdef DATABSE_ENABLE_WRITE_MUTEX
   uchar data[], key[];
   StringToCharArray((flag & DATABASE_OPEN_COMMON) == 0 ? TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + db : TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\MQL5\\Files\\" + db, data);
   ArrayResize(data, ArraySize(data) - 1);

   CryptEncode(CRYPT_HASH_MD5, data, key, key);
   int total = ArraySize(key);
   for(int i = 0; i < total; i++)
      mMutexName += StringFormat("%02x", key[i]);
   mMutex = CreateMutexW(0, false, mMutexName);
#endif

//mFlag = flag;
   if((flag & DATABASE_OPEN_READONLY) != 0 && (flag & DATABASE_OPEN_READWRITE) == 0)
      mIsReadonly = true;

   mHandle = DatabaseOpen(db, flag);

#ifdef _DEBUG
   PrintFormat("Database Open : %s Flag : %x", db, flag);
#endif
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabase::~CDatabase(void)
  {
   Close();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::Miggrate(string migdb = NULL)
  {
   if(migdb == NULL)
      migdb = mdbPath + ".mig";

   int ver = 0;
   if(HasTable("__Miggration__"))
      QueryFirst<int>(ver, "SELECT MAX(Version) FROM __Miggration__");

   string sqls[];
   int ids[];
   CDatabase db(migdb, mFlag & ~DATABASE_OPEN_READWRITE);
   bool rr = db.Query<int, string>(ids, sqls, StringFormat("SELECT Version, Sql FROM miggrate WHERE Version>%d", ver));


   int total = ArraySize(sqls);
   BeginTransaction();
   for(int i = 0; i < total; i++)
     {
      Execute(sqls[i]);
      Execute(StringFormat("INSERT INTO __Miggration__ (Version, UpdateTime, SQL) VALUES(%d, '%s', '%s');", ids[i], SQLiteTimeStr(TimeLocal()), sqls[i]));
     }
   Commit();

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabaseRequestCore* CDatabase::Query(string sql)
  {
   return new CDatabaseRequestCore(mHandle, sql);
  }

template<typename T1>
bool CDatabase::QueryFirst(T1& v1, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0);
  }
template<typename T1>
bool CDatabase::Query(T1& v1[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      if(z1 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0))
         return false;
     }
   return true;
  }

template<typename T1, typename T2>
bool CDatabase::QueryFirst(T1& v1, T2& v2, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1);
  }
template<typename T1, typename T2>
bool CDatabase::Query(T1& v1[], T2& v2[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      if(z1 == -1 || z2 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1))
         return false;
     }
   return true;
  }

template<typename T1, typename T2, typename T3>
bool CDatabase::QueryFirst(T1& v1, T2& v2, T3& v3, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1) && req.GetValue(v3, 2);
  }
template<typename T1, typename T2, typename T3>
bool CDatabase::Query(T1& v1[], T2& v2[], T3& v3[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   ArrayResize(v3, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      int z3 = ArrayAppend(v3);
      if(z1 == -1 || z2 == -1 || z3 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1) || !req.GetValue(v3[z3], 2))
         return false;
     }
   return true;
  }

template<typename T1, typename T2, typename T3, typename T4>
bool CDatabase::QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1) && req.GetValue(v3, 2) && req.GetValue(v4, 3);
  }
template<typename T1, typename T2, typename T3, typename T4>
bool CDatabase::Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   ArrayResize(v3, 0, 10);
   ArrayResize(v4, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      int z3 = ArrayAppend(v3);
      int z4 = ArrayAppend(v4);
      if(z1 == -1 || z2 == -1 || z3 == -1 || z4 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1) || !req.GetValue(v3[z3], 2) || !req.GetValue(v4[z4], 3))
         return false;
     }
   return true;
  }

template<typename T1, typename T2, typename T3, typename T4, typename T5>
bool CDatabase::QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1) && req.GetValue(v3, 2) && req.GetValue(v4, 3) && req.GetValue(v5, 4);
  }
template<typename T1, typename T2, typename T3, typename T4, typename T5>
bool CDatabase::Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   ArrayResize(v3, 0, 10);
   ArrayResize(v4, 0, 10);
   ArrayResize(v5, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      int z3 = ArrayAppend(v3);
      int z4 = ArrayAppend(v4);
      int z5 = ArrayAppend(v5);
      if(z1 == -1 || z2 == -1 || z3 == -1 || z4 == -1 || z5 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1) || !req.GetValue(v3[z3], 2) || !req.GetValue(v4[z4], 3) || !req.GetValue(v5[z5], 4))
         return false;
     }
   return true;
  }

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6>
bool CDatabase::QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, T6& v6, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1) && req.GetValue(v3, 2) && req.GetValue(v4, 3) && req.GetValue(v5, 4) && req.GetValue(v6, 5);
  }
template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6>
bool CDatabase::Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], T6& v6[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   ArrayResize(v3, 0, 10);
   ArrayResize(v4, 0, 10);
   ArrayResize(v5, 0, 10);
   ArrayResize(v6, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      int z3 = ArrayAppend(v3);
      int z4 = ArrayAppend(v4);
      int z5 = ArrayAppend(v5);
      int z6 = ArrayAppend(v6);
      if(z1 == -1 || z2 == -1 || z3 == -1 || z4 == -1 || z5 == -1 || z6 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1) || !req.GetValue(v3[z3], 2) || !req.GetValue(v4[z4], 3) || !req.GetValue(v5[z5], 4) || !req.GetValue(v6[z6], 5))
         return false;
     }
   return true;
  }

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7>
bool CDatabase::QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, T6& v6, T7& v7, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1) && req.GetValue(v3, 2) && req.GetValue(v4, 3) && req.GetValue(v5, 4) && req.GetValue(v6, 5) && req.GetValue(v7, 6);
  }
template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7>
bool CDatabase::Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], T6& v6[], T7& v7[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   ArrayResize(v3, 0, 10);
   ArrayResize(v4, 0, 10);
   ArrayResize(v5, 0, 10);
   ArrayResize(v6, 0, 10);
   ArrayResize(v7, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      int z3 = ArrayAppend(v3);
      int z4 = ArrayAppend(v4);
      int z5 = ArrayAppend(v5);
      int z6 = ArrayAppend(v6);
      int z7 = ArrayAppend(v7);
      if(z1 == -1 || z2 == -1 || z3 == -1 || z4 == -1 || z5 == -1 || z6 == -1 || z7 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1) || !req.GetValue(v3[z3], 2) || !req.GetValue(v4[z4], 3) || !req.GetValue(v5[z5], 4) || !req.GetValue(v6[z6], 5) || !req.GetValue(v7[z7], 6))
         return false;
     }
   return true;
  }

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8>
bool CDatabase::QueryFirst(T1& v1, T2& v2, T3& v3, T4& v4, T5& v5, T6& v6, T7& v7, T8& v8, string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   return req.IsAvaliable() && req.GetValue(v1, 0) && req.GetValue(v2, 1) && req.GetValue(v3, 2) && req.GetValue(v4, 3) && req.GetValue(v5, 4) && req.GetValue(v6, 5) && req.GetValue(v7, 6) && req.GetValue(v8, 7);
  }
template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8>
bool CDatabase::Query(T1& v1[], T2& v2[], T3& v3[], T4& v4[], T5& v5[], T6& v6[], T7& v7[], T8& v8[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);
   if(!req.IsAvaliable())
      return false;
   ArrayResize(v1, 0, 10);
   ArrayResize(v2, 0, 10);
   ArrayResize(v3, 0, 10);
   ArrayResize(v4, 0, 10);
   ArrayResize(v5, 0, 10);
   ArrayResize(v6, 0, 10);
   ArrayResize(v7, 0, 10);
   ArrayResize(v8, 0, 10);
   while(req.Read())
     {
      int z1 = ArrayAppend(v1);
      int z2 = ArrayAppend(v2);
      int z3 = ArrayAppend(v3);
      int z4 = ArrayAppend(v4);
      int z5 = ArrayAppend(v5);
      int z6 = ArrayAppend(v6);
      int z7 = ArrayAppend(v7);
      int z8 = ArrayAppend(v8);
      if(z1 == -1 || z2 == -1 || z3 == -1 || z4 == -1 || z5 == -1 || z6 == -1 || z7 == -1 || z8 == -1)
         return false;
      if(!req.GetValue(v1[z1], 0) || !req.GetValue(v2[z2], 1) || !req.GetValue(v3[z3], 2) || !req.GetValue(v4[z4], 3) || !req.GetValue(v5[z5], 4) || !req.GetValue(v6[z6], 5) || !req.GetValue(v7[z7], 6) || !req.GetValue(v8[z8], 7))
         return false;
     }
   return true;
  }



//////////////////////////////////////////////////////////////////////////////
template<typename T>
bool CDatabase::QueryFirstObject(T &val,string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);

   return req.IsAvaliable() && Read(val);
  }


template<typename T>
bool CDatabase::QueryObjects(T& val[], string sql)
  {
   CDatabaseRequest req = new CDatabaseRequestCore(mHandle, sql);

   if(!req.IsAvaliable())
      return false;

   ArrayResize(val, 0, 10);

   int sz = ArraySize(val);
   do
      sz = ArrayAppend(val);
   while(req.Read(val[sz]));

   ArrayResize(val, ArraySize(val) - 1);
   return ArraySize(val) > 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDatabase::Close(void)
  {
   if(mHandle != INVALID_HANDLE)
      DatabaseClose(mHandle);

#ifdef _DEBUG
   PrintFormat("Database Close : %s", mdbPath);
#endif

   mHandle = INVALID_HANDLE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabase::BeginTransaction(void)
  {
   if(mIsReadonly)
      return ERR_DATABASE_READONLY;

   if(mTransactionBegin)
      return ERR_SUCCESS;

#ifdef DATABSE_ENABLE_WRITE_MUTEX
   WaitForSingleObject(mMutex, -1);
#endif
   mTransactionBegin = DatabaseTransactionBegin(mHandle);
   return mTransactionBegin ? ERR_SUCCESS : GetLastError();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabase::Commit(void)
  {
   if(mIsReadonly)
      return ERR_DATABASE_READONLY;

   if(!mTransactionBegin)
      return ERR_DATABASE_ERROR;

   int rc = DatabaseTransactionCommit(mHandle) ? ERR_SUCCESS : GetLastError();

#ifdef DATABSE_ENABLE_WRITE_MUTEX
   ReleaseMutex(mMutex);
#endif

   mTransactionBegin = false;
   return rc;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabase::Rollback(void)
  {
   if(mIsReadonly)
      return ERR_DATABASE_READONLY;

   if(!mTransactionBegin)
      return ERR_DATABASE_ERROR;

   return DatabaseTransactionRollback(mHandle) ? ERR_SUCCESS : GetLastError();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabaseSentenceCore* CDatabase::BeginExecute(string sql)
  {
   return new CDatabaseSentenceCore(mHandle, sql);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabase::Execute(string sql)
  {
   if(mIsReadonly)
      return ERR_DATABASE_READONLY;

#ifdef DATABSE_ENABLE_WRITE_MUTEX
   uint wr = WaitForSingleObject(mMutex, 1500);
   if(wr == 0x00000102)
      Print("Database Mutex TimeOut:", sql);
#endif

   StringReplace(sql, "'(null)'", "NULL");
   StringReplace(sql, "\"(null)\"", "NULL");
   int rc = DatabaseExecute(mHandle, sql) ? ERR_SUCCESS : GetLastError();
   if(rc != ERR_SUCCESS)
      Print("DataBase Error [", mdbPath, "] ", rc, " sql= ", sql);

#ifdef DATABSE_ENABLE_WRITE_MUTEX
   ReleaseMutex(mMutex);
#endif
   return rc;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabase::ExecuteForce(string sql, uint ms)
  {
   if(DatabaseExecute(mHandle, sql))
      return ERR_SUCCESS;

   StringReplace(sql, "'(null)'", "NULL");
   StringReplace(sql, "\"(null)\"", "NULL");

   int rc = GetLastError();

   ulong st = GetTickCount64();
   for(int i = 0; rc == ERR_DATABASE_BUSY && GetTickCount64() - st < ms; i++)
      rc = DatabaseExecute(mHandle, sql) ? ERR_SUCCESS : GetLastError();

   Print("DataBase Force Cost ", GetTickCount64() - st, "ms, Return=", rc, " sql= ", sql);
   return rc;
  }

//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDatabaseTable
  {
protected:
   string            mDbPath;

   string            mValueSql;

   int               mLastError;

   string            Table;
private:
   void              EnsureVersionTable();

   int               GetColumnIndex(int reqh,string field);
protected:
   virtual string    GetValueSql() = NULL;

   //virtual string    SetValueSql(int property, bool val) {return SetValueSql(property,(int)val);}

   ///virtual string    SetValueSql(int property, int val) {return NULL;}

   virtual string    SetValueSql(string property, long val) {return NULL;}

   virtual string    SetValueSql(string property, double val) {return NULL;}

   virtual string    SetValueSql(string property, string val) {return NULL;}


protected:
   string            SqlCreateTable[];
   string            SqlMoveRecord[];

   virtual bool      OnMiggrate();
public:
                     CDatabaseTable(void);
                    ~CDatabaseTable(void);

protected:
   int               GetVersion(string table);

   void              SetVersion(string table,int ver);

   virtual void      OnPropertyChanged(string property) {};
public:
   string            GetString(string property,string defaultval=NULL);

   bool              SetString(string property,string val);

   int               GetInteger(string property,int defaultval=0);

   bool              SetInteger(string property,int val);

   bool              GetBoolean(string property,bool defaultval=false);

   bool              SetBoolean(string property,bool val);

   long              GetLong(string property,long defaultval=0);

   bool              SetLong(string property,long val);


   ENUM_TIMEFRAMES   GetTimeFrame(string property) {int val = GetInteger(property); return val == 0 ? _Period : (ENUM_TIMEFRAMES)val;}

   ulong             GetTicket(string property) {return GetLong(property,0);}

   double            GetDouble(string property,double defaultval=0);


   bool              SetDouble(string property,double val);

   int               Execute(string sql);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabaseTable::CDatabaseTable(void)
  {
   mDbPath = StringFormat("Strategy\\%s_%I64u.dat",_Symbol, AccountInfoInteger(ACCOUNT_LOGIN));
//bool r = FileCopy(StringFormat("strategy_%d.dat", AccountInfoInteger(ACCOUNT_LOGIN)),0,mDbPath,FILE_REWRITE );

   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return;

   if(!db.HasTable("Version"))
      db.Execute("create table if not exists Version (Name TEXT PRIMARY KEY, Version INTEGER DEFAULT (0));");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabaseTable::~CDatabaseTable(void)
  {
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::OnMiggrate()
  {
   int sz = ArraySize(SqlCreateTable);
   int sz2 = ArraySize(SqlMoveRecord);

   if(sz != sz2 || sz <= 0)
      return false;

   string gbn = "DB_MIGGRATE_" + mDbPath;

   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;


   if(!db.HasTable(Table))
     {
      int rc = db.Execute(SqlCreateTable[sz-1]);
      SetVersion(Table,sz);
      return rc == ERR_SUCCESS;
     }

//10秒内不迁移
   if(GlobalVariableCheck(gbn) && TimeLocal() - GlobalVariableGet(gbn) < 10)
      return false;

   GlobalVariableSet(gbn, TimeLocal());

   int ver = GetVersion(Table);
   for(int i=ver; i<sz; i++)
     {
      if(SqlMoveRecord[i] == NULL || StringLen(SqlMoveRecord[i]) == 0)
         continue;
      string sql = StringFormat("ALTER TABLE %s RENAME TO sqlitestudio_temp_table; %s %s DROP TABLE sqlitestudio_temp_table;",Table,SqlCreateTable[i], SqlMoveRecord[i]);
      if(ERR_SUCCESS == db.Execute(sql))
         SetVersion(Table,sz);;

      //db.Execute("DROP TABLE sqlitestudio_temp_table;");
     }

   GlobalVariableDel(gbn);
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseTable::GetVersion(string table)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return 1;

   CDatabaseRequest req = db.Query(StringFormat("select Version from Version where Name='%s'",table));
   if(!req.IsAvaliable() || !req.Read())
     {
      mLastError = GetLastError();
      return 1;
     }

   return req.GetIntegerOrDefault("Version",1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDatabaseTable::SetVersion(string table,int ver)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return ;

   int rc = db.Execute(StringFormat("replace into Version values('%s',%d)",table,ver));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseTable::GetColumnIndex(int reqh,string field)
  {
   if(reqh == INVALID_HANDLE)
      return -1;

   int total = DatabaseColumnsCount(reqh);
   for(int i=0; i<total; i++)
     {
      string nm;
      if(DatabaseColumnName(reqh,i,nm) && nm == field)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseTable::GetInteger(string property,int defaultval=0)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return defaultval;

   string sql = GetValueSql();
   if(sql == NULL)
      return defaultval;

   CDatabaseRequest req = db.Query(sql);
   if(!req.IsAvaliable() || !req.Read())
     {
      mLastError = GetLastError();
      return defaultval;
     }

   return req.GetIntegerOrDefault(property,defaultval);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::SetInteger(string property,int val)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;

   string sql = SetValueSql(property,val);
   if(sql == NULL)
      return false;

   db.BeginTransaction();
   mLastError = db.ExecuteForce(sql);
   db.Commit();
   OnPropertyChanged(property);
   return mLastError == ERR_SUCCESS;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::GetBoolean(string property,bool defaultval=false)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return defaultval;

   string sql = GetValueSql();
   if(sql == NULL)
      return defaultval;

   CDatabaseRequest req = db.Query(sql);
   if(!req.IsAvaliable() || !req.Read())
     {
      mLastError = GetLastError();
      return defaultval;
     }

   return req.GetBooleanOrDefault(property,defaultval);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::SetBoolean(string property,bool val)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;

   string sql = SetValueSql(property,val);
   if(sql == NULL)
      return false;

   db.BeginTransaction();
   mLastError = db.ExecuteForce(sql);
   db.Commit();
   OnPropertyChanged(property);
   return mLastError == ERR_SUCCESS;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CDatabaseTable::GetLong(string property,long defaultval=0)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return defaultval;

   string sql = GetValueSql();
   if(sql == NULL)
      return defaultval;

   CDatabaseRequest req = db.Query(sql);
   if(!req.IsAvaliable() || !req.Read())
     {
      mLastError = GetLastError();
      return defaultval;
     }

   return req.GetLongOrDefault(property,defaultval);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::SetLong(string property,long val)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;

   string sql = SetValueSql(property,val);
   if(sql == NULL)
      return false;

   db.BeginTransaction();
   mLastError = db.ExecuteForce(sql);
   db.Commit();
   OnPropertyChanged(property);
   return mLastError == ERR_SUCCESS;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDatabaseTable::GetDouble(string property,double defaultval=0)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return defaultval;

   string sql = GetValueSql();
   if(sql == NULL)
      return defaultval;

   CDatabaseRequest req = db.Query(sql);
   if(!req.IsAvaliable() || !req.Read())
     {
      mLastError = GetLastError();
      return defaultval;
     }

   return req.GetDoubleOrDefault(property,defaultval);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::SetDouble(string property,double val)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;

   string sql = SetValueSql(property,val);
   if(sql == NULL)
      return false;

   db.BeginTransaction();
   mLastError = db.ExecuteForce(sql);
   db.Commit();
   OnPropertyChanged(property);
   return mLastError == ERR_SUCCESS;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabaseTable::GetString(string property,string defaultval=NULL)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return defaultval;

   string sql = GetValueSql();
   if(sql == NULL)
      return defaultval;

   CDatabaseRequest req = db.Query(sql);
   if(!req.IsAvaliable() || !req.Read())
     {
      mLastError = GetLastError();
      return defaultval;
     }

   return req.GetStringOrDefault(property,defaultval);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabaseTable::SetString(string property,string val)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;

   string sql = SetValueSql(property,val);
   if(sql == NULL)
      return false;

   db.BeginTransaction();
   mLastError = db.ExecuteForce(sql);
   db.Commit();
   OnPropertyChanged(property);
   return mLastError == ERR_SUCCESS;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabaseTable::Execute(string sql)
  {
   CDatabase db(mDbPath);
   if(!db.IsAvaliable())
      return false;

   db.BeginTransaction();
   mLastError = db.ExecuteForce(sql,10000);
   db.Commit();
   return mLastError;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SQLiteTimeStr(datetime time, int flag = TIME_DATE | TIME_MINUTES | TIME_SECONDS)
  {
   string str = TimeToString(time, flag);
   StringReplace(str, ".", "-");
   return str;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
