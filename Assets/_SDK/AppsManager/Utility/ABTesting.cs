using GameAnalyticsSDK;
using System;

namespace app
{
    public static class ABTesting
    {
        public static event Action handleUpdated
        {
            add
            {
                GameAnalytics.OnRemoteConfigsUpdatedEvent += value;
            }
            remove
            {
                GameAnalytics.OnRemoteConfigsUpdatedEvent -= value;
            }
        }

        public static bool isReady => GameAnalytics.IsRemoteConfigsReady();

        public static string GetValue(string ab_key)
        {
            return GameAnalytics.GetRemoteConfigsValueAsString(ab_key);
        }
    }
}