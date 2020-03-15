#property copyright "Adam Parusel"
#property link      "https://adamparusel.com"
#property version   "1.00"
#property strict

int periods[] = {PERIOD_MN1, PERIOD_W1, PERIOD_D1, PERIOD_H1, PERIOD_M15};

long newChartId;
int htmlFile;

void OnInit()
{
   newChartId = ChartOpen(SymbolName(1, true), PERIOD_D1);
      Sleep(100);
   ChartApplyTemplate(newChartId, "adam_black_candle.tpl");
      Sleep(100);
   ChartSetInteger(newChartId, CHART_SCALE, 0, 3);
      Sleep(100);

   htmlFile = FileOpen("index.html", FILE_WRITE);
   FileWriteString(htmlFile, "<html><head><title>Market Scan</title></head><body>");      
}

int OnDeinit(const int reason)
{
   FileWriteString(htmlFile, "</body></html>");
   FileClose(htmlFile);   

   ChartClose(newChartId);
   
   Alert("Scan completed. Report generated.");

   return(reason);
}

void OnStart()
{
   for (int s=0; s < SymbolsTotal(true); s++) {
      string symbolName = SymbolName(s, true);
      FileWriteString(htmlFile, "<h1>" + symbolName + "</h1>");

      for (int p=0; p < ArraySize(periods); p++) {      
         string periodName = periodAsString(periods[p]);
         string screenshotFilename = symbolName + "-" + periodName + ".png";

         FileWriteString(htmlFile, "<h2>" + periodName+ "</h2>");
         
         ChartSetSymbolPeriod(newChartId, symbolName, periods[p]);
         ChartScreenShot(newChartId, screenshotFilename, 1024, 768);

         FileWriteString(htmlFile, "<img src=\"" + screenshotFilename + "\"/>");
      }
   }
}

string periodAsString(int period)
{
   switch (period) {
      case PERIOD_M1:
         return("1 minute");
      case PERIOD_M5:
         return("5 minutes");
      case PERIOD_M15:
         return("15 minutes");
      case PERIOD_M30:
         return("30 minutes");
      case PERIOD_H1:
         return("1 hour");
      case PERIOD_H4:
         return("4 hours");
      case PERIOD_D1:
         return("1 day");
      case PERIOD_W1:
         return("1 week");
      case PERIOD_MN1:
         return("1 month");
   }

   return("unkown");
}
