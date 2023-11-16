﻿using System;
using System.Collections.Generic;
using HaloShaderGenerator.DirectX;
using HaloShaderGenerator.LegacyGenerator.Generator;
using HaloShaderGenerator.Globals;

namespace HaloShaderGenerator.LegacyGenerator.Screen
{
    public class LegacyScreenGenerator : IShaderGenerator
    {
        private bool TemplateGenerationValid;
        private bool ApplyFixes;

        Warp warp;
        Base _base;
        Overlay_A overlay_a;
        Overlay_B overlay_b;
        Blend_Mode blend_mode;

        /// <summary>
        /// Generator insantiation for shared shaders. Does not require method options.
        /// </summary>
        public LegacyScreenGenerator(bool applyFixes = false) { TemplateGenerationValid = false; ApplyFixes = applyFixes; }

        /// <summary>
        /// Generator instantiation for method specific shaders.
        /// </summary>
        public LegacyScreenGenerator(Warp warp, Base _base, Overlay_A overlay_a, Overlay_B overlay_b, Blend_Mode blend_mode, bool applyFixes = false)
        {
            this.warp = warp;
            this._base = _base;
            this.overlay_a = overlay_a;
            this.overlay_b = overlay_b;
            this.blend_mode = blend_mode;

            ApplyFixes = applyFixes;
            TemplateGenerationValid = true;
        }

        public LegacyScreenGenerator(byte[] options, bool applyFixes = false)
        {
            options = ValidateOptions(options);

            this.warp = (Warp)options[0];
            this._base = (Base)options[1];
            this.overlay_a = (Overlay_A)options[2];
            this.overlay_b = (Overlay_B)options[3];
            this.blend_mode = (Blend_Mode)options[4];

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
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Warp>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Base>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Overlay_A>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Overlay_B>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.Blend_Mode>());

            //
            // Convert to shared enum
            //

            var sBlendMode = Enum.Parse(typeof(Shared.Blend_Mode), blend_mode.ToString());

            //
            // The following code properly names the macros (like in rmdf)
            //

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("calc_screen_warp", warp, "calc_screen_warp_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("calc_base", _base, "calc_base_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("overlay_type_a", overlay_a, "overlay_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("overlay_type_b", overlay_b, "overlay_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("blend_type", sBlendMode, "blend_type_")); 

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("shaderstage", entryPoint, "k_shaderstage_"));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("shadertype", Shared.ShaderType.Screen, "k_shadertype_"));

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("blend_type_arg", sBlendMode, "k_blend_mode_"));

            //macros.Add(LegacyShaderGeneratorBase.CreateMacro("APPLY_HLSL_FIXES", ApplyFixes ? 1 : 0));

            byte[] shaderBytecode = LegacyShaderGeneratorBase.GenerateSource($"pixl_screen.hlsl", macros, "entry_" + entryPoint.ToString().ToLower(), "ps_3_0");

            return new LegacyShaderGeneratorResult(shaderBytecode);
        }

        public LegacyShaderGeneratorResult GenerateSharedPixelShader(ShaderStage entryPoint, int methodIndex, int optionIndex)
        {
            if (!IsEntryPointSupported(entryPoint) || !IsPixelShaderShared(entryPoint))
                return null;

            List<D3D.SHADER_MACRO> macros = new List<D3D.SHADER_MACRO>();

            macros.Add(new D3D.SHADER_MACRO { Name = "_DEFINITION_HELPER_HLSLI", Definition = "1" });
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<ShaderStage>());
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.ShaderType>());

            byte[] shaderBytecode = LegacyShaderGeneratorBase.GenerateSource($"glps_screen.hlsl", macros, "entry_" + entryPoint.ToString().ToLower(), "ps_3_0");

            return new LegacyShaderGeneratorResult(shaderBytecode);
        }

        public LegacyShaderGeneratorResult GenerateSharedVertexShader(VertexType vertexType, ShaderStage entryPoint)
        {
            if (!IsVertexFormatSupported(vertexType) || !IsEntryPointSupported(entryPoint))
                return null;

            List<D3D.SHADER_MACRO> macros = new List<D3D.SHADER_MACRO>();
            macros.AddRange(LegacyShaderGeneratorBase.CreateMethodEnumDefinitions<Shared.ShaderType>());

            macros.Add(new D3D.SHADER_MACRO { Name = "_DEFINITION_HELPER_HLSLI", Definition = "1" });
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("calc_vertex_transform", vertexType, "calc_vertex_transform_", ""));
            macros.Add(LegacyShaderGeneratorBase.CreateMacro("transform_unknown_vector", vertexType, "transform_unknown_vector_", ""));
            macros.Add(LegacyShaderGeneratorBase.CreateVertexMacro("input_vertex_format", vertexType));

            macros.Add(LegacyShaderGeneratorBase.CreateMacro("shadertype", Shared.ShaderType.Screen, "shadertype_"));

            byte[] shaderBytecode = LegacyShaderGeneratorBase.GenerateSource(@"glvs_screen.hlsl", macros, $"entry_{entryPoint.ToString().ToLower()}", "vs_3_0");

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
            return System.Enum.GetValues(typeof(ScreenMethods)).Length;
        }

        public int GetMethodOptionCount(int methodIndex)
        {
            switch ((ScreenMethods)methodIndex)
            {
                case ScreenMethods.Warp:
                    return Enum.GetValues(typeof(Warp)).Length;
                case ScreenMethods.Base:
                    return Enum.GetValues(typeof(Base)).Length;
                case ScreenMethods.Overlay_A:
                    return Enum.GetValues(typeof(Overlay_A)).Length;
                case ScreenMethods.Overlay_B:
                    return Enum.GetValues(typeof(Overlay_B)).Length;
                case ScreenMethods.Blend_Mode:
                    return Enum.GetValues(typeof(Blend_Mode)).Length;
            }

            return -1;
        }

        public int GetMethodOptionValue(int methodIndex)
        {
            switch ((ScreenMethods)methodIndex)
            {
                case ScreenMethods.Warp:
                    return (int)warp;
                case ScreenMethods.Base:
                    return (int)_base;
                case ScreenMethods.Overlay_A:
                    return (int)overlay_a;
                case ScreenMethods.Overlay_B:
                    return (int)overlay_b;
                case ScreenMethods.Blend_Mode:
                    return (int)blend_mode;
            }
            return -1;
        }

        public bool IsEntryPointSupported(ShaderStage entryPoint)
        {
            if (entryPoint == ShaderStage.Default)
                return true;
            return false;
        }

        public bool IsMethodSharedInEntryPoint(ShaderStage entryPoint, int method_index)
        {
            return false;
        }

        public bool IsSharedPixelShaderUsingMethods(ShaderStage entryPoint)
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
            return vertexType == VertexType.Screen;
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

            switch (warp)
            {
                case Warp.Pixel_Space:
                case Warp.Screen_Space:
                    result.AddSamplerParameter("warp_map");
                    result.AddFloatParameter("warp_amount");
                    break;
            }
            switch (_base)
            {
                case Base.Single_Screen_Space:
                case Base.Single_Pixel_Space:
                    result.AddSamplerParameter("base_map");
                    break;
            }
            switch (overlay_a)
            {
                case Overlay_A.Tint_Add_Color:
                    result.AddFloat4ColorParameter("tint_color");
                    result.AddFloat4ColorParameter("add_color");
                    break;
                case Overlay_A.Detail_Screen_Space:
                case Overlay_A.Detail_Pixel_Space:
                    result.AddSamplerParameter("detail_map_a");
                    result.AddFloatParameter("detail_fade_a");
                    result.AddFloatParameter("detail_multiplier_a");
                    break;
                case Overlay_A.Detail_Masked_Screen_Space:
                    result.AddSamplerParameter("detail_map_a");
                    result.AddSamplerParameter("detail_mask_a");
                    result.AddFloatParameter("detail_fade_a");
                    result.AddFloatParameter("detail_multiplier_a");
                    break;
            }
            switch (overlay_b)
            {
                case Overlay_B.Tint_Add_Color when overlay_a != Overlay_A.Tint_Add_Color:
                    result.AddFloat4ColorParameter("tint_color");
                    result.AddFloat4ColorParameter("add_color");
                    break;
            }
            switch (blend_mode)
            {
                case Blend_Mode.Opaque:
                    break;
                default:
                    result.AddFloatParameter("fade");
                    break;
            }

            return result;
        }

        public ShaderParameters GetVertexShaderParameters()
        {
            if (!TemplateGenerationValid)
                return null;
            var result = new ShaderParameters();

            return result;
        }

        public ShaderParameters GetGlobalParameters()
        {
            var result = new ShaderParameters();
            return result;
        }

        public ShaderParameters GetParametersInOption(string methodName, int option, out string rmopName, out string optionName)
        {
            ShaderParameters result = new ShaderParameters();
            rmopName = null;
            optionName = null;

            if (methodName == "warp")
            {
                optionName = ((Warp)option).ToString();

                switch ((Warp)option)
                {
                    case Warp.Pixel_Space:
                    case Warp.Screen_Space:
                        result.AddSamplerParameter("warp_map");
                        result.AddFloatParameter("warp_amount");
                        rmopName = @"shaders\screen_options\warp_simple";
                        break;
                }
            }
            if (methodName == "base")
            {
                optionName = ((Base)option).ToString();

                switch ((Base)option)
                {
                    case Base.Single_Screen_Space:
                    case Base.Single_Pixel_Space:
                        result.AddSamplerParameter("base_map");
                        rmopName = @"shaders\screen_options\base_single";
                        break;
                }
            }
            if (methodName == "overlay_a")
            {
                optionName = ((Overlay_A)option).ToString();

                switch ((Overlay_A)option)
                {
                    case Overlay_A.Tint_Add_Color:
                        result.AddFloat4ColorParameter("tint_color");
                        result.AddFloat4ColorParameter("add_color");
                        rmopName = @"shaders\screen_options\overlay_tint_add_color";
                        break;
                    case Overlay_A.Detail_Screen_Space:
                    case Overlay_A.Detail_Pixel_Space:
                        result.AddSamplerParameter("detail_map_a");
                        result.AddFloatParameter("detail_fade_a");
                        result.AddFloatParameter("detail_multiplier_a");
                        rmopName = @"shaders\screen_options\detail_a";
                        break;
                    case Overlay_A.Detail_Masked_Screen_Space:
                        result.AddSamplerParameter("detail_map_a");
                        result.AddSamplerParameter("detail_mask_a");
                        result.AddFloatParameter("detail_fade_a");
                        result.AddFloatParameter("detail_multiplier_a");
                        rmopName = @"shaders\screen_options\detail_mask_a";
                        break;
                }
            }
            if (methodName == "overlay_b")
            {
                optionName = ((Overlay_B)option).ToString();

                switch ((Overlay_B)option)
                {
                    case Overlay_B.Tint_Add_Color:
                        result.AddFloat4ColorParameter("tint_color");
                        result.AddFloat4ColorParameter("add_color");
                        rmopName = @"shaders\screen_options\overlay_tint_add_color";
                        break;
                }
            }
            if (methodName == "blend_mode")
            {
                optionName = ((Blend_Mode)option).ToString();

                switch ((Blend_Mode)option)
                {
                    case Blend_Mode.Opaque:
                        break;
                    default:
                        result.AddFloatParameter("fade");
                        rmopName = @"shaders\screen_options\blend";
                        break;
                }
            }

            return result;
        }

        public Array GetMethodNames()
        {
            return Enum.GetValues(typeof(ScreenMethods));
        }

        public Array GetMethodOptionNames(int methodIndex)
        {
            switch ((ScreenMethods)methodIndex)
            {
                case ScreenMethods.Warp:
                    return Enum.GetValues(typeof(Warp));
                case ScreenMethods.Base:
                    return Enum.GetValues(typeof(Base));
                case ScreenMethods.Overlay_A:
                    return Enum.GetValues(typeof(Overlay_A));
                case ScreenMethods.Overlay_B:
                    return Enum.GetValues(typeof(Overlay_B));
                case ScreenMethods.Blend_Mode:
                    return Enum.GetValues(typeof(Blend_Mode));
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
