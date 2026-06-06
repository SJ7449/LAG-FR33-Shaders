#version 150 compatibility
// gbuffers_terrain.fsh
// Writes terrain into colortex0 at the reduced resolution set by scale.colortex0
// composite.fsh reads this and upscales to colortex1
// final.fsh does post-processing on colortex1

uniform sampler2D gtexture;  // terrain texture atlas
uniform sampler2D lightmap;  // vanilla light values (sky + block light)

varying vec2 texCoord;
varying vec2 lmCoord;        // lightmap UV passed from vsh
varying vec4 vertColor;

/* DRAWBUFFERS:0 */
out vec4 fragColor;

void main() {
    // Sample terrain texture
    vec4 albedo = texture(gtexture, texCoord);

    // Discard transparent pixels (leaf edges, glass borders)
    if (albedo.a < 0.1) discard;

    // Sample vanilla lightmap for correct cave/sky lighting
    vec4 light = texture(lightmap, lmCoord);

    // Combine: texture * biome/brightness vertex color * lightmap
    fragColor = albedo * vertColor * light;
}
