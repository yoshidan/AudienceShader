Shader "Custom/audience"
{
    Properties {
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0) 
    }
    SubShader
    {
        
        Tags { 
            "Queue"="Transparent"
            "RenderType"="Transparent" 
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #include "common.hlsl"

            float4 _EmissionColor;;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color: COLOR;
            };

            StructuredBuffer<AudienceInfo> _Buffer;
            static float4 offset = float4(0.0, 0.15, 0.0, 0.0); // penlight height
            
            v2f vert (appdata v, uint instanceId : SV_InstanceID)
            {
                AudienceInfo audience = _Buffer[instanceId];
                v2f o;

                float4 wpos = mul(audience.rotation, v.vertex + offset) - offset + float4(audience.position.xyz, 1.0);                
                o.vertex = mul(UNITY_MATRIX_VP, float4(wpos.xyz, 1.0)) ;

                o.color = audience.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color + i.color * _EmissionColor;
            }
          
            ENDCG
        }
    }
}
