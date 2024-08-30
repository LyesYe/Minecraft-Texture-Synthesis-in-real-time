#define TEXSYN_PI 3.14159265359

void SquareGrid(vec2 uv, out vec2 weights, out ivec2 vertex1, out ivec2 vertex2)
{   
    // New code for pixelated transitions
    // Scale UV to a 16x16 grid
    // Aligns the UV coordinates to a 16x16 grid
    // En multipliant les coordonnées UV par 16 puis en prenant la valeur floor, 
    // nous alignons effectivement les coordonnées UV sur le plus proche intervalle de 1/16ème.
    uv = floor(uv * 16.0) / 16.0;
    
    // Calculate sine values 
    vec2 sinuv = sin(uv * TEXSYN_PI);
    vec2 sinuv2 = sinuv * sinuv;
    
    vertex1 = ivec2(0, 0);
    
    // Calculate weights based on the sine values
    weights.x = sinuv2.x * sinuv2.y + 0.001;

    // Adjust UV for the second vertex
    vec2 uv2 = uv - vec2(0.5, 0.5);
    vertex2 = ivec2(floor(uv2)) * ivec2(2, 2) + ivec2(1, 1);
    sinuv = sin(uv2 * TEXSYN_PI);
    sinuv2 = sinuv * sinuv;

    weights.y = sinuv2.x * sinuv2.y + 0.001;
}


// see https://www.shadertoy.com/view/XlGcRh
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

// see https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float floatConstruct(uint m) {
    const uint ieeeMantissa = 0x007FFFFFu; // binary32 mantissa bitmask
    const uint ieeeOne      = 0x3F800000u; // 1.0 in IEEE binary32

    m &= ieeeMantissa;                     // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                          // Add fractional part to 1.0

    float  f = uintBitsToFloat(m);         // Range [1:2]
    return f - 1.0;                        // Range [0:1]
}

vec2 hash22u(uvec2 p)
{
    uvec2 hash = pcg2d(p);
    return vec2(floatConstruct(hash.x), floatConstruct(hash.y));
}

// offsetTo16x16 is a function that takes a vec2 nbBlocks, a vec2 offset, and a vec2 uv as input and returns a vec2. The function is used to calculate the offset of a 16x16 block in a texture. The function first calculates the block position by dividing the uv coordinates by the number of blocks in the texture. It then adds the offset to the uv coordinates and adjusts the coordinates based on whether they are greater than or equal to the ceil of the uv coordinates. The function returns the fract of the adjusted uv coordinates.

vec2 offsetTo16x16(vec2 nbBlocks, in vec2 offset, in vec2 uv)
{

    // -----------------------------------------------------------------------------------------
    offset = floor(offset * 16.0) / 16.0; // Align to 16x16 grid pour avoir des blocs de 16x16 , evite un minecraft pixel a plusieur couleur 
    
    // Align the offset to the brick grid
    float brickHeight = 4.0 / 16.0; // Normalized brick height in UV space
    
    offset.y = floor(offset.y / brickHeight) * brickHeight; // Align to brick height grid
    
    vec2 uvCeil = ceil(uv);

  
    uv += offset ; 
    uv.x = float(uv.x < uvCeil.x) * uv.x + float(uv.x >= uvCeil.x) * (uv.x - 1.0);
    uv.y = float(uv.y < uvCeil.y) * uv.y + float(uv.y >= uvCeil.y) * (uv.y - 1.0);
    

    // -----------------------------------------------------------------------------------------

    
    return fract(uv);
}


vec2 offsetTo2x2(vec2 nbBlocks, in vec2 offset, in vec2 uv)
{
    // -----------------------------------------------------------------------------------------
    offset = floor(offset * 2.0) / 2.0; // Align to 2x2 grid (chaque brique occupe 1/2 de la texture)
    
    // Align the offset to the brick grid
    float brickHeight = 1.0 / 2.0; // Taille normalisée d'une brique dans l'espace UV
    
    offset.y = floor(offset.y / brickHeight) * brickHeight; // Aligner à la hauteur de la grille de briques
    
    vec2 uvCeil = ceil(uv);

    uv += offset; 
    uv.x = float(uv.x < uvCeil.x) * uv.x + float(uv.x >= uvCeil.x) * (uv.x - 1.0);
    uv.y = float(uv.y < uvCeil.y) * uv.y + float(uv.y >= uvCeil.y) * (uv.y - 1.0);
    
    return fract(uv);
}



vec2 offsetTo16x16Normal(vec2 nbBlocks, in vec2 offset, in vec2 uv)
{
	//offset = vec2(0.0625, 0.0625);
	offset = floor(offset*16.0)/16.0;
	vec2 uvCeil = ceil(uv);
	uv += offset;
	uv.x = float(uv.x < uvCeil.x)*uv.x + float(uv.x >= uvCeil.x)*(uv.x - 1.0);
	uv.y = float(uv.y < uvCeil.y)*uv.y + float(uv.y >= uvCeil.y)*(uv.y - 1.0);
	return fract(uv);
}


vec4 TilingAndBlending(in sampler2D sampler, in vec2 uv, in ivec3 blockPos)
{
    // Dynamically determine the atlas size
    vec2 atlasSize = vec2(textureSize(sampler, 0));


    vec2 nbBlocks = atlasSize / 16.0;
    ivec2 tile1;
    ivec2 tile2;
    vec2 weights;

    vec2 blockUV = uv * nbBlocks;
    vec2 blockUVFract = fract(blockUV);
    vec2 blockUVFloor = floor(blockUV);

    SquareGrid(blockUVFract, weights, tile1, tile2); // Weight is normalized for 16x16 pixels per cube
    float W = length(weights);

    ivec2 uniqueID = ivec2(blockPos.x + blockPos.y, blockPos.z);
    tile1 = uniqueID * ivec2(2, 2);
    tile2 = uniqueID * ivec2(2, 2) + tile2;

    vec2 offset1 = hash22u(uvec2(tile1));
    vec2 offset2 = hash22u(uvec2(tile2));

    vec2 uvContent1 = offsetTo2x2(nbBlocks, offset1, blockUVFract);
    vec2 uvContent2 = offsetTo2x2(nbBlocks, offset2, blockUVFract);

        

    uvContent1 = (uvContent1 + blockUVFloor) / nbBlocks;
    uvContent2 = (uvContent2 + blockUVFloor) / nbBlocks;

    vec4 mean = textureLod(sampler, uv, 4);

    vec4 content1 = texture2DLod(sampler, uvContent1, 0.0) - mean;
    vec4 content2 = texture2DLod(sampler, uvContent2, 0.0) - mean;

    vec4 value = content1 * weights.x + content2 * weights.y;
    return value / W + mean;


}


vec4 TilingAndBlendingNormal(in sampler2D sampler, in vec2 uv, in ivec3 blockPos)
{
    // Dynamically determine the atlas size
    vec2 atlasSize = vec2(textureSize(sampler, 0));


    vec2 nbBlocks = atlasSize / 16.0;
    ivec2 tile1;
    ivec2 tile2;
    vec2 weights;

    vec2 blockUV = uv * nbBlocks;
    vec2 blockUVFract = fract(blockUV);
    vec2 blockUVFloor = floor(blockUV);

    SquareGrid(blockUVFract, weights, tile1, tile2); // Weight is normalized for 16x16 pixels per cube
    float W = length(weights);

    ivec2 uniqueID = ivec2(blockPos.x + blockPos.y, blockPos.z);
    tile1 = uniqueID * ivec2(2, 2);
    tile2 = uniqueID * ivec2(2, 2) + tile2;

    vec2 offset1 = hash22u(uvec2(tile1));
    vec2 offset2 = hash22u(uvec2(tile2));

    vec2 uvContent1 = offsetTo16x16Normal(nbBlocks, offset1, blockUVFract);
    vec2 uvContent2 = offsetTo16x16Normal(nbBlocks, offset2, blockUVFract);

        

    uvContent1 = (uvContent1 + blockUVFloor) / nbBlocks;
    uvContent2 = (uvContent2 + blockUVFloor) / nbBlocks;

    vec4 mean = textureLod(sampler, uv, 4);

    vec4 content1 = texture2DLod(sampler, uvContent1, 0.0) - mean;
    vec4 content2 = texture2DLod(sampler, uvContent2, 0.0) - mean;

    vec4 value = content1 * weights.x + content2 * weights.y;
    return value / W + mean;


}


vec4 TilingAndBlending4Bricks(in sampler2D sampler, in vec2 uv, in ivec3 blockPos)
{
    // Dynamically determine the atlas size
    vec2 atlasSize = vec2(textureSize(sampler, 0));


    vec2 nbBlocks = atlasSize / 16.0;
    ivec2 tile1;
    ivec2 tile2;
    vec2 weights;

    vec2 blockUV = uv * nbBlocks;
    vec2 blockUVFract = fract(blockUV);
    vec2 blockUVFloor = floor(blockUV);

    SquareGrid(blockUVFract, weights, tile1, tile2); // Weight is normalized for 16x16 pixels per cube
    float W = length(weights);

    ivec2 uniqueID = ivec2(blockPos.x + blockPos.y, blockPos.z);
    tile1 = uniqueID * ivec2(2, 2);
    tile2 = uniqueID * ivec2(2, 2) + tile2;

    vec2 offset1 = hash22u(uvec2(tile1));
    vec2 offset2 = hash22u(uvec2(tile2));

    vec2 uvContent1 = offsetTo16x16(nbBlocks, offset1, blockUVFract);
    vec2 uvContent2 = offsetTo16x16(nbBlocks, offset2, blockUVFract);

        

    uvContent1 = (uvContent1 + blockUVFloor) / nbBlocks;
    uvContent2 = (uvContent2 + blockUVFloor) / nbBlocks;

    vec4 mean = textureLod(sampler, uv, 4);

    vec4 content1 = texture2DLod(sampler, uvContent1, 0.0) - mean;
    vec4 content2 = texture2DLod(sampler, uvContent2, 0.0) - mean;

    vec4 value = content1 * weights.x + content2 * weights.y;
    return value / W + mean;


}


vec4 TilingAndBlending2Bricks(in sampler2D sampler, in vec2 uv, in ivec3 blockPos)
{
    // Dynamically determine the atlas size
    vec2 atlasSize = vec2(textureSize(sampler, 0));


    vec2 nbBlocks = atlasSize / 16.0;
    ivec2 tile1;
    ivec2 tile2;
    vec2 weights;

    vec2 blockUV = uv * nbBlocks;
    vec2 blockUVFract = fract(blockUV);
    vec2 blockUVFloor = floor(blockUV);

    SquareGrid(blockUVFract, weights, tile1, tile2); // Weight is normalized for 16x16 pixels per cube
    float W = length(weights);

    ivec2 uniqueID = ivec2(blockPos.x + blockPos.y, blockPos.z);
    tile1 = uniqueID * ivec2(2, 2);
    tile2 = uniqueID * ivec2(2, 2) + tile2;

    vec2 offset1 = hash22u(uvec2(tile1));
    vec2 offset2 = hash22u(uvec2(tile2));

    vec2 uvContent1 = offsetTo2x2(nbBlocks, offset1, blockUVFract);
    vec2 uvContent2 = offsetTo2x2(nbBlocks, offset2, blockUVFract);

        

    uvContent1 = (uvContent1 + blockUVFloor) / nbBlocks;
    uvContent2 = (uvContent2 + blockUVFloor) / nbBlocks;

    vec4 mean = textureLod(sampler, uv, 4);

    vec4 content1 = texture2DLod(sampler, uvContent1, 0.0) - mean;
    vec4 content2 = texture2DLod(sampler, uvContent2, 0.0) - mean;

    vec4 value = content1 * weights.x + content2 * weights.y;
    return value / W + mean;


}
