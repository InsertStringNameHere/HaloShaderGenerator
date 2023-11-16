﻿#ifndef _DIFFUSE_ONLY_LIGHTING_HLSLI
#define _DIFFUSE_ONLY_LIGHTING_HLSLI

#include "..\material_models\lambert.hlsli"
#include "..\helpers\input_output.hlsli"
#include "..\helpers\sh.hlsli"
#include "..\methods\environment_mapping.hlsli"
#include "..\methods\self_illumination.hlsli"

void calc_dynamic_lighting_diffuse_only_ps(SHADER_DYNAMIC_LIGHT_COMMON common_data, out float3 color)
{
	float l_dot_n = dot(common_data.light_direction, common_data.surface_normal);
	color = common_data.light_intensity * l_dot_n * common_data.albedo.rgb; // lambertian diffuse
}


float3 calc_lighting_diffuse_only_ps(SHADER_COMMON common_data, out float4 unknown_output)
{
	float3 diffuse;
	if (!common_data.no_dynamic_lights)
	{
		float3 diffuse_accumulation = 0;
		float3 specular_accumulation = 0;
		
		calc_material_lambert_diffuse_ps(common_data.surface_normal, common_data.world_position, 0, 0, diffuse_accumulation, specular_accumulation);
		
		diffuse = common_data.diffuse_reflectance * common_data.precomputed_radiance_transfer.x + diffuse_accumulation;
	}
	else
		diffuse = common_data.diffuse_reflectance * common_data.precomputed_radiance_transfer.x;
	
	diffuse *= common_data.albedo.rgb;
	
#if shaderstage != k_shaderstage_static_per_vertex_color
	
	ENVIRONMENT_MAPPING_COMMON env_mapping_common_data;
	
	env_mapping_common_data.reflect_dir = common_data.reflect_dir;
	env_mapping_common_data.view_dir = common_data.view_dir;
	env_mapping_common_data.env_area_specular = get_environment_contribution(common_data.sh_0);
	env_mapping_common_data.specular_coefficient = 1.0;
	env_mapping_common_data.area_specular = 0;
	env_mapping_common_data.specular_exponent = 0.0;
	envmap_type(env_mapping_common_data, diffuse, unknown_output);
	
#else
	unknown_output = 0.0f;
#endif
	
    float3 n_view;
    n_view.x = dot(common_data.n_view_dir, common_data.normal);
    n_view.y = dot(common_data.n_view_dir, common_data.binormal);
    n_view.z = dot(common_data.n_view_dir, common_data.tangent);
	
    float view_tangent = dot(common_data.tangent, common_data.n_view_dir);
    float view_binormal = dot(common_data.binormal, common_data.n_view_dir);

	calc_self_illumination_ps(0, common_data.texcoord.xy, common_data.albedo.rgb, n_view, common_data.view_dir, dot(common_data.n_view_dir, common_data.surface_normal), view_tangent, view_binormal, diffuse.rgb);
	
	return diffuse;
}
#endif