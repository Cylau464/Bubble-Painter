namespace engine
{
    public static class Maths
    {
        public static float ResetAngle(float angle)
        {
            return (180 <= angle) ? angle - 360 : angle;
        }
    }
}