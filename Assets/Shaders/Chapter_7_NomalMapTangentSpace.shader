Shader "Unity Shader/Charpter 7/NomalMapTangentSpace"
{
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpTex("Normal Map",2D)="bump"{}
		_BumpScale("Bump Scale",float)=1.0
		_Specular("Specular Color",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct a2v{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				//float4的原因是w分量是需要使用w分量得到副切线
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;

			};
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw=v.texcoord.xy*_BumpTex_ST.xy+_BumpTex_ST.zw;
				//副切线
				float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				//模型空间到切线空间的矩阵
				float3x3 rotation=float3x3(v.tangent.xyz,binormal,v.normal);
				//[--|----|-------]
				//[-切线-|-副切线|---法线 ]
				o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed4 packedNormal = tex2D(_BumpTex,i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy*=_BumpScale;
				tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo=tex2D(_MainTex,i.uv.xy)*_Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir+tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb *pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
