using UnityEngine;

public interface IGUNReciever
{
    void AddForce(Vector3 pos, Vector3 dir, float force);
}

[ExecuteInEditMode]
public class JellyShaderModify : MonoBehaviour, IGUNReciever
{
    public enum Type
    {
        Wave,
        Explore,
    }

    [SerializeField] private float _collisionForce = 1f;
    [SerializeField] private ComputeShader cs;
    [SerializeField] private Shader shader;
    [SerializeField] public float Spring;
    [SerializeField] public float Damping;
    [SerializeField] public float Namida;
    [SerializeField] public int CountMax;
    [SerializeField] public Type type;

    private MeshRenderer render;
    private int probe;
    private Vector4[] pAfs;
    private Vector4[] dAts;

    private Collider _collider;
    private MaterialPropertyBlock _propertyBlock;

    private void Start()
    {
        _collider = GetComponent<Collider>();
    }

    private void OnEnable()
    {
        if (render == null)
        {
            render = GetComponent<MeshRenderer>();

            if (render == null)
            {
                render = gameObject.AddComponent<MeshRenderer>();
            }

            _propertyBlock = new MaterialPropertyBlock();
            //render.sharedMaterial = new Material(shader);
            //render.hideFlags = HideFlags.HideInInspector;
        }
        pAfs = new Vector4[CountMax];
        dAts = new Vector4[CountMax];
        probe = 0;
    }

    public void AddForce(Vector3 pos, Vector3 dir, float force)
    {
        //Debug.Log("Bingo");
        Vector4 posAndForce = new Vector4(pos.x, pos.y, pos.z, force);
        Vector4 dirAndTime = new Vector4(dir.x, dir.y, dir.z, Time.time);
        EnQueue(posAndForce, dirAndTime);
        Transmit();
    }

    //private void OnCollisionEnter(Collision collision)
    //{
    //    foreach (ContactPoint contact in collision.contacts)
    //    {
    //        Vector3 dir = (contact.otherCollider.transform.position - contact.thisCollider.transform.position).normalized;
    //        float force = Mathf.Clamp(_collisionForce * collision.relativeVelocity.magnitude, 0f, _collisionForce);
            
    //        if (contact.otherCollider.TryGetComponent(out JellyShaderModify jsm))
    //            jsm.AddForce(contact.point, dir, force);

    //        AddForce(contact.point, -dir, force);
    //    }
    //}

    private void OnTriggerEnter(Collider other)
    {
        Vector3 otherClosestPoint = other.ClosestPointOnBounds(transform.position);
        Vector3 myClosestPoint = _collider.ClosestPointOnBounds(other.transform.position);
        Vector3 intersectionPoint = (otherClosestPoint + myClosestPoint) / 2f;
        Vector3 relativeVelocity;

        if (other.attachedRigidbody == null)
            relativeVelocity = _collider.attachedRigidbody.GetPointVelocity(intersectionPoint);
        else
            relativeVelocity = _collider.attachedRigidbody.GetPointVelocity(intersectionPoint) - other.attachedRigidbody.GetPointVelocity(intersectionPoint);

        Vector3 dir = (other.transform.position - transform.position).normalized;
        float force = Mathf.Clamp(_collisionForce * relativeVelocity.magnitude, .1f, _collisionForce);
        
        if (other.TryGetComponent(out JellyShaderModify jsm))
            jsm.AddForce(otherClosestPoint, dir, force);

        AddForce(myClosestPoint, -dir, force);
    }

    //private void OnCollisionExit(Collision collision)
    //{
    //    Vector3 otherClosetPoint = collision.collider.ClosestPoint(transform.position);
    //    Vector3 myClosetPoint = _collider.ClosestPoint(otherClosetPoint);
    //    Vector3 dir = (otherClosetPoint - myClosetPoint).normalized;
    //    float force = Mathf.Min(_collisionForce * collision.impulse.magnitude, _collisionForce);

    //    if (collision.collider.TryGetComponent(out JellyShaderModify jsm))
    //        jsm.AddForce(myClosetPoint, dir, force);

    //    AddForce(otherClosetPoint, -dir, force);
    //}

    private void EnQueue(Vector4 a, Vector4 b)
    {
        pAfs[probe] = a;
        dAts[probe] = b;
        probe++;
        probe %= CountMax;
    }

    private void Transmit()
    {
        //for (int i = 0; i < render.materials.Length; i++)
        //{
        //    render.GetPropertyBlock(_propertyBlock, i);
        //    _propertyBlock.SetInt("_Count", CountMax);
        //    _propertyBlock.SetFloat("_Spring", Spring);
        //    _propertyBlock.SetFloat("_Damping", Damping);
        //    _propertyBlock.SetFloat("_Namida", Namida);
        //    _propertyBlock.SetVectorArray("_pAfs", pAfs);
        //    _propertyBlock.SetVectorArray("_dAts", dAts);
        //    render.SetPropertyBlock(_propertyBlock, i);
        //}

        render.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetInt("_Count", CountMax);
        _propertyBlock.SetFloat("_Spring", Spring);
        _propertyBlock.SetFloat("_Damping", Damping);
        _propertyBlock.SetFloat("_Namida", Namida);
        _propertyBlock.SetVectorArray("_pAfs", pAfs);
        _propertyBlock.SetVectorArray("_dAts", dAts);
        render.SetPropertyBlock(_propertyBlock);

        //switch(type)
        //{
        //    case Type.Wave:
        //        render.sharedMaterial.EnableKeyword("_IsWave");
        //        render.sharedMaterial.DisableKeyword("_Explore");
        //        break;
        //    case Type.Explore:
        //        render.sharedMaterial.EnableKeyword("_Explore");
        //        render.sharedMaterial.DisableKeyword("_IsWave");
        //        break;
        //}

    }
}
