#ifdef GL_ES
precision highp float;
#else
#define highp
#define lowp
#endif

uniform sampler2D texture_0;
uniform sampler2D texture_1;
varying vec2 varTexCoord_0;
varying vec4 varColor;
uniform highp vec2 texture_offset;

float unpack_depth(const in vec4 rgba)
{
    return dot( rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/160581375.0) ) * 2.0 - 1.0;
}

void main(void) {
    vec4 clr = varColor;
    float height_dX = unpack_depth(texture2D(texture_0,varTexCoord_0+vec2(-texture_offset.x,0.0))) -
                    unpack_depth(texture2D(texture_0,varTexCoord_0+vec2(texture_offset.x,0.0)));
    float height_dY = unpack_depth(texture2D(texture_0,varTexCoord_0+vec2(0.0,-texture_offset.y))) -
                    unpack_depth(texture2D(texture_0,varTexCoord_0+vec2(0.0,texture_offset.y)));
    
    vec2 offset = vec2(height_dX,height_dY);
    vec3 pixel = texture2D(texture_1, varTexCoord_0 + offset).rgb;
    
    /// glow
    //pixel += length(offset)*0.1;
    
    pixel = vec3(unpack_depth(texture2D(texture_0,varTexCoord_0)))*0.5+0.5;
    
                        
    clr *= vec4(pixel,1.0);
    
    gl_FragColor = clr;
}