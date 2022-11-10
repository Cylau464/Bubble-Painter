#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace editor
{
    public class EditorMode
    {
        /// <summary>
        /// When player Start play mode in editor. This function will execute.
        /// </summary>
        [InitializeOnEnterPlayMode]
        public static void OnEnteredPlayMode(EnterPlayModeOptions options)
        {
            IAwake[] scriptables = EditorManager.FindAllAssetsOfType<IAwake>();
            foreach (var item in scriptables)
            {
                if (item != null)
                    item.Awake();
            }
        }
    }
}
#endif