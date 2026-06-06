#version 150 compatibility
// gbuffers_terrain.vsh
// Passes terrain geometry to fragment stage
// Exports texCoord, lmCoord (lightmap), and vertColor

varying vec2 texCoord;
varying vec2 lmCoord;
varying vec4 vertColor;

void main() {
    // Terrain texture UV
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // Lightmap UV — texture unit 1 in vanilla Minecraft
    lmCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // Vertex color carries biome tint and brightness
    vertColor = gl_Color;

    gl_Position = ftransform();
}
