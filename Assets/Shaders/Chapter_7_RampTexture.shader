// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shader/Charpter 7/RampTexture" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_RampTex ("Ramp Tex ", 2D) = "white" {}
		_Specular("Specular Color",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20
	}
	SubShader {
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 worldPos:TEXCOORD1;
				float3 wordNormal:TEXCOORD2;
			};

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.wordNormal = UnityObjectToWorldNormal(v.normal);
				o.uv= TRANSFORM_TEX(v.texcoord,_RampTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.wordNormal);
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed halfLambert = 0.5*(dot(worldNormal,worldLightDir))+0.5;
				//使用半兰伯特模型得到 halfLambert 构建纹理坐标 进行纹理采样
				fixed3 diffuseColor = tex2D(_RampTex,half2(halfLambert,halfLambert)).rgb * _Color.rgb;
				fixed3 diffuse  = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = UnityWorldSpaceViewDir(i.worldPos);
				fixed3 halfDir = normalize(viewDir + worldLightDir) ;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir )) ,_Gloss);
				
				return fixed4(ambient+diffuse+specular,1.0);

			}
			ENDCG
		}
	}
	FallBack "Specular"
}
