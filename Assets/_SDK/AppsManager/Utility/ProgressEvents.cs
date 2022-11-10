using GameAnalyticsSDK;

namespace app
{
    public static class ProgressEvents
    {
        /// <summary>
        /// Send events about progress levels when player start the level.
        /// </summary>
        /// <param name="playerLevel"> The level what player see it in the game. </param>
        public static void OnLevelStarted(int playerLevel, int indexLevel = -1)
        {
            AppsManager.SendProgressionEvent(GAProgressionStatus.Start, playerLevel, indexLevel);
        }

        /// <summary>
        /// Send events about progress levels when player fieled the level.
        /// </summary>
        /// <param name="playerLevel"> The level what player see it in the game. </param>
        public static void OnLevelFieled(int playerLevel, int indexLevel = -1)
        {
            AppsManager.SendProgressionEvent(GAProgressionStatus.Fail, playerLevel, indexLevel);
            AppsManager.AutoShowInterstitial();
        }

        /// <summary>
        /// Send events about progress levels when player Completed the level.
        /// </summary>
        /// <param name="playerLevel"> The level what player see it in the game. </param>
        public static void OnLevelCompleted(int playerLevel, int indexLevel = -1)
        {
            AppsManager.SendProgressionEvent(GAProgressionStatus.Complete, playerLevel, indexLevel);
            AppsManager.AutoShowInterstitial();
        }
    }
}
