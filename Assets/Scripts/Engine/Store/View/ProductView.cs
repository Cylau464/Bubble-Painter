using UnityEngine;

namespace store
{
    public class ProductView : MonoBehaviour
    {
        public StoreViewPanel storePanel { get; private set; }
        public ProductSO product { get; private set; }

        [Header("Object")]
        [SerializeField] private GameObject _selected;
        [SerializeField] private GameObject _locked;
        [SerializeField] private GameObject _unselected;
        [SerializeField] private GameObject _hover;

        private GameObject _currentObject;
        public ProductStatue statue { get; private set; } = ProductStatue.Non;

        public void Initialize(StoreViewPanel storePanel,IProduct product)
        {
            // Init values.
            this.storePanel = storePanel;
            this.product = (ProductSO)product;

            UpdateStatue(this.product.state);
            // Init states.
            this.product.handleStateChanged += UpdateStatue;
        }

        protected void OnDestroy()
        {
            if (product != null)
                product.handleStateChanged -= UpdateStatue;
        }

        protected void UpdateStatue(ProductStatue statue)
        {
            if (this.statue == statue)
                return;

            /// Update statue
            this.statue = statue;

            // Disable the last object
            if (_currentObject != null)
                _currentObject.SetActive(false);

            switch (statue)
            {
                case (ProductStatue.Bought):
                    _currentObject = _unselected;
                    break;

                case (ProductStatue.Selected):
                    _currentObject = _selected;
                    break;

                case (ProductStatue.ForBuy):
                    _currentObject = _locked;
                    break;
            }

            if (_currentObject != null)
                _currentObject.SetActive(true);
        }

        public void SetHover(bool enableHover)
        {
            _hover.SetActive(enableHover);
        }

        public void MakeSelect()
        {
            storePanel.SelectProduct(product.id);
        }
    }
}
