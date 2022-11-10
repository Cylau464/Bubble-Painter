using System;
using input;
using UnityEngine;

namespace examples
{
    public class DragingExample : MonoBehaviour
    {
        public Camera _camera;
        public GameObject _cube;

        // Start is called before the first frame update
        void OnEnable()
        {
            ClickAndDrag.onBeginDrag += OnBeginDrag;
            ClickAndDrag.onDragging += OnDraging;
            ClickAndDrag.onEndDrag += OnEndDrag;
        }

        // Update is called once per frame
        void OnDisable()
        {
            ClickAndDrag.onBeginDrag -= OnBeginDrag;
            ClickAndDrag.onDragging -= OnDraging;
            ClickAndDrag.onEndDrag -= OnEndDrag;
        }

        private void OnBeginDrag(DragingData data)
        {
            _cube.SetActive(true);
        }

        private void OnDraging(DragingData data)
        {
            CrossPoint crossPoint = CrossInputs.GetCrossPoint(_camera);
            if (crossPoint.isReached == true)
                _cube.transform.position = crossPoint.point;
        }

        private void OnEndDrag(DragingData data)
        {
            _cube.SetActive(false);
        }

    }
}