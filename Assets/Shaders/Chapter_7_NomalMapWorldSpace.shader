// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shader/Charpter 7/NomalMapWorldSpace"
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

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
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
				o.uv.xy = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy*_BumpTex_ST.xy + _BumpTex_ST.zw;
				//副切线
				float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				float3 wordPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				float3 wordNormal = UnityObjectToWorldNormal(v.normal);
				float3 wordTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 wordBinormal=cross(wordNormal,wordTangent)*v.tangent.w;

				// 使用float4只是为了利用空间 再放顶点的坐标
				o.TtoW0 = float4(wordTangent.x, wordBinormal.x, wordNormal.x ,wordPos.x);
				o.TtoW1 = float4(wordTangent.y, wordBinormal.y, wordNormal.y ,wordPos.y);
				o.TtoW2 = float4(wordTangent.z, wordBinormal.z, wordNormal.z ,wordPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 wordPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);	
				
				fixed3 lightDir =  normalize(UnityWorldSpaceLightDir(wordPos)) ;
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(wordPos));

				//得到切线空间下的法线
				fixed3 bump = UnpackNormal(tex2D(_BumpTex,i.uv.zw));
				bump.xy *=_BumpScale;
				bump.z = sqrt(1.0- saturate(dot(bump.xy,bump.xy)));

				bump = normalize(half3(dot(i.TtoW0.xyz, bump ),dot(i.TtoW1.xyz, bump ),dot(i.TtoW2.xyz, bump )));

				fixed3 albedo=tex2D(_MainTex,i.uv.xy)*_Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(bump,lightDir));
				fixed3 halfDir = normalize(lightDir+viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb *pow(max(0,dot(bump,halfDir)),_Gloss);
				return fixed4(ambient+diffuse+specular,1.0);

			}
			ENDCG
		}
	}
}
