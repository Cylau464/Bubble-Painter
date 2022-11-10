#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

namespace app
{
    [InitializeOnLoad]
    public class StartupManager
    {
        static StartupManager()
        {
            AddDefineSymbolSDK(BuildTargetGroup.Android);
            AddDefineSymbolSDK(BuildTargetGroup.iOS);
        }

        static void AddDefineSymbolSDK(BuildTargetGroup targetGroup)
        {
            string supports = "Support_SDK";
            string result = PlayerSettings.GetScriptingDefineSymbolsForGroup(targetGroup);

            if (!result.Contains(supports))
            {
                PlayerSettings.SetScriptingDefineSymbolsForGroup(targetGroup, result + ";" + supports);
                Debug.Log("Support_SDK is added!!");
            }
            
        }

    }
}
#endif