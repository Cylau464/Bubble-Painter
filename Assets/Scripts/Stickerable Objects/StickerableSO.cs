using UnityEngine;

[CreateAssetMenu(fileName = "Stickerable Object", menuName = "Add/Stickerable Object", order = 2)]
public class StickerableSO : engine.ScriptableAsset, System.IComparable
{
    [SerializeField] private int _id;
    [SerializeField] private StickerableObject _prefab;

    public int ID => _id;
    public StickerableObject Prefab => _prefab;

    public int CompareTo(object obj)
    {
        if (obj == null) return 1;
        try
        {
            return ID - ((StickerableSO)obj).ID;
        }
        catch
        {
            return 1;
        }
    }
}
