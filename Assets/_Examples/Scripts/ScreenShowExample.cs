using engine;
using UnityEngine;

public class ScreenShowExample : MonoBehaviour
{
    protected void OnGUI()
    {
        GUIDisplay.MakeLabel("Level playing: " + GameManager.isPlaying, 0, Color.blue, GUISide.Left);
        GUIDisplay.MakeLabel("Level lost: " + GameManager.isLost, 1, Color.blue, GUISide.Left);
        GUIDisplay.MakeLabel("Level win: " + GameManager.isWin, 2);
    }
}