using UnityEngine;

namespace app
{
    public class InitIronSource
    {
        private AppsManager _initAppsManager;
        private static int _idRewards = -1;

        public InitIronSource (AppsManager initAppsManager)
        {
            _initAppsManager = initAppsManager;
            Initialize();
            LoadAds();
        }

        public void Initialize()
        {
            if (_initAppsManager == null)
                return;

            if (_initAppsManager.appSettings == null)
                return;

            if (_initAppsManager.appSettings.integrateAds.useInterstitial)
            {
                // Add Interstitial Events
                IronSourceEvents.onInterstitialAdShowFailedEvent += InterstitialAdShowFailedEvent;
                IronSourceEvents.onInterstitialAdClosedEvent += InterstitialAdClosedEvent;
            }

            if (_initAppsManager.appSettings.integrateAds.useRewardedVideo)
            {
                IronSourceEvents.onRewardedVideoAdRewardedEvent += OnRewardedVideoAdRewardedEvent;
            }
        }

        private void OnRewardedVideoAdRewardedEvent(IronSourcePlacement placement)
        {
            AppsManager.InvokeOnCompletedRewardedVideo(placement, _idRewards);
        }

        public void LoadAds()
        {
#if UNITY_ANDROID
            string appKey = _initAppsManager.appSettings.androidKey;
#elif UNITY_IPHONE
            string appKey = _initAppsManager.appSettings.iosKey;
#else
            string appKey = "unexpected_platform";
#endif
            IronSource.Agent.validateIntegration();
            IronSource.Agent.init(appKey);

            if (_initAppsManager.appSettings.integrateAds.useBanner)
                IronSource.Agent.loadBanner(IronSourceBannerSize.BANNER, _initAppsManager.appSettings.ironSourceBannerPosition);

            if (_initAppsManager.appSettings.integrateAds.useInterstitial)
                IronSource.Agent.loadInterstitial();
        }

        #region Methods
        public static bool ShowInterstitial()
        {
            if (IronSource.Agent == null)
                return false;

            if (IronSource.Agent.isInterstitialReady())
            {
                IronSource.Agent.showInterstitial();
                return true;
            }
            else
            {
                Debug.Log("unity-script: IronSource.Agent.isInterstitialReady - False");
            }

            return false;
        }

        public static bool ShowRewardedVideo(string placementName, int idRewards = 0)
        {
            if (IronSource.Agent == null)
                return false;

            if (IronSource.Agent.isRewardedVideoAvailable())
            {
                _idRewards = idRewards;
                IronSource.Agent.showRewardedVideo(placementName);
                return true;
            }
            else
            {
                Debug.Log("unity-script: IronSource.Agent.isRewardedVideoAvailable - False");
            }

            return false;
        }

        public static bool ShowBanner()
        {
            if (IronSource.Agent == null)
                return false;

            IronSource.Agent.displayBanner();
            return true;
        }

        public static bool HideBanner()
        {
            if (IronSource.Agent == null)
                return false;

            IronSource.Agent.hideBanner();
            return true;
        }
        #endregion

        #region Interstitial callback handlers
        void InterstitialAdShowFailedEvent(IronSourceError error)
        {
            IronSource.Agent.loadInterstitial();
        }

        void InterstitialAdClosedEvent()
        {
            IronSource.Agent.loadInterstitial();
        }
        #endregion
    }
}
