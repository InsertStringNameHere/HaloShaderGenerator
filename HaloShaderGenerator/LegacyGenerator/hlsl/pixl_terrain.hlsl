﻿#define terrain_template

#include "helpers\terrain_helper.hlsli"
#include "helpers\input_output.hlsli"

#if shaderstage == k_shaderstage_albedo
#include "terrain/entry_albedo.hlsli"
PS_OUTPUT_ALBEDO entry_albedo(VS_OUTPUT_ALBEDO_TERRAIN input) : COLOR
{	
	return shader_entry_albedo(input);
}
#endif

#if shaderstage == k_shaderstage_static_per_pixel
#include "terrain/entry_per_pixel_lighting.hlsli"
PS_OUTPUT_DEFAULT entry_static_per_pixel(VS_OUTPUT_PER_PIXEL_TERRAIN input) : COLOR
{	
	return terrain_entry_static_per_pixel(input);
}
#endif

#if shaderstage == k_shaderstage_static_per_vertex
#include "terrain/entry_per_vertex_lighting.hlsli"
PS_OUTPUT_DEFAULT entry_static_per_vertex(VS_OUTPUT_PER_VERTEX_TERRAIN input) : COLOR
{	
	return terrain_entry_static_per_vertex(input);
}
#endif

#if shaderstage == k_shaderstage_lightmap_debug_mode
#include "terrain/entry_lightmap_debug.hlsli"
PS_OUTPUT_DEFAULT entry_lightmap_debug_mode(VS_OUTPUT_LIGHTMAP_DEBUG_MODE_TERRAIN input) : COLOR
{
	return shader_entry_lightmap_debug_mode(input);
}
#endif

#if shaderstage == k_shaderstage_dynamic_light || shaderstage == k_shaderstage_dynamic_light_cinematic
#include "terrain/entry_dynamic_light.hlsli"
PS_OUTPUT_DEFAULT entry_dynamic_light(VS_OUTPUT_DYNAMIC_LIGHT_TERRAIN input) : COLOR
{
	return shader_entry_dynamic_light(input);
}

PS_OUTPUT_DEFAULT entry_dynamic_light_cinematic(VS_OUTPUT_DYNAMIC_LIGHT_TERRAIN input) : COLOR
{
	return shader_entry_dynamic_light_cinematic(input);
}
#endif

#if shaderstage == k_shaderstage_static_sh || shaderstage == k_shaderstage_static_prt_ambient || shaderstage == k_shaderstage_static_prt_linear || shaderstage == k_shaderstage_static_prt_quadratic
#include "terrain/entry_prt.hlsli"
PS_OUTPUT_DEFAULT entry_static_sh(VS_OUTPUT_STATIC_SH_TERRAIN input) : COLOR
{
	return shader_entry_static_sh(input);
}

PS_OUTPUT_DEFAULT entry_static_prt_ambient(VS_OUTPUT_STATIC_PRT_TERRAIN input) : COLOR
{
	return shader_entry_static_prt(input);
}

PS_OUTPUT_DEFAULT entry_static_prt_linear(VS_OUTPUT_STATIC_PRT_TERRAIN input) : COLOR
{
	return shader_entry_static_prt(input);
}

PS_OUTPUT_DEFAULT entry_static_prt_quadratic(VS_OUTPUT_STATIC_PRT_TERRAIN input) : COLOR
{
	return shader_entry_static_prt(input);
}
#endif