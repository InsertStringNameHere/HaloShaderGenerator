﻿
#include "helpers\input_output.hlsli"

struct PS_ZONLY_OUTPUT
{
    float4 ldr;
    float4 hdr;
    float4 w;
};

PS_ZONLY_OUTPUT entry_z_only(VS_OUTPUT_ZONLY input) : COLOR
{
    PS_ZONLY_OUTPUT output;
    output.ldr = float4(0, 0, 0, 1);
    output.hdr = float4(0.5, 0.5, 0.5, 1);
    output.w = input.normal_and_w.w;
    return output;
}