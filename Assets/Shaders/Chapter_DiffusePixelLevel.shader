// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shader/Charpter 6/DiffusePixelLevel" {
	Properties {
		//定义漫反射的颜色
		_Diffuse("Diffuse",Color)=(1,1,1,1)
	}
	SubShader {
		Pass{
		Tags{ "LightMode"="ForwardBase"}//得到内置的光照变量
			
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "Lighting.cginc"
			fixed4 _Diffuse;

		struct a2v{
			float4 vertex :POSITION;
			float3 normal:NORMAL;
		};
		struct v2f{
			float4 pos :SV_POSITION;
			float3 worldNormal:TEXCOORD0;
		};

		v2f vert(a2v v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
			return o;
		}

		fixed4 frag(v2f v):SV_Target{
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			//世界坐标下的模型法线
		fixed3 worldNormal = normalize(v.worldNormal);
		//光源方向
		fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
		//计算漫反射强度
		fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
		

		fixed3 color = ambient+diffuse;
			return fixed4(color,1.0);
		}
		



		ENDCG
		}
	
	}
	FallBack "Diffuse"
}
