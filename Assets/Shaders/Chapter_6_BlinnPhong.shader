Shader "Unity Shader/Charpter 6/Chapter_6_BlinnPhong" {
	Properties {
		//定义漫反射的颜色
		_Diffuse("Diffuse",Color)=(1,1,1,1)
		//高光反射颜色
		_Specular("Specular",Color)= (1,1,1,1)
		//高光区域大小
		_Gloss("Gloss",Range(8.0,256))= 20
	}
	SubShader {
		Pass{
		Tags{ "LightMode"="ForwardBase"}//得到内置的光照变量
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "Lighting.cginc"
		fixed4 _Diffuse;
		fixed4 _Specular;
		float _Gloss;

		struct a2v{
			float4 vertex :POSITION;
			float3 normal:NORMAL;
		};
		struct v2f{
			float4 pos :SV_POSITION;
			float3 worldNormal:TEXCOORD0;
			float3 worldPos:TEXCOORD1;
		};

		v2f vert(a2v v){
			v2f o;
			o.pos=UnityObjectToClipPos(v.vertex);
			o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
			o.worldPos =mul(unity_ObjectToWorld,v.vertex).xyz;
			return o;
		}

		fixed4 frag(v2f i) :SV_Target{
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 worldNormal = normalize(i.worldNormal);
		
			//光源方向
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			fixed3 reflectDir = normalize(reflect(-worldLightDir,i.worldNormal));
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos);
			fixed3 halfDir= normalize(worldLightDir+viewDir);
			//计算漫反射强度
		fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal,worldLightDir));
			fixed3 specular = _LightColor0.rgb*_Specular* pow(max(0,dot(i.worldNormal,halfDir)),_Gloss);
			
		return fixed4( specular+ambient+diffuse,1.0);
		
		}

		
		ENDCG

		}
		
	
	}
	FallBack "Specular"
}
