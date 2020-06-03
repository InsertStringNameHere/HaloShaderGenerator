﻿#ifndef _SHADER_TEMPLATE_PRT_HLSLI
#define _SHADER_TEMPLATE_PRT_HLSLI



#include "entry_albedo.hlsli"



#include "..\registers\shader.hlsli"
#include "..\helpers\input_output.hlsli"
#include "..\helpers\definition_helper.hlsli"
#include "..\helpers\color_processing.hlsli"

#include "..\methods\specular_mask.hlsli"
#include "..\methods\material_model.hlsli"
#include "..\methods\environment_mapping.hlsli"
#include "..\methods\self_illumination.hlsli"
#include "..\methods\blend_mode.hlsli"
#include "..\methods\misc.hlsli"


PS_OUTPUT_DEFAULT entry_static_sh_prt(
float2 position,
float2 texcoord,
float3 camera_dir,
float3 normal,
float3 tangent,
float3 binormal,
float3 sky_radiance,
float3 extinction_factor,
float prt)
{
	float3 view_dir = normalize(camera_dir);
	float4 albedo;
	float3 modified_normal;
	texcoord = calc_parallax_ps(texcoord, camera_dir, tangent, binormal, normal);
	float alpha = calc_alpha_test_ps(texcoord);
	get_albedo_and_normal(actually_calc_albedo, position.xy, texcoord, camera_dir, tangent.xyz, binormal.xyz, normal.xyz, albedo, modified_normal);
	
	
	modified_normal = normalize(modified_normal);
	float v_dot_n = dot(view_dir, modified_normal);
	float3 reflect_dir = v_dot_n * modified_normal - view_dir;
	reflect_dir = reflect_dir * 2 + view_dir;
	
	float3 world_position = Camera_Position_PS - camera_dir;
	
	float4 sh_0, sh_312[3], sh_457[3], sh_8866[3];
	float3 dominant_light_direction, dominant_light_intensity;
	bool m_no_dynamic_lights = no_dynamic_lights;
	get_current_sh_coefficients_quadratic(sh_0, sh_312, sh_457, sh_8866, dominant_light_direction, dominant_light_intensity);
	float3 diffuse_ref = diffuse_reflectance(modified_normal);
	
	float4 color = 0;

	if (calc_material)
	{
		float3 material_lighting = material_type(albedo.rgb, modified_normal, view_dir, texcoord.xy, camera_dir, world_position, sh_0, sh_312, sh_457, sh_8866, dominant_light_direction, dominant_light_intensity, diffuse_ref, no_dynamic_lights, prt, 0.0);
		color.rgb += material_lighting;
	}
	else
	{
		color.rgb = 1.0;
		if (!calc_atmosphere_no_material)
		{
			sky_radiance = 0.0;
			extinction_factor = 1.0;
		}
	}

	color.rgb *= albedo.rgb;
	float3 env_band_0 = get_environment_contribution(sh_0);
	envmap_type(view_dir, reflect_dir, env_band_0, color.rgb);
	calc_self_illumination_ps(texcoord.xy, albedo.rgb, color.rgb);
	

	color.rgb = color.rgb * extinction_factor;
		
	color.a = blend_type_calculate_alpha_blending(albedo, alpha);
	
	if (blend_type_arg != k_blend_mode_additive)
	{
		color.rgb += sky_radiance.rgb;
	}

	if (blend_type_arg == k_blend_mode_double_multiply)
		color.rgb *= 2;

	color.rgb = expose_color(color.rgb);
	
	if (blend_type_arg == k_blend_mode_pre_multiplied_alpha)
		color.rgb *= color.a;

	PS_OUTPUT_DEFAULT output = export_color(color);
	if (calc_env_output)
	{
		output.unknown.rgb = env_tint_color.rgb;
	}
	return output;
}

PS_OUTPUT_DEFAULT shader_entry_static_sh(VS_OUTPUT_STATIC_SH input)
{
	return entry_static_sh_prt(input.position.xy, input.texcoord.xy, input.camera_dir.xyz, input.normal, input.tangent, input.binormal, input.sky_radiance, input.extinction_factor, 1.0);
}

PS_OUTPUT_DEFAULT shader_entry_static_prt(VS_OUTPUT_STATIC_PRT input)
{
	return entry_static_sh_prt(input.position.xy, input.texcoord.xy, input.camera_dir.xyz, input.normal, input.tangent, input.binormal, input.sky_radiance, input.extinction_factor, input.prt_radiance_vector.x);
}

#endif