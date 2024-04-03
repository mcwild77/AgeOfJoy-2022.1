// Upgrade NOTE: upgraded instancing buffer 'AgeOfJoySlidingDoors' to new syntax.

// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AgeOfJoy/SlidingDoors"
{
	Properties
	{
		_RoomCubemap("RoomCubemap", CUBE) = "black" {}
		_Slide("Slide", Range( 0 , 1)) = 1
		_NormalsDistance("NormalsDistance", 2D) = "bump" {}
		_DecalSmooth("DecalSmooth", Range( 0 , 1)) = 0
		_Texture_Diffuse("Texture_Diffuse", 2D) = "white" {}
		_Texture_ORM("Texture_ORM", 2D) = "white" {}
		_NormalsTiling("NormalsTiling", Vector) = (2,2,0,0)
		_GlassDistort("GlassDistort", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			half3 viewDir;
			INTERNAL_DATA
		};

		uniform sampler2D _Texture_Diffuse;
		uniform samplerCUBE _RoomCubemap;
		uniform sampler2D _NormalsDistance;
		uniform half2 _NormalsTiling;
		uniform half _GlassDistort;
		uniform sampler2D _Texture_ORM;
		uniform half _DecalSmooth;

		UNITY_INSTANCING_BUFFER_START(AgeOfJoySlidingDoors)
			UNITY_DEFINE_INSTANCED_PROP(half4, _Texture_Diffuse_ST)
#define _Texture_Diffuse_ST_arr AgeOfJoySlidingDoors
			UNITY_DEFINE_INSTANCED_PROP(half4, _Texture_ORM_ST)
#define _Texture_ORM_ST_arr AgeOfJoySlidingDoors
			UNITY_DEFINE_INSTANCED_PROP(half, _Slide)
#define _Slide_arr AgeOfJoySlidingDoors
		UNITY_INSTANCING_BUFFER_END(AgeOfJoySlidingDoors)

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			half3 _OffsetR = half3(1.32,0,0);
			half3 lerpResult4 = lerp( _OffsetR , ( _OffsetR * float3( 0.5,0,0 ) ) , v.color.r);
			half _Slide_Instance = UNITY_ACCESS_INSTANCED_PROP(_Slide_arr, _Slide);
			v.vertex.xyz += ( lerpResult4 * _Slide_Instance );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			half4 _Texture_Diffuse_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_Texture_Diffuse_ST_arr, _Texture_Diffuse_ST);
			float2 uv_Texture_Diffuse = i.uv_texcoord * _Texture_Diffuse_ST_Instance.xy + _Texture_Diffuse_ST_Instance.zw;
			half4 tex2DNode49 = tex2D( _Texture_Diffuse, uv_Texture_Diffuse );
			half4 lerpResult9 = lerp( tex2DNode49 , float4( 0,0,0,0 ) , i.vertexColor.b);
			half4 lerpResult57 = lerp( lerpResult9 , tex2DNode49 , tex2DNode49.a);
			o.Albedo = lerpResult57.rgb;
			float2 uv_TexCoord38 = i.uv_texcoord * float2( 4,4 );
			half3 tex2DNode36 = UnpackNormal( tex2D( _NormalsDistance, ( uv_TexCoord38 * _NormalsTiling ) ) );
			half3 temp_output_102_0 = ( ( i.viewDir + float3( 0,0,0 ) ) * float3( -1,1,1 ) );
			half3 temp_output_104_0 = ( float3( 1,1,1 ) / temp_output_102_0 );
			half3 appendResult103 = (half3(( ( frac( i.uv_texcoord ) * float2( 2,-2 ) ) - float2( 1,-1 ) ) , -1.0));
			half3 break108 = ( abs( temp_output_104_0 ) - ( temp_output_104_0 * appendResult103 ) );
			half3 temp_output_112_0 = ( ( min( min( break108.x , break108.y ) , break108.z ) * temp_output_102_0 ) + appendResult103 );
			half4 lerpResult48 = lerp( float4( 0,0,0,0 ) , texCUBE( _RoomCubemap, ( ( tex2DNode36 * _GlassDistort ) + ( temp_output_112_0 * half3(-1,1,1) ) ) ) , i.vertexColor.b);
			o.Emission = ( lerpResult48 * ( 1.0 - tex2DNode49.a ) ).rgb;
			half4 _Texture_ORM_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_Texture_ORM_ST_arr, _Texture_ORM_ST);
			float2 uv_Texture_ORM = i.uv_texcoord * _Texture_ORM_ST_Instance.xy + _Texture_ORM_ST_Instance.zw;
			half4 tex2DNode76 = tex2D( _Texture_ORM, uv_Texture_ORM );
			half lerpResult71 = lerp( tex2DNode76.b , 0.0 , tex2DNode49.a);
			o.Metallic = lerpResult71;
			half lerpResult70 = lerp( ( 1.0 - tex2DNode76.g ) , _DecalSmooth , tex2DNode49.a);
			o.Smoothness = lerpResult70;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.CommentaryNode;116;-5041.735,-1148.523;Inherit;False;2588.815;633.8499;Interior Mapping;20;96;97;98;99;100;101;102;103;104;105;106;107;108;109;110;111;112;113;114;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;96;-4973.597,-742.5105;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;97;-4699.357,-743.0376;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;98;-4991.735,-1098.523;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-4560.253,-743.1497;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,-2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-4660.124,-1063.65;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-4390.612,-743.0447;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-4439.814,-940.2999;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;-4207.61,-742.0447;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;-1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;104;-4196.174,-1012.549;Inherit;False;2;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-4055.544,-853.6558;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;106;-4037.38,-1013.048;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-3880.971,-1012.549;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;108;-3734.107,-1015.798;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMinOpNode;109;-3592.107,-1016.798;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;110;-3440.107,-989.798;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-3842.223,-1932.954;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;4,4;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;88;-3815.461,-1743.226;Inherit;False;Property;_NormalsTiling;NormalsTiling;6;0;Create;True;0;0;0;False;0;False;2,2;4,4;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-3277.106,-966.8749;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-3368.96,-1879.291;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-3106.307,-771.9686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;119;-2988.175,-377.5208;Inherit;False;Constant;_Vector7;Vector 7;9;0;Create;True;0;0;0;False;0;False;-1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;91;-2735.463,-1654.99;Inherit;False;Property;_GlassDistort;GlassDistort;7;0;Create;True;0;0;0;False;0;False;0.5;-0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-3037.096,-1905.571;Inherit;True;Property;_NormalsDistance;NormalsDistance;2;0;Create;True;0;0;0;False;0;False;-1;None;2e7df1fb15fc2af439af22ebf06d4591;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-2740.175,-432.1874;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-2213.242,-1887.032;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.3;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2000.649,-1316.573;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;49;-2450.906,-450.4217;Inherit;True;Property;_Texture_Diffuse;Texture_Diffuse;4;0;Create;True;0;0;0;False;0;False;-1;None;dde2996015b322c4899060b7213f12b1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1;-1294.228,-70.26935;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;83;-1434.565,-280.1708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-1714.087,-967.1108;Inherit;True;Property;_RoomCubemap;RoomCubemap;0;0;Create;True;0;0;0;False;0;False;-1;1064b3af7c0210041ac63a494868bdef;47459a021f09a7c4296bc9c1184047b4;True;0;False;black;Auto;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;3;-1148.667,131.8334;Inherit;False;Constant;_OffsetR;OffsetR;1;0;Create;True;0;0;0;False;0;False;1.32,0,0;1.32,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;76;-2534.923,-2230.818;Inherit;True;Property;_Texture_ORM;Texture_ORM;5;0;Create;True;0;0;0;False;0;False;-1;None;626d7d4c9b59e8b489ad563f10c216cd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;58;-852.0833,-749.2839;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;85;-1385.898,-246.8375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;82;-1392.565,-302.1707;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;9;-325.6674,-982.8701;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-838.5582,281.4338;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;61;699.1879,-176.0157;Inherit;False;228;210;Normal lerp - Alpha = Frame;1;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;48;-37.94452,-389.2363;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;52;219.4812,-297.6888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;-58.31451,-1151.946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;81;-1407.232,-314.8375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;84;-1394.565,-278.1708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;260.5606,-1496.473;Inherit;False;Constant;_MetallicDecal;MetallicDecal;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;57;91.11432,-818.1927;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;339.5966,-1017.217;Inherit;False;Property;_DecalSmooth;DecalSmooth;3;0;Create;True;0;0;0;False;0;False;0;0.477;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;4;-529.1141,94.72583;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-495.3331,334.5;Inherit;False;InstancedProperty;_Slide;Slide;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;74;-2467.669,-1711.418;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;115;-2630.92,-788.0221;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;66;-436.145,-4.015808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;86;-1388.565,-222.8375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;60;505.8547,56.65102;Inherit;False;Constant;_Vector0;Vector 0;8;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-199.9996,219.1667;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;59;749.1879,-126.0157;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;62;1066.521,103.3176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;494.8147,-405.022;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;67;676.5658,-728.6603;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;70;804.509,-1055.398;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;71;776.8518,-1371.385;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;113;-2952.688,-780.2559;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2780.362,-651.0056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;65;308.5216,-64.01581;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;36.52148,-77.34918;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1593.874,-333.5654;Half;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AgeOfJoy/SlidingDoors;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;97;0;96;0
WireConnection;99;0;97;0
WireConnection;100;0;98;0
WireConnection;101;0;99;0
WireConnection;102;0;100;0
WireConnection;103;0;101;0
WireConnection;104;1;102;0
WireConnection;105;0;104;0
WireConnection;105;1;103;0
WireConnection;106;0;104;0
WireConnection;107;0;106;0
WireConnection;107;1;105;0
WireConnection;108;0;107;0
WireConnection;109;0;108;0
WireConnection;109;1;108;1
WireConnection;110;0;109;0
WireConnection;110;1;108;2
WireConnection;111;0;110;0
WireConnection;111;1;102;0
WireConnection;87;0;38;0
WireConnection;87;1;88;0
WireConnection;112;0;111;0
WireConnection;112;1;103;0
WireConnection;36;1;87;0
WireConnection;117;0;112;0
WireConnection;117;1;119;0
WireConnection;45;0;36;0
WireConnection;45;1;91;0
WireConnection;34;0;45;0
WireConnection;34;1;117;0
WireConnection;83;0;49;4
WireConnection;35;1;34;0
WireConnection;58;0;35;0
WireConnection;85;0;49;4
WireConnection;82;0;83;0
WireConnection;9;0;49;0
WireConnection;9;2;1;3
WireConnection;92;0;3;0
WireConnection;48;1;58;0
WireConnection;48;2;1;3
WireConnection;52;0;85;0
WireConnection;77;0;76;2
WireConnection;81;0;49;4
WireConnection;84;0;49;4
WireConnection;57;0;9;0
WireConnection;57;1;49;0
WireConnection;57;2;82;0
WireConnection;4;0;3;0
WireConnection;4;1;92;0
WireConnection;4;2;1;1
WireConnection;74;0;36;0
WireConnection;115;0;113;0
WireConnection;115;1;114;0
WireConnection;115;2;113;2
WireConnection;66;0;1;3
WireConnection;86;0;49;4
WireConnection;6;0;4;0
WireConnection;6;1;7;0
WireConnection;59;0;74;0
WireConnection;59;1;60;0
WireConnection;59;2;65;0
WireConnection;51;0;48;0
WireConnection;51;1;52;0
WireConnection;67;0;57;0
WireConnection;70;0;77;0
WireConnection;70;1;47;0
WireConnection;70;2;84;0
WireConnection;71;0;76;3
WireConnection;71;1;46;0
WireConnection;71;2;81;0
WireConnection;113;0;112;0
WireConnection;114;0;113;1
WireConnection;65;0;63;0
WireConnection;63;0;86;0
WireConnection;63;1;66;0
WireConnection;0;0;67;0
WireConnection;0;2;51;0
WireConnection;0;3;71;0
WireConnection;0;4;70;0
WireConnection;0;11;6;0
ASEEND*/
//CHKSM=914F51653A9A869ED75CB611A178144B0B49685F