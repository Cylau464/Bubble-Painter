using UnityEngine;

namespace data
{
    [System.Serializable]
    public struct Data
    {
        #region Levels
        [Tooltip("The ID of current level")]
        public int idLevel;

        [Tooltip("The player level counter")]
        public int playerLevel;

        [Tooltip("In true case the idLevel will be random value. and player will player random levels.")]
        public bool randomLevels;
        #endregion

        /// <summary>
        /// Restore the data to the default values.
        /// </summary>
        /// <param name="initScore"> The Init score. When player start play first time. </param>
        public void Reset()
        {
            idLevel = 0;
            playerLevel = 1;
            randomLevels = false;
        }
    }
}