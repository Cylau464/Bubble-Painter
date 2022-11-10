using UnityEngine;
using UnityEngine.UI;

public class ExampleProgress : MonoBehaviour
{
    public int currentLevel;
    public int indexLevel;
    public Text textLevel;

    protected void OnEnable()
    {
        currentLevel = PlayerPrefs.GetInt("level id");
        indexLevel = Random.Range(0, 5);

        textLevel.text = "Player Level: " + currentLevel + ", Index Level: " + indexLevel;
    }

    public void MakeStart()
    {
        app.ProgressEvents.OnLevelStarted(currentLevel, indexLevel);
    }

    public void MakeWin()
    {
        app.ProgressEvents.OnLevelCompleted(currentLevel, indexLevel);
        currentLevel++;
        PlayerPrefs.SetInt("level id", currentLevel);
        indexLevel = Random.Range(0, 5);

        textLevel.text = "Player Level: " + currentLevel + ", Index Level: " + indexLevel;
    }

    public void MakeLose()
    {
        app.ProgressEvents.OnLevelFieled(currentLevel, indexLevel);
    }
}
