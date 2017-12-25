Shader "Unity Shader/Charpter 7/MaskTexture"
{
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpTex("Normal Map",2D)="bump"{}
		_BumpScale("Bump Scale",float)=1.0
		_SpecularMask("Specular Mask Tex",2D)="white"{}
		_Specular("Specular Color",Color)=(1,1,1,1)
		_SpecularScale("Specular Scale",float) = 1.0
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;


			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.vertex, _MainTex);
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 tangentLightDir = normalize(i.lightDir);
				float3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpTex,i.uv);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy*=_BumpScale;
				tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex,i.pos).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));

				fixed3 halfDir =normalize(tangentViewDir+tangentViewDir) ;

				// 对遮罩纹理进行采样 由于在本例中各个纹素的rgb分量都一样，所以取r代表该点对应的高光发射强度， 结合 _SpecularScale 控制高光发射强度
				// TODO 为什么是r呢？
				fixed3 specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss)  * specularMask;

				
				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
		
	}
	FallBack "Specular"
}
