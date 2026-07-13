#version 330 core

in vec3 v_normal;
in vec2 v_uv;
in vec4 v_color;

uniform sampler2D uTexture;
/* chrome control */
uniform int   u_chromeMode;
uniform float u_wave1;
uniform float u_wave2;
uniform vec3  u_chromeL;
uniform vec2  BlendMeshTexCoord;

out vec4 FragColor;

vec2 ComputeChrome(vec3 normal)
{
    vec2 uv;

    if (u_chromeMode == 1)
    {
        uv.x = normal.z * 0.5 + u_wave1;
        uv.y = normal.y * 0.5 + u_wave1 * 2.0;
    }
    else if (u_chromeMode == 2)
    {
        uv.x = (normal.z + normal.x) * 0.8 + u_wave2 * 2.0;
        uv.y = (normal.y + normal.x) * 1.0 + u_wave2 * 3.0;
    }
    else if (u_chromeMode == 3)
    {
        float d = dot(normal, u_chromeL);
        uv.x = d;
        uv.y = 1.0 - d;
    }
    else if (u_chromeMode == 4)
    {
        float d = dot(normal, u_chromeL);
		
        uv.y = (1.0 - d) - (normal.z * 0.5 + u_wave1 * 3.0);
        uv.x = d + (normal.y * 0.5 + u_chromeL.y * 3.0);
    }
    else if (u_chromeMode == 5)
    {
        float d = dot(normal, u_chromeL);
        uv.x = d + (normal.y * 3.0 + u_chromeL.y * 5.0);
        uv.y = 1.0 - d - (normal.z * 2.5 + u_wave1);
    }
    else if (u_chromeMode == 6)
    {
        uv.x = (normal.z + normal.x) * 0.8 + u_wave2 * 2.0;
        uv.y = uv.x;
    }
    else if (u_chromeMode == 7)
    {
        uv.x = (normal.z + normal.x) * 0.8 + u_wave1;
        uv.y = uv.x;
    }
    else if (u_chromeMode == 8)
    {
        uv.x = normal.x;
        uv.y = normal.y;
    }
    else if (u_chromeMode == 9)
    {
        uv.x = (normal.z + normal.x) * 0.8 + u_wave1 * 2.0;
        uv.y = (normal.y + normal.x) * 1.0 + u_wave1 * 3.0;
    }
    else if (u_chromeMode == 10)
    {
        uv.x = normal.x;
        uv.y = normal.y;
    }
    else
    {
        uv.x = normal.z * 0.5 + 0.2;
        uv.y = normal.y * 0.5 + 0.5;
    }

    return uv;
}

void main()
{
    vec2 uv = v_uv;

    if (u_chromeMode != 0)
    {
        uv = ComputeChrome(normalize(v_normal));
    }
	
	uv += BlendMeshTexCoord;

    vec4 tex = texture(uTexture, uv);
	
	vec4 vLightColor = v_color;
	
    float maxIntensity = 1.0;
    vLightColor.rgb = min(vLightColor.rgb, vec3(maxIntensity));
	
    FragColor = tex * vLightColor;
}