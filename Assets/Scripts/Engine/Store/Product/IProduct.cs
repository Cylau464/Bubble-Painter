namespace store
{
    public interface IProduct
    {
        void Initialize(Store store, int id);

        bool AllowBuy();
        bool Buy();

        bool Selected();
        bool AllowSelect();
        bool Deselect();

        bool UpdateState();
    }
}
