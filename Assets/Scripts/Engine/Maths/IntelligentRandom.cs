using System.Collections.Generic;
using UnityEngine;

namespace engine.random
{
    public struct DataRandom
    {
        public int value { get; }
        public float percent { get; }

        public DataRandom(int value, float percent)
        {
            this.value = value;
            this.percent = percent;
        }
    }

    public struct RandomFieldInfo
    {
        public int min { get; private set; }
        public int max { get; private set; }

        public RandomFieldInfo(int min, int max)
        {
            this.min = min;
            this.max = max;
        }

        public int GetRandomValue()
        {
            return Random.Range(min, max);
        }
    }

    public static class IntelligentRandom
    {
        /// <summary>
        /// You can make random by percent of all possibilities.
        /// </summary>
        public static int CustomRandom(DataRandom[] dataRandoms)
        {
            float randomValue = UnityEngine.Random.Range(0, 100);
            float lastRange = 0;
            for (int i = 0; i < dataRandoms.Length; i++)
            {
                if (lastRange <= randomValue && randomValue < lastRange + dataRandoms[i].percent)
                    return dataRandoms[i].value;
                else
                    lastRange += dataRandoms[i].percent;
            }

            if (lastRange != 100)
                throw new System.ArgumentException("The data random is not right, please give total 100 right percents");
            else
                return 0;
        }

        public static int[] GetRandomsNotRepeated(int[] values, int numbersNeeds)
        {
            List<int> rands = new List<int>(values);
            int[] returns = new int[numbersNeeds];
            for (int i = 0; i < numbersNeeds; i++)
            {
                returns[i] = rands[UnityEngine.Random.Range(0, rands.Count)];
                rands.Remove(returns[i]);
            }

            return returns;
        }

        public static int GetRandomWithField(RandomFieldInfo[] fieldInfos)
        {
            return fieldInfos[Random.Range(0, fieldInfos.Length)].GetRandomValue();
        }

        public static float RandomParabola(float value)
        {
            return (Random.value - 0.5f) * 2 * value;
        }
    }
}
