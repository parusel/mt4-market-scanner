#property copyright "Adam Parusel"
#property link      "https://adamparusel.com"
#property version   "0.2"
#property strict

const string templateName = "adam_black_candle.tpl";

int periods[] = {PERIOD_MN1, PERIOD_W1, PERIOD_D1, PERIOD_H1, PERIOD_M15};

long newChartId;
int htmlReportFile;

void OnInit()
{
   newChartId = ChartOpen(SymbolName(1, true), PERIOD_D1);
      Sleep(100);
   ChartApplyTemplate(newChartId, templateName);
      Sleep(100);
   ChartSetInteger(newChartId, CHART_SCALE, 0, 3);
      Sleep(100);

   int headerTemplateFile = FileOpen("MarketScanner\\template_header.html", FILE_READ);
   htmlReportFile = FileOpen("MarketScanner\\Reports\\index.html", FILE_WRITE);

   while (!FileIsEnding(headerTemplateFile)) {
      string line = FileReadString(headerTemplateFile);
      FileWriteString(htmlReportFile, line);
   }
   
   FileClose(headerTemplateFile);
}

void OnDeinit(const int reason)
{
   int footerTemplateFile = FileOpen("MarketScanner\\template_footer.html", FILE_READ);
      
   while (!FileIsEnding(footerTemplateFile)) {
      string line = FileReadString(footerTemplateFile);
      FileWriteString(htmlReportFile, line);
   }
   
   FileClose(footerTemplateFile);
   FileClose(htmlReportFile);

   ChartClose(newChartId);
   
   Alert("Scan completed. Report generated.");
}

void OnStart()
{
   for (int s=0; s < SymbolsTotal(true); s++) {
      string symbolName = SymbolName(s, true);
      string symbolDescription = SymbolInfoString(symbolName, SYMBOL_DESCRIPTION);

      FileWriteString(htmlReportFile, "<div class=\"display-4 text-center mt-4\">" + symbolDescription + "</div>");
      FileWriteString(htmlReportFile, generatePeriodsNavbar(symbolName));
      FileWriteString(htmlReportFile, "<div class=\"tab-content\">");
      
      string isActive = " active";
      for (int p=0; p < ArraySize(periods); p++) {      
         string periodName = periodAsString(periods[p]);
         string screenshotPath = "MarketScanner\\Reports\\";
         string screenshotFilename = symbolName + "-" + periodName + ".png";
         
         ChartSetSymbolPeriod(newChartId, symbolName, periods[p]);
         ChartScreenShot(newChartId, screenshotPath + screenshotFilename, 2000, 1000);

  
         FileWriteString(htmlReportFile, "<div id=\"" + htmlIdGenerator(symbolName, periods[p]) + "\" class=\"tab-pane container" + isActive + "\">");
         FileWriteString(htmlReportFile, "<img src=\"" + screenshotFilename + "\" class=\"img-fluid\"/>");
         FileWriteString(htmlReportFile, "</div>");
         isActive = "";
      }

      FileWriteString(htmlReportFile, "</div>");
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

string htmlIdGenerator(string symbol, int period)
{
   string idName = symbol +"-" + period;
   StringReplace(idName, ".", "");
   return idName;
}

string generatePeriodsNavbar(string symbol)
{
   string result = "<ul class=\"nav nav-tabs nav-fill\">";
                     
   string classActive = " active";
   
   for (int i=0; i<ArraySize(periods); i++) {
      result = result +"<li class=\"nav-item\"><a class=\"nav-link" + classActive + "\" data-toggle=\"tab\" href=\"#" + htmlIdGenerator(symbol, periods[i]) + "\">" + periodAsString(periods[i]) + "</a></li>";
      classActive = "";
   }

   result = result + "</ul>";
   
   return(result);
}