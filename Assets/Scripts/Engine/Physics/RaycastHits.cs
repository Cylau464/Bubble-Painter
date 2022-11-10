using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace input
{
    public static class RaycastHits
    {
        #region canvas
        /// <summary>
        /// All RaycastResult hits canvas on mouse position.
        /// </summary>
        /// <returns>RaycastResult all UI hits</returns>
        public static List<RaycastResult> GetRaycastResults(GraphicRaycaster graphicRaycaster)
        {
            return GetRaycastResults(graphicRaycaster, Input.mousePosition);
        }

        /// <summary>
        /// All RaycastResult hits canvas on position inputs.
        /// </summary>
        /// <returns>RaycastResult all UI hits</returns>
        public static List<RaycastResult> GetRaycastResults(GraphicRaycaster graphicRaycaster, Vector3 position)
        {
            PointerEventData pointerEventData = new PointerEventData(EventSystem.current);
            pointerEventData.position = position;
            List<RaycastResult> results = new List<RaycastResult>();

            graphicRaycaster.Raycast(pointerEventData, results);
            return results;
        }

        /// <summary>
        /// Get object of type T hits canvas on Mouse position.
        /// </summary>
        /// <returns>Object of Type T in UI hits</returns>
        public static TObject ObjectRaycasterCanvas<TObject>(GraphicRaycaster graphicRaycaster) where TObject : class
        {
            return ObjectRaycasterCanvas<TObject>(graphicRaycaster, Input.mousePosition);
        }

        /// <summary>
        /// Get object of type T hits canvas on input position.
        /// </summary>
        /// <returns>Object of Type T in UI hits</returns>
        public static TObject ObjectRaycasterCanvas<TObject>(GraphicRaycaster graphicRaycaster, Vector3 position) where TObject : class
        {
            RaycastResult[] results = GetRaycastResults(graphicRaycaster, position).ToArray();
            foreach (RaycastResult raycast in results)
            {
                TObject obj = raycast.gameObject.GetComponent<TObject>();
                if (obj != null)
                    return obj;
            }
            return null;
        }
        #endregion

        #region collider raycast
        public static GameObject GetColliderHitedRaycast(Camera main, LayerMask layerMask)
        {
            RaycastHit hit;
            Ray ray = main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out hit, 300, layerMask))
            {
                return hit.collider.gameObject;
            }

            return null;
        }

        public static GameObject GetColliderHitedRaycast(Camera main, Vector3 position, LayerMask layerMask)
        {
            RaycastHit hit;
            Ray ray = main.ScreenPointToRay(position);
            if (Physics.Raycast(ray, out hit, 300, layerMask))
            {
                return hit.collider.gameObject;
            }

            return null;
        }

        public static TObject GetColliderHitedRaycast<TObject>(Camera main, Vector3 position, LayerMask layerMask) where TObject : Object
        {
            RaycastHit hit;
            Ray ray = main.ScreenPointToRay(position);
            if (Physics.Raycast(ray, out hit, 300, layerMask))
            {
                return hit.collider.GetComponent<TObject>();
            }

            return null;
        }

        public static TObject GetColliderHitedRaycast<TObject>(Camera main, Vector3 position) where TObject : Object
        {
            RaycastHit hit;
            Ray ray = main.ScreenPointToRay(position);
            if (Physics.Raycast(ray, out hit, 300))
            {
                return hit.collider.GetComponent<TObject>();
            }

            return null;
        }
        #endregion
    }
}
