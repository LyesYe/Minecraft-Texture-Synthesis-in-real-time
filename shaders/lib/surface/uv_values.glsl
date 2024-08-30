// uv offsets

#define NUM_NORMAL_BLOCKS 7
#define NUM_4BRICKS_BLOCKS 2
#define NUM_2BRICKS_BLOCKS 4

// Define UV offsets for each block category
const vec2 normalBlockOffsets[NUM_NORMAL_BLOCKS] = vec2[NUM_NORMAL_BLOCKS](
    vec2(624.0, 272.0),  // Cobblestcobbone
    vec2(768.0, 304.0),  // Dirt
    vec2(640.0, 368.0),  // Oak Leaves
    vec2(736.0, 416.0),  // Sand
    vec2(656.0, 368.0),  // Oak Wood (Log)
    vec2(480.0, 240.0),   // Birch Wood (Log)
        vec2(160.0, 256.0)  // normal Bricks

);

const vec2 bricks4BlockOffsets[NUM_4BRICKS_BLOCKS] = vec2[NUM_4BRICKS_BLOCKS](
    vec2(688.0, 368.0),  // Oak Planks
    vec2(272.0, 224.0)  // acacia planks
);

const vec2 bricks2BlockOffsets[NUM_2BRICKS_BLOCKS] = vec2[NUM_2BRICKS_BLOCKS](
    vec2(112.0, 448.0),  // Stone Bricks
    vec2(96.0, 320.0),  // End stone bricks
    vec2(272.0, 368.0),   // Mossy stone bricks
    vec2(64.0, 256.0)   // Books chelf
);

vec2 minUVNormal(int blockIndex) {
    return normalBlockOffsets[blockIndex] / atlasSize;
}

vec2 maxUVNormal(int blockIndex) {
    return (normalBlockOffsets[blockIndex] + vec2(16.0, 16.0)) / atlasSize;
}

vec2 minUV4Bricks(int blockIndex) {
    return bricks4BlockOffsets[blockIndex] / atlasSize;
}

vec2 maxUV4Bricks(int blockIndex) {
    return (bricks4BlockOffsets[blockIndex] + vec2(16.0, 16.0)) / atlasSize;
}

vec2 minUV2Bricks(int blockIndex) {
    return bricks2BlockOffsets[blockIndex] / atlasSize;
}

vec2 maxUV2Bricks(int blockIndex) {
    return (bricks2BlockOffsets[blockIndex] + vec2(16.0, 16.0)) / atlasSize;
}
