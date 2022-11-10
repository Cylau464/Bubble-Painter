using UnityEngine;

namespace core.ui
{
    public class PanelWin : Panel
    {
        public void NextLevel()
        {
            _mainCanvasManager.ReloadScene();
        }
    }
}
