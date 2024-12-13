Shader "Evolis3D/Burechan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange] _IdTex ("#Id Texture", Range(0,3)) = 0
        
        _Color ("Main Color", Color) = (1,1,1,1)
        [Enum(Multiply,0,Add,1,Overlay,2,Screen,3,Resta,4)] _Blend ("Blend mode subset", Int) = 0
        
 
    }
    SubShader
    {
 
        Tags { "RenderType"="Opaque" }
        LOD 100
        Color [_Color]
       
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
   
         
            struct appdata
        {
	        float4 vertex : POSITION;
	        float2 uv : TEXCOORD0;
        };
 
            struct v2f
            {
	            float2 uv : TEXCOORD0;
	            UNITY_FOG_COORDS(1)
	            float4 vertex : SV_POSITION;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            int _IdTex;
            int _Blend;
 
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            //funcion custom para el overlay
            float BlendMode_Overlay(float base, float blend)
			{
				return (base <= 0.5) ? 2*base*blend : 1 - 2*(1-base)*(1-blend);
			}
			
 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = col.rgb;
                
                //id texture
                switch(_IdTex) 
                {
                 case 0:
                	col.rgb = col.rrr;
                 break;
                 
                 case 1:
                	col.rgb = col.ggg;
                 break;
                 
                 case 2:
                	col.rgb = col.bbb;
                 break;
                 
                 case 3:
                	col.rgb = col.aaa;
                 break;
                 
                 default:
                	col.rgb = col.rrr;
                 break;
                }
                
                
                //Blend apply
                switch (_Blend)
                {
                	case 0:  //mul
                		col *= _Color;
                	break;
                	
                	case 1: //add
                		col += _Color;
                	break;
                	
                	case 2: //Overlay
                		col.r = BlendMode_Overlay(col.r,_Color.r);
                		col.g = BlendMode_Overlay(col.g,_Color.g);
                		col.b = BlendMode_Overlay(col.b,_Color.b);
                	break;
                	
                	case 3: //Screen
                			//1−(1−A)×(1−B)
                		col = 1-(1 - col)*(1 - _Color);
                	break;
                	
                	case 4: //resta
                		col = (1 - col) * _Color;
                	break;
                	
                	default: //mul by default
                		col *= _Color;
                	break;
                }
               
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
         
           
            ENDCG
        }
    }
}
