using UnityEngine;


public class Palette : MonoBehaviour
{
    private enum Axis { X, Y, Z }

    [SerializeField] private Gradient _colorsGradient;
    [Space]
    [SerializeField] private Paint _paintPrefab;
    [SerializeField] private int _paintCount = 5;
    [Header("Group Sorting")]
    [SerializeField] private Axis _axis;
    [SerializeField] private float _spacing;
    [SerializeField] private float _maxSpacing = 8.5f;
    [SerializeField] private Transform _sortStartPoint;

    private Paint[] _paints;

    private void Start()
    {
        _paints = new Paint[_paintCount];

        for(int i = 0; i < _paintCount; i++)
        {
            _paints[i] = Instantiate(_paintPrefab, transform.position, transform.rotation, transform);
            _paints[i].Validate();
            _paints[i].SetColor(_colorsGradient.Evaluate((float)i / _paintCount + 0.01f));
        }

        SortPaints();
        ColorPicker.OnColorPick.Invoke(_paints[Random.Range(0, _paints.Length)]);
    }

    private void Update()
    {
        //for (int i = 0; i < _paintCount; i++)
        //{
        //    _paints[i].SetColor(_colorsGradient.Evaluate((float)i / _paintCount + 0.01f));
        //}
        //SortPaints();
    }

    private void SortPaints()
    {
        float paintBoundSize, spacing;
        int columnNumber;
        Vector3 point, startPoint, direction;

        if(_axis == Axis.X)
        {
            direction = Vector3.right;
            paintBoundSize = _paints[0].GetComponent<Renderer>().bounds.size.x;
        }
        else if(_axis == Axis.Y)
        {
            direction = Vector3.up;
            paintBoundSize = _paints[0].GetComponent<Renderer>().bounds.size.y;
        }
        else
        {
            direction = Vector3.forward;
            paintBoundSize = _paints[0].GetComponent<Renderer>().bounds.size.z;
        }

        float overspace = 0f;
        int columns = (_paints.Length - 1) / 2;
        spacing = _spacing + paintBoundSize;

        if (_paints.Length % 2 == 0)
        {
            startPoint = point = _sortStartPoint.position + direction * spacing / 2f;
            float sp = Vector3.Scale(startPoint, direction).magnitude;
            overspace = Mathf.Max(0f, spacing * columns + sp - _maxSpacing) / (columns + 1);
        }
        else
        {
            startPoint = point = _sortStartPoint.position;
            overspace = Mathf.Max(0f, spacing * columns - _maxSpacing) / columns;
        }

        spacing = _spacing + paintBoundSize - overspace;

        for(int i = 0; i < _paints.Length; i++)
        {
            _paints[i].transform.position = point;
            columnNumber = i / 2 + 1;

            if (i % 2 == 0)
                point = startPoint - direction * spacing * columnNumber;
            else
                point = startPoint + direction * spacing * columnNumber;
        }
    }
}