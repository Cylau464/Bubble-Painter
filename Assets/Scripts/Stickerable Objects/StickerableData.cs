using UnityEngine;
using engine;
using data;
using System.Collections.Generic;

namespace Stickerable
{
    [System.Serializable]
    public struct Data
    {
        //public Dictionary<int, StickerableTexture> StickerableTextures;
        public Dictionary<int, int> StickersCount;
        //public Dictionary<int, Texture2D> Textures;
        public int CurrentID;
    }

    [System.Serializable]
    public struct StickerableTexture
    {
        public Texture2D Texture;
        public int StickersCount;

        public StickerableTexture(Texture2D texture, int stickersCount = 0)
        {
            Texture = texture;
            StickersCount = stickersCount;
        }
    }

    [CreateAssetMenu(fileName = "New Stickerable Data", menuName = "Add/Stickerable Data")]
    public class StickerableData : ScriptableAsset, IResetData, IAwake, IData
    {
        [Header("Data")]
        [Tooltip("Currect data saving values.")]
        [SerializeField] private Data _data;
        private Dictionary<int, Texture2D> _textures;
        public Data Data => _data;
        public Dictionary<int, Texture2D> Textures => _textures;

        private const string texturePathPrefix = "/data/textures/";
        private const string texturePath = "_sticker_texture.png";

        public void Awake()
        {
            Initialize();
        }

        public void ResetData()
        {
            //_data.StickerableTextures = null;
            _data.CurrentID = 0;
            _data.StickersCount = new Dictionary<int, int>();
            //_data.Textures = new Dictionary<int, Texture2D>();
            _textures = new Dictionary<int, Texture2D>();
        }

        public string GetKey()
        {
            return "StickerableData.json";
        }

        public void Initialize()
        {
            _data = ES3.Load(GetKey(), ObjectSaver.GetSavingPathFile<Data>(GetKey()), _data);

            if (_data.StickersCount == null)
            {
                ResetData();
            }
            else
            {
                List<int> keys = new List<int>(_data.StickersCount.Keys);
                _textures = new Dictionary<int, Texture2D>(_data.StickersCount.Count);

                foreach (int key in keys)
                {
                    string path = Application.persistentDataPath + texturePathPrefix + key + texturePath;
                    _textures[key] = ES3.LoadImage(path);
                }
            }
        }
        
        public void Save()
        {
            ES3.Save(GetKey(), _data, ObjectSaver.GetSavingPathFile<Data>(GetKey()));
        }

        public bool AddStickerableTexture(int id, Texture2D texture)
        {
            if (texture == null)
            {
                Debug.LogError("Try to save null texture!");
                return false;
            }

            if (_textures.ContainsKey(id) == true)
            {
                _textures[id] = texture;
                _data.StickersCount[id]++;
            }
            else
            {
                _textures.Add(id, texture);
                _data.StickersCount.Add(id, 1);
            }

            _data.CurrentID = id;
            
            string path = Application.persistentDataPath + texturePathPrefix + id + texturePath;
            ES3.SaveImage(_textures[id], path);
            Save();
            return true;
        }
    }
}