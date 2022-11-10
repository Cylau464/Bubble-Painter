using Facebook.Unity.Settings;
using System.IO;
using UnityEngine;

namespace app
{
    [System.Serializable]
    public class UsingAds
    {
        public bool useBanner = true;
        public bool useRewardedVideo = true;
        public bool useInterstitial = true;
    }

    [CreateAssetMenu(fileName = "AppsSettings", menuName = "AppsSettings", order = 1)]
    public class AppsSettings : ScriptableObject
    {
        public static string globalDirectoryPath => /*Application.dataPath + */"Assets/_SDK/Resources/";
        public static string insideResourcesDirectoryPath => "";
        public bool integrateFacebook = true;

        public string appLabels = "";
        public string appFacebookID = "Entry Facebook ID...";
        public string clientTokens = "";

        public bool integrateFirebase = true;
        public bool integrateIronSource = false;

        public bool autoInterstitial = true;
        public float showInterstitialEvery = 60;
        public UsingAds integrateAds;

        public string androidKey = "Entry Android Key";
        public string iosKey = "Entry IOS Key";
        public IronSourceBannerPosition ironSourceBannerPosition = IronSourceBannerPosition.BOTTOM;

        public bool integrateGameAnalytics = true;

#if UNITY_EDITOR
        public static AppsSettings CreateAppsSettings()
        {
            AppsSettings asset = CreateInstance<AppsSettings>();

            if (!Directory.Exists(globalDirectoryPath))
            {
                Directory.CreateDirectory(globalDirectoryPath);
            }

            UnityEditor.AssetDatabase.CreateAsset(asset, globalDirectoryPath + "AppsSettings.asset");
            UnityEditor.AssetDatabase.SaveAssets();
            return asset;
        }

        public void UpdateAppSettings()
        {
            AppsManager[] managers = Resources.FindObjectsOfTypeAll<AppsManager>();
            foreach (AppsManager manager in managers)
            {
                manager.SetAppSettings(this);
            }
        }

        public bool CheckExistGameObjectSDK()
        {
            AppsManager initAppsManager = FindObjectOfType<AppsManager>();
            if (initAppsManager != null)
            {
                return true;
            }
            return false;
        }

        public void SaveData()
        {
            RefreshFacebookSettings();
            UnityEditor.AssetDatabase.Refresh();
            UnityEditor.AssetDatabase.SaveAssets();
        }

        public void PingObject()
        {
            UnityEditor.Selection.activeObject = this;
            UnityEditor.EditorGUIUtility.PingObject(this);
        }

        public void RefreshFacebookSettings()
        {
            FacebookSettings.AppIds[0] = appFacebookID;
            FacebookSettings.AppLabels[0] = appLabels;
            FacebookSettings.ClientTokens[0] = clientTokens;
        }

        public static T[] GetAllInstances<T>() where T : ScriptableObject
        {
            string[] guids = UnityEditor.AssetDatabase.FindAssets("t:" + typeof(T).Name);
            T[] a = new T[guids.Length];
            for (int i = 0; i < guids.Length; i++)
            {
                string path = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i]);
                a[i] = UnityEditor.AssetDatabase.LoadAssetAtPath<T>(path);
            }

            return a;
        }
#endif
    }
}
