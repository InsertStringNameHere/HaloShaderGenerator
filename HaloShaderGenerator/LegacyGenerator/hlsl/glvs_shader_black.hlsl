﻿#include "registers\vertex_shader.hlsli"
#include "helpers\input_output.hlsli"
#include "helpers\transform_math.hlsli"
#include "helpers\math.hlsli"
#include "helpers\atmosphere.hlsli"
#include "vertices\vertices.hlsli"

VS_OUTPUT_BLACK_ALBEDO entry_albedo(input_vertex_format input)
{
	VS_OUTPUT_BLACK_ALBEDO output;
	float4 world_position;
	float3 normal;
	float3 tangent;
	float3 binormal;
	float2 texcoord;
	float3 sky_radiance;
	float3 extinction_factor;
	
	calc_vertex_transform(input, world_position, output.position, normal, tangent, binormal, texcoord);
    calculate_z_squish(output.position);
    calculate_atmosphere_radiance_new(Camera_Position, world_position.xyz, extinction_factor, sky_radiance);
    output.scattering = sky_radiance;
	return output;
}