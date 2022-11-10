using GameAnalyticsSDK;
using System;
using System.Linq;
using UnityEngine;

namespace app
{
    public class AppsManager : MonoBehaviour
    {
        #region delegates
        private static event Action<string, string> _onSendEvent;
        public static event Action<string, string> onSendEvent
        {
            add
            {
                _onSendEvent += value;
            }
            remove
            {
                _onSendEvent -= value;
            }
        }

        private static event Action<IronSourcePlacement, int> _onCompletedRewardedVideo;
        public static event Action<IronSourcePlacement, int> onCompletedRewardedVideo
        {
            add
            {
                if (_onCompletedRewardedVideo == null || !_onCompletedRewardedVideo.GetInvocationList().Contains(value))
                    _onCompletedRewardedVideo += value;
            }
            remove
            {
                if (_onCompletedRewardedVideo != null || _onCompletedRewardedVideo.GetInvocationList().Contains(value))
                    _onCompletedRewardedVideo -= value;
            }
        }
        #endregion

        #region variables
        public static AppsManager agent { get; private set; }

        [SerializeField] private AppsSettings _appSettings;
        [SerializeField] private bool _debugEnable = true;

        public AppsSettings appSettings => _appSettings;
        public InitFacebook initFacebook { get; private set; }
        public InitIronSource adsManager { get; private set; }
        public InitGameAnalytics initGameAnalytics { get; private set; }

        private static float lastTimerAds = 0;
        #endregion

        #region Inits
        protected void Awake()
        {
            if (DefineAgent())
            {
                Initialize();
            }
        }

        private bool DefineAgent()
        {
            if (agent == null)
            {
                DontDestroyOnLoad(gameObject);
                agent = this;
                return true;
            }
            else
            {
                Destroy(gameObject);
                return false;
            }
        }

        private void Initialize() 
        {
#if UNITY_IOS
            RequestAuthorizations.RequestAuthorizationsIOS();
#endif
            if (appSettings.integrateFacebook)
                initFacebook = new InitFacebook();

            if (appSettings.integrateIronSource)
                adsManager = new InitIronSource(this);

            if (appSettings.integrateGameAnalytics)
                initGameAnalytics = new InitGameAnalytics();

            lastTimerAds = Time.time;
        }
        #endregion

        #region events
        /// <summary>
        /// For send event to the Analysis dashboards by the name "eventName"
        /// </summary>
        /// <param name="eventName"> The name in event sending. </param>
        public static void SendEvent(string eventName)
        {
            if (agent == null)
                return;

            /// Remove space and _ for not have problems to send the event.
            eventName = eventName.Replace(" ", "").Replace("_", "");

            if (agent.appSettings.integrateGameAnalytics)
                GameAnalytics.NewDesignEvent("Design:" + eventName);

            if (_onSendEvent != null)
                _onSendEvent.Invoke(eventName, "0.0");

            if (agent._debugEnable)
                Debug.Log("The event sent is: " + eventName + ", value is: 0.0");
        }

        /// <summary>
        /// For send event to the Analysis dashboards by the name "eventName"
        /// </summary>
        /// <param name="eventName"> The name in event sending. </param>
        /// <param name="eventValue"> The value in event sending. </param>
        public static void SendEvent(string eventName, float eventValue)
        {
            if (agent == null)
                return;

            /// Remove space and _ for not have problems to send the event.
            eventName = eventName.Replace(" ", "").Replace("_", "");

            if (agent.appSettings.integrateGameAnalytics)
                GameAnalytics.NewDesignEvent(eventName, eventValue);

            if (_onSendEvent != null)
                _onSendEvent.Invoke(eventName, eventValue.ToString());

            if (agent._debugEnable)
                Debug.Log("The event sent is: " + eventName + ", value is: " + eventValue);
        }

        /// <summary>
        /// Send progress event to GameAnalytics after checking if GA integrated.
        /// </summary>
        /// <param name="status"> GAProgressionStatus is level statue </param>
        /// <param name="playerLevel"> Player level progress </param>
        public static void SendProgressionEvent(GAProgressionStatus status, int playerLevel, int indexLevel)
        {
            if (agent == null)
                return;

            if (agent.appSettings.integrateGameAnalytics)
            {
                if (0 <= indexLevel) SendEvent(status + ":IdLevel_" + indexLevel);
                GameAnalytics.NewProgressionEvent(status, "Level_" + playerLevel);
            }
        }

        /// <summary>
        /// Send progress event to GameAnalytics after checking if GA integrated.
        /// </summary>
        /// <param name="status"> GAProgressionStatus is level statue </param>
        /// <param name="playerLevel"> Player level progress </param>
        public static void SendErrorEvent(GAErrorSeverity severity, string errorMessage)
        {
            if (agent == null)
                return;

            if (agent.appSettings.integrateGameAnalytics)
            {
                GameAnalytics.NewErrorEvent(severity, errorMessage);
            }
        }
        #endregion

        #region ads
        internal static void InvokeOnCompletedRewardedVideo(IronSourcePlacement placement, int idRewards)
        {
            _onCompletedRewardedVideo?.Invoke(placement, idRewards);
        }

        public static bool AutoShowInterstitial()
        {
            if (agent == null)
                return false;

            if (!agent._appSettings.autoInterstitial)
                return false;


            if (lastTimerAds + agent._appSettings.showInterstitialEvery <= Time.time)
            {
                if (ShowInterstitial("BetweenLevels"))
                {
                    lastTimerAds = Time.time;
                    return true;
                }
            }
            return false;
        }

        public static bool ShowInterstitial()
        {
            return ShowInterstitial("DefaultInterstitial");
        }

        public static bool ShowInterstitial(string placementName)
        {
            if (agent == null)
                return false;

            if (agent._debugEnable)
                Debug.Log("Call to show Interstitial Ads.");

            if (agent._appSettings.integrateIronSource && agent._appSettings.integrateAds.useInterstitial)
            {
                bool isShowed = InitIronSource.ShowInterstitial();
                if (isShowed)
                {
                    GameAnalytics.NewAdEvent(GAAdAction.Show, GAAdType.Interstitial, "IronSource", placementName);
                }
                else
                {
                    GameAnalytics.NewAdEvent(GAAdAction.FailedShow, GAAdType.Interstitial, "IronSource", placementName);
                }
                return isShowed;
            }

            return false;
        }

        public static bool ShowRewardedVideo(string placementName, int idReward)
        {
            if (agent == null)
                return false;

            if (agent._debugEnable)
                Debug.Log("Call to show RewardedVideo Ads.");

            if (agent._appSettings.integrateIronSource && agent._appSettings.integrateAds.useRewardedVideo)
            {
                bool isShowed = InitIronSource.ShowRewardedVideo(placementName, idReward);
                if (isShowed)
                {
                    GameAnalytics.NewAdEvent(GAAdAction.Show, GAAdType.RewardedVideo, "IronSource", placementName);
                }
                else
                {
                    GameAnalytics.NewAdEvent(GAAdAction.FailedShow, GAAdType.RewardedVideo, "IronSource", placementName);
                }
                return isShowed;
            }

            return false;
        }

        public static void ShowBanner()
        {
            if (agent == null)
                return;

            if (agent._debugEnable)
                Debug.Log("Call to show Banner Ads.");

            if (agent._appSettings.integrateIronSource && agent._appSettings.integrateAds.useBanner)
                InitIronSource.ShowBanner();
        }

        public static void HideBanner()
        {
            if (agent == null)
                return;

            if (agent._debugEnable)
                Debug.Log("Call to hide Banner Ads.");

            if (agent._appSettings.integrateIronSource && agent._appSettings.integrateAds.useBanner)
                InitIronSource.HideBanner();
        }
#endregion

        #region editor
#if UNITY_EDITOR
        public void SetAppSettings(AppsSettings settings)
        {
            if (_appSettings == null)
                _appSettings = settings;
        }

        protected void OnValidate()
        {
            if (_appSettings != null)
                return;

            AppsSettings[] appsSettings = AppsSettings.GetAllInstances<AppsSettings>();
            if (appsSettings != null && 0 < appsSettings.Length)
                SetAppSettings(appsSettings[0]);
            else
                Debug.Log("AppsSettings is not exists please create and insert it.");
        }
#endif
        #endregion
    }
}