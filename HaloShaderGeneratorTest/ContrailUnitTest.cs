﻿using HaloShaderGenerator.DirectX;
using HaloShaderGenerator.Globals;
using HaloShaderGenerator.Contrail;
using System.Collections.Generic;

namespace HaloShaderGenerator
{
    public class ContrailUnitTest : GenericUnitTest
    {
        public ContrailUnitTest(string referencePath) : base(referencePath, new ContrailGenerator(), "contrail") { }

        public override string GeneratePixelShader(ShaderStage stage, List<int> shaderOptions)
        {
            var albedo = (Albedo)shaderOptions[0];
            var blend_mode = (Blend_Mode)shaderOptions[1];
            var black_point = (Black_Point)shaderOptions[2];
            var fog = (Fog)shaderOptions[3];

            var gen = new ContrailGenerator(albedo, blend_mode, black_point, fog);
            var bytecode = gen.GeneratePixelShader(stage).Bytecode;
            return D3DCompiler.Disassemble(bytecode);
        }

        public override string GenerateSharedPixelShader(ShaderStage stage, int methodIndex, int optionIndex)
        {
            var gen = new ContrailGenerator();
            var bytecode = gen.GenerateSharedPixelShader(stage, methodIndex, optionIndex).Bytecode;
            return D3DCompiler.Disassemble(bytecode);
        }

        public override string GenerateVertexShader(VertexType vertex, ShaderStage stage)
        {
            var gen = new ContrailGenerator();
            var bytecode = gen.GenerateVertexShader(vertex, stage).Bytecode;
            return D3DCompiler.Disassemble(bytecode);
        }

        public override string GenerateSharedVertexShader(VertexType vertex, ShaderStage stage)
        {
            var gen = new ContrailGenerator();
            var bytecode = gen.GenerateSharedVertexShader(vertex, stage).Bytecode;
            return D3DCompiler.Disassemble(bytecode);
        }

        public override string GenerateExplicitPixelShader(ExplicitShader explicitShader, ShaderStage stage)
        {
            throw new System.NotImplementedException();
        }

        public override string GenerateExplicitVertexShader(ExplicitShader explicitShader, ShaderStage stage, VertexType vertexType)
        {
            throw new System.NotImplementedException();
        }

        public override string GenerateChudPixelShader(ChudShader chudShader, ShaderStage entry)
        {
            throw new System.NotImplementedException();
        }

        public override string GenerateChudVertexShader(ChudShader chudShader, ShaderStage entry, VertexType vertexType)
        {
            throw new System.NotImplementedException();
        }
    }
}
