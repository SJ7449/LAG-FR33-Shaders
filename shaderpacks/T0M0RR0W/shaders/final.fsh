#version 150 compatibility
// T0M0RR0W — built on T0D4Y lineage
// Removed no-op gamma pow, folded shadow lift, conditional Reinhard

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

in  vec2 texCoord;
out vec4 fragColor;

// CAS — 2-tap diagonal, weight capped at 0.75
vec3 CASharpen(vec2 uv, vec3 base) {
    float sharpness = 0.20;
    vec2  texel = vec2(1.0/viewWidth, 1.0/viewHeight);

    vec3 a = texture(colortex0, uv + vec2( texel.x,  texel.y)).rgb;
    vec3 b = texture(colortex0, uv + vec2(-texel.x, -texel.y)).rgb;

    vec3 minRGB = min(min(a, b), base);
    vec3 maxRGB = max(max(a, b), base);
    vec3 weight = clamp(sharpness * (minRGB / (maxRGB + 0.0001)), 0.0, 1.0);
    vec3 sharp  = (a + b) * weight / (1.75 * weight + vec3(1.0));
    return clamp((base + sharp) / (vec3(1.0) + weight), 0.0, 1.0);
}

// Bloom — early exit on dark pixels, tighter spread
vec3 Bloom(vec2 uv, vec3 base) {
    float bloomThreshold = 0.40;
    float bloomStrength  = 0.10;
    float bloomSpread    = 2.00; // restored from 1.0 — at 1.0 neighbors are same pixel

    float centerLuma = dot(base, vec3(0.2126, 0.7152, 0.0722));
    float knee = smoothstep(bloomThreshold - 0.1, bloomThreshold + 0.2, centerLuma);
    if (knee <= 0.0) return base;

    vec2 texel = vec2(1.0/viewWidth, 1.0/viewHeight) * bloomSpread;

    vec3 c1 = texture(colortex0, uv + vec2( texel.x,  0.0  )).rgb;
    vec3 c2 = texture(colortex0, uv + vec2(-texel.x,  0.0  )).rgb;
    vec3 c3 = texture(colortex0, uv + vec2( 0.0,  texel.y  )).rgb;
    vec3 c4 = texture(colortex0, uv + vec2( 0.0, -texel.y  )).rgb;

    vec3 avg = (base*2.0 + c1 + c2 + c3 + c4) / 6.0;
    return base + avg * knee * bloomStrength;
}

// Reinhard — skip on pixels already in [0, 0.5] range
// Those pixels compress negligibly and the division costs more than it saves visually
vec3 Reinhard(vec3 x) {
    float luma = dot(x, vec3(0.2126, 0.7152, 0.0722));
    if (luma < 0.5) return x;
    return x / (x + vec3(1.0));
}

// Shadow lift only — gamma pow removed (was 1.0, pure no-op)
// Folded into single fma-friendly form: color * (1.0 - lift) + lift
vec3 ShadowLift(vec3 color) {
    float shadowLift = 0.04;
    return clamp(color * (1.0 - shadowLift) + vec3(shadowLift), 0.0, 1.0);
}

void main() {
    vec2 uv    = texCoord;
    vec3 color = texture(colortex0, uv).rgb;

    color = CASharpen(uv, color);
    color = Bloom(uv, color);
    color = Reinhard(color);
    color = ShadowLift(color);

    fragColor = vec4(color, 1.0);
}
