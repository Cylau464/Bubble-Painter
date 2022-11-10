using UnityEngine;
using UnityEngine.UI;
using core.level;
using System;

public class CreateStickerButton : MonoBehaviour
{
    [SerializeField] private Button _button;
    [SerializeField] private int _minDrawsForCreateEnable = 10;

    private int _drawsCounter;
    private GameLevel _level;

    private void Awake()
    {
        _button.onClick.AddListener(Create);
        DeactivateButton();
        LevelsManager.OnLevelLoaded += OnLevelLoaded;
    }

    private void OnDestroy()
    {
        LevelsManager.OnLevelLoaded -= OnLevelLoaded;

        if(_level != null)
            _level.DrawableObject.OnDraw -= OnDraw;
    }

    private void OnLevelLoaded(GameLevel level)
    {
        if (_level != null)
            _level.DrawableObject.OnDraw -= OnDraw;

        _level = level;
        _level.DrawableObject.OnDraw += OnDraw;
        _drawsCounter = 0;
        DeactivateButton();
    }

    private void OnDraw()
    {
        _drawsCounter++;

        if (_drawsCounter >= _minDrawsForCreateEnable)
            ActivateButton();
    }

    private void Create()
    {
        _level.DrawableObject.CreateSticker();
        DeactivateButton();
        _level.DrawableObject.OnDraw -= OnDraw;
    }

    private void ActivateButton()
    {
        if(_button.gameObject.activeSelf == false)
            _button.gameObject.SetActive(true);

    }

    private void DeactivateButton()
    {
        if (_button.gameObject.activeSelf == true)
            _button.gameObject.SetActive(false);
    }
}
