# Minecraft Complementary Shaders v4 - Texture Synthesis Using Tiling and Blending

## Overview

This project focuses on texture synthesis in Minecraft using Complementary Shaders v4, with a particular emphasis on Tiling and Blending techniques. The project was forked from Nicolas Lutz's original implementation of Tiling and Blending, and further developed as part of an internship at the University of Sherbrooke. The goal of this project was to tweak and improve the results of the texture synthesis process, ultimately enhancing the visual quality of textures in Minecraft.

![1](https://github.com/user-attachments/assets/a80b860b-1dcd-4252-8651-437c0b3228f7)


## Project Background

Minecraft is known for its blocky, pixelated aesthetic, which relies heavily on texture atlases to define the appearance of different blocks. While this aesthetic is iconic, it can lead to visible repetition in textures, especially when large areas of the same block type are used. Tiling and Blending techniques offer a solution to this issue by creating more seamless transitions between textures and reducing the visual repetition.

This project builds on the work of Nicolas Lutz, who implemented a basic version of Tiling and Blending in Minecraft Complementary Shaders v4. The project was forked to allow for further development and refinement, with the aim of achieving higher-quality texture synthesis.

## My Contribution

During my internship at the University of Sherbrooke, I was responsible for:

- **Tweaking and Improving Results**: I worked on refining the Tiling and Blending algorithms to produce better visual outcomes. This involved adjusting various parameters and experimenting with different approaches to achieve the best possible texture synthesis.
- **Explaining Tiling and Blending**: I prepared a brief explanation of the Tiling and Blending techniques used in this project, highlighting their importance in reducing texture repetition and improving visual quality.
- **Presenting Results**: I documented the results of the improved Tiling and Blending techniques, showcasing the enhanced textures in Minecraft.

## What is Tiling and Blending?

**Tiling** refers to the process of repeating a texture across a surface to cover it completely. In Minecraft, textures are typically repeated (or "tiled") to cover the faces of blocks. However, without proper management, tiling can lead to visible seams and repetitive patterns, which can detract from the visual appeal.

**Blending** is the technique of smoothly transitioning between adjacent textures to reduce the appearance of seams and create a more cohesive look. By blending textures at their boundaries, the transition between different blocks becomes less noticeable, resulting in a more polished and natural appearance.

### Implementation Details

- **TilingAndBlending Function**: The core of this project lies in the `TilingAndBlending` function, which handles the seamless tiling and blending of textures based on UV coordinates and block positions (made by **Nicolas Lutz**).
- **Block Categorization**: Blocks are categorized into three groups—normal blocks, 4 bricks blocks, and 2 bricks blocks—each using a different Tiling and Blending method tailored to its characteristics.
- **Improved UV Handling**: The project includes optimizations for handling UV coordinates more effectively, ensuring that textures align correctly across block boundaries.
- **Fixing bugs and artefacts**: My job was to debug and improve the existing Tiling adn blending function , adat it to different blocks, and fix artifacts and some bugs.

## Results

The improvements made during this internship have resulted in significantly enhanced texture synthesis in Minecraft Complementary Shaders v4. The new Tiling and Blending techniques produce more seamless and visually appealing textures, with reduced repetition and improved transitions between different blocks.

![2](https://github.com/user-attachments/assets/b1f69c2c-84d6-4563-92f2-296b7c8c986c)

![3](https://github.com/user-attachments/assets/5516d138-ab80-42c6-81ee-b75ccffbc983)

## How to Use

1. The same way you download Complemantary sahders, just replace the og files with the repo

## Acknowledgments

This project was developed as part of an internship at the University of Sherbrooke, under the guidance of **Nicoalas Lutz**. The project builds on the work of Nicolas Lutz, whose original implementation of Tiling and Blending provided the foundation for these improvements.

## License

This project is licensed under the [Your License Here] License - see the [LICENSE](LICENSE) file for details.
