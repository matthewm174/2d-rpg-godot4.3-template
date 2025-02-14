shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D mask_texture; // Mask texture for foggy/blurred edges
uniform vec2 center = vec2(0.5, 0.5);  // Center of effect (normalized)
uniform float radius = 0.1;            // Base effect size
uniform float feather = 0.3;           // Soft fade at edges
uniform float distortion_strength = 0.03; // Controls how much the edges morph
uniform float blur_radius : hint_range(0.0, 1.0) = 1; // Blur radius for the edges
uniform float time_speed = 1.0;  // Speed of morphing

void vertex() {
    float dist = length(VERTEX.xy);

    float noise = sin(VERTEX.x * 10.0 + TIME * time_speed) * 
                  cos(VERTEX.y * 15.0 - TIME * time_speed);


    VERTEX.xy += normalize(VERTEX.xy) * noise * distortion_strength * smoothstep(radius, radius + feather, dist);
}


void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 screen_color = texture(screen_texture, uv);
    vec4 texture_color = texture(TEXTURE, UV);
    float dist = length(uv - center);
    float alpha = smoothstep(radius + feather, radius, dist);

    vec2 mask_uv = (uv - center) * 2.0 + 0.5;
    float mask_value = texture(mask_texture, mask_uv).r;
    float blur = smoothstep(0.0, blur_radius, mask_value);

    vec4 whispy_effect = vec4(0.1, 0.1, 0.0, 1.0 - alpha+0.2);

    COLOR = mix(screen_color, screen_color + whispy_effect, alpha * blur);
    COLOR.a = texture_color.a * alpha * blur;
}