// Panel blur fragment shader (direction controlled by u_blur_step)
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_blur_step;

void main() {
  vec4 col = texture2D(gm_BaseTexture, v_vTexcoord) * 0.2270270270;
  col += texture2D(gm_BaseTexture, v_vTexcoord + (u_blur_step * 1.3846153846)) * 0.3162162162;
  col += texture2D(gm_BaseTexture, v_vTexcoord - (u_blur_step * 1.3846153846)) * 0.3162162162;
  col += texture2D(gm_BaseTexture, v_vTexcoord + (u_blur_step * 3.2307692308)) * 0.0702702703;
  col += texture2D(gm_BaseTexture, v_vTexcoord - (u_blur_step * 3.2307692308)) * 0.0702702703;
  gl_FragColor = vec4(v_vColour.rgb * col.rgb, v_vColour.a);
}
