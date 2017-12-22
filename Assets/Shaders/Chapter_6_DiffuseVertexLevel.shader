// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shader/Charpter 6/DiffuseVertexLevel" {
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
			float3 color:COLOR;
		};

		v2f vert(a2v v){
			v2f o;
			o.pos=UnityObjectToClipPos(v.vertex);
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			// m*v = v * m^-1 矩阵
			fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
			//光源方向
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			//计算漫反射强度
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
			


			o.color = ambient+diffuse;

			return o;
		}

		fixed4 frag(v2f i) :SV_Target{
		return fixed4(i.color,1.0);
		
		}

		
		
		ENDCG


		}
		
		
	}
	FallBack "Diffuse"
}
