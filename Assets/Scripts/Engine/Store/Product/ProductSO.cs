using System;
using UnityEngine;

namespace store
{
    [CreateAssetMenu(fileName = "New Product", menuName = "Add/Store/Add Product", order = 10)]
    public class ProductSO : Product
    {
        #region delegates
        private event Action<ProductStatue> _handleStateChanged;
        public event Action<ProductStatue> handleStateChanged
        {
            add
            {
                _handleStateChanged += value;
            }
            remove
            {
                _handleStateChanged -= value;
            }
        }
        #endregion

        public int id { get; private set; }
        public int price { get; private set; }
        public Store store { get; private set; }
        public ProductStatue state { get; private set; } = ProductStatue.Non;

        public override void Initialize(Store store, int id)
        {
            this.id = id;
            this.store = store;
            UpdateState();
        }

        public override bool Buy()
        {
            return ChangeState(ProductStatue.Selected);
        }

        public override bool Deselect()
        {
            return ChangeState(ProductStatue.Bought);
        }

        public override bool Selected()
        {
            return ChangeState(ProductStatue.Selected);
        }

        public override bool AllowBuy()
        {
            return true;
        }

        public override bool AllowSelect()
        {
            return true;
        }

        public override bool UpdateState()
        {
            ProductStatue newState;
            if (store.GetIDSelectedProduct() == id)
                newState = ProductStatue.Selected;
            else
            if (store.IsBoughtProduct(id))
                newState = ProductStatue.Bought;
            else
                newState = ProductStatue.ForBuy;

            return ChangeState(newState);
        }

        protected bool ChangeState(ProductStatue newState)
        {
            if (state != newState)
            {
                state = newState;
                _handleStateChanged?.Invoke(state);
                return true;
            }
            return false;
        }
    }
}
