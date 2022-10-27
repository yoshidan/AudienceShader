using Unity.Mathematics;
using UnityEngine;
using Random = UnityEngine.Random;

public class Square : Area
{
    public float x;
    public float z;
        
    public override Vector3 position()
    {
        return rotation * (center + new Vector3(Random.Range(-x, x), 0, Random.Range(-z, z)));
    }
}