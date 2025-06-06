//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Database.mqh>


struct abc
  {
   int value;
  };
  
   
//+------------------------------------------------------------------+
//| 脚本程序起始函数                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//Open
   CDatabase db("test.db");
   Print("db IsAvaliable=", db.IsAvaliable());

//HasTable
   Print("table ",db.HasTable("tab") ? "exist" : "not exist");

//execute
   db.Execute("create table if not exists tab(aa integer, bb double, cc string);");

   for(int i=1; i<10; i++)
     {
      db.Execute(StringFormat("insert into tab (aa, bb, cc) values(%d, %G, '%s');", i, rand()/100, SQLiteTimeStr(TimeCurrent())));
     }



//read
     {
      int v;
      double d;
      ENUM_TIMEFRAMES tf;
      color c;
      CDatabaseRequest req = db.Query("select * from tab");
      abc aa;
      req.Read(aa);
      req.GetInteger(0, v);
      req.GetValue(v, 0);
      req.GetValue(d, 1);
      req.GetValue(tf, 0);
      req.GetValue(c, 0);
      
      char data[];
      req.GetValue(data, 2);
      
      ENUM_DATABASE_FIELD_TYPE type = req.ColumnType(1);
      req.Read();
      req.Read();
      
        type = req.ColumnType(1);
      
      int v2 = req.GetIntegerOrDefault("aa");
     }
     {
      int v;
      double d;
      string s;
      bool rc = db.QueryFirst<int, double, string>(v, d, s, "select * from tab");
     }
     {
      int v[];
      double d[];
      string s[];
      bool rc = db.Query<int, double, string>(v, d, s, "select * from tab");
     }

//---
  }
//+------------------------------------------------------------------+
