#ifdef GL_ES
precision highp float;
#else
#define highp
#define lowp
#endif


uniform highp sampler2D texture_0;
uniform highp sampler2D texture_1;
varying vec2 varTexCoord_0;
varying highp vec4 varColor;

uniform vec2 mouse_pos;

const float max_range = 1.0;


highp vec4 pack_depth(highp float depth)
{
    depth = clamp(depth * 0.5 + 0.5,0.0,1.0-1.0/160581375.0);
    highp vec4 enc = vec4(1.0, 255.0, 65025.0, 160581375.0) * depth;
    enc = fract(enc);
    enc -= enc.yzww * vec4(1.0/255.0,1.0/255.0,1.0/255.0,0.0);
    return enc;
}

highp float unpack_depth(const in highp vec4 rgba)
{
    return dot( rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/160581375.0) ) * 2.0 - 1.0;
}

uniform highp vec2 texture_offset;



void main(void) {
    highp vec4 clr = varColor;
    highp float smoothed = (
        unpack_depth(texture2D(texture_0,vec2(varTexCoord_0.x               ,varTexCoord_0.y-texture_offset.y))) +
        unpack_depth(texture2D(texture_0,vec2(varTexCoord_0.x+texture_offset.x,varTexCoord_0.y                ))) +
        unpack_depth(texture2D(texture_0,vec2(varTexCoord_0.x               ,varTexCoord_0.y+texture_offset.y))) +
        unpack_depth(texture2D(texture_0,vec2(varTexCoord_0.x-texture_offset.x,varTexCoord_0.y                )))
    ) / 4.0;
    
    highp float center = unpack_depth(texture2D(texture_1,vec2(varTexCoord_0)));
    highp float val = (smoothed * 2.0 - center);
    
    /// dempth
    val -= val * 0.025;
    
    clr = pack_depth(val);
    
    if (mouse_pos.x > 0.0) {
        float dist = distance(mouse_pos,varTexCoord_0);
        if ( dist < texture_offset.x*2.0 ) {
            if ( dist < texture_offset.x*1.0 ) {
                clr = pack_depth(val-1.0);
            } else {
                clr = pack_depth( val + dist / texture_offset.x*2.0 );
            }
        }
    }
    
    gl_FragColor = clr;
}