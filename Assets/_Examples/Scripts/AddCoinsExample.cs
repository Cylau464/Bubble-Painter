using engine.coin;
using UnityEngine;

namespace examples
{
    public class AddCoinsExample : MonoBehaviour
    {
        public CoinsData coinsData;

        void OnEnable()
        {
            GameDelegate.onWin += OnWin;
            GameDelegate.onLose += OnLose;
        }

        void OnDisable()
        {
            GameDelegate.onWin -= OnWin;
            GameDelegate.onLose -= OnLose;
        }

        void OnLose()
        {
            coinsData.RemoveCoins(500);
        }

        void OnWin()
        {
            coinsData.AddCoins(1000);
        }
    }
}