#version 150 compatibility
// MyFSR — Post-processing optimized
// CAS (2-tap diagonal) + Bloom (early-exit) + Reinhard tonemap + Shadow/Gamma

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

in  vec2 texCoord;
out vec4 fragColor;

// ---------------------------------------------------------------------------
// CAS — diagonal 2-tap instead of 4-tap cardinal
// Same adaptive sharpening behavior, half the texture fetches
// ---------------------------------------------------------------------------
vec3 CASharpen(vec2 uv, vec3 base) {
    float sharpness = 0.25;
    vec2  texel = vec2(1.0/viewWidth, 1.0/viewHeight);

    // Diagonal neighbors instead of cardinal — same contrast detection, 2 samples
    vec3 a = texture(colortex0, uv + vec2( texel.x,  texel.y)).rgb;
    vec3 b = texture(colortex0, uv + vec2(-texel.x, -texel.y)).rgb;

    vec3 minRGB = min(min(a, b), base);
    vec3 maxRGB = max(max(a, b), base);
    vec3 weight = clamp(sharpness * (minRGB / (maxRGB + 0.0001)), 0.0, 1.0);
    vec3 sharp  = (a + b) * weight / (2.0 * weight + vec3(1.0));
    return clamp((base + sharp) / (vec3(1.0) + weight), 0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Bloom — early exit if center pixel is dark
// Skips all 4 neighbor samples in dark scenes (caves, night)
// Only pays full cost when a bright pixel is actually present
// ---------------------------------------------------------------------------
vec3 Bloom(vec2 uv, vec3 base) {
    float bloomThreshold = 0.60;
    float bloomStrength  = 0.18;
    float bloomSpread    = 2.25;

    // Check center luminance first — bail out early if dark
    float centerLuma = dot(base, vec3(0.2126, 0.7152, 0.0722));
    float knee = smoothstep(bloomThreshold - 0.1, bloomThreshold + 0.2, centerLuma);
    if (knee <= 0.0) return base;

    // Only reach here if pixel is bright enough to bloom
    vec2 texel = vec2(1.0/viewWidth, 1.0/viewHeight) * bloomSpread;

    vec3 c1 = texture(colortex0, uv + vec2( texel.x,  0.0  )).rgb;
    vec3 c2 = texture(colortex0, uv + vec2(-texel.x,  0.0  )).rgb;
    vec3 c3 = texture(colortex0, uv + vec2( 0.0,  texel.y  )).rgb;
    vec3 c4 = texture(colortex0, uv + vec2( 0.0, -texel.y  )).rgb;

    vec3 avg = (base*2.0 + c1 + c2 + c3 + c4) / 6.0;
    return base + avg * knee * bloomStrength;
}

// ---------------------------------------------------------------------------
// Reinhard tonemap — replaces ACES
// x / (x + 1.0) per channel — one op vs six, near-identical result at low values
// Slightly less filmic in highlights but undetectable at typical Minecraft brightness
// ---------------------------------------------------------------------------
vec3 Reinhard(vec3 x) {
    return x / (x + vec3(1.0));
}

// ---------------------------------------------------------------------------
// Shadow Lift + Gamma
// ---------------------------------------------------------------------------
vec3 ShadowLiftGamma(vec3 color) {
    float shadowLift = 0.02;
    float gamma      = 0.95;
    color = color + vec3(shadowLift) * (1.0 - color);
    return pow(clamp(color, 0.0, 1.0), vec3(gamma));
}

void main() {
    vec2 uv    = texCoord;
    vec3 color = texture(colortex0, uv).rgb;

    color = CASharpen(uv, color);
    color = Bloom(uv, color);
    color = Reinhard(color);
    color = ShadowLiftGamma(color);

    fragColor = vec4(color, 1.0);
}
