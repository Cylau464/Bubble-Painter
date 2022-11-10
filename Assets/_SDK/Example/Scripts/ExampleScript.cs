using app;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ExampleScript : MonoBehaviour
{
    public InputField inputField;

    protected void OnEnable()
    {
        AppsManager.onCompletedRewardedVideo += OnCompletedRewardedVideo;
    }

    protected void OnDisable()
    {
        AppsManager.onCompletedRewardedVideo -= OnCompletedRewardedVideo;
    }

    #region rewards
    private void OnCompletedRewardedVideo(IronSourcePlacement arg1, int arg2)
    {
        /// Execute function on rewards videos.
        inputField.text = "On Completed Rewarded Video id reward is: " + arg2;
    }

    public void ShowRewardedVideo()
    {
        AppsManager.ShowRewardedVideo("Coins 3X", Random.Range(0, 3));
    }
    #endregion


    public void LoadScene(int index)
    {
        SceneManager.LoadScene(index);
    }

    public void ShowInterstitial()
    {
        AppsManager.ShowInterstitial();
    }

    public void ShowBanner()
    {
        AppsManager.ShowBanner();
    }

    public void HideBanner()
    {
        AppsManager.HideBanner();
    }

    public void SendEvent()
    {
        AppsManager.SendEvent(inputField.text);
    }

    public void SendEvent(string eventName)
    {
        AppsManager.SendEvent(eventName);
    }
}