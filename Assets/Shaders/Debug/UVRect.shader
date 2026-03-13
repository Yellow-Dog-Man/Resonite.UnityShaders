Shader "Unlit/UVRect"
{
    Properties
    {
        _Rect ("Rect", Vector) = (0.25, 0.25, 0.75, 0.75)
        _ClipRect ("Rect", Vector) = (0, 0, 1, 1)
		_OuterColor ("Outer Color", Color) = (0, 0, 0, 1)
		_InnerColor ("Inner Color", Color) = (1, 1, 1, 1)

		_SrcBlend("SrcBlend", Float) = 1.0
		_DstBlend("DstBlend", Float) = 0.0
		_ZWrite("ZWrite", Float) = 1.0
		_Cull("Cull", Float) = 2.0
		_ZTest("ZTest", Float) = 2
    }
    SubShader
    {
		Tags { "Queue" = "AlphaTest+200" "RenderType" = "Transparent" }
        LOD 100

        Pass
        {
				Blend[_SrcBlend][_DstBlend], One One
				BlendOp Add, Max
				ZWrite[_ZWrite]
				Cull[_Cull]
				ZTest[_ZTest]
				Offset[_OffsetFactor],[_OffsetUnits]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_instancing

			#pragma multi_compile _ RECTCLIP

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "UnityStandardUtils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

				UNITY_VERTEX_OUTPUT_STEREO
            };

			float4 _Rect;
			float4 _OuterColor;
			float4 _InnerColor;

#ifdef RECTCLIP
			float4 _ClipRect;
#endif

            v2f vert (appdata v)
            {
                v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
#ifdef RECTCLIP
					clip(UnityGet2DClipping(i.uv, _ClipRect) - 0.1);
#endif

				return lerp(_OuterColor, _InnerColor, UnityGet2DClipping(i.uv, _Rect));
            }
            ENDCG
        }
    }
}
