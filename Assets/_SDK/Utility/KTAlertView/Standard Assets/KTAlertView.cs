#if UNITY_IOS
using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;
using System.Linq;
using System.Collections.Generic;

public class KTAlertView : MonoBehaviour {

	[DllImport("__Internal")]
	private static extern void setupKTAlertView(string title, string message, string cancelButton, string[] buttons, int tag, string objectName,
	                                            int totalButtons,string callbackName);

	private static KTAlertView _instance = null;

	public delegate void AlertViewDelegate (int tag,int clickedIndex);
	public event AlertViewDelegate AlertViewReturned; 

	private string title_;
	private string message_;
	private string cancelButton_;
	private string[] buttons_;
	int tag_;

	void Awake () {
		if (_instance == null) {
				_instance = this;
				// Sets this to not be destroyed when reloading scene
				DontDestroyOnLoad(_instance.gameObject);
		} else if (_instance != this) {
				// If there's any other object exist of this type delete it
				// as it's breaking our singleton pattern
				Destroy(gameObject);
		}
	}

		public static KTAlertView sharedInstance {
			get {
				if (!_instance) {
						_instance = FindObjectOfType(typeof(KTAlertView)) as KTAlertView;

						if (!_instance) {
								var obj = new GameObject("KTAlertView");
								_instance = obj.AddComponent<KTAlertView>();
						} else {
								_instance.gameObject.name = "KTAlertView";
						}
				}
				return _instance;
			}
		}

	public void ShowAlertViewCS (string title, string message, string cancelButton, string[] buttons, int tag) {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			ShowAlertView(title,message,cancelButton,buttons,tag,"AlertViewTapped");
		}
	}

	void ShowAlertView (string title, string message, string cancelButton, string[] buttons, int tag,string callbackName) {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			setupKTAlertView(title,message,cancelButton,buttons,tag,gameObject.name,buttons.Length,callbackName);
		}
	}

	void AlertViewTapped (string resultString) {
		string[] arr = resultString.Split('_');
		int tag = int.Parse(arr[0]);
		int clickedIndex = int.Parse(arr[1]);
		if (AlertViewReturned != null)
			AlertViewReturned(tag,clickedIndex);
	}

	void SetTitle (string title) {
		title_ =  title;
	}

	void SetMessage (string message) {
		message_ = message;
	}

	void SetCancelButton (string cancelButton) {
		cancelButton_ = cancelButton;
	}

	void SetButtons (string[] buttons) {
		buttons_ = buttons;
	}

	void SetTag (int tag) {
		tag_ = tag;
	}

	void ShowJSAlertView () {
		ShowAlertView(title_,message_,cancelButton_,buttons_,tag_,"AlertViewTappedJS");
	}
}
#endif