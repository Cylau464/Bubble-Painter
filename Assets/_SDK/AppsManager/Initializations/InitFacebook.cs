using Facebook.Unity;
using UnityEngine;

namespace app
{
    public class InitFacebook
    {
        public InitFacebook()
        {
            Initialize();
        }

        public void Initialize()
        {
            if (FB.IsInitialized == true)
            {
                CallEvents();
            }
            else
            {
                FB.Init(() =>
                {
                    CallEvents();
                });
            }
        }

        public void CallEvents()
        {
            FB.ActivateApp();
            FB.LogAppEvent(AppEventName.ActivatedApp);
            FB.Mobile.SetAdvertiserIDCollectionEnabled(true);
        }
    }
}
