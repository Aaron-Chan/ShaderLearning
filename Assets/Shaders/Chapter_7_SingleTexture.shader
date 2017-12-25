﻿Shader "Unity Shader/Charpter 7/Chapter_7_SingleTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
			//定义漫反射的颜色
		_Color("Color Tint",Color)=(1,1,1,1)
		//高光反射颜色
		_Specular("Specular",Color)= (1,1,1,1)
		//高光区域大小
		_Gloss("Gloss",Range(8.0,256))= 20
	}
	SubShader
	{

		Pass
		{
			Tags{ "LightMode"="ForwardBase"}//得到内置的光照变量

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Color;
			sampler2D _MainTex;
			//纹理坐标的缩放 和位移值
			fixed4 _MainTex_ST;
		fixed4 _Specular;
		float _Gloss;
			
		#include "Lighting.cginc"

			struct a2v{
			float4 vertex :POSITION;
			float3 normal:NORMAL;
			float4 texcoord :TEXCOORD0;
		};
		struct v2f{
			float4 pos :SV_POSITION;
			float3 worldNormal:TEXCOORD0;
			float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
		};

		
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos =mul(unity_ObjectToWorld,v.vertex).xyz;
			o.uv= v.texcoord.xy * _MainTex_ST.xy+_MainTex_ST.zw;
			// or
			// o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb*_Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//计算漫反射强度
		fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));
		
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos);
			fixed3 halfDir= normalize(worldLightDir+viewDir);
			fixed3 specular = _LightColor0.rgb*_Specular* pow(max(0,dot(worldNormal,halfDir)),_Gloss);
				
			return fixed4( specular+ambient+diffuse,1.0);
			}
			ENDCG
		}
	}
}
