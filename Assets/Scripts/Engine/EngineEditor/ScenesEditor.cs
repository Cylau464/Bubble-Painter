#if UNITY_EDITOR
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

public static class ScenesEditor
{
    public static void SaveAllActiveScenes()
    {
        for (int i = 0; i < SceneManager.sceneCount; i++)
        {
            EditorSceneManager.SaveScene(SceneManager.GetSceneAt(i));
        }
    }

    public static void SaveSceneAt(int i)
    {
        EditorSceneManager.SaveScene(SceneManager.GetSceneAt(i));
    }
}
#endif