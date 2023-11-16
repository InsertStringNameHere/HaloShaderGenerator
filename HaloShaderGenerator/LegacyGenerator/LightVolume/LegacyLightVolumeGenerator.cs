﻿using System;
using System.Collections.Generic;
using HaloShaderGenerator.DirectX;
using HaloShaderGenerator.LegacyGenerator.Generator;
using HaloShaderGenerator.Globals;

namespace HaloShaderGenerator.LegacyGenerator.LightVolume
{
    public class LegacyLightVolumeGenerator : IShaderGenerator
    {
        private bool TemplateGenerationValid;
        private bool ApplyFixes;

        Albedo albedo;
        Blend_Mode blend_mode;
        Fog fog;

        /// <summary>
        /// Generator insantiation for shared shaders. Does not require method options.
        /// </summary>
        public LegacyLightVolumeGenerator(bool applyFixes = false) { TemplateGenerationValid = false; ApplyFixes = applyFixes; }

        /// <summary>
        /// Generator instantiation for method specific shaders.
        /// </summary>
        public LegacyLightVolumeGenerator(Albedo albedo, Blend_Mode blend_mode, Fog fog, bool applyFixes = false)
        {
            this.albedo = albedo;
            this.blend_mode = blend_mode;
            this.fog = fog;

            ApplyFixes = applyFixes;
            TemplateGenerationValid = true;
        }

        public LegacyLightVolumeGenerator(byte[] options, bool applyFixes = false)
        {
            options = ValidateOptions(options);

            this.albedo = (Albedo)options[0];
            this.blend_mode = (Blend_Mode)options[1];
            this.fog = (Fog)options[2];

            ApplyFixes = applyFixes;
            TemplateGenerationValid = true;
        }

        public LegacyShaderGeneratorResult GeneratePixelShader(ShaderStage entryPoint)
        {
            if (!TemplateGenerationValid)
                throw new System.Exception("Generator initialized with shared shader constructor. Use template constructor.");

            List<D3D.SHADER_MACRO> macros = new List<D3D.SHADER_MACRO>();

            macros.Add(new D3D.SHADER_MACRO { Name = "_DEFINITION_HELPER_HLSLI", Definition = "1" });
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<ShaderStage>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.ShaderType>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.Albedo>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.Blend_Mode>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.Fog>());

            //
            // Convert to shared enum
            //

            var sAlbedo = Enum.Parse(typeof(Shared.Albedo), albedo.ToString());
            var sBlendMode = Enum.Parse(typeof(Shared.Blend_Mode), blend_mode.ToString());
            var sFog = Enum.Parse(typeof(Shared.Fog), fog.ToString());

            //
            // The following code properly names the macros (like in rmdf)
            //

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("calc_albedo_ps", sAlbedo, "calc_albedo_", "_ps"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("blend_type", sBlendMode, "blend_type_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("light_volume_fog", sFog, "fog_"));

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("shaderstage", entryPoint, "k_shaderstage_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("shadertype", Shared.ShaderType.Light_Volume, "k_shadertype_"));

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("albedo_arg", sAlbedo, "k_albedo_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("blend_type_arg", sBlendMode, "k_blend_mode_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("fog_arg", sFog, "k_fog_"));

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("APPLY_HLSL_FIXES", ApplyFixes ? 1 : 0));

            byte[] shaderBytecode = LegacyShaderGeneratorBase.GenerateSource($"pixl_light_volume.hlsl", macros, "entry_" + entryPoint.ToString().ToLower(), "ps_3_0");

            return new LegacyShaderGeneratorResult(shaderBytecode);
        }

        public LegacyShaderGeneratorResult GenerateSharedPixelShader(ShaderStage entryPoint, int methodIndex, int optionIndex)
        {
            if (!IsEntryPointSupported(entryPoint) || !IsPixelShaderShared(entryPoint))
                return null;

            List<D3D.SHADER_MACRO> macros = new List<D3D.SHADER_MACRO>();

            macros.Add(new D3D.SHADER_MACRO { Name = "_DEFINITION_HELPER_HLSLI", Definition = "1" });
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<ShaderStage>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<ShaderType>());

            byte[] shaderBytecode = LegacyShaderGeneratorBase.GenerateSource($"glps_light_volume.hlsl", macros, "entry_" + entryPoint.ToString().ToLower(), "ps_3_0");

            return new LegacyShaderGeneratorResult(shaderBytecode);
        }

        public LegacyShaderGeneratorResult GenerateSharedVertexShader(VertexType vertexType, ShaderStage entryPoint)
        {
            if (!IsVertexFormatSupported(vertexType) || !IsEntryPointSupported(entryPoint))
                return null;

            List<D3D.SHADER_MACRO> macros = new List<D3D.SHADER_MACRO>();

            macros.Add(new D3D.SHADER_MACRO { Name = "_DEFINITION_HELPER_HLSLI", Definition = "1" });
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("calc_vertex_transform", vertexType, "calc_vertex_transform_", ""));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("transform_unknown_vector", vertexType, "transform_unknown_vector_", ""));
            macros.Add(LegacyShaderGeneratorBase.CreateVertexMacro("input_vertex_format", vertexType));

            byte[] shaderBytecode = LegacyShaderGeneratorBase.GenerateSource(@"glvs_light_volume.hlsl", macros, $"entry_{entryPoint.ToString().ToLower()}", "vs_3_0");

            return new LegacyShaderGeneratorResult(shaderBytecode);
        }

        public LegacyShaderGeneratorResult GenerateVertexShader(VertexType vertexType, ShaderStage entryPoint)
        {
            if (!TemplateGenerationValid)
                throw new System.Exception("Generator initialized with shared shader constructor. Use template constructor.");
            return null;
        }

        public int GetMethodCount()
        {
            return System.Enum.GetValues(typeof(LightVolumeMethods)).Length;
        }

        public int GetMethodOptionCount(int methodIndex)
        {
            switch ((LightVolumeMethods)methodIndex)
            {
                case LightVolumeMethods.Albedo:
                    return Enum.GetValues(typeof(Albedo)).Length;
                case LightVolumeMethods.Blend_Mode:
                    return Enum.GetValues(typeof(Blend_Mode)).Length;
                case LightVolumeMethods.Fog:
                    return Enum.GetValues(typeof(Fog)).Length;
            }

            return -1;
        }

        public int GetMethodOptionValue(int methodIndex)
        {
            switch ((LightVolumeMethods)methodIndex)
            {
                case LightVolumeMethods.Albedo:
                    return (int)albedo;
                case LightVolumeMethods.Blend_Mode:
                    return (int)blend_mode;
                case LightVolumeMethods.Fog:
                    return (int)fog;
            }
            return -1;
        }

        public bool IsEntryPointSupported(ShaderStage entryPoint)
        {
            return entryPoint == ShaderStage.Default;
        }

        public bool IsMethodSharedInEntryPoint(ShaderStage entryPoint, int method_index)
        {
            return false;
        }

        public bool IsSharedPixelShaderWithoutMethod(ShaderStage entryPoint)
        {
            return false;
        }

        public bool IsPixelShaderShared(ShaderStage entryPoint)
        {
            return false;
        }

        public bool IsVertexFormatSupported(VertexType vertexType)
        {
            return vertexType == VertexType.LightVolume;
        }

        public bool IsVertexShaderShared(ShaderStage entryPoint)
        {
            return true;
        }

        public ShaderParameters GetPixelShaderParameters()
        {
            if (!TemplateGenerationValid)
                return null;
            var result = new ShaderParameters();

            switch (albedo)
            {
                case Albedo.Diffuse_Only:
                    result.AddSamplerWithoutXFormParameter("base_map");
                    break;
                case Albedo.Circular:
                    result.AddFloatParameter("center_offset");
                    result.AddFloatParameter("falloff");
                    break;
            }

            return result;
        }

        public ShaderParameters GetVertexShaderParameters()
        {
            if (!TemplateGenerationValid)
                return null;

            var result = new ShaderParameters();

            result.AddPrefixedFloat4VertexParameter("blend_mode", "category_");
            result.AddPrefixedFloat4VertexParameter("fog", "category_");

            return result;
        }

        public ShaderParameters GetGlobalParameters()
        {
            return new ShaderParameters();
        }

        public bool IsSharedPixelShaderUsingMethods(ShaderStage entryPoint)
        {
            throw new NotImplementedException();
        }

        public ShaderParameters GetParametersInOption(string methodName, int option, out string rmopName, out string optionName)
        {
            ShaderParameters result = new ShaderParameters();
            rmopName = null;
            optionName = null;

            if (methodName == "albedo")
            {
                optionName = ((Albedo)option).ToString();

                switch ((Albedo)option)
                {
                    case Albedo.Diffuse_Only:
                        result.AddSamplerWithoutXFormParameter("base_map");
                        rmopName = @"shaders\light_volume_options\albedo_diffuse_only";
                        break;
                    case Albedo.Circular:
                        result.AddFloatParameter("center_offset");
                        result.AddFloatParameter("falloff");
                        rmopName = @"shaders\light_volume_options\albedo_circular";
                        break;
                }
            }
            if (methodName == "blend_mode")
            {
                optionName = ((Blend_Mode)option).ToString();
            }
            if (methodName == "fog")
            {
                optionName = ((Fog)option).ToString();
            }

            return result;
        }

        public Array GetMethodNames()
        {
            return Enum.GetValues(typeof(LightVolumeMethods));
        }

        public Array GetMethodOptionNames(int methodIndex)
        {
            switch ((LightVolumeMethods)methodIndex)
            {
                case LightVolumeMethods.Albedo:
                    return Enum.GetValues(typeof(Albedo));
                case LightVolumeMethods.Blend_Mode:
                    return Enum.GetValues(typeof(Blend_Mode));
                case LightVolumeMethods.Fog:
                    return Enum.GetValues(typeof(Fog));
            }

            return null;
        }

        public byte[] ValidateOptions(byte[] options)
        {
            List<byte> optionList = new List<byte>(options);

            while (optionList.Count < GetMethodCount())
                optionList.Add(0);

            return optionList.ToArray();
        }
    }
}
