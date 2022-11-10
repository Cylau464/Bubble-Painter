using System;
using UnityEngine;
using data;

namespace store
{
    [CreateAssetMenu(fileName = "New Store", menuName = "Add/Store/Add Store", order = 1)]
    public class Store : engine.ScriptableAsset, IAwake, IData
    {
        #region delegates
        private event Action<IProduct, ProductStatue> _handleRefresh;
        public event Action<IProduct, ProductStatue> handleRefresh
        {
            add
            {
                _handleRefresh += value;
            }
            remove
            {
                _handleRefresh -= value;
            }
        }
        #endregion

        #region variables
        [Header("Data")]
        [SerializeField] protected engine.coin.CoinsData _coinData;
        [SerializeField] protected StoreData _data;

        [Header("Settings")]
        [SerializeField] protected int _idStore = -1;
        [SerializeField] protected Product[] _products;
        #endregion

        #region inits
        public void Awake()
        {
            Initialize();
        }

        public void Initialize()
        {
            LoadData();

            InitializeProducts();
        }

        private void InitializeProducts()
        {
            if (_products == null)
                return;

            for (int i = 0; i < _products.Length; i++)
            {
                _products[i].Initialize(this, i);
            }
        }

        public void RefreshProducts()
        {
            for (int i = 0; i < _products.Length; i++)
            {
                _products[i].UpdateState();
            }
        }
        #endregion

        #region data
        public void LoadData()
        {
            _data = ES3.Load(GetKey(), ObjectSaver.GetSavingPathFile<Data>(GetKey()), _data);
        }

        public void Save()
        {
            ES3.Save(GetKey(), _data, ObjectSaver.GetSavingPathFile<Data>(GetKey()));
        }
        #endregion

        #region select
        protected void DeselectProduct()
        {
            if (_data.idSelectedProduct < 0)
                return;

            _products[_data.idSelectedProduct].Deselect();
            _handleRefresh?.Invoke(_products[_data.idSelectedProduct], ProductStatue.Bought);
        }

        /// <summary>
        /// If user the use can select or choice this product.
        /// </summary>
        /// <param name="idProduct"> The id of the product. </param>
        /// <returns> True if product is enable for select.</returns>
        public bool AllowSelect(int idProduct)
        {
            if (idProduct < 0 || _products.Length <= idProduct)
            {
                Debug.LogError("The id is out of array lenght: ID " + idProduct + ", Array Lenght: " + _products.Length);
                return false;
            }

            return _data.isBoughtProducts[idProduct] && _data.idSelectedProduct != idProduct && _products[idProduct].AllowSelect();
        }

        public bool SelectProduct(int idProduct)
        {
            if (!AllowSelect(idProduct))
                return false;
            else
            {
                // Deselect the old id.
                DeselectProduct();

                // update data product.
                _data.idSelectedProduct = idProduct;

                // Execut select on the product class.
                _products[idProduct].Selected();
                _handleRefresh?.Invoke(_products[idProduct], ProductStatue.Selected);

                // Save data.
                Save();
                return true;
            }
        }
        #endregion

        #region buy
        /// <summary>
        /// If user the use can Buy this product.
        /// </summary>
        /// <param name="idProduct"> The id of the product. </param>
        /// <returns> True if product is enable for buy.</returns>
        public bool AllowBuy(int idProduct)
        {
            if (idProduct < 0 || _products.Length <= idProduct)
            {
                Debug.LogError("The id is out of array lenght: ID " + idProduct + ", Array Lenght: " + _products.Length);
                return true;
            }

            return !_data.isBoughtProducts[idProduct] && _products[idProduct].AllowBuy();
        }

        public bool BuyProduct(int idProduct)
        {
            if (!AllowBuy(idProduct))
                return false;

            DeselectProduct();

            // Update data
            _data.idSelectedProduct = idProduct;
            _data.isBoughtProducts[idProduct] = true;

            // Execut buy on the product class.
            _products[idProduct].Buy();
            _handleRefresh?.Invoke(_products[idProduct], ProductStatue.Selected);

            // Save data.
            Save();
            return true;
        }
        #endregion

        #region info
        public int GetTotalCoins()
        {
            return _coinData.totalCoins;
        }

        public int GetTotalProducts()
        {
            return _products.Length;
        }

        public int GetIDSelectedProduct()
        {
            return _data.idSelectedProduct;
        }

        public IProduct GetProduct(int idProduct)
        {
            if (idProduct < 0 || _products.Length <= idProduct)
            {
                Debug.LogError("The id is out of array lenght: ID " + idProduct + ", Array Lenght: " + _products.Length);
                return null;
            }

            return _products[idProduct];
        }

        public bool IsBoughtProduct(int idProduct)
        {
            if (_data.isBoughtProducts.Length <= idProduct)
                return false;

            return _data.isBoughtProducts[idProduct];
        }
        #endregion

        #region editor
        public void ResetData()
        {
            if (_products != null && _products.Length != 0)
            {
                _data = new StoreData();
                _data.idSelectedProduct = 0;
                _data.isBoughtProducts = new bool[_products.Length];

                if (_data.isBoughtProducts.Length != 0) _data.isBoughtProducts[0] = true;
            }

#if UNITY_EDITOR
            if (_idStore < 0)
                _idStore = editor.ScriptableManager.FindScribtableObjectsOfType<Store>().Length;
#endif
        }

        public string GetKey()
        {
            return "Store" + _idStore.ToString() + ".json";
        }
        #endregion
    }
}
