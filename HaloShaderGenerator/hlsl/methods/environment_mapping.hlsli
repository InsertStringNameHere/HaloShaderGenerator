﻿#ifndef _ENVIRONMENT_MAPPING_HLSLI
#define _ENVIRONMENT_MAPPING_HLSLI

#include "../helpers/types.hlsli"
#include "../helpers/math.hlsli"
#include "../helpers/sh.hlsli"
#include "../registers/shader.hlsli"
#include "../methods/blend_mode.hlsli"

uniform float3 env_tint_color;
uniform float env_roughness_scale;
uniform samplerCUBE dynamic_environment_map_0;
uniform samplerCUBE dynamic_environment_map_1;

float4 _calculate_partial_derivative_cubemap_world_coordinate_reflection(float3 eye, float3 normal)
{
    //def c65, 6, -0.600000024, 1, -1
    float4 c65 = float4(6, -0.600000024, 1, -1);
    //def c13, 0.429042995, 0.318309873, 0, 9.99999975e-005
    float4 c13 = float4(0.429042995, 0.318309873, 0, 9.99999975e-005);

    float4 r0 = float4(eye, 0);
    r0.xyz = eye;
    float4 r1 = float4(0, 0, 0, 0);
    float4 r2 = float4(0, 0, 0, 0);
    float4 r3 = float4(0, 0, 0, 0);


    //mov r0.w, -r0.y
    r0.w = -r0.y;
    //dsy r2.xyz, r0.xwzw
    r2.xyz = ddy(r0.xwzw).xyz;
    //dsx r3.xyz, r0.xwzw
    r3.xyz = ddx(r0.xwzw).xyz;

    //dp3 r0.w, r3, r3
    //rsq r0.w, r0.w
    //rcp r0.w, r0.w
    r0.w = length(r3.xyz);

    //dp3 r1.w, r2, r2
    //rsq r1.w, r1.w
    //rcp r1.w, r1.w
    r1.w = length(r2.xyz);

    //max r2.x, r0.w, r1.w
    r2.x = max(r0.w, r1.w);


    //rsq r0.w, r2.x
    //rcp r0.w, r0.w
    r0.w = sqrt(r2.x);

    //mad r0.w, r0.w, c65.x, c65.y
    r0.w = r0.w * c65.x + c65.y;

    //max r2.w, r0.w, c13.z
    r2.w = max(r0.w, c13.z);

    //mul r2.xyz, r0, c65.zwzw
    r2.xyz = (r0 * c65.zwzw).xyz;

    return r2;
}

float3 cubemap_coordinate_shift(float3 coordinate)
{
    // inverted Y axis
    return coordinate * float3(1, -1, 1);
}

void envmap_type_none(
in float3 view_dir,
in float3 reflect_dir,
in float3 sh_0,
inout float3 diffuse)
{
}

void envmap_type_per_pixel(
in float3 view_dir,
in float3 reflect_dir,
in float3 sh_0,
inout float3 diffuse)
{
	float3 envmap_texcoord = float3(reflect_dir.x, -reflect_dir.y, reflect_dir.z);
	float4 envmap_sample = texCUBE(environment_map, envmap_texcoord);
	float3 environment_color = (envmap_sample.rgb * sh_0.rgb) * env_tint_color * envmap_sample.a;
	diffuse += environment_color;
}

float3 envmap_type_dynamic(float3 eye_world, float3 normal)
{
    float4 pdcwcr = _calculate_partial_derivative_cubemap_world_coordinate_reflection(eye_world, normal);

    //TODO Implement these lod functions

    //float4 dynamic_environment_map_0_sample = texCUBElod(dynamic_environment_map_0, float4(0, 0, 0, 0));
    //float4 dynamic_environment_map_1_sample = texCUBElod(dynamic_environment_map_1, float4(0, 0, 0, 0));
    float4 dynamic_environment_map_0_sample = texCUBElod(dynamic_environment_map_0, pdcwcr);
    float4 dynamic_environment_map_1_sample = texCUBElod(dynamic_environment_map_1, pdcwcr);

    float3 dynamic_environment_map_0 = dynamic_environment_map_0_sample.rgb;
    float3 dynamic_environment_map_1 = dynamic_environment_map_1_sample.rgb;

    float3 interpolated_color = lerp(dynamic_environment_map_0, dynamic_environment_map_1, dynamic_environment_blend.xyz);
    return interpolated_color * env_tint_color.xyz;

}

float3 envmap_type_from_flat_texture(float3 eye_world, float3 normal)
{
    

    return float3(0, 0, 0);
}

float3 envmap_type_custom_map(float3 eye_world, float3 normal)
{
    

    return float3(0, 0, 0);
}

#ifndef envmap_type
#define envmap_type envmap_type_none
#endif

#endif
