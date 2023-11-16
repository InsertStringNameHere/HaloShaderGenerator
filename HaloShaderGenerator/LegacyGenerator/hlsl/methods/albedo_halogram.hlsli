﻿#ifndef _ALBEDO_HALOGRAM_HLSLI
#define _ALBEDO_HALOGRAM_HLSLI

#include "../helpers/types.hlsli"
#include "../helpers/math.hlsli"
#include "../helpers/color_processing.hlsli"
#include "../helpers/halogram_helper.hlsli"
#include "../helpers/definition_helper.hlsli"

uniform float4 albedo_color;
uniform float4 albedo_color2;
uniform float4 albedo_color3;
uniform sampler base_map;
uniform xform2d base_map_xform;

uniform sampler detail_map;
uniform xform2d detail_map_xform;
uniform float4 debug_tint;
uniform sampler detail_map2;
uniform xform2d detail_map2_xform;
uniform sampler change_color_map;
uniform xform2d change_color_map_xform;
uniform float3 primary_change_color;
uniform float3 secondary_change_color;
uniform float3 tertiary_change_color;
uniform float3 quaternary_change_color;
uniform sampler detail_map3;
uniform xform2d detail_map3_xform;
uniform sampler detail_map_overlay;
uniform xform2d detail_map_overlay_xform;
uniform sampler color_mask_map;
uniform xform2d color_mask_map_xform;
uniform float4 neutral_gray;

uniform float4 primary_change_color_anim;
uniform float4 secondary_change_color_anim;

//
// HALOGRAM
//

// Mostly the same as shader albedo

float3 apply_debug_tint(float3 color)
{
    float debug_tint_factor = DETAIL_MULTIPLIER;
    float3 positive_color = color * debug_tint_factor;
    float3 negative_tinted_color = debug_tint.rgb - color * debug_tint_factor;
    return positive_color + debug_tint.a * negative_tinted_color;
}

float4 calc_albedo_default_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 albedo = detail_map_sample * base_map_sample;
    albedo *= albedo_color;
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return albedo;
}

float4 calc_albedo_detail_blend_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float2 detail_map2_texcoord = apply_xform2d(texcoord, detail_map2_xform);

    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 detail_map2_sample = tex2D(detail_map2, detail_map2_texcoord);

    float4 blended_detail = lerp(detail_map_sample, detail_map2_sample, base_map_sample.w);
    float3 albedo = base_map_sample.rgb * blended_detail.rgb;
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return float4(albedo, blended_detail.w);
}

float4 calc_albedo_constant_color_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float3 albedo = lerp(albedo_color.rgb, debug_tint.rgb, debug_tint.w);
    return float4(albedo, albedo_color.a);
}

float4 calc_albedo_two_change_color_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float3 primary_change;
    float3 secondary_change;

    
    float old_contrib = position.y * secondary_change_color_old.w - primary_change_color_old.w;
    old_contrib = saturate(old_contrib * 15.0 + 0.5);
    
    primary_change = old_contrib * (primary_change_color_old.rgb - primary_change_color.rgb) + primary_change_color.rgb;
    secondary_change = lerp(secondary_change_color, secondary_change_color_old.rgb, old_contrib);
    
    
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float2 change_color_map_texcoord = apply_xform2d(texcoord, change_color_map_xform);

    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 change_color_map_sample = tex2D(change_color_map, change_color_map_texcoord);

    float2 change_color_value = change_color_map_sample.xy;
    float2 change_color_value_invert = 1.0 - change_color_value;
	
    float3 change_primary = change_color_value.x * primary_change.rgb + change_color_value_invert.x;
    float3 change_secondary = change_color_value.y * secondary_change.rgb + change_color_value_invert.y;

    float3 change_aggregate = change_primary * change_secondary;

    float4 base_detail_aggregate = detail_map_sample * base_map_sample;
    float4 albedo = float4(base_detail_aggregate.xyz * change_aggregate, base_detail_aggregate.w);
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return albedo;
}

float4 calc_albedo_four_change_color_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float2 change_color_map_texcoord = apply_xform2d(texcoord, change_color_map_xform);

    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 change_color_map_sample = tex2D(change_color_map, change_color_map_texcoord);

    float4 change_color_value = change_color_map_sample;
    float4 change_color_value_invert = 1.0 - change_color_value;

    float3 change_primary = change_color_value.x * primary_change_color + change_color_value_invert.x;
    float3 change_secondary = change_color_value.y * secondary_change_color + change_color_value_invert.y;
    float3 change_tertiary = change_color_value.z * tertiary_change_color + change_color_value_invert.z;
    float3 change_quaternary = change_color_value.w * quaternary_change_color + change_color_value_invert.w;

    float3 change_aggregate = change_primary * change_secondary * change_tertiary * change_quaternary;

    float4 base_detail_aggregate = base_map_sample * detail_map_sample;

    float4 albedo = float4(base_detail_aggregate.xyz * change_aggregate, base_detail_aggregate.w);
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return albedo;
}

float4 calc_albedo_three_detail_blend_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float2 detail_map2_texcoord = apply_xform2d(texcoord, detail_map2_xform);
    float2 detail_map3_texcoord = apply_xform2d(texcoord, detail_map3_xform);

    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 detail_map2_sample = tex2D(detail_map2, detail_map2_texcoord);
    float4 detail_map3_sample = tex2D(detail_map3, detail_map3_texcoord);

    float alpha2 = saturate(base_map_sample.a * 2.0); // I don't understand why this is so
    float4 blended_detailA = lerp(detail_map_sample, detail_map2_sample, alpha2);

    float alpha2b = saturate(base_map_sample.a * 2.0 - 1.0); // I don't understand why this is so
    float4 blended_detailB = lerp(blended_detailA, detail_map3_sample, alpha2b);

    float4 albedo = float4(base_map_sample.rgb * blended_detailB.rgb, blended_detailB.a);
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return albedo;
}

float4 calc_albedo_two_detail_overlay_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    
    float2 detail_map2_texcoord = apply_xform2d(texcoord, detail_map2_xform);
    float4 detail_map2_sample = tex2D(detail_map2, detail_map2_texcoord);
    
    float2 detail_map_overlay_texcoord = apply_xform2d(texcoord, detail_map_overlay_xform);
    float4 detail_map_overlay_sample = tex2D(detail_map_overlay, detail_map_overlay_texcoord);

    float4 detail_blend = lerp(detail_map_sample, detail_map2_sample, base_map_sample.w);

    float3 detail_color = base_map_sample.xyz * detail_blend.xyz * detail_map_overlay_sample.xyz * DETAIL_MULTIPLIER;

    float alpha = detail_blend.w * detail_map_overlay_sample.w;

    float4 albedo = float4(detail_color, alpha);
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return albedo;
}

float4 calc_albedo_two_detail_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float2 detail_map2_texcoord = apply_xform2d(texcoord, detail_map2_xform);

    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 detail_map2_sample = tex2D(detail_map2, detail_map2_texcoord);

    float4 albedo = base_map_sample * detail_map_sample * detail_map2_sample;

    albedo.rgb = apply_debug_tint(albedo.rgb * DETAIL_MULTIPLIER);
    return albedo;
}

float4 calc_albedo_color_mask_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float4 masked_color;
    float4 color;
    
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float2 color_mask_map_texcoord = apply_xform2d(texcoord, color_mask_map_xform);

    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 color_mask_map_sample = tex2D(color_mask_map, color_mask_map_texcoord);

    color = base_map_sample * detail_map_sample;

    float3 color_mask_invert = 1.0 - color_mask_map_sample.rgb;
    float4 neutral_invert = float4((1.0 / neutral_gray.rgb), 1.0);

    float4 masked_color0 = color_mask_map_sample.r * albedo_color;
    float4 masked_color1 = color_mask_map_sample.g * albedo_color2;
    float4 masked_color2 = color_mask_map_sample.b * albedo_color3;
    
    masked_color = masked_color0 * neutral_invert + color_mask_invert.rrrr;
    masked_color *= masked_color1 * neutral_invert + color_mask_invert.gggg;
    masked_color *= masked_color2 * neutral_invert + color_mask_invert.bbbb;


    float4 albedo = masked_color * color;
    albedo.rgb = apply_debug_tint(albedo.rgb);
    return albedo;
}

float4 calc_albedo_two_detail_black_point_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
	
    float2 detail_map2_texcoord = apply_xform2d(texcoord, detail_map2_xform);
    float4 detail_map2_sample = tex2D(detail_map2, detail_map2_texcoord);

    float4 albedo;
    albedo.rgb = base_map_sample.rgb * detail_map_sample.rgb * detail_map2_sample.rgb;
    albedo.rgb = apply_debug_tint(albedo.rgb * DETAIL_MULTIPLIER);
	
    // blackpoint code
    float details = detail_map_sample.a * detail_map2_sample.a;
    float base = (1.0 + base_map_sample.a) * 0.5;
    float x = (details - base_map_sample.a) / (base - base_map_sample.a);
    float b = details - base;
    albedo.a = base * saturate(x) + saturate(b);
	
    return albedo;
}

float4 calc_albedo_two_change_color_anim_ps(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    float3 primary_change;
    float3 secondary_change;

    
    float anim = position.y * secondary_change_color_anim.w - primary_change_color_anim.w;
    anim = saturate(anim * 15.0 + 0.5);
	
	
    primary_change = anim * (primary_change_color_anim.rgb - primary_change_color.rgb) + primary_change_color.rgb;
    secondary_change = anim * (secondary_change_color_anim.rgb - secondary_change_color.rgb) + secondary_change_color.rgb;

    float2 base_map_texcoord = apply_xform2d(texcoord, base_map_xform);
    float2 detail_map_texcoord = apply_xform2d(texcoord, detail_map_xform);
    float4 base_map_sample = tex2D(base_map, base_map_texcoord);
    float4 detail_map_sample = tex2D(detail_map, detail_map_texcoord);
    float4 base_detail_aggregate = detail_map_sample * base_map_sample;
    base_detail_aggregate.rgb *= DETAIL_MULTIPLIER;
	
    primary_change = primary_change * base_detail_aggregate.rgb - base_detail_aggregate.rgb;
	
    float2 change_color_map_texcoord = apply_xform2d(texcoord, change_color_map_xform);
    float4 change_color_map_sample = tex2D(change_color_map, change_color_map_texcoord);

    float2 change_color_value = change_color_map_sample.xy;
	
    primary_change = change_color_value.x * primary_change + base_detail_aggregate.rgb;
	
    secondary_change = secondary_change * base_detail_aggregate.rgb - primary_change;
	
    float3 change_aggregate = change_color_value.y * secondary_change + primary_change;

	
    float4 albedo = float4(change_aggregate, base_detail_aggregate.w);

    float3 negative_tinted_color = debug_tint.rgb - albedo.rgb;
    albedo.rgb = albedo.rgb + debug_tint.a * negative_tinted_color;
	
    return albedo;
}



float4 calc_albedo_default_vs(float2 texcoord, float2 position, float3 surface_normal, float3 camera_dir)
{
    return 0;
}

//#ifndef calc_albedo_ps
//#define calc_albedo_ps calc_albedo_default_ps
//#endif
//#ifndef calc_albedo_vs
//#define calc_albedo_vs calc_albedo_default_vs
//#endif

#endif
