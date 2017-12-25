Shader "Unity Shader/Charpter 8/AlphaBlend"
{
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1.0))=1
	}
	SubShader {
		// 不受投影影响  
		Tags { "Queue"="AlphaTest" "IgnoreProjectot"="True" "RenderType"="TransparentCutout"}
		
		pass{
			Tags  {"LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcColor
			CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			struct a2v{
				 float4 vertex:POSITION;
				 float3 normal:NORMAL;
				 float4 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex );
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				float3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal, worldLightDir ));

				return fixed4(ambient+diffuse ,texColor.a * _AlphaScale);
			}

			ENDCG
		
		}
	
	}
	FallBack "Transparent/VertexLit"
}
