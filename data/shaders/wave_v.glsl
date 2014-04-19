attribute vec3 vPosition;
attribute vec2 vTexCoord;
attribute vec4 vColor;
uniform mat4 mProjection;
uniform mat4 mModelView;
varying vec2 varTexCoord_0;
varying vec4 varColor;
void main(void) {
 gl_Position = mProjection * mModelView * vec4(vPosition,1.0);
 varTexCoord_0 = vTexCoord;
 varColor = vColor;
}

