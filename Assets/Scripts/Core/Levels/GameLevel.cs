using UnityEngine;

namespace core.level
{
    [System.Serializable]
    public struct LevelContainer
    {
        public LevelInfoSO levelInfo;
    }

    public class GameLevel : MonoBehaviour
    {
        [SerializeField] private LevelContainer _levelContainer;
        [SerializeField] private DrawOnTexture _drawableObject;
        public DrawOnTexture DrawableObject => _drawableObject;

        public LevelsManager levelsManager { get; private set; }

        public LevelContainer levelContainer => _levelContainer;
        public SceneContainer sceneContainer { get; private set; }


        public virtual LevelContainer Initialize(LevelsManager levelsManager, SceneContainer sceneContainer)
        {
            this.levelsManager = levelsManager;
            this.sceneContainer = sceneContainer;

            return _levelContainer;
        }
    }
}
