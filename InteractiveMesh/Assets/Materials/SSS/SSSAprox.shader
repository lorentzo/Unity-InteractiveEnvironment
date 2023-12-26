Shader "Custom/SSSAprox"
{
    // Material properties visible in inspector.
    Properties
    { 
        // Object surface material.
        cSurfaceColor("Surface Color", Color) = (0.9019608, 0.6201963, 0.2705882, 1.0)
        // SSS Light.
        vLightPosition("SSS Light Position", Vector) = (0, 0, 0)
        cLightDiffuse("SSS Light Diffuse", Color) = (0.9114898, 0.8529226, 0.09899997)
        fLTScale("SSS Light Scale Factor", Float) = 1.5
        // Object SSS material.
        cDiffAlbedo("SSS Diffuse Albedo", Color) = (0.9034261, 0.9353062, 0.9325579)
        fLTAmbient("SSS Ambient Factor", Float) = 0.1
        fLTThickness("SSS Thickness Factor", Float) = 0.7
        iLTPower("SSS Power Factor", Int) = 1
        fLTDistortion("SSS Distortion Factor", Float) = 0.3
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
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                float3 positionWS   : TEXCOORD1;
                float4 positionOS   : TEXCOORD2;
                float4 positionHCS  : POSITION;
                half3 normal        : NORMAL;
            };

            // To make the Unity shader SRP Batcher compatible, declare all
            // properties related to a Material in a a single CBUFFER block with
            // the name UnityPerMaterial.
            // The following declaration enables using the variables in the fragment shader.
            CBUFFER_START(UnityPerMaterial)
                // Light.
                half3 vLightPosition;
                half3 cLightDiffuse;
                half fLTScale;
                // Object Material.
                half4 cSurfaceColor;
                half3 cDiffAlbedo;
                half fLTAmbient;
                half fLTThickness;
                int iLTPower;
                half fLTDistortion;
            CBUFFER_END

            // The vertex shader definition with properties defined in the Varyings
            // structure. The type of the vert function must match the type (struct)
            // that it returns.
            Varyings vert(Attributes IN)
            {
                // Declaring the output object (OUT) with the Varyings struct.
                Varyings OUT;
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
                // Params.
                //half3 cLightDiffuse = half3(0.93f, 0.94f, 0.9f); // light
                //half fLTScale = 0.2; // light
                //half3 cDiffAlbedo = half3(0.23f, 0.34f, 0.8f); // object material
                //half fLTAmbient = 0.7; // object material
                //half fLTThickness = 0.2; // object material
                //int iLTPower = 2; // object material
                //half fLTDistortion = 0.3; // object material

                // Variants.
                half3 vNormal = IN.normal;
                // For this implementation, assume that the light is inside the object.
                // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
                half3 ObjectWorldPosition = unity_ObjectToWorld._m30_m31_m32; // half3(0.0f, 0.0f, 0.0f); // https://discussions.unity.com/t/shader-get-object-position-or-distinct-value-per-object/31873/2
                half3 vEye = normalize(_WorldSpaceCameraPos - IN.positionWS.xyz);
                half3 vLight = normalize(vLightPosition - IN.positionWS.xyz);

                // SSS approx.
                half4 color = cSurfaceColor;
                half3 vLTLight = vLight + vNormal * fLTDistortion;
                half fLTDot = pow(saturate(dot(vEye, -vLTLight)), iLTPower) * fLTScale;
                half fLightAttenuation = dot(vNormal, vLight) + dot(vEye, -vLight);
                half fLT = fLightAttenuation * (fLTDot + fLTAmbient) * fLTThickness;
                color.rgb += cDiffAlbedo * cLightDiffuse * fLT;
                return color;                
            }
            ENDHLSL
        }
    }
}
