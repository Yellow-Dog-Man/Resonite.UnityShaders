// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Debug"
{
	Properties
	{
		_Scale ("Scale", Vector) = (1.0,1.0,1.0,0)
		_Offset ("Offset", Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _NORMALIZE
			#pragma multi_compile _POSITION _COLOR _COLOR_ALPHA _NORMAL _TANGENT _TANGENT4 _UV0 _UV1 _UV2 _UV3 _BITANGENT
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				float4 uv3 : TEXCOORD3;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
#ifdef _BITANGENT
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
#endif
				float3 data : TEXCOORD0;
			};
			
			uniform float3 _Scale;
			uniform float3 _Offset;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

#if		defined(_POSITION)
				o.data = v.vertex.xyz;
#elif	defined(_COLOR)
				o.data = v.color.rgb;
#elif	defined(_COLOR_ALPHA)
				o.data = v.color.aaa;
#elif	defined(_NORMAL)
				o.data = v.normal;
#elif	defined(_TANGENT)
				o.data = v.tangent;
#elif	defined(_TANGENT4)
				o.data = v.tangent.www;
#elif	defined(_UV0)
				o.data = v.uv0.xyz;
#elif	defined(_UV1)
				o.data = v.uv1.xyz;
#elif	defined(_UV2)
				o.data = v.uv2.xyz;
#elif	defined(_UV3)
				o.data = v.uv3.xyz;
#elif	defined(_BITANGENT)
				o.normal = v.normal;
				o.tangent = v.tangent;
#endif
				return o;
			}

		
			float4 frag (v2f i) : SV_Target
			{
#ifdef _BITANGENT
				i.data = cross(i.normal, i.tangent.xyz) * i.tangent.w;
#endif

#ifdef _NORMALIZE
				i.data = normalize(i.data);
#endif

				return float4(saturate((i.data * _Scale) + _Offset), 1);
			}
			ENDCG
		}
	}
}
