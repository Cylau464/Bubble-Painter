#if UNITY_EDITOR
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace app
{
    public class AppsWindow
    {
        [UnityEditor.MenuItem("DSOneGames/Ping AppsSettings", false, 101)]
        public static void AppSettingsPing()
        {
            AppsSettings[] appsSettings = AppsSettings.GetAllInstances<AppsSettings>();
            if (appsSettings == null || appsSettings.Length <= 0)
            {
                appsSettings = new AppsSettings[] { AppsSettings.CreateAppsSettings() };
                Debug.Log("AppsSettings is created...");
            }

            if (appsSettings != null && 0 <= appsSettings.Length)
            {
                appsSettings[0].UpdateAppSettings();
                appsSettings[0].SaveData();
                appsSettings[0].PingObject();
            }
            else
            {
                Debug.LogError("We can't create AppsSettings please create it manual...");
            }
        }

        [UnityEditor.MenuItem("DSOneGames/New DSOneGames GO", false, 110)]
        public static void CreateDSOneGamesGO()
        {
            if (GameObject.FindObjectOfType<AppsManager>())
            {
                Debug.LogError("AppsManager object already exist on the scene...");
                return;
            }

            GameObject dsOneGamesGO = Resources.Load(AppsSettings.insideResourcesDirectoryPath + "DSOneGames GO") as GameObject;
            if (dsOneGamesGO != null)
            {
                (UnityEditor.PrefabUtility.InstantiatePrefab(dsOneGamesGO) as GameObject).transform.SetAsLastSibling();
            }
            else
            {
                Debug.LogError("DSOneGames GO not found in the path: " + AppsSettings.insideResourcesDirectoryPath);
            }

            SaveAllActiveScenes();
        }

        public static void SaveAllActiveScenes()
        {
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                EditorSceneManager.SaveScene(SceneManager.GetSceneAt(i));
            }
        }
    }
}
#endif