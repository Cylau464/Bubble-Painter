using TMPro;
using UnityEngine;

namespace engine.coin
{
    public class TotalCoinsText : MonoBehaviour
    {
        [Header("Settings")]
        [SerializeField] protected TextMeshProUGUI _textTotalCoins;
        [SerializeField] protected CoinsData _coinsInfo;

        protected virtual void Start()
        {
            _textTotalCoins.text = Normalization.NormalizeScore(_coinsInfo.totalCoins);
            _coinsInfo.onUpdate += OnUpdateCoins;
        }

        protected virtual void OnDestroy()
        {
            _coinsInfo.onUpdate -= OnUpdateCoins;
        }

        protected virtual void OnUpdateCoins(ParametersUpdate data)
        {
            _textTotalCoins.text = data.total.ToString();
        }

#if UNITY_EDITOR
        protected virtual void OnValidate()
        {
            if (_coinsInfo == null)
                _coinsInfo = editor.ScriptableManager.FindScribtableObjectOfType<CoinsData>();
        }
#endif
    }
}