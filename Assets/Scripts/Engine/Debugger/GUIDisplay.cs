using UnityEngine;

namespace engine
{
    public enum GUISide { Left, Right}
    public static class GUIDisplay
    {
        public struct GUIInfo
        {
            public GUIStyle guiStyle;
            public Rect rect;
        }

        public static GUIInfo GetGUIInfo(int index, Color color, GUISide anchor)
        {
            int w = Screen.width, h = Screen.height;

            GUIInfo info = new GUIInfo();

            info.guiStyle = new GUIStyle();
            info.guiStyle.alignment = (anchor == GUISide.Left) ? TextAnchor.UpperLeft : TextAnchor.UpperRight;
            info.guiStyle.fontSize = Screen.height * 3 / 100;
            info.guiStyle.normal.textColor = color;

            info.rect = new Rect(0, info.guiStyle.fontSize * index, w, h * 2 / 100);
            return info;
        }

        public static void MakeLabel(string text, int index)
        {
            GUIInfo info = GetGUIInfo(index, Color.blue, GUISide.Left);
            GUI.Label(info.rect, text, info.guiStyle);
        }

        public static void MakeLabel(string text, int index, Color color)
        {
            GUIInfo info = GetGUIInfo(index, color, GUISide.Left);
            GUI.Label(info.rect, text, info.guiStyle);
        }

        public static void MakeLabel(string text, int index, Color color, GUISide anchor)
        {
            GUIInfo info = GetGUIInfo(index, color, anchor);
            GUI.Label(info.rect, text, info.guiStyle);
        }
    }
}
