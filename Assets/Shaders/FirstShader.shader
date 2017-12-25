// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader/Charpter 5/Simple Shader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		pass{
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma vertex vert

		#pragma fragment frag

		// 使用结构体
		struct a2v{
		//模型空间的顶点
			float4 vertex2 : POSITION;
			//模型空间的法线方向
			float3 normal : NORMAL;
			//模型空间的第一套纹理坐标
			float3 texcoord : TEXCOORD0;
		};

		struct v2f{

			//顶点在裁减空间上的位置信息
			float4 pos:SV_POSITION;
			//COLOR0存储颜色信息
			float3 color:COLOR;
		};

		v2f vert(a2v v) {
			//访问模型的空间坐标		
			v2f o;
			
			o.pos = UnityObjectToClipPos(v.vertex2);
			// 法线分量是[-1,1]，把color映射到[0,1]
			o.color = v.normal *0.5 + fixed3(0.5,0.5,0.5);
			return o;
		}

		float4 frag(v2f i):SV_Target{
		//SV_Target 等同于 directx9中的COLOR
			//插值后的i.color显示到屏幕
			return fixed4(i.color,1.0);
		}

		ENDCG


		}
		

	}
	FallBack "Diffuse"
}