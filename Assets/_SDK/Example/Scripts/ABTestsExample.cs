using app;
using UnityEngine;
using UnityEngine.UI;

public class ABTestsExample : MonoBehaviour
{
    public Text debugs1;
    public Text debugs2;

    protected void OnEnable()
    {
        ABTesting.handleUpdated += OnUpdateABTests;
    }

    protected void Update()
    {
        debugs1.text = "On Started ABTests: " + ABTesting.isReady;
        debugs2.text = "Testing variant value: " + ABTesting.GetValue("Atoms");
    }

    protected void OnDisable()
    {
        ABTesting.handleUpdated -= OnUpdateABTests;
    }

    private void OnUpdateABTests()
    {
        debugs1.text = "On Updated ABTests: " + ABTesting.isReady;
    }
}

