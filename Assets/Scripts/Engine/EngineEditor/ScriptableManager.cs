#if UNITY_EDITOR
using UnityEngine;

namespace editor
{
    public static class ScriptableManager
    {
        public static T[] FindScribtableObjectsOfType<T>() where T : ScriptableObject
        {
            string[] guids = UnityEditor.AssetDatabase.FindAssets("t:" + typeof(T).Name);

            if (guids == null || guids.Length == 0)
                return null;

            T[] a = new T[guids.Length];
            for (int i = 0; i < guids.Length; i++)
            {
                string path = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i]);
                a[i] = UnityEditor.AssetDatabase.LoadAssetAtPath<T>(path);
            }

            return a;
        }

        public static T FindScribtableObjectOfType<T>() where T : ScriptableObject
        {
            string[] guids = UnityEditor.AssetDatabase.FindAssets("t:" + typeof(T).Name);

            if (guids == null || guids.Length == 0)
                return null;

            string path = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[0]);
            return UnityEditor.AssetDatabase.LoadAssetAtPath<T>(path);
        }
    }
}
#endif