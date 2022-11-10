using UnityEngine;

namespace engine
{
    public abstract class ScriptableAsset : ScriptableObject
    {
#if UNITY_EDITOR
        [TextArea][SerializeField] protected string _description;
#endif
    }
}