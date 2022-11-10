using UnityEngine;

namespace engine
{
    public class FPSDisplay : MonoBehaviour
    {
        protected float deltaTime = 0.0f;

        protected void Update()
        {
            deltaTime += (Time.unscaledDeltaTime - deltaTime) * 0.1f;
        }

        protected void OnGUI()
        {
            float msec = deltaTime * 1000.0f;
            float fps = 1.0f / deltaTime;
            string text = string.Format("{0:0.0} ms ({1:0.} fps)", msec, fps);

            GUIDisplay.MakeLabel(text, 0, Color.blue);
        }
    }
}