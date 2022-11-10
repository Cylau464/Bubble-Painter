using GameAnalyticsSDK;
using System;

namespace app
{
    public class InitGameAnalytics
    {
        private bool _isInited;

        public InitGameAnalytics()
        {
            if (_isInited == true)
                return;

            GameAnalytics.Initialize();
        }
    }
}