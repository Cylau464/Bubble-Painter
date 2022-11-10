using UnityEngine.SceneManagement;

public static class GameSceneManager
{
    public static void ReloadScene()
    {
        LoadScene(SceneManager.GetActiveScene().name);
    }

    private static void LoadScene(string sceneName, bool async = false)
    {
        if (async)
            SceneManager.LoadSceneAsync(sceneName);
        else
            SceneManager.LoadScene(sceneName);
    }

    public static void ReloadSceneAsync()
    {
        LoadScene(SceneManager.GetActiveScene().name, true);
    }
}
