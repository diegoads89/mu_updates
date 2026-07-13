#version 330
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aNorm;
layout(location = 2) in vec2 aTex;
layout(location = 3) in uint aBone;

uniform mat4 uProj;
uniform mat4 uView;
uniform vec4 uBones[600];
uniform vec4 BodyLight;
uniform vec4 LightPosition;
uniform bool u_enableLight;
uniform bool u_shadowMode;
uniform vec3 BodyOrigin;

out vec4 v_color;
out vec3 v_normal;
out vec2 v_uv;

vec4 TransformPosition(uint boneIdx, vec3 p)
{
    int offset = int(boneIdx);
    vec4 r;
    r.x = dot(uBones[offset + 0], vec4(p, 1.0));
    r.y = dot(uBones[offset + 1], vec4(p, 1.0));
    r.z = dot(uBones[offset + 2], vec4(p, 1.0));
    r.w = 1.0;
    return r;
}

vec3 TransformNormal(uint boneIdx, vec3 n)
{
    int offset = int(boneIdx);
    vec3 r;
    r.x = dot(uBones[offset + 0].xyz, n);
    r.y = dot(uBones[offset + 1].xyz, n);
    r.z = dot(uBones[offset + 2].xyz, n);
    return normalize(r);
}

void main(){

    vec4 worldPos = TransformPosition(aBone, aPos);
	
	if (u_shadowMode)
    {
        vec3 p = worldPos.xyz - BodyOrigin;
        p.x += p.z * (p.x + 2000.0) / (p.z - 4000.0);
        p.z = 0.5;
        worldPos.xyz = p + BodyOrigin;
    }	
	gl_Position = uProj * uView * worldPos;
	
	v_normal = TransformNormal(aBone, aNorm);
	
	if (u_enableLight)
    {
        float lum = max(dot(v_normal, LightPosition.xyz) * 0.8 + 0.4, 0.2);
        v_color = BodyLight * vec4(lum, lum, lum, LightPosition.w);
    }
    else
    {
        v_color = BodyLight;
    }

    v_uv = aTex;
}