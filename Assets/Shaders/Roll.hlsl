void Roll_float(float3 Position, out float3 Out)
{
    float UNITY_PI = 3.14159265359f;
    float3 v0 = Position.xyz;

    float3 upDir = normalize(_UpDir);
    float3 blendDir = normalize(_RollDir);

    float y = _PointY;
    float dP = dot(v0 - upDir * y, upDir);
    dP = max(0, dP);
    float3 fromInitialPos = upDir * dP;
    v0 -= fromInitialPos;

    float length = 2 * UNITY_PI * _Radius;
    float r = dP / length;
    float a = 2 * r * UNITY_PI;

    float s = sin(a);
    float c = cos(a);
    float one_minus_c = 1.0 - c;

    float3 axis = normalize(cross(upDir, blendDir));
    float3x3 rot_mat =
    {
        one_minus_c * axis.x * axis.x + c, one_minus_c * axis.x * axis.y - axis.z * s, one_minus_c * axis.z * axis.x + axis.y * s,
        one_minus_c * axis.x * axis.y + axis.z * s, one_minus_c * axis.y * axis.y + c, one_minus_c * axis.y * axis.z - axis.x * s,
        one_minus_c * axis.x * axis.z - axis.y * s, one_minus_c * axis.y * axis.z + axis.x * s, one_minus_c * axis.z * axis.z + c
    };
    float3 cycleCenter = blendDir * _PointX + blendDir * _Radius + upDir * y;
    v0.xyz = mul(rot_mat, v0.xyz - cycleCenter) + cycleCenter;

    Out = v0;
}