using UnityEngine;
using Cinemachine;
using System;
using UnityEngine.Rendering;
using core.level;

public class StickerMetaSystem : MonoBehaviour
{
    [SerializeField] private StickerableAssetManager _stickerableManager;
    [SerializeField] private Transform _spawnPos;

    [Header("Sticker Size")]
    [SerializeField] private StickerControllerUI _stickerControllerUI;
    [SerializeField] private float _minStickerSize = 5f;
    [SerializeField] private float _maxStickerSize = 15f;

    [SerializeField] private CinemachineVirtualCamera _stickVirtualCamera;
    
    public static StickerMetaSystem Instance;

    public Action<Sticker> OnStartStickProcess;
    public Action OnFinishStickProcess;

    private void Awake()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;
        LevelsManager.OnLevelLoaded += OnLevelLoaded;
    }

    private void OnDestroy()
    {
        LevelsManager.OnLevelLoaded -= OnLevelLoaded;
    }

    private void OnLevelLoaded(GameLevel level)
    {
        _stickVirtualCamera.Priority = 0;
    }

    public void StartStickProcess(Sticker sticker)
    {
        _stickerControllerUI.Initialize(_minStickerSize, _maxStickerSize);
        _stickVirtualCamera.Priority = 100;
        StickerableSO sso = _stickerableManager.GetSO();
        StickerableObject stickerableObj = Instantiate(sso.Prefab, _spawnPos.position, sso.Prefab.transform.rotation);

        if(_stickerableManager.StickerableData.Textures.ContainsKey(sso.ID) == true)
        {
            Texture2D texture = _stickerableManager.StickerableData.Textures[sso.ID];
            stickerableObj.Initialize(sticker, sso.ID, texture);
        }
        else
        { 
            stickerableObj.Initialize(sticker, sso.ID);
        }

        _stickVirtualCamera.LookAt = stickerableObj.transform;
        OnStartStickProcess?.Invoke(sticker);
    }

    public void FinishStickProcess()
    {
        OnFinishStickProcess?.Invoke();
    }

    public void AddSticker(int id, Texture2D renderTexture)
    {
        Texture2D texture = new Texture2D(renderTexture.width, renderTexture.height, TextureFormat.ARGB32, false);

        ////if (SystemInfo.copyTextureSupport != CopyTextureSupport.None)
        ////{
        ////    Graphics.CopyTexture(renderTexture, texture);
        ////    texture.Apply(false);
        ////}
        ////else
        //{
        //    RenderTexture.active = renderTexture;
        //    texture.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
        //    texture.Apply();
        //    RenderTexture.active = null;
        //}

        _stickerableManager.StickerableData.AddStickerableTexture(id, renderTexture);
    }
}
