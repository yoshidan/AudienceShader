using System.Linq;
using System.Runtime.InteropServices;
using UnityEngine;
using Random = UnityEngine.Random;

struct AudienceInfo
{
    public Vector3 position;
    public Vector4 color;
    public Matrix4x4 rotation;
}

public class AudienceController : MonoBehaviour
{

    [SerializeField]
    private ComputeShader computeShader;
    
    [SerializeField]
    private Mesh audienceMesh;
    
    [SerializeField]
    private Material audienceMaterial;
    
    [SerializeField]
    private Area[] areas;
    
    private GraphicsBuffer dataBuffer;
    private GraphicsBuffer argsBuffer;

    private int kernelId;
    
    private AudienceInfo[] data;
    
    private int audienceCount;
    
    private void Awake()
    {
        kernelId = computeShader.FindKernel("CSMain");
        audienceCount = areas.Select(v => v.count).Sum();
    }
    
    void Start()
    {
        data = new AudienceInfo[audienceCount];
        dataBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, audienceCount, Marshal.SizeOf(typeof(AudienceInfo)));
        var index = 0;
        foreach (var area in areas)
        {
            for (var j = 0; j < area.count; j++)
            {
                data[index] = new AudienceInfo
                {
                    position = area.position(),
                    color = new Vector4(Random.value, Random.value, Random.value, 1.0f),
                };
                index++;
            }
        }
        dataBuffer.SetData(data);
        computeShader.SetBuffer(kernelId, "_Buffer", dataBuffer);
        audienceMaterial.SetBuffer("_Buffer", dataBuffer);
        
        // indirect args
        var args = new uint[4];
        args[0] = audienceMesh.GetIndexCount(0);
        args[1] = (uint) audienceCount;
        args[2] = 0;
        args[3] = 0;
       
        argsBuffer = new GraphicsBuffer(GraphicsBuffer.Target.IndirectArguments, 1, sizeof(uint) * args.Length);
        argsBuffer.SetData(args);

    }

    void Update()
    {
        computeShader.SetFloat("_Time", Time.time);
        computeShader.Dispatch(kernelId, Mathf.Max(audienceCount / 8, 1), 1, 1);

        Graphics.DrawMeshInstancedIndirect(audienceMesh, 0, audienceMaterial,
            new Bounds(Vector3.zero , Vector3.one * 20.2f), argsBuffer); 
    }

    private void OnDestroy()
    {
        if (dataBuffer != null)
        {
            dataBuffer.Release();
        }
        if (argsBuffer != null)
        {
            argsBuffer.Release();
        }

        argsBuffer = null;
        dataBuffer = null;
    }
}
