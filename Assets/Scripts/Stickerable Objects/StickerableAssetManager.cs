using UnityEngine;
using engine;
using System;
using Stickerable;
using System.Linq;

[CreateAssetMenu(fileName = "Stickerable Assets", menuName = "Add/More/Stickerable Assets", order = 11)]
public class StickerableAssetManager : ScriptableAsset, IValidate
{
    [SerializeField] private StickerableSO[] _stickerableObjects;
    [SerializeField] private StickerableData _stickerableData;
    [SerializeField] private int _maxStickersOnObject = 5;

    public StickerableSO[] StickerableObjects => _stickerableObjects;
    public StickerableData StickerableData => _stickerableData;

    public void Validate()
    {
#if UNITY_EDITOR
        /// Find all levels.
        _stickerableObjects = editor.ScriptableManager.FindScribtableObjectsOfType<StickerableSO>();
        Array.Sort(_stickerableObjects);
#endif
    }

    public StickerableSO GetSO()
    {
        return GetSO(_stickerableData.Data.CurrentID);
    }

    public StickerableSO GetSO(int id)
    {
        if (_stickerableData.Textures.ContainsKey(id) == false)
        {
            if (_stickerableData.Textures.Count <= 0)
                return _stickerableObjects.FirstOrDefault(x => x.ID == 0);
        }
        else if (_stickerableData.Data.StickersCount[id] >= _maxStickersOnObject)
        {
            id++;
        }

        StickerableSO so;
        so = _stickerableObjects.FirstOrDefault(x => x.ID == id);

        if (so == default)
            so = _stickerableObjects.FirstOrDefault(x => x.ID == 0);

        return so;
    }
}
