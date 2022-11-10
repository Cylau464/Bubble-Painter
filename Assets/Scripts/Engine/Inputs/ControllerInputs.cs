using UnityEngine;
using UnityEngine.UI;

namespace input
{
    public enum MouseType { Non = 0, Down = 1, Up = 2 }

    public class ControllerInputs : MonoBehaviour
    {
        [SerializeField] private GraphicRaycaster _graphicRaycaster;
        [SerializeField] private bool _initEnableInputs = true;
        [SerializeField] private ClickAndDrag _screenInputs;
        [SerializeField] private CrossInputs _crossInputs;


        public static bool isInited { get; private set; }
        public static bool enableInputs { get; set; }

        protected void Awake()
        {
            Initialize();
        }

        protected void Initialize()
        {
            enableInputs = _initEnableInputs;

            _screenInputs.OnEnable(_graphicRaycaster);
            _crossInputs.OnEnable();

            isInited = true;
        }

        protected void Update()
        {
            _screenInputs.Update();
        }

        protected void OnDisable()
        {
            _crossInputs.OnDisable();
        }

        protected void OnDrawGizmosSelected()
        {
            _crossInputs.OnDrawGizmosSelected();
        }

#if UNITY_EDITOR
        protected void OnValidate()
        {
            if (_graphicRaycaster == null)
                _graphicRaycaster = FindObjectOfType<GraphicRaycaster>();
        }
#endif

        #region mouse
        public static bool OnMouse(MouseType mouseType)
        {
            if (isInited == false)
            {
                Debug.Log("The inputs is not initializated!");
                return false;
            }

            switch (mouseType)
            {
                case MouseType.Down:
                    return enableInputs && Input.GetMouseButtonDown(0);
                case MouseType.Non:
                    return enableInputs && Input.GetMouseButton(0);
                case MouseType.Up:
                    return enableInputs && Input.GetMouseButtonUp(0);
            }

            return false;
        }

        public static bool OnMouse()
        {
            if (isInited == false)
            {
                Debug.Log("The inputs is not initializated!");
                return false;
            }

            return enableInputs && (Input.GetMouseButtonDown(0) || Input.GetMouseButton(0) || Input.GetMouseButtonUp(0));
        }

        public static bool OnMouse(MouseType mouseType, GraphicRaycaster graphicRaycaster, bool ignoreUI = false)
        {
            if (isInited == false)
            {
                Debug.Log("The inputs is not initializated!");
                return false;
            }

            switch (mouseType)
            {
                case MouseType.Down:
                    return enableInputs && Input.GetMouseButtonDown(0) && (ignoreUI || !OnClickUI(graphicRaycaster));
                case MouseType.Non:
                    return enableInputs && Input.GetMouseButton(0);
                case MouseType.Up:
                    return enableInputs && Input.GetMouseButtonUp(0);
            }

            return false;
        }

        public static bool OnMouse(GraphicRaycaster graphicRaycaster, bool ignoreUI = false)
        {
            if (isInited == false)
            {
                Debug.Log("The inputs is not initializated!");
                return false;
            }

            return enableInputs && (Input.GetMouseButtonDown(0) || Input.GetMouseButton(0) || Input.GetMouseButtonUp(0)) && (ignoreUI || !OnClickUI(graphicRaycaster));
        }
        #endregion

        #region UI
        public static bool OnClickUI(GraphicRaycaster graphicRaycaster)
        {
            return RaycastHits.GetRaycastResults(graphicRaycaster).Count != 0;
        }
        #endregion
    }
}