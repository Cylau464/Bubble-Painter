using System;
using UnityEngine;
using UnityEngine.UI;

namespace input
{
    #region draging data
    public struct DragingData
    {
        public Vector3 lastPosition;
        public Vector3 initPoint;

        public Vector3 currentPosition => Input.mousePosition;
        public Vector3 daltaDrag => currentPosition - initPoint;

        public float lengthDrag => Vector3.Distance(currentPosition, initPoint);
        public Vector3 lastDaltaDrag => Input.mousePosition - lastPosition;
    }
    #endregion

    [Serializable]
    public class ClickAndDrag
    {
        #region delegates
        private static event Action<DragingData> _onBeginDrag;
        public static event Action<DragingData> onBeginDrag
        {
            add
            {
                _onBeginDrag += value;
            }
            remove
            {
                _onBeginDrag -= value;
            }
        }

        private static event Action<DragingData> _onClicked;
        public static event Action<DragingData> onClicked
        {
            add
            {
                _onClicked += value;
            }
            remove
            {
                _onClicked -= value;
            }
        }

        private static event Action<DragingData> _onEndDrag;
        public static event Action<DragingData> onEndDrag
        {
            add
            {
                _onEndDrag += value;
            }
            remove
            {
                _onEndDrag -= value;
            }
        }

        private static event Action<DragingData> _onDragging;
        public static event Action<DragingData> onDragging
        {
            add
            {
                _onDragging += value;
            }
            remove
            {
                _onDragging -= value;
            }
        }
        #endregion

        #region variables
        [SerializeField] private bool _justOnLevelPlaying = true;
        [SerializeField] private bool _ignoreUI = true;
        [SerializeField] private float _smoothDrag = 0;

        private GraphicRaycaster _graphicRaycaster;

        public static bool isClicked { get; private set; }
        public static bool isDragging { get; private set; }

        private DragingData _dragingData;
        private bool _isClickedDown;
        private bool _isInited = false;
        #endregion

        #region public
        public void OnEnable(GraphicRaycaster graphicRaycaster)
        {
            _graphicRaycaster = graphicRaycaster;

            // Init data
            _isClickedDown = false;
            isClicked = false;
            isDragging = false;
            _dragingData = new DragingData();

            // is inited
            _isInited = true;
        }

        public void Update()
        {
            if (_isInited == false)
                return;

            isClicked = false;
            if (GameManager.isPlaying || !_justOnLevelPlaying)
            {
                if (ControllerInputs.OnMouse(MouseType.Down, _graphicRaycaster, _ignoreUI))
                {
                    _isClickedDown = true;
                    OnMouseDown();
                }
                else
                if (ControllerInputs.OnMouse(MouseType.Up) && _isClickedDown)
                {
                    _isClickedDown = false;
                    OnMouseUp();
                }
                else
                if (ControllerInputs.OnMouse(MouseType.Non) && _isClickedDown)
                    OnMouse();
            }
        }

        public void OnDisable()
        {
            isClicked = false;
            isDragging = false;
        }
        #endregion

        #region private
        private void OnMouseDown()
        {
            _dragingData.lastPosition = _dragingData.initPoint = Input.mousePosition;
            isDragging = false;
        }

        private void OnMouseUp()
        {
            if (isDragging)
            {
                if (_onEndDrag != null)
                    _onEndDrag.Invoke(_dragingData);
            }
            else
            if (!ControllerInputs.OnClickUI(_graphicRaycaster))
            {
                isClicked = true;

                if (_onClicked != null)
                    _onClicked.Invoke(_dragingData);
            }
            isDragging = false;
        }

        private void OnMouse()
        {
            /// On drag
            if (_smoothDrag < Vector3.Distance(_dragingData.lastPosition, Input.mousePosition))
            {
                if (_onBeginDrag != null && !isDragging)
                {
                    _onBeginDrag.Invoke(_dragingData);
                    isDragging = true;
                }

                if (_onDragging != null)
                    _onDragging.Invoke(_dragingData);

                _dragingData.lastPosition = Input.mousePosition;
            }
        }
        #endregion
    }
}
