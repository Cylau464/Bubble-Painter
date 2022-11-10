using UnityEngine;
using System;

public class ColorPicker : MonoBehaviour
{
    public static ColorPicker Instance;

    public static Action<Paint> OnColorPick;

    private void Awake()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;
    }
}
