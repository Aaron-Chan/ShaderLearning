
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
		Pass{
			Tags  {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			fixed _Gloss;
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f f):SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldLightDir, f.worldNormal));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldPos);
				fixed3 haldfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(haldfDir, f.worldNormal)),_Gloss);
				fixed4 color = fixed4(ambient + specular + diffuse, 1.0);
				return color;

			}

			ENDCG

        }

		Pass{
				Tags {"LightMode"= "ForwardAdd"}
				Blend One One
				CGPROGRAM
				#pragma multi_compile_fwdadd
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
				};

				fixed4 _Diffuse;
				fixed4 _Specular;
				fixed _Gloss;

				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					return o;
				}
				fixed4 frag(v2f f) :SV_Target{
					#ifdef USING_DIRECTIONAL_LIGHT
						fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					#else
						fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - f.worldPos);
					#endif
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldLightDir, f.worldNormal));
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldPos);
					fixed3 haldfDir = normalize(viewDir + worldLightDir);
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(haldfDir, f.worldNormal)),_Gloss);
					#ifdef USING_DIRECTIONAL_LIGHT
										fixed atten = 1.0;
					#else
						#if defined (POINT)
							float3 lightCoord = mul(unity_WorldToLight, float4(f.worldPos, 1)).xyz;
							fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#elif defined (SPOT)
							float4 lightCoord = mul(unity_WorldToLight, float4(f.worldPos, 1));
							fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#else
							fixed atten = 1.0;
						#endif
					#endif

					return fixed4((diffuse + specular) * atten, 1.0);
				}

				ENDCG
		}
	}
}
