﻿#include "registers\vertex_shader.hlsli"
#include "helpers\input_output_terrain.hlsli"
#include "helpers\transform_math.hlsli"
#include "helpers\math.hlsli"
#include "helpers\atmosphere.hlsli"
#include "helpers\prt.hlsli"
#include "vertices\vertices.hlsli"
#include "helpers\sfx_distortion.hlsli"
#include "helpers\vertex_shader_helper.hlsli"

// TODO

VS_OUTPUT_ALBEDO_TERRAIN entry_albedo(input_vertex_format input)
{
	VS_OUTPUT_ALBEDO_TERRAIN output;
	float4 world_position;
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord.xy);
	calculate_z_squish(output.position);
	output.normal.w = output.position.w;
	output.texcoord.zw = 1;
	return output;
}

VS_OUTPUT_STATIC_PRT_TERRAIN entry_static_prt_ambient(input_vertex_format input, AMBIENT_PRT input_prt)
{
    VS_OUTPUT_STATIC_PRT_TERRAIN output;
	float4 world_position;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord);
    //output.normal.w = output.position.w;
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
    output.prt_radiance_vector = calculate_ambient_radiance_vector(input_prt.coefficient, output.normal.xyz);
	calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor.rgb, output.sky_radiance.rgb);
	
	return output;
}

VS_OUTPUT_STATIC_PRT_TERRAIN entry_static_prt_linear(input_vertex_format input, LINEAR_PRT input_prt)
{
    VS_OUTPUT_STATIC_PRT_TERRAIN output;
	float4 world_position;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord);
    //output.normal.w = output.position.w;
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
    output.prt_radiance_vector = calculate_linear_radiance_vector(input, input_prt.coefficients, output.normal.xyz);
	calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor.rgb, output.sky_radiance.rgb);
	
	return output;
}

VS_OUTPUT_STATIC_PRT_TERRAIN entry_static_prt_quadratic(input_vertex_format input, QUADRATIC_PRT input_prt)
{
    VS_OUTPUT_STATIC_PRT_TERRAIN output;
	float4 world_position;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord);
    //output.normal.w = output.position.w;
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
	
	calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor.rgb, output.sky_radiance.rgb);
    output.prt_radiance_vector = calculate_quadratic_radiance_vector(input, input_prt, output.normal.xyz);
	return output;
}

VS_OUTPUT_STATIC_SH_TERRAIN entry_static_sh(input_vertex_format input)
{
    VS_OUTPUT_STATIC_SH_TERRAIN output;
	float4 world_position;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord.xy);
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
	calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor.rgb, output.sky_radiance.rgb);
	
	return output;
}

VS_OUTPUT_PER_PIXEL_TERRAIN entry_static_per_pixel(input_vertex_format input, STATIC_PER_PIXEL_DATA per_pixel)
{
    VS_OUTPUT_PER_PIXEL_TERRAIN output;
	float4 world_position;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord.xy);
    //output.normal.w = output.position.w;
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
	calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor.rgb, output.sky_radiance.rgb);
	output.lightmap_texcoord = per_pixel.lightmap_texcoord;
	return output;
}

VS_OUTPUT_PER_VERTEX_TERRAIN entry_static_per_vertex(input_vertex_format input, STATIC_PER_VERTEX_DATA per_vertex)
{
    VS_OUTPUT_PER_VERTEX_TERRAIN output;
	float4 world_position;
	float3 sky_radiance;
	
	// pack 5 rgb colors into 4  values
    output.lightmap_coefficients.color4 = rgbe_to_rgb(per_vertex.color_1);
	
	float3 rgb_2 = rgbe_to_rgb(per_vertex.color_2);
	output.lightmap_coefficients.color1.r = rgb_2.r;
	output.lightmap_coefficients.color2.r = rgb_2.g;
    output.lightmap_coefficients.color3.r = rgb_2.b;
	float3 rgb_3 = rgbe_to_rgb(per_vertex.color_3);
	output.lightmap_coefficients.color1.g = rgb_3.r;
	output.lightmap_coefficients.color2.g = rgb_3.g;
    output.lightmap_coefficients.color3.g = rgb_3.b;
	float3 rgb_4 = rgbe_to_rgb(per_vertex.color_4);
	output.lightmap_coefficients.color1.b = rgb_4.r;
	output.lightmap_coefficients.color2.b = rgb_4.g;
    output.lightmap_coefficients.color3.b = rgb_4.b;
	float3 rgb_5 = rgbe_to_rgb(per_vertex.color_5);
	output.lightmap_coefficients.color1.a = rgb_5.r;
	output.lightmap_coefficients.color2.a = rgb_5.g;
	output.lightmap_coefficients.color3.a = rgb_5.b;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord.xy);
    //output.normal.w = output.position.w;
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
	calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor.rgb, sky_radiance);
	// pack sky_radiance and extinction factor into the texcoord and radiance outputs
	output.extinction_factor.w = sky_radiance.z;
	output.texcoord.zw = sky_radiance.xy;
	
	return output;
}

VS_OUTPUT_SFX_DISTORT entry_sfx_distort(input_vertex_format input)
{
	VS_OUTPUT_SFX_DISTORT output;
	calc_distortion(input, output);
	return output;

}

VS_OUTPUT_DYNAMIC_LIGHT_TERRAIN entry_dynamic_light(input_vertex_format input)
{
    VS_OUTPUT_DYNAMIC_LIGHT_TERRAIN output;
	float4 world_position;
	
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord);
    //output.normal.w = output.position.w;
	
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	
	output.camera_dir = Camera_Position - world_position.xyz;
    output.shadowmap_texcoord = mul(world_position, shadow_projection);
	
    calculate_atmosphere_radiance(world_position, output.camera_dir, output.extinction_factor, output.sky_radiance);
	
	return output;

}

VS_OUTPUT_DYNAMIC_LIGHT_TERRAIN entry_dynamic_light_cinematic(input_vertex_format input)
{
	return entry_dynamic_light(input);
}

VS_OUTPUT_LIGHTMAP_DEBUG_MODE_TERRAIN entry_lightmap_debug_mode(input_vertex_format input, float2 lightmap_texcoord : TEXCOORD1)
{
    VS_OUTPUT_LIGHTMAP_DEBUG_MODE_TERRAIN output;
	float4 world_position;
	output.camera_dir = Camera_Position - input.position.xyz;
	calc_vertex_transform(input, world_position, output.position, output.normal.xyz, output.tangent, output.binormal, output.texcoord);
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	output.lightmap_texcoord = lightmap_texcoord;
	
	return output;
}

VS_OUTPUT_SHADOW_GENERATE entry_shadow_generate(input_vertex_format input)
{
	VS_OUTPUT_SHADOW_GENERATE output;
	float4 world_position;
	float3 normal, tangent, binormal, camera_dir;

	calc_vertex_transform(input, world_position, output.position, normal.xyz, tangent, binormal, output.texcoord);
	if (vertextype == k_vertextype_skinned)
		calculate_z_squish_2(output.position);
	else
		calculate_z_squish(output.position);
	output.depth = output.position.w;

	return output;
}

