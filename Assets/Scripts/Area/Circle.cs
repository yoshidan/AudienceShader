using System;
using UnityEngine;
using Random = UnityEngine.Random;

public class Circle : Area
{
    public float radius = 2;
    public int angleFrom = 0;
    public int angleTo = 360;
        
    public override Vector3 position()
    {
        var angle = - Mathf.Deg2Rad * Random.Range(angleFrom, angleTo);
        var r = Random.Range(0.0f, radius);
        var x = r * Mathf.Cos(angle);
        var z = r * Mathf.Sin(angle);
        return rotation * (center + new Vector3(- x, 0, z));
    }
}