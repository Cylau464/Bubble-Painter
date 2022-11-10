using UnityEngine;

namespace engine.coin
{
    public class TotalCoinsCountText : TotalCoinsText
    {
        [Header("Counter")]
        [Range(0.1f, 10f)] [SerializeField] private float _timeCounting = 1;
        [Range(0.03f, 0.4f)] [SerializeField] private float _smouth = 0.1f;

        private CoinsCounter counter;

        protected override void Start()
        {
            counter = new CoinsCounter(_textTotalCoins, _coinsInfo.totalCoins, _timeCounting, _smouth);
            base.Start();
        }

        protected override void OnUpdateCoins(ParametersUpdate data)
        {
            if (data.operation == OperationType.Add)
                counter.UpdateCount(data.total, data.amount);
            else
            if (data.operation == OperationType.Minus)
                counter.UpdateCount(data.total, -data.amount);
        }
    }
}