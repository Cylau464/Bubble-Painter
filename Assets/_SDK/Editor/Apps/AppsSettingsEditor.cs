using UnityEditor;
using UnityEngine;

namespace app
{
    [CustomEditor(typeof(AppsSettings))]
    public class AppsSettingsEditor : Editor
    {
        SerializedProperty integrateFacebook;
        SerializedProperty appLabels;
        SerializedProperty appFacebookID;
        SerializedProperty clientTokens;

        SerializedProperty integrateIronSource;
        SerializedProperty autoInterstitial;
        SerializedProperty showInterstitialEvery;
        SerializedProperty integrateAds;
        SerializedProperty androidKey;
        SerializedProperty iosKey;
        SerializedProperty ironSourceBannerPosition;
        SerializedProperty integrateGameAnalytics;

        protected void OnEnable()
        {
            integrateFacebook = serializedObject.FindProperty("integrateFacebook");
            appLabels = serializedObject.FindProperty("appLabels");
            appFacebookID = serializedObject.FindProperty("appFacebookID");
            clientTokens = serializedObject.FindProperty("clientTokens");

            integrateIronSource = serializedObject.FindProperty("integrateIronSource");
            autoInterstitial = serializedObject.FindProperty("autoInterstitial");
            showInterstitialEvery = serializedObject.FindProperty("showInterstitialEvery");
            integrateAds = serializedObject.FindProperty("integrateAds");
            androidKey = serializedObject.FindProperty("androidKey");
            iosKey = serializedObject.FindProperty("iosKey");
            ironSourceBannerPosition = serializedObject.FindProperty("ironSourceBannerPosition");
            integrateGameAnalytics = serializedObject.FindProperty("integrateGameAnalytics");

        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            AppsSettings appsSettings = (AppsSettings)target;

            if (!appsSettings.CheckExistGameObjectSDK())
            {
                EditorGUILayout.HelpBox("Please drag Prefab DSOneGames GO in the boost scene", MessageType.Warning);
            }

            GUIStyle header = new GUIStyle(GUI.skin.label);
            header.margin = new RectOffset(25, 20, 20, 5);
            header.fontStyle = FontStyle.Bold;
            GUILayout.Label("Facebook Settings", header);

            EditorGUILayout.PropertyField(integrateFacebook);
            if (appsSettings.integrateFacebook)
            {
                EditorGUILayout.PropertyField(appLabels);
                EditorGUILayout.PropertyField(appFacebookID);
                EditorGUILayout.PropertyField(clientTokens);
            }

            GUILayout.Label("IronSource Settings", header);
            EditorGUILayout.PropertyField(integrateIronSource);
            if (appsSettings.integrateIronSource)
            {
                EditorGUILayout.PropertyField(autoInterstitial);
                if (appsSettings.autoInterstitial)
                    EditorGUILayout.PropertyField(showInterstitialEvery);

                EditorGUILayout.PropertyField(integrateAds);
                EditorGUILayout.PropertyField(androidKey);
                EditorGUILayout.PropertyField(iosKey);
                EditorGUILayout.PropertyField(ironSourceBannerPosition);
            }

            GUILayout.Label("IronSource GameAnalytics", header);
            EditorGUILayout.PropertyField(integrateGameAnalytics);

            GUILayout.Label("Player Settings Information", header);
            GUIStyle headInfo = new GUIStyle(GUI.skin.label);
            headInfo.margin = new RectOffset(40, 0, 0, 0);

            GUILayout.BeginHorizontal("box");
            GUILayout.Label("Package name:   " + PlayerSettings.applicationIdentifier, headInfo);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal("box");
            GUILayout.Label("Default orientation:   " + PlayerSettings.defaultInterfaceOrientation, headInfo);
            GUILayout.EndHorizontal();


            GUILayout.Label("Android", headInfo);

            GUILayout.BeginHorizontal("box");
            GUILayout.Label("Min sdk version:   " + PlayerSettings.Android.minSdkVersion, headInfo);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal("box");
            GUILayout.Label("Target sdk version:   " + PlayerSettings.Android.targetSdkVersion, headInfo);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal("box");
            GUILayout.Label("Target architectures:   " + PlayerSettings.Android.targetArchitectures, headInfo);
            GUILayout.EndHorizontal();


            GUILayout.Label("IOS", headInfo);

            GUILayout.BeginHorizontal("box");
            GUILayout.Label("Target device:   " + PlayerSettings.iOS.targetDevice, headInfo);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal("box");
            int num = PlayerSettings.GetArchitecture(BuildTargetGroup.iOS);
            string architecture = (num == 0) ? "Armv7" : (num == 1) ? "Arm64" : "Universal";
            GUILayout.Label("Architecture:   " + architecture, headInfo);
            GUILayout.EndHorizontal();

            GUIStyle headButton = new GUIStyle(GUI.skin.button);
            headButton.margin = new RectOffset(0, 0, 20, 0);
            headButton.fixedHeight = 50;
            headButton.fontStyle = FontStyle.Bold;

            if (GUILayout.Button("Save And Refresh", headButton))
            {
                appsSettings.SaveData();
                Facebook.Unity.Editor.ManifestMod.GenerateManifest();
            }


            serializedObject.ApplyModifiedProperties();
        }
    }
}