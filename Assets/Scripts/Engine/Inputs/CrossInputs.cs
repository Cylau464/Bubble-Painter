using UnityEngine;

namespace input
{
    public struct CrossPoint
    {
        public bool isReached;
        public Vector3 point;
    }

    [System.Serializable]
    public class CrossInputs
    {
        public enum NormalAxis { Vertical, Horizontal }

        [SerializeField] private float _offset = 0.0f;
        [SerializeField] private NormalAxis _normalAxis;

        private static Plane _plane;
        public static Vector3 crossPoint { get; private set; }
        public static bool isInited { get; private set; } = false;

        public void OnEnable()
        {
            switch (_normalAxis)
            {
                case NormalAxis.Vertical:
                    _plane = new Plane(Vector3.forward, -Vector3.forward * _offset);
                    isInited = true;
                    break;
                case NormalAxis.Horizontal:
                    _plane = new Plane(Vector3.up, Vector3.up * _offset);
                    isInited = true;
                    break;
            }
        }

        public void OnDisable()
        {
            isInited = false;
        }

        /// <summary>
        /// Get cross point on plane.
        /// </summary>
        /// <param name="camera"> The camera that will give ray. </param>
        /// <returns></returns>
        public static CrossPoint GetCrossPoint(Camera camera = null)
        {
            CrossPoint crossData = new CrossPoint();
            crossData.isReached = false;

            if (isInited == false)
                return crossData;

            if (camera == null)
                camera = Camera.main;

            Ray ray = camera.ScreenPointToRay(Input.mousePosition);
            if (_plane.Raycast(ray, out float enter))
            {

                crossData.isReached = true;
                crossData.point = ray.GetPoint(enter);

                return crossData;
            }

            return crossData;
        }

        public void OnDrawGizmosSelected()
        {
            switch (_normalAxis)
            {
                case NormalAxis.Vertical:
                    Gizmos.color = Color.yellow;
                    Vector3 center = -Vector3.forward * _offset;
                    Gizmos.DrawLine(center + new Vector3(20, 20, 0), center + new Vector3(20, -20, 0));
                    Gizmos.DrawLine(center + new Vector3(20, -20, 0), center + new Vector3(-20, -20, 0));
                    Gizmos.DrawLine(center + new Vector3(-20, -20, 0), center + new Vector3(-20, 20, 0));
                    Gizmos.DrawLine(center + new Vector3(-20, 20, 0), center + new Vector3(20, 20, 0));
                    break;
                case NormalAxis.Horizontal:
                    Gizmos.color = Color.yellow;
                    center = Vector3.up * _offset;
                    Gizmos.DrawLine(center + new Vector3(20, 0, 20), center + new Vector3(20, 0, -20));
                    Gizmos.DrawLine(center + new Vector3(20, 0, -20), center + new Vector3(-20, 0, -20));
                    Gizmos.DrawLine(center + new Vector3(-20, 0, -20), center + new Vector3(-20, 0, 20));
                    Gizmos.DrawLine(center + new Vector3(-20, 0, 20), center + new Vector3(20, 0, 20));
                    break;
            }
        }
    }
}
