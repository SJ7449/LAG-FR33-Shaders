#version 150 compatibility
// MyFSR+ Enhanced
// CAS + Bloom + ACES + Shadow/Gamma
// Single-pass post-processing

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texCoord;
out vec4 fragColor;

vec3 ACESFilmic(vec3 x) {
    return clamp(
        (x * (2.35 * x + 0.03)) /
        (x * (2.20 * x + 0.59) + 0.14),
        0.0,
        1.0
    );
}

vec3 ShadowLiftGamma(vec3 color) {
    float shadowLift = 0.03;
    float gamma      = 0.90;

    color = color + vec3(shadowLift) * (1.0 - color);

    return pow(clamp(color, 0.0, 1.0), vec3(gamma));
}

void main() {
    vec2 uv = texCoord;

    vec2 texel = vec2(
        1.0 / viewWidth,
        1.0 / viewHeight
    );

    // Center + Cross Samples
    vec3 c0 = texture(colortex0, uv).rgb;

    vec3 n = texture(colortex0, uv + vec2(0.0,      texel.y)).rgb;
    vec3 s = texture(colortex0, uv - vec2(0.0,      texel.y)).rgb;
    vec3 e = texture(colortex0, uv + vec2(texel.x,  0.0)).rgb;
    vec3 w = texture(colortex0, uv - vec2(texel.x,  0.0)).rgb;

    // Diagonal Samples for Better Bloom
    vec3 ne = texture(colortex0, uv + vec2( texel.x,  texel.y)).rgb;
    vec3 nw = texture(colortex0, uv + vec2(-texel.x,  texel.y)).rgb;
    vec3 se = texture(colortex0, uv + vec2( texel.x, -texel.y)).rgb;
    vec3 sw = texture(colortex0, uv + vec2(-texel.x, -texel.y)).rgb;

    // Sharpen

    float sharpness = 0.65;

    vec3 minRGB = min(min(n, s), min(e, w));
    vec3 maxRGB = max(max(n, s), max(e, w));

    vec3 amp = sqrt(
        minRGB /
        (maxRGB + 0.0001)
    );

    vec3 weight = clamp(
        sharpness * amp,
        0.0,
        1.0
    );

    vec3 sharp =
        (n + s + e + w) *
        weight /
        (4.0 * weight + vec3(1.0));

    vec3 color =
        clamp(
            (c0 + sharp) /
            (vec3(1.0) + weight),
            0.0,
            1.0
        );

    // Bloom

    float bloomThreshold = 0.60;

    vec3 avg =
        (
            c0 * 2.0 +
            n + s + e + w +
            ne + nw + se + sw
        ) / 10.0;

    float luma =
        max(avg.r,
        max(avg.g,
            avg.b));

    float knee =
        smoothstep(
            bloomThreshold,
            bloomThreshold + 0.20,
            luma
        );

    float bloomStrength =
        mix(
            0.15,
            0.35,
            1.0 - luma
        );

    color += avg * knee * bloomStrength;

    // ACES

    color = ACESFilmic(color);

    // Shadows + Gamma

    color = ShadowLiftGamma(color);

    // Vignette

    float vignette =
        1.0 -
        dot(uv - 0.5, uv - 0.5) * 0.35;

    color *= clamp(
        vignette,
        0.90,
        1.00
    );

    fragColor = vec4(color, 1.0);
}
