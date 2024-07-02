#define TEXSYN_PI 3.14159265359

void SquareGrid(vec2 uv, out vec2 weights, out uvec2 vertex1, out uvec2 vertex2)
{
	vec2 sinuv, sinuv2;
	
	vertex1 = uvec2(0, 0);
	sinuv = sin(uv*TEXSYN_PI);
	sinuv2 = sinuv*sinuv;
	weights.x = sinuv2.x*sinuv2.y;
	
	vec2 uv2 = uv - vec2(0.5, 0.5);
	vertex2 = uvec2(floor(uv2))*2u + uvec2(1, 1);
	sinuv = sin(uv2*TEXSYN_PI);
	sinuv2 = sinuv*sinuv;
	weights.y = sinuv2.x*sinuv2.y;
}

//see https://www.shadertoy.com/view/XlGcRh
uvec2 pcg2d(uvec2 v)
{
    v = v * 1664525u + 1013904223u;

    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;

    v = v ^ (v>>16u);

    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;

    v = v ^ (v>>16u);

    return v;
}

//see https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float floatConstruct( uint m ) {
    const uint ieeeMantissa = 0x007FFFFFu; // binary32 mantissa bitmask
    const uint ieeeOne      = 0x3F800000u; // 1.0 in IEEE binary32

    m &= ieeeMantissa;                     // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                          // Add fractional part to 1.0

    float  f = uintBitsToFloat( m );       // Range [1:2]
    return f - 1.0;                        // Range [0:1]
}

vec2 hash22u(uvec2 p)
{
	uvec2 hash = pcg2d(p);
	return vec2(floatConstruct(hash.x), floatConstruct(hash.y));
}

vec2 offsetTo16x16(vec2 nbBlocks, in vec2 offset, in vec2 uv)
{
	vec2 uv64 = uv*nbBlocks;
	vec2 uv64ceil = ceil(uv64);
	uv64 += offset;
	uv64.x = float(uv64.x < uv64ceil.x)*uv64.x + float(uv64.x >= uv64ceil.x)*(uv64.x - 1.0);
	uv64.y = float(uv64.y < uv64ceil.y)*uv64.y + float(uv64.y >= uv64ceil.y)*(uv64.y - 1.0);
	return uv64/nbBlocks;
}

vec4 TilingAndBlending(in sampler2D sampler, in vec2 uv, in ivec3 blockPos)
{
	uvec2 tile1;
	uvec2 tile2;
	vec2 weights;
	SquareGrid(uv, weights, tile1, tile2); //weight is not between 0 and 1 because uv is between 0 and 1 for whole texture
	float W = length(weights);
	
	uvec2 uniqueID = uvec2(blockPos.x+blockPos.y+blockPos.z+65, 1);
	tile1 = (uniqueID + tile1)*uvec2(2u, 2u);
	tile2 = (uniqueID + tile2)*uvec2(2u, 2u)+uvec2(1u, 1u);
	
	vec2 offset1 = hash22u(tile1);
	vec2 offset2 = hash22u(tile2);
	
	vec2 uvContent1 = uv.xy;
	vec2 uvContent2 = uv.xy;
	
	
	vec2 nbBlocks = vec2(textureSize(sampler, 0))/16.0;
	uvContent1 = offsetTo16x16(nbBlocks, offset1, uv);
	uvContent2 = offsetTo16x16(nbBlocks, offset2, uv);
	
	//debug
	
	vec4 mean = texture2DLod(sampler, uv, 4);
	
	vec4 content1 = texture(sampler, uvContent1) - mean;
	vec4 content2 = texture(sampler, uvContent2) - mean;

	vec4 value = content1*weights.x + content2*weights.y;
	return value/W + mean;
}
