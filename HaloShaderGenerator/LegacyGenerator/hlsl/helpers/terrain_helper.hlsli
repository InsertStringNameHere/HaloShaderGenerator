﻿
#define material_active(index) (material_type_##index##_arg != k_material_off)
#define four_materials_active (material_active(0) && material_active(1) && material_active(2) && material_active(3))

#define material_has_specular(index) (material_type_##index##_arg == 1 || material_type_##index##_arg == 4 || material_type_##index##_arg == 5 || material_type_##index##_arg == 7)
#define material_has_illum(index) (material_type_##index##_arg == k_material_diffuse_only_plus_self_illum || material_type_##index##_arg == k_material_diffuse_plus_specular_plus_self_illum)
#define material_has_heightmap(index) (material_type_##index##_arg == k_material_diffuse_plus_specular_plus_heightmap || material_type_##index##_arg == k_material_diffuse_diffuse_plus_specular_plus_up_vector_plus_heightmap)

#define self_illum_map(index) self_illum_map_m_##index
#define self_illum_map_xform(index) self_illum_map_m_##index##_xform
#define self_illum_detail_map(index) self_illum_detail_map_m_##index
#define self_illum_detail_map_xform(index) self_illum_detail_map_m_##index##_xform
#define self_illum_color(index) self_illum_color_m_##index
#define self_illum_intensity(index) self_illum_intensity_m_##index

#ifndef _TERRAIN_HELPER_HLSLI
#define _TERRAIN_HELPER_HLSLI

// Generics
#define shaderstage 0
#define shadertype 0

// Enums

#define k_shaderstage_default 0
#define k_shaderstage_albedo 1
#define k_shaderstage_static_default 2
#define k_shaderstage_static_per_pixel 3
#define k_shaderstage_static_per_vertex 4
#define k_shaderstage_static_sh 5
#define k_shaderstage_static_prt_ambient 6
#define k_shaderstage_static_prt_linear 7
#define k_shaderstage_static_prt_quadratic 8
#define k_shaderstage_dynamic_light 9
#define k_shaderstage_shadow_generate 10
#define k_shaderstage_shadow_apply 11
#define k_shaderstage_active_camo 12
#define k_shaderstage_lightmap_debug_mode 13
#define k_shaderstage_static_per_vertex_color 14
#define k_shaderstage_water_tesselation 15
#define k_shaderstage_water_shading 16
#define k_shaderstage_dynamic_light_cinematic 17
#define k_shaderstage_z_only 18
#define k_shaderstage_sfx_distort 19

// Method Enums

#define k_blend_type_morph 0
#define k_blend_type_dynamic_morph 1

#define k_environment_map_none 0
#define k_environment_map_per_pixel 1
#define k_environment_map_dynamic

#define k_material_diffuse_only 0
#define k_material_diffuse_plus_specular 1
#define k_material_off 2
#define k_material_diffuse_only_plus_self_illum 3
#define k_material_diffuse_plus_specular_plus_self_illum 4
#define k_material_diffuse_plus_specular_plus_heightmap 5
#define k_material_diffuse_plus_two_detail 6
#define k_material_diffuse_diffuse_plus_specular_plus_up_vector_plus_heightmap 7

// method options

#define blend_type_arg 0
#define env_map_arg 0
#define material_type_0_arg 0
#define material_type_1_arg 0
#define material_type_2_arg 0
#define material_type_3_arg 0

#endif



