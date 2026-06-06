#version 150 compatibility
// final.fsh — Post-processing pass
// Reads colortex1 (full-res upscaled frame from composite.fsh)
// CAS + Bloom + ACES + Shadow/Gamma

uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

in  vec2 texCoord;
out vec4 fragColor;

// ---------------------------------------------------------------------------
// Contrast-Adaptive Sharpening
// sharpness: 0.0 = off, 0.5 = default, 1.0 = max
// ---------------------------------------------------------------------------
vec3 CASharpen(vec2 uv, vec3 base) {
    float sharpness = 0.5;
    vec2  texel = vec2(1.0/viewWidth, 1.0/viewHeight);

    vec3 n = texture(colortex1, uv+vec2( 0.0,      texel.y)).rgb;
    vec3 s = texture(colortex1, uv+vec2( 0.0,     -texel.y)).rgb;
    vec3 e = texture(colortex1, uv+vec2( texel.x,  0.0    )).rgb;
    vec3 w = texture(colortex1, uv+vec2(-texel.x,  0.0    )).rgb;

    vec3 minRGB = min(min(n,s), min(e,w));
    vec3 maxRGB = max(max(n,s), max(e,w));
    vec3 weight = clamp(sharpness * (minRGB / (maxRGB + 0.0001)), 0.0, 1.0);
    vec3 sharp  = (n+s+e+w) * weight / (4.0*weight + vec3(1.0));
    return clamp((base+sharp) / (vec3(1.0)+weight), 0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Bloom — 5-tap plus pattern, cheap and effective
// Replaces 13-tap cross — same visible result, much lower cost at 1080p
// bloomThreshold : 0.55 = fire/lava/sun  |  0.40 = broader glow
// bloomStrength  : 0.08–0.12 clean       |  0.20+ heavy
// bloomSpread    : pixel radius, 3.0–6.0 natural
// ---------------------------------------------------------------------------
vec3 Bloom(vec2 uv, vec3 base) {
    float bloomThreshold = 0.60;
    float bloomStrength  = 0.20;
    float bloomSpread    = 4.50;

    vec2 texel = vec2(1.0/viewWidth, 1.0/viewHeight) * bloomSpread;

    // 5 taps: center + 4 cardinal directions
    vec3 c0 = texture(colortex1, uv                          ).rgb;
    vec3 c1 = texture(colortex1, uv + vec2( texel.x,  0.0  )).rgb;
    vec3 c2 = texture(colortex1, uv + vec2(-texel.x,  0.0  )).rgb;
    vec3 c3 = texture(colortex1, uv + vec2( 0.0,      texel.y)).rgb;
    vec3 c4 = texture(colortex1, uv + vec2( 0.0,     -texel.y)).rgb;

    // Weighted average: center counts double
    vec3 avg = (c0*2.0 + c1 + c2 + c3 + c4) / 6.0;

    // Only keep the bright part
    float luma = dot(avg, vec3(0.2126, 0.7152, 0.0722));
    float knee = smoothstep(bloomThreshold, bloomThreshold + 0.2, luma);

    return base + avg * knee * bloomStrength;
}

// ---------------------------------------------------------------------------
// ACES Filmic Tonemap
// ---------------------------------------------------------------------------
vec3 ACESFilmic(vec3 x) {
    return clamp((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14), 0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Shadow Lift + Gamma
// shadowLift : 0.02 subtle  |  0.06 noticeable  |  0.10+ foggy
// gamma      : 0.92 default |  1.0 no change    |  0.85 very bright mids
// ---------------------------------------------------------------------------
vec3 ShadowLiftGamma(vec3 color) {
    float shadowLift = 0.02;
    float gamma      = 0.95;
    color = color + vec3(shadowLift) * (1.0 - color);
    return pow(clamp(color, 0.0, 1.0), vec3(gamma));
}

void main() {
    vec2 uv    = texCoord;
    vec3 color = texture(colortex1, uv).rgb;

    color = CASharpen(uv, color);
    color = Bloom(uv, color);
    color = ACESFilmic(color);
    color = ShadowLiftGamma(color);

    fragColor = vec4(color, 1.0);
}
