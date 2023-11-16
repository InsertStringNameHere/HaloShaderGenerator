﻿#ifndef _EXPLICIT_INPUT_OUTPUT_HLSLI
#define _EXPLICIT_INPUT_OUTPUT_HLSLI

struct VS_OUTPUT_DEFAULT
{
    float4 position : SV_Position;
    float2 texcoord : TEXCOORD;
};

struct VS_OUTPUT_SHIELD_IMPACT
{
    float4 position : SV_Position;
    float4 v0 : TEXCOORD1;
    float4 v1 : TEXCOORD2;
};

struct VS_OUTPUT_SCREEN
{
    float4 position : SV_Position;
    float4 texcoord : TEXCOORD;
};

#endif