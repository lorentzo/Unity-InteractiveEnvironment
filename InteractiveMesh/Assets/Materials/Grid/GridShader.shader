Shader "Custom/GridShader"
{
    // Material properties visible in inspector.
    Properties
    { 
        // Object surface material.
        cSurfaceColor1("Surface Color 1", Color) = (0.9019608, 0.6201963, 0.2705882, 1.0)
        cSurfaceColor2("Surface Color 2", Color) = (0.9019608, 0.6201963, 0.2705882, 1.0)
        fGridWidthU("Grid Width U", Range(0,1000)) = 100
        fGridWidthV("Grid Width V", Range(0,1000)) = 20
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            // This line defines the name of the vertex shader.
            #pragma vertex vert
            // This line defines the name of the fragment shader.
            #pragma fragment frag

            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // The structure definition defines which variables it contains.
            // This example uses the Attributes structure as an input structure in
            // the vertex shader.
            struct Attributes
            {
                // The positionOS variable contains the vertex positions in object
                // space.
                float4 positionOS   : POSITION;
                half3 normal        : NORMAL;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                float2 uv           : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
                float4 positionOS   : TEXCOORD2;
                float4 positionHCS  : SV_POSITION;
                half3 normal        : NORMAL;
            };

            // To make the Unity shader SRP Batcher compatible, declare all
            // properties related to a Material in a a single CBUFFER block with
            // the name UnityPerMaterial.
            // The following declaration enables using the variables in the fragment shader.
            CBUFFER_START(UnityPerMaterial)
                // Object Material.
                half4 cSurfaceColor1;
                half4 cSurfaceColor2;
                half fGridWidthU;
                half fGridWidthV;
            CBUFFER_END

            // The vertex shader definition with properties defined in the Varyings
            // structure. The type of the vert function must match the type (struct)
            // that it returns.
            Varyings vert(Attributes IN)
            {
                // Declaring the output object (OUT) with the Varyings struct.
                Varyings OUT;
                // UV.
                OUT.uv = IN.uv;
                // World space. https://forum.unity.com/threads/shader-world-position-questions.523232/
                // https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                // Object space.
                OUT.positionOS = IN.positionOS;
                // Homogenous clip space.
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // Use the TransformObjectToWorldNormal function to transform the
                // normals from object to world space. This function is from the
                // SpaceTransforms.hlsl file, which is referenced in Core.hlsl.
                OUT.normal = TransformObjectToWorldNormal(IN.normal);
                // Returning the output.
                return OUT;
            }

            // The fragment shader definition.
            half4 frag(Varyings IN) : SV_Target
            {   
                float chessboard_x = floor(IN.positionWS.x * fGridWidthU); // create stripes
                chessboard_x = frac(chessboard_x * 0.5); // results in 0 for even and 0.5 for odd numbers
                chessboard_x *= 2; // make odd values white instead of gray

                float chessboard_y = floor(IN.positionWS.y * fGridWidthU); // create stripes
                chessboard_y = frac(chessboard_y * 0.5); // results in 0 for even and 0.5 for odd numbers
                chessboard_y *= 2; // make odd values white instead of gray

                float chessboard_z = floor(IN.positionWS.z * fGridWidthU); // create stripes
                chessboard_z = frac(chessboard_z * 0.5); // results in 0 for even and 0.5 for odd numbers
                chessboard_z *= 2; // make odd values white instead of gray

                float chessboard_u = floor(IN.uv.x * fGridWidthU); // create stripes
                chessboard_u = frac(chessboard_u * 0.5); // results in 0 for even and 0.5 for odd numbers
                chessboard_u *= 2; // make odd values white instead of gray

                float chessboard_v = floor(IN.uv.y * fGridWidthV); // create stripes
                chessboard_v = frac(chessboard_v * 0.5); // results in 0 for even and 0.5 for odd numbers
                chessboard_v *= 2; // make odd values white instead of gray

                //half4 color = cSurfaceColor1 * chessboard_u;
                half4 color = lerp(cSurfaceColor2, cSurfaceColor1, min(chessboard_v, chessboard_u));
                

                return color;                
            }
            ENDHLSL
        }
    }
}
