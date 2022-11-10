namespace data
{
    public interface IData : engine.IResetData
    {
        /// <summary>
        /// Get the key of saving data.
        /// </summary>
        string GetKey();

        void Initialize();

        void Save();
    }
}