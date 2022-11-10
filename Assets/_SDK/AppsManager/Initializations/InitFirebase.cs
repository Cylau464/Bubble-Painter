#if Firebase_Enable
using Firebase;
using Firebase.Analytics;

namespace app
{
    public class InitFirebase
    {
        public bool isInited { get; private set; }

        public InitFirebase()
        {
            isInited = false;
            Initialize();
        }

        public void Initialize()
        {
            FirebaseApp.CheckAndFixDependenciesAsync().ContinueWith(task => { isInited = true; });
        }

        public void SendEvent(string nameEvent)
        {
            if (isInited == true)
            {
                FirebaseAnalytics.LogEvent(nameEvent);
            }
        }

        public void SendEvent(string nameEvent, params Parameter[] parameters)
        {
            if (isInited == true)
            {
                FirebaseAnalytics.LogEvent(nameEvent, parameters);
            }
        }
    }
}
#endif