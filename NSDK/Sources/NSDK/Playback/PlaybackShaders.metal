#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 texCoord;
};

struct Uniforms {
    float3x3 uvTransform;
    float4 tint;
};

vertex VertexOut playbackVertexShader(VertexIn in [[stage_in]],
                                     constant Uniforms& uniforms [[buffer(1)]]) {
    VertexOut out;
    
    // Forward vertex position
    out.position = float4(in.position, 0.0, 1.0);
    
    // Transform UVs
    float3 uvh = float3(in.texCoord, 1.0);
    out.texCoord = uniforms.uvTransform * uvh;
    
    return out;
}

fragment float4 playbackFragmentShader(VertexOut in [[stage_in]],
                                      texture2d<float> imageTexture [[texture(0)]],
                                      constant Uniforms& uniforms [[buffer(1)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    // Sample the texture with perspective-correct UV coordinates
    float2 uv = in.texCoord.xy / in.texCoord.z;
    float4 color = imageTexture.sample(textureSampler, uv);
    
    // Apply tint and opacity
    return color * uniforms.tint;
}

