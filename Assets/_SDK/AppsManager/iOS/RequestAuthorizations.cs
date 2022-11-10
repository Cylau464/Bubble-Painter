#if UNITY_IOS
using Balaso;
using System;
using UnityEngine;

namespace app
{
    public enum AuthorizateState { PrivayAndTerms = 0, AuthorizationTracking = 1, Completed = 2}

    public static class RequestAuthorizations
    {
        public static AuthorizateState authorizateState { get; private set; }

        public static event Action onPrivacyAndTermsCompleted;
        public static event Action onAuthorizationTrackingCompleted;
        public static event Action onAllCompleted;

        public static void RequestAuthorizationsIOS()
        {
            RegisterAppForAdNetworkAttribution();

            if (!PlayerPrefs.HasKey("Privacy Terms"))
                CreateAlertView();
            else
                OnCompletedPrivacyAndTerms();
        }

        private static void RegisterAppForAdNetworkAttribution()
        {
            AppTrackingTransparency.RegisterAppForAdNetworkAttribution();
            AppTrackingTransparency.UpdateConversionValue(3);
        }


        private static void CreateAlertView()
        {
            authorizateState = AuthorizateState.PrivayAndTerms;
            KTAlertView.sharedInstance.AlertViewReturned += AlertViewDelegate;
            KTAlertView.sharedInstance.ShowAlertViewCS(
                "Notice",
                "By clicking \" accept\" I confirm that I have read and accept Terms and Conditions and Privacy policy",
                "Accept",
                new string[] { "Privacy", "Terms and Conditions" },
                10
                );
        }

        private static void AlertViewDelegate(int tag, int clickedIndex)
        {
            if (tag != 10)
                return;

            switch (clickedIndex)
            {
                case 0:
                    PlayerPrefs.SetInt("Privacy Terms", 1);
                    OnCompletedPrivacyAndTerms();
                    break;
                case 1:
                    Application.OpenURL("http://dsone.ru/privacy-policy");
                    CreateAlertView();
                    break;
                case 2:
                    Application.OpenURL("http://dsone.ru/terms-and-conditions");
                    CreateAlertView();
                    break;
            }

            KTAlertView.sharedInstance.AlertViewReturned -= AlertViewDelegate;
        }

        private static void OnCompletedPrivacyAndTerms()
        {
            onPrivacyAndTermsCompleted?.Invoke();
            CreateAuthorizationTracking();
        }

        private static void CreateAuthorizationTracking()
        {
            PlayerPrefs.SetInt("Authorizate Tracking", 1);
            authorizateState = AuthorizateState.AuthorizationTracking;

            AppTrackingTransparency.OnAuthorizationRequestDone += OnAuthorizationRequestDone;

            AppTrackingTransparency.AuthorizationStatus currentStatus = AppTrackingTransparency.TrackingAuthorizationStatus;
            Debug.Log(string.Format("Current authorization status: {0}", currentStatus.ToString()));
            if (currentStatus != AppTrackingTransparency.AuthorizationStatus.AUTHORIZED)
            {
                Debug.Log("Requesting authorization...");
                AppTrackingTransparency.RequestTrackingAuthorization();
            }
        }

        /// <summary>
        /// Callback invoked with the user's decision
        /// </summary>
        /// <param name="status"></param>
        private static void OnAuthorizationRequestDone(AppTrackingTransparency.AuthorizationStatus status)
        {
            OnCompletedAllStates();
        }

        private static void OnCompletedAllStates()
        {
            authorizateState = AuthorizateState.Completed;
            onAuthorizationTrackingCompleted?.Invoke();
            onAllCompleted?.Invoke();
        }
    }
}
#endif