Shader "Evolis3D/Burechan-Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange] _IdTex ("#Id Texture", Range(0,3)) = 0
        
        [Header(Gradient)]
        [Space]
        _Color1 ("Gradient Color #1", Color) = (1,1,1,1)
        _Color2 ("Gradient Color #2", Color) = (0,0,0,1)
        
        [Enum(Left_Right,0,Top_Bottom,1,Right_Left,2,Bottom_Top,3)] 
        _RampDir("Gradient Direction", Float) = 1
        [Space(20)]
        [Enum(Multiply,0,Add,1,Overlay,2,Screen,3,Resta,4)] _Blend ("Blend mode subset", Int) = 0
        
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Color [_Color1]

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color1;
        fixed4 _Color2;
        half _RampDir;
        half _InvertDir;
        int _IdTex;
        int _Blend;

        struct Input
        {
            float2 uv_MainTex;
        };

		//funcion custom para el overlay
        float BlendMode_Overlay(float base, float blend)
		{
			return (base <= 0.5) ? 2*base*blend : 1 - 2*(1-base)*(1-blend);
		}

        
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
        	fixed4 grad = 0;
        	
        	//id texture
        	switch(_RampDir)
        	{
        		case 0:
        			grad = lerp(_Color1, _Color2, IN.uv_MainTex.x);
        		break;
        		
        		case 1:
        			grad = lerp(_Color2, _Color1, IN.uv_MainTex.y);
        		break;
        		
        		case 2:
        			grad = lerp(_Color2, _Color1, IN.uv_MainTex.x);
        		break;
        		
        		case 3:
        			grad = lerp(_Color1, _Color2, IN.uv_MainTex.y);
        		break;
        	}
        	
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            c.rgb = c.rgb;
            
            switch(_IdTex) 
            {
             case 0:
            	c.rgb = c.rrr;
             break;
             
             case 1:
            	c.rgb = c.ggg;
             break;
             
             case 2:
            	c.rgb = c.bbb;
             break;
             
             case 3:
            	c.rgb = c.aaa;
             break;
             
             default:
            	c.rgb = c.rrr;
             break;
            }
            
            //Blend apply
            switch (_Blend)
            {
            	case 0:  //mul
            		c *= grad;
            	break;
            	
            	case 1: //add
            		c += grad;
            	break;
            	
            	case 2: //Overlay
            		c.r = BlendMode_Overlay(c.r, grad.r);
            		c.g = BlendMode_Overlay(c.g, grad.g);
            		c.b = BlendMode_Overlay(c.b, grad.b);
            	break;
            	
            	case 3: //Screen
            			//1−(1−A)×(1−B)
            		c = 1-(1 - c)*(1 - grad);
            	break;
            	
            	case 4: //resta
            		c = (1 - c) * grad;
            	break;
            	
            	default: //mul by default
            		c *= grad;
            	break;
            }
            
            // apply fog
            UNITY_APPLY_FOG(i.fogCoord, c);
            o.Albedo = c;
            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
