// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shader/Charpter 9/ForwardRendering"
{
	Properties
	{
		//定义漫反射的颜色
		_Diffuse("Diffuse",Color)=(1,1,1,1)
		//高光反射颜色
		_Specular("Specular",Color)= (1,1,1,1)
		//高光区域大小
		_Gloss("Gloss",Range(8.0,256))= 20
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode"= "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				//环境光
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//漫反射
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal,lightDir ));
				//高光发射
				float3 halfDir = viewDir + lightDir;

				float3 specular =  _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)),_Gloss);

				//衰减系数
				float atten =1.0;

				return fixed4(diffuse+(ambient+specular) * atten,1.0);
			}
			ENDCG
		}
		pass{
			Tags { "LightMode"= "ForwardAdd" }

			Blend One One


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fwdadd
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				//环境光
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else 
					fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz-i.worldPos.xyz);
				#endif

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//漫反射
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal,lightDir ));
				//高光发射
				float3 halfDir = viewDir + lightDir;

				float3 specular =  _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)),_Gloss);

				//衰减系数
				
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten =1.0;
				#else 
					float lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
					fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif

				return fixed4(diffuse+(ambient+specular) * atten,1.0);
			}
			ENDCG
		
		}
	}
}
