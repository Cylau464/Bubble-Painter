using UnityEngine;

namespace examples
{
    public class WinLostLogicExample : MonoBehaviour, engine.IValidate
    {
        public GameManager _gameManager;
        public Transform _cube;

        public Transform _winPoint;
        public Transform _lostPoint;

        void Update()
        {
            if (!GameManager.isPlaying)
                return;

            /// Example of logic for win case.
            if (Vector3.Distance(_cube.position, _winPoint.position) < 3)
            {
                _gameManager.MakeWin();
            }
            else
            /// Example of logic for lost case.
            if (Vector3.Distance(_cube.position, _lostPoint.position) < 3)
                _gameManager.MakeLost();

        }

        /// <summary>
        /// This function will execut in editor for set the data of Game manager automatic.
        /// </summary>
        public void Validate()
        {
            if (_gameManager == null)
                _gameManager = FindObjectOfType<GameManager>();
        }
    }
}
