#version 150 compatibility
// composite.fsh — Bicubic upscale pass
// Reads colortex0 at reduced res, writes upscaled result to colortex1

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

in  vec2 texCoord;
out vec4 fragColor;

vec3 UpscaleBicubic(vec2 uv) {
    vec2 texel = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    vec2 pos   = uv * vec2(viewWidth, viewHeight) - 0.5;
    vec2 f     = fract(pos);
    vec2 i     = floor(pos);

    vec4 wx, wy;
    {
        vec4 t  = vec4(f.x+1.0, f.x, 1.0-f.x, 2.0-f.x);
        vec4 t2 = t*t; vec4 t3 = t2*t;
        wx = vec4(
            -0.5*t3.x + 2.5*t2.x - 4.0*t.x + 2.0,
             1.5*t3.y - 2.5*t2.y + 1.0,
             1.5*t3.z - 2.5*t2.z + 1.0,
            -0.5*t3.w + 2.5*t2.w - 4.0*t.w + 2.0
        );
    }
    {
        vec4 t  = vec4(f.y+1.0, f.y, 1.0-f.y, 2.0-f.y);
        vec4 t2 = t*t; vec4 t3 = t2*t;
        wy = vec4(
            -0.5*t3.x + 2.5*t2.x - 4.0*t.x + 2.0,
             1.5*t3.y - 2.5*t2.y + 1.0,
             1.5*t3.z - 2.5*t2.z + 1.0,
            -0.5*t3.w + 2.5*t2.w - 4.0*t.w + 2.0
        );
    }

    vec3 color = vec3(0.0);
    for (int row = 0; row < 4; row++)
        for (int col = 0; col < 4; col++) {
            vec2 s = (i + vec2(float(col)-1.0, float(row)-1.0) + 0.5) * texel;
            color += texture(colortex0, s).rgb * wx[col] * wy[row];
        }

    return clamp(color, 0.0, 1.0);
}

/* DRAWBUFFERS:1 */
void main() {
    fragColor = vec4(UpscaleBicubic(texCoord), 1.0);
}
