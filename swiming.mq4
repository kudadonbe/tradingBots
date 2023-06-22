// Swing Trading Strategy: 10/20 SMA and 200 SMA

extern int FastMAPeriod = 10;      // Period for the fast moving average
extern int SlowMAPeriod = 20;      // Period for the slow moving average
extern int LongMAPeriod = 200;     // Period for the long-term moving average
extern int Slippage = 3;           // Maximum allowed slippage in pips

// Global variables
double LotSize = 0.003;

// Initialization function
int OnInit()
{
    return (INIT_SUCCEEDED);
}

// Start function
void OnStart()
{
    int maFastHandle, maSlowHandle, maLongHandle;
    double maFast, maSlow, maLong;
    int ticket;
    
    // Assign moving average handles
    maFastHandle = iMA(NULL, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    maSlowHandle = iMA(NULL, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    maLongHandle = iMA(NULL, 0, LongMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    
    while (!IsStopped())
    {
        // Get the current moving average values
        maFast = iMA(NULL, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
        maSlow = iMA(NULL, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
        maLong = iMA(NULL, 0, LongMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
        
        // Check for buy signal
        if (maFast > maSlow && maFast < maLong && maSlow < maLong)
        {
            // Close any existing sell positions
            if (PositionSelect(NULL))
            {
                ticket = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slippage, clrNone);
                if (ticket != -1)
                    Print("Error closing sell order: ", GetLastError());
            }
            
            // Open a new buy position
            ticket = OrderSend(OrderSymbol(), OP_BUY, LotSize, Ask, Slippage, Ask - (10 * Point), Ask + (20 * Point), "Swing Trading Strategy - Buy", 0, 0, clrGreen);
            if (ticket < 0)
                Print("Error opening buy order: ", GetLastError());
        }
        
        // Check for sell signal
        if (maFast < maSlow && maFast > maLong && maSlow > maLong)
        {
            // Close any existing buy positions
            if (PositionSelect(NULL))
            {
                ticket = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, clrNone);
                if (ticket != -1)
                    Print("Error closing buy order: ", GetLastError());
            }
            
            // Open a new sell position
            ticket = OrderSend(OrderSymbol(), OP_SELL, LotSize, Bid, Slippage, Bid + (10 * Point), Bid - (20 * Point), "Swing Trading Strategy - Sell", 0, 0, clrRed);
            if (ticket < 0)
                Print("Error opening sell order: ", GetLastError());
        }
        
        // Sleep for a short while to avoid high CPU usage
        Sleep(1000);
    }
}
