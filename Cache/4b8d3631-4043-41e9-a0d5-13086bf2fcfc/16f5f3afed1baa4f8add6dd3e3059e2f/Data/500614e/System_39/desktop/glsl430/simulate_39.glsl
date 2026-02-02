#version 430
//#include <required.glsl> // [HACK 4/6/2023] See SCC shader_merger.cpp
//SG_REFLECTION_BEGIN(200)
//attribute vec4 position 0
//attribute vec2 texture0 3
//attribute vec2 texture1 4
//attribute vec3 normal 1
//attribute vec4 tangent 2
//output vec4 sc_FragData0 0
//output vec4 sc_FragData1 1
//output vec4 sc_FragData2 2
//output vec4 sc_FragData3 3
//sampler sampler renderTarget0SmpSC 0:22
//sampler sampler renderTarget1SmpSC 0:23
//sampler sampler renderTarget2SmpSC 0:24
//sampler sampler renderTarget3SmpSC 0:25
//texture texture2D renderTarget0 0:1:0:22
//texture texture2D renderTarget1 0:2:0:23
//texture texture2D renderTarget2 0:3:0:24
//texture texture2D renderTarget3 0:4:0:25
//texture texture2DArray renderTarget0ArrSC 0:36:0:22
//texture texture2DArray renderTarget1ArrSC 0:37:0:23
//texture texture2DArray renderTarget2ArrSC 0:38:0:24
//texture texture2DArray renderTarget3ArrSC 0:39:0:25
//spec_const bool renderTarget0HasSwappedViews 0 0
//spec_const bool renderTarget1HasSwappedViews 1 0
//spec_const bool renderTarget2HasSwappedViews 2 0
//spec_const bool renderTarget3HasSwappedViews 3 0
//spec_const int renderTarget0Layout 4 0
//spec_const int renderTarget1Layout 5 0
//spec_const int renderTarget2Layout 6 0
//spec_const int renderTarget3Layout 7 0
//spec_const int sc_ShaderCacheConstant 8 0
//spec_const int sc_StereoRenderingMode 9 0
//spec_const int sc_StereoRendering_IsClipDistanceEnabled 10 0
//spec_const int sc_StereoViewID 11 0
//SG_REFLECTION_END
#define SC_ENABLE_INSTANCED_RENDERING
#define sc_StereoRendering_Disabled 0
#define sc_StereoRendering_InstancedClipped 1
#define sc_StereoRendering_Multiview 2
#ifdef VERTEX_SHADER
#define scOutPos(clipPosition) gl_Position=clipPosition
#define MAIN main
#endif
#ifdef SC_ENABLE_INSTANCED_RENDERING
#ifndef sc_EnableInstancing
#define sc_EnableInstancing 1
#endif
#endif
#define mod(x,y) (x-y*floor((x+1e-6)/y))
#if __VERSION__<300
#define isinf(x) (x!=0.0&&x*2.0==x ? true : false)
#define isnan(x) (x>0.0||x<0.0||x==0.0 ? false : true)
#define inverse(M) M
#endif
#ifdef sc_EnableStereoClipDistance
#if defined(GL_APPLE_clip_distance)
#extension GL_APPLE_clip_distance : require
#elif defined(GL_EXT_clip_cull_distance)
#extension GL_EXT_clip_cull_distance : require
#else
#error Clip distance is requested but not supported by this device.
#endif
#endif
#ifdef sc_EnableMultiviewStereoRendering
#define sc_StereoRenderingMode sc_StereoRendering_Multiview
#define sc_NumStereoViews 2
#extension GL_OVR_multiview2 : require
#ifdef VERTEX_SHADER
#ifdef sc_EnableInstancingFallback
#define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
#else
#define sc_GlobalInstanceID gl_InstanceID
#endif
#define sc_LocalInstanceID sc_GlobalInstanceID
#define sc_StereoViewID int(gl_ViewID_OVR)
#endif
#elif defined(sc_EnableInstancedClippedStereoRendering)
#ifndef sc_EnableInstancing
#error Instanced-clipped stereo rendering requires enabled instancing.
#endif
#ifndef sc_EnableStereoClipDistance
#define sc_StereoRendering_IsClipDistanceEnabled 0
#else
#define sc_StereoRendering_IsClipDistanceEnabled 1
#endif
#define sc_StereoRenderingMode sc_StereoRendering_InstancedClipped
#define sc_NumStereoClipPlanes 1
#define sc_NumStereoViews 2
#ifdef VERTEX_SHADER
#ifdef sc_EnableInstancingFallback
#define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
#else
#define sc_GlobalInstanceID gl_InstanceID
#endif
#define sc_LocalInstanceID (sc_GlobalInstanceID/2)
#define sc_StereoViewID (sc_GlobalInstanceID%2)
#endif
#else
#define sc_StereoRenderingMode sc_StereoRendering_Disabled
#endif
#if defined(sc_EnableInstancing)&&defined(VERTEX_SHADER)
#ifdef GL_ARB_draw_instanced
#extension GL_ARB_draw_instanced : require
#define gl_InstanceID gl_InstanceIDARB
#endif
#ifdef GL_EXT_draw_instanced
#extension GL_EXT_draw_instanced : require
#define gl_InstanceID gl_InstanceIDEXT
#endif
#ifndef sc_InstanceID
#define sc_InstanceID gl_InstanceID
#endif
#ifndef sc_GlobalInstanceID
#ifdef sc_EnableInstancingFallback
#define sc_GlobalInstanceID (sc_FallbackInstanceID)
#define sc_LocalInstanceID (sc_FallbackInstanceID)
#else
#define sc_GlobalInstanceID gl_InstanceID
#define sc_LocalInstanceID gl_InstanceID
#endif
#endif
#endif
#ifndef GL_ES
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable
#define precision
#define lowp
#define mediump
#define highp
#define sc_FragmentPrecision
#endif
#ifdef GL_ES
#ifdef sc_FramebufferFetch
#if defined(GL_EXT_shader_framebuffer_fetch)
#extension GL_EXT_shader_framebuffer_fetch : require
#elif defined(GL_ARM_shader_framebuffer_fetch)
#extension GL_ARM_shader_framebuffer_fetch : require
#else
#error Framebuffer fetch is requested but not supported by this device.
#endif
#endif
#ifdef GL_FRAGMENT_PRECISION_HIGH
#define sc_FragmentPrecision highp
#else
#define sc_FragmentPrecision mediump
#endif
#ifdef FRAGMENT_SHADER
precision highp int;
precision highp float;
#endif
#endif
#ifdef VERTEX_SHADER
#ifdef sc_EnableMultiviewStereoRendering
layout(num_views=sc_NumStereoViews) in;
#endif
#endif
#define SC_INT_FALLBACK_FLOAT int
#define SC_INTERPOLATION_FLAT flat
#define SC_INTERPOLATION_CENTROID centroid
#ifndef sc_NumStereoViews
#define sc_NumStereoViews 1
#endif
#ifndef sc_TextureRenderingLayout_Regular
#define sc_TextureRenderingLayout_Regular 0
#define sc_TextureRenderingLayout_StereoInstancedClipped 1
#define sc_TextureRenderingLayout_StereoMultiview 2
#endif
#if defined VERTEX_SHADER
struct ssParticle
{
vec3 Position;
vec3 Velocity;
vec4 Color;
float Size;
float Age;
float Life;
float Mass;
mat3 Matrix;
bool Dead;
vec4 Quaternion;
float SpawnIndex;
float SpawnIndexRemainder;
float NextBurstTime;
float SpawnOffset;
float Seed;
vec2 Seed2000;
float TimeShift;
int Index1D;
int Index1DPerCopy;
float Index1DPerCopyF;
int StateID;
float Coord1D;
float Ratio1D;
float Ratio1DPerCopy;
ivec2 Index2D;
vec2 Coord2D;
vec2 Ratio2D;
vec3 Force;
bool Spawned;
float CopyId;
float SpawnAmount;
float BurstAmount;
float BurstPeriod;
};
struct ssGlobals
{
float gTimeElapsed;
float gTimeDelta;
float gTimeElapsedShifted;
float gComponentTime;
};
#ifndef sc_StereoRenderingMode
#define sc_StereoRenderingMode 0
#endif
#ifndef sc_StereoViewID
#define sc_StereoViewID 0
#endif
#ifndef sc_StereoRendering_IsClipDistanceEnabled
#define sc_StereoRendering_IsClipDistanceEnabled 0
#endif
#ifndef sc_NumStereoViews
#define sc_NumStereoViews 1
#endif
#ifndef sc_ShaderCacheConstant
#define sc_ShaderCacheConstant 0
#endif
#ifndef renderTarget0HasSwappedViews
#define renderTarget0HasSwappedViews 0
#elif renderTarget0HasSwappedViews==1
#undef renderTarget0HasSwappedViews
#define renderTarget0HasSwappedViews 1
#endif
#ifndef renderTarget0Layout
#define renderTarget0Layout 0
#endif
#ifndef renderTarget1HasSwappedViews
#define renderTarget1HasSwappedViews 0
#elif renderTarget1HasSwappedViews==1
#undef renderTarget1HasSwappedViews
#define renderTarget1HasSwappedViews 1
#endif
#ifndef renderTarget1Layout
#define renderTarget1Layout 0
#endif
#ifndef renderTarget2HasSwappedViews
#define renderTarget2HasSwappedViews 0
#elif renderTarget2HasSwappedViews==1
#undef renderTarget2HasSwappedViews
#define renderTarget2HasSwappedViews 1
#endif
#ifndef renderTarget2Layout
#define renderTarget2Layout 0
#endif
#ifndef renderTarget3HasSwappedViews
#define renderTarget3HasSwappedViews 0
#elif renderTarget3HasSwappedViews==1
#undef renderTarget3HasSwappedViews
#define renderTarget3HasSwappedViews 1
#endif
#ifndef renderTarget3Layout
#define renderTarget3Layout 0
#endif
uniform int sc_FallbackInstanceID;
uniform vec4 sc_StereoClipPlanes[sc_NumStereoViews];
uniform vec4 sc_UniformConstants;
uniform int overrideTimeEnabled;
uniform float overrideTimeElapsed[32];
uniform vec4 sc_Time;
uniform int vfxOffsetInstancesRead;
uniform int vfxTargetWidth;
uniform vec2 vfxTargetSizeRead;
uniform bool vfxBatchEnable[32];
uniform float Port_SpawnRate_N013;
uniform vec3 vfxLocalAabbMin;
uniform vec3 vfxLocalAabbMax;
uniform float Port_Import_N036;
uniform vec3 Port_Import_N037;
uniform vec3 Port_Import_N038;
uniform float Port_Import_N041;
uniform float Port_Import_N046;
uniform float Port_Import_N049;
uniform float Port_Import_N050;
uniform float Port_Import_N132;
uniform float Port_Import_N133;
uniform float Port_Import_N053;
uniform vec3 Port_Import_N054;
uniform vec4 Port_Import_N117;
uniform vec4 Port_Import_N118;
uniform float Port_Min_N119;
uniform float Port_Max_N119;
uniform float Port_Value_N014;
uniform mat4 vfxModelMatrix[32];
uniform float Port_Import_N004;
uniform float Port_Import_N017;
uniform float Port_Import_N185;
uniform float Port_Import_N188;
uniform float overrideTimeDelta;
uniform bool vfxEmitParticle[32];
uniform float Port_Import_N267;
uniform float Port_Import_N268;
uniform float Port_Import_N269;
uniform vec2 vfxTargetSizeWrite;
uniform int vfxOffsetInstancesWrite;
uniform sampler2D renderTarget0;
uniform sampler2DArray renderTarget0ArrSC;
uniform sampler2D renderTarget1;
uniform sampler2DArray renderTarget1ArrSC;
uniform sampler2D renderTarget2;
uniform sampler2DArray renderTarget2ArrSC;
uniform sampler2D renderTarget3;
uniform sampler2DArray renderTarget3ArrSC;
out float varClipDistance;
flat out int varStereoViewID;
in vec4 position;
in vec2 texture0;
in vec2 texture1;
flat out int Interp_Particle_Index;
out vec2 Interp_Particle_Coord;
out vec3 Interp_Particle_Force;
out float Interp_Particle_SpawnIndex;
out float Interp_Particle_NextBurstTime;
out vec3 Interp_Particle_Position;
out vec3 Interp_Particle_Velocity;
out float Interp_Particle_Life;
out float Interp_Particle_Age;
out float Interp_Particle_Size;
out vec4 Interp_Particle_Color;
out vec4 Interp_Particle_Quaternion;
out float Interp_Particle_Mass;
out vec4 varPosAndMotion;
out vec4 varNormalAndMotion;
out vec4 varTangent;
out vec4 varTex01;
out vec4 varScreenPos;
out vec2 varScreenTexturePos;
out vec2 varShadowTex;
in vec3 normal;
in vec4 tangent;
out vec4 varColor;
ssParticle gParticle;
ssGlobals tempGlobals;
int sc_GetLocalInstanceIDInternal(int id)
{
#ifdef sc_LocalInstanceID
return sc_LocalInstanceID;
#else
return 0;
#endif
}
void ssCalculateParticleSeed(inout ssParticle Particle,int copyId)
{
float l9_0;
if (overrideTimeEnabled==1)
{
l9_0=overrideTimeElapsed[copyId];
}
else
{
l9_0=sc_Time.x;
}
Particle.Seed=(Particle.Ratio1D*0.97637898)+0.151235;
Particle.Seed+=(floor(((((l9_0-Particle.SpawnOffset)-0.0)+0.0)+7200.0)/3600.0)*4.32723);
Particle.Seed=fract(abs(Particle.Seed));
Particle.Seed2000=(vec2(ivec2(Particle.Index1D%400,Particle.Index1D/400))+vec2(1.0))/vec2(399.0);
}
int sc_GetStereoViewIndex()
{
int l9_0;
#if (sc_StereoRenderingMode==0)
{
l9_0=0;
}
#else
{
l9_0=sc_StereoViewID;
}
#endif
return l9_0;
}
int renderTarget0GetStereoViewIndex()
{
int l9_0;
#if (renderTarget0HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec3 sc_SamplingCoordsViewToGlobal(vec2 uv,int renderingLayout,int viewIndex)
{
vec3 l9_0;
if (renderingLayout==0)
{
l9_0=vec3(uv,0.0);
}
else
{
vec3 l9_1;
if (renderingLayout==1)
{
l9_1=vec3(uv.x,(uv.y*0.5)+(0.5-(float(viewIndex)*0.5)),0.0);
}
else
{
l9_1=vec3(uv,float(viewIndex));
}
l9_0=l9_1;
}
return l9_0;
}
vec4 renderTarget0SampleViewBias(vec2 uv,float bias)
{
vec4 l9_0;
#if (renderTarget0Layout==2)
{
l9_0=textureLod(renderTarget0ArrSC,sc_SamplingCoordsViewToGlobal(uv,renderTarget0Layout,renderTarget0GetStereoViewIndex()),0.0);
}
#else
{
l9_0=textureLod(renderTarget0,sc_SamplingCoordsViewToGlobal(uv,renderTarget0Layout,renderTarget0GetStereoViewIndex()).xy,0.0);
}
#endif
return l9_0;
}
int renderTarget1GetStereoViewIndex()
{
int l9_0;
#if (renderTarget1HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec4 renderTarget1SampleViewBias(vec2 uv,float bias)
{
vec4 l9_0;
#if (renderTarget1Layout==2)
{
l9_0=textureLod(renderTarget1ArrSC,sc_SamplingCoordsViewToGlobal(uv,renderTarget1Layout,renderTarget1GetStereoViewIndex()),0.0);
}
#else
{
l9_0=textureLod(renderTarget1,sc_SamplingCoordsViewToGlobal(uv,renderTarget1Layout,renderTarget1GetStereoViewIndex()).xy,0.0);
}
#endif
return l9_0;
}
int renderTarget2GetStereoViewIndex()
{
int l9_0;
#if (renderTarget2HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec4 renderTarget2SampleViewBias(vec2 uv,float bias)
{
vec4 l9_0;
#if (renderTarget2Layout==2)
{
l9_0=textureLod(renderTarget2ArrSC,sc_SamplingCoordsViewToGlobal(uv,renderTarget2Layout,renderTarget2GetStereoViewIndex()),0.0);
}
#else
{
l9_0=textureLod(renderTarget2,sc_SamplingCoordsViewToGlobal(uv,renderTarget2Layout,renderTarget2GetStereoViewIndex()).xy,0.0);
}
#endif
return l9_0;
}
int renderTarget3GetStereoViewIndex()
{
int l9_0;
#if (renderTarget3HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec4 renderTarget3SampleViewBias(vec2 uv,float bias)
{
vec4 l9_0;
#if (renderTarget3Layout==2)
{
l9_0=textureLod(renderTarget3ArrSC,sc_SamplingCoordsViewToGlobal(uv,renderTarget3Layout,renderTarget3GetStereoViewIndex()),0.0);
}
#else
{
l9_0=textureLod(renderTarget3,sc_SamplingCoordsViewToGlobal(uv,renderTarget3Layout,renderTarget3GetStereoViewIndex()).xy,0.0);
}
#endif
return l9_0;
}
float DecodeFloat32(vec4 rgba,bool Quantize)
{
if (Quantize)
{
rgba=floor((rgba*255.0)+vec4(0.5))/vec4(255.0);
}
return dot(rgba,vec4(1.0,0.0039215689,1.53787e-05,6.0308629e-08));
}
float DecodeFloat16(vec2 rg,bool Quantize)
{
if (Quantize)
{
rg=floor((rg*255.0)+vec2(0.5))/vec2(255.0);
}
return dot(rg,vec2(1.0,0.0039215689));
}
float DecodeFloat8(float r,bool Quantize)
{
if (Quantize)
{
r=floor((r*255.0)+0.5)/255.0;
}
return r;
}
bool ssDecodeParticle(int InstanceID)
{
gParticle=ssParticle(vec3(0.0),vec3(0.0),vec4(0.0),0.0,0.0,0.0,1.0,mat3(vec3(1.0,0.0,0.0),vec3(0.0,1.0,0.0),vec3(0.0,0.0,1.0)),gParticle.Dead,vec4(0.0,0.0,0.0,1.0),-1.0,-1.0,0.0,gParticle.SpawnOffset,gParticle.Seed,gParticle.Seed2000,gParticle.TimeShift,gParticle.Index1D,gParticle.Index1DPerCopy,gParticle.Index1DPerCopyF,gParticle.StateID,gParticle.Coord1D,gParticle.Ratio1D,gParticle.Ratio1DPerCopy,gParticle.Index2D,gParticle.Coord2D,gParticle.Ratio2D,gParticle.Force,gParticle.Spawned,float(InstanceID/2001),0.0,0.0,0.0);
int l9_0=InstanceID/2001;
int l9_1=InstanceID%2001;
float l9_2=float(l9_1);
ivec2 l9_3=ivec2(InstanceID%682,InstanceID/682);
float l9_4=float(InstanceID);
vec2 l9_5=vec2(l9_3);
float l9_6=l9_4/2000.0;
ssParticle l9_7=ssParticle(gParticle.Position,gParticle.Velocity,gParticle.Color,gParticle.Size,gParticle.Age,gParticle.Life,gParticle.Mass,gParticle.Matrix,false,gParticle.Quaternion,gParticle.SpawnIndex,gParticle.SpawnIndexRemainder,gParticle.NextBurstTime,l9_6*3600.0,0.0,gParticle.Seed2000,float(((InstanceID*((InstanceID*1471343)+101146501))+1559861749)&2147483647)*4.6566129e-10,InstanceID,l9_1,l9_2,(2001*(l9_0+1))-1,(l9_4+0.5)/2001.0,l9_6,l9_2/2000.0,l9_3,(l9_5+vec2(0.5))/vec2(682.0,3.0),l9_5/vec2(681.0,2.0),vec3(0.0),false,gParticle.CopyId,gParticle.SpawnAmount,gParticle.BurstAmount,gParticle.BurstPeriod);
ssCalculateParticleSeed(l9_7,l9_0);
gParticle=l9_7;
int l9_8=InstanceID;
int l9_9=(vfxOffsetInstancesRead+l9_8)*3;
int l9_10=l9_9/vfxTargetWidth;
vec2 l9_11=(vec2(ivec2(l9_9-(l9_10*vfxTargetWidth),l9_10))+vec2(0.5))/vec2(2048.0,vfxTargetSizeRead.y);
vec2 l9_12=l9_11+vec2(0.0);
vec4 l9_13=renderTarget0SampleViewBias(l9_12,0.0);
bool l9_14=dot(abs(l9_13),vec4(1.0))<9.9999997e-06;
bool l9_15;
if (!l9_14)
{
l9_15=!vfxBatchEnable[sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001];
}
else
{
l9_15=l9_14;
}
if (l9_15)
{
return false;
}
float l9_16=1000.0-(-1000.0);
float l9_17=0.99998999-0.0;
gParticle.Position.x=(-1000.0)+(((DecodeFloat32(l9_13,true)-0.0)*l9_16)/l9_17);
gParticle.Position.y=(-1000.0)+(((DecodeFloat32(renderTarget1SampleViewBias(l9_12,0.0),true)-0.0)*l9_16)/l9_17);
gParticle.Position.z=(-1000.0)+(((DecodeFloat32(renderTarget2SampleViewBias(l9_12,0.0),true)-0.0)*l9_16)/l9_17);
gParticle.Velocity.x=(-1000.0)+(((DecodeFloat32(renderTarget3SampleViewBias(l9_12,0.0),true)-0.0)*l9_16)/l9_17);
vec2 l9_18=l9_11+vec2(0.00048828125,0.0);
gParticle.Velocity.y=(-1000.0)+(((DecodeFloat32(renderTarget0SampleViewBias(l9_18,0.0),true)-0.0)*l9_16)/l9_17);
gParticle.Velocity.z=(-1000.0)+(((DecodeFloat32(renderTarget1SampleViewBias(l9_18,0.0),true)-0.0)*l9_16)/l9_17);
float l9_19=3600.0-0.0;
gParticle.Life=0.0+(((DecodeFloat32(renderTarget2SampleViewBias(l9_18,0.0),true)-0.0)*l9_19)/l9_17);
gParticle.Age=0.0+(((DecodeFloat32(renderTarget3SampleViewBias(l9_18,0.0),true)-0.0)*l9_19)/l9_17);
vec2 l9_20=l9_11+vec2(0.0009765625,0.0);
vec4 l9_21=renderTarget0SampleViewBias(l9_20,0.0);
vec4 l9_22=renderTarget1SampleViewBias(l9_20,0.0);
vec4 l9_23=renderTarget2SampleViewBias(l9_20,0.0);
vec4 l9_24=renderTarget3SampleViewBias(l9_20,0.0);
float l9_25=100.0-0.0;
gParticle.Size=0.0+(((DecodeFloat16(vec2(l9_21.xy),true)-0.0)*l9_25)/l9_17);
float l9_26=1.0-(-1.0);
gParticle.Quaternion.x=(-1.0)+(((DecodeFloat16(vec2(l9_21.zw),true)-0.0)*l9_26)/l9_17);
gParticle.Quaternion.y=(-1.0)+(((DecodeFloat16(vec2(l9_22.xy),true)-0.0)*l9_26)/l9_17);
gParticle.Quaternion.z=(-1.0)+(((DecodeFloat16(vec2(l9_22.zw),true)-0.0)*l9_26)/l9_17);
gParticle.Quaternion.w=(-1.0)+(((DecodeFloat16(vec2(l9_23.xy),true)-0.0)*l9_26)/l9_17);
gParticle.Mass=0.0+(((DecodeFloat16(vec2(l9_23.zw),true)-0.0)*l9_25)/l9_17);
float l9_27=1.00001-0.0;
float l9_28=1.0-0.0;
gParticle.Color.x=0.0+(((DecodeFloat8(l9_24.x,true)-0.0)*l9_27)/l9_28);
gParticle.Color.y=0.0+(((DecodeFloat8(l9_24.y,true)-0.0)*l9_27)/l9_28);
gParticle.Color.z=0.0+(((DecodeFloat8(l9_24.z,true)-0.0)*l9_27)/l9_28);
gParticle.Color.w=0.0+(((DecodeFloat8(l9_24.w,true)-0.0)*l9_27)/l9_28);
vec4 l9_29=normalize(gParticle.Quaternion.yzwx);
float l9_30=l9_29.x;
float l9_31=l9_30*l9_30;
float l9_32=l9_29.y;
float l9_33=l9_32*l9_32;
float l9_34=l9_29.z;
float l9_35=l9_34*l9_34;
float l9_36=l9_30*l9_34;
float l9_37=l9_30*l9_32;
float l9_38=l9_32*l9_34;
float l9_39=l9_29.w;
float l9_40=l9_39*l9_30;
float l9_41=l9_39*l9_32;
float l9_42=l9_39*l9_34;
gParticle.Matrix=mat3(vec3(1.0-(2.0*(l9_33+l9_35)),2.0*(l9_37+l9_42),2.0*(l9_36-l9_41)),vec3(2.0*(l9_37-l9_42),1.0-(2.0*(l9_31+l9_35)),2.0*(l9_38+l9_40)),vec3(2.0*(l9_36+l9_41),2.0*(l9_38-l9_40),1.0-(2.0*(l9_31+l9_33))));
gParticle.Velocity=floor((gParticle.Velocity*2000.0)+vec3(0.5))*0.00050000002;
gParticle.Position=floor((gParticle.Position*2000.0)+vec3(0.5))*0.00050000002;
gParticle.Color=floor((gParticle.Color*2000.0)+vec4(0.5))*0.00050000002;
gParticle.Size=floor((gParticle.Size*2000.0)+0.5)*0.00050000002;
gParticle.Mass=floor((gParticle.Mass*2000.0)+0.5)*0.00050000002;
gParticle.Life=floor((gParticle.Life*2000.0)+0.5)*0.00050000002;
return true;
}
vec4 ssRandVec4(int seed)
{
return vec4(float(((seed*((seed*1471343)+101146501))+1559861749)&2147483647)*4.6566129e-10,float((((seed*1399)*((seed*2058408857)+101146501))+1559861749)&2147483647)*4.6566129e-10,float((((seed*7177)*((seed*1969894119)+101146501))+1559861749)&2147483647)*4.6566129e-10,float((((seed*18919)*((seed*2066534441)+101146501))+1559861749)&2147483647)*4.6566129e-10);
}
vec3 ssRandVec3(int seed)
{
return vec3(float(((seed*((seed*1471343)+101146501))+1559861749)&2147483647)*4.6566129e-10,float((((seed*1399)*((seed*2058408857)+101146501))+1559861749)&2147483647)*4.6566129e-10,float((((seed*7177)*((seed*1969894119)+101146501))+1559861749)&2147483647)*4.6566129e-10);
}
vec2 ssRandVec2(int seed)
{
return vec2(float(((seed*((seed*1471343)+101146501))+1559861749)&2147483647)*4.6566129e-10,float((((seed*1399)*((seed*2058408857)+101146501))+1559861749)&2147483647)*4.6566129e-10);
}
vec4 ssGetParticleRandom(int Dimension,bool UseTime,bool UseNodeID,bool UseParticleID,float NodeID,ssParticle Particle,float ExtraSeed,float Time)
{
vec4 l9_0;
if (UseTime)
{
vec4 l9_1=vec4(0.0);
l9_1.x=floor(fract(Time)*1000.0);
l9_0=l9_1;
}
else
{
l9_0=vec4(0.0);
}
vec4 l9_2;
if (UseParticleID)
{
vec4 l9_3=l9_0;
l9_3.y=float(Particle.Index1D^((Particle.Index1D*15299)+Particle.Index1D));
l9_2=l9_3;
}
else
{
l9_2=l9_0;
}
vec4 l9_4;
if (UseNodeID)
{
vec4 l9_5=l9_2;
l9_5.z=NodeID;
l9_4=l9_5;
}
else
{
l9_4=l9_2;
}
float l9_6=ExtraSeed;
int l9_7=(((int(l9_4.x)*15299)^(int(l9_4.y)*30133))^(int(l9_4.z)*17539))^(int(l9_6*1000.0)*12113);
vec4 l9_8;
if (Dimension==1)
{
vec4 l9_9=vec4(0.0);
l9_9.x=float(((l9_7*((l9_7*1471343)+101146501))+1559861749)&2147483647)*4.6566129e-10;
l9_8=l9_9;
}
else
{
vec4 l9_10;
if (Dimension==2)
{
vec2 l9_11=ssRandVec2(l9_7);
l9_10=vec4(l9_11.x,l9_11.y,vec4(0.0).z,vec4(0.0).w);
}
else
{
vec4 l9_12;
if (Dimension==3)
{
vec3 l9_13=ssRandVec3(l9_7);
l9_12=vec4(l9_13.x,l9_13.y,l9_13.z,vec4(0.0).w);
}
else
{
l9_12=ssRandVec4(l9_7);
}
l9_10=l9_12;
}
l9_8=l9_10;
}
return l9_8;
}
vec3 N42_system_getParticleRandomVec3(bool useParticleID,bool useNodeID,bool useTime,float extraSeed)
{
return ssGetParticleRandom(3,useTime,useNodeID,useParticleID,42.0,gParticle,extraSeed,tempGlobals.gTimeElapsed).xyz;
}
void sc_SetClipDistancePlatform(float dstClipDistance)
{
#if sc_StereoRenderingMode==sc_StereoRendering_InstancedClipped&&sc_StereoRendering_IsClipDistanceEnabled
gl_ClipDistance[0]=dstClipDistance;
#endif
}
void sc_SetClipDistance(float dstClipDistance)
{
#if (sc_StereoRendering_IsClipDistanceEnabled==1)
{
sc_SetClipDistancePlatform(dstClipDistance);
}
#else
{
varClipDistance=dstClipDistance;
}
#endif
}
void sc_SetClipDistance(vec4 clipPosition)
{
#if (sc_StereoRenderingMode==1)
{
sc_SetClipDistance(dot(clipPosition,sc_StereoClipPlanes[sc_StereoViewID]));
}
#endif
}
void sc_SetClipPosition(vec4 clipPosition)
{
#if (sc_ShaderCacheConstant!=0)
{
clipPosition.x+=(sc_UniformConstants.x*float(sc_ShaderCacheConstant));
}
#endif
#if (sc_StereoRenderingMode>0)
{
varStereoViewID=sc_StereoViewID;
}
#endif
sc_SetClipDistance(clipPosition);
gl_Position=clipPosition;
}
vec4 matrixToQuaternion(mat3 m)
{
float l9_0=m[0].x;
float l9_1=m[1].y;
float l9_2=m[2].z;
float l9_3=(l9_0-l9_1)-l9_2;
float l9_4=m[1].y;
float l9_5=m[0].x;
float l9_6=m[2].z;
float l9_7=(l9_4-l9_5)-l9_6;
float l9_8=m[2].z;
float l9_9=m[0].x;
float l9_10=m[1].y;
float l9_11=(l9_8-l9_9)-l9_10;
float l9_12=m[0].x;
float l9_13=m[1].y;
float l9_14=m[2].z;
float l9_15=(l9_12+l9_13)+l9_14;
float l9_16;
int l9_17;
if (l9_3>l9_15)
{
l9_17=1;
l9_16=l9_3;
}
else
{
l9_17=0;
l9_16=l9_15;
}
float l9_18;
int l9_19;
if (l9_7>l9_16)
{
l9_19=2;
l9_18=l9_7;
}
else
{
l9_19=l9_17;
l9_18=l9_16;
}
float l9_20;
int l9_21;
if (l9_11>l9_18)
{
l9_21=3;
l9_20=l9_11;
}
else
{
l9_21=l9_19;
l9_20=l9_18;
}
float l9_22=l9_20+1.0;
float l9_23=sqrt(l9_22)*0.5;
float l9_24=0.25/l9_23;
if (l9_21==0)
{
return vec4(l9_23,(m[1].z-m[2].y)*l9_24,(m[2].x-m[0].z)*l9_24,(m[0].y-m[1].x)*l9_24);
}
else
{
if (l9_21==1)
{
return vec4((m[1].z-m[2].y)*l9_24,l9_23,(m[0].y+m[1].x)*l9_24,(m[2].x+m[0].z)*l9_24);
}
else
{
if (l9_21==2)
{
return vec4((m[2].x-m[0].z)*l9_24,(m[0].y+m[1].x)*l9_24,l9_23,(m[1].z+m[2].y)*l9_24);
}
else
{
if (l9_21==3)
{
return vec4((m[0].y-m[1].x)*l9_24,(m[2].x+m[0].z)*l9_24,(m[1].z+m[2].y)*l9_24,l9_23);
}
else
{
return vec4(1.0,0.0,0.0,0.0);
}
}
}
}
}
void main()
{
int l9_0=sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID);
bool l9_1=ssDecodeParticle(l9_0);
int l9_2=(vfxOffsetInstancesRead+gParticle.StateID)*3;
int l9_3=l9_2/vfxTargetWidth;
vec2 l9_4=((vec2(ivec2(l9_2-(l9_3*vfxTargetWidth),l9_3))+vec2(0.5))/vec2(2048.0,vfxTargetSizeRead.y))+vec2(0.00048828125,0.0);
float l9_5=0.99998999-0.0;
gParticle.SpawnIndex=(-1.0)+(((DecodeFloat32(renderTarget0SampleViewBias(l9_4,0.0),true)-0.0)*(500000.0-(-1.0)))/l9_5);
gParticle.NextBurstTime=0.0+(((DecodeFloat16(renderTarget1SampleViewBias(l9_4,0.0).xy,true)-0.0)*(300.0-0.0))/l9_5);
int l9_6=sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001;
float l9_7=min(overrideTimeDelta,0.5);
float l9_8=gParticle.TimeShift;
float l9_9=(sc_Time.x-(l9_8*l9_7))-0.0;
if (vfxEmitParticle[sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001])
{
gParticle.SpawnAmount+=max(Port_SpawnRate_N013*l9_7,0.0);
if (sc_Time.x>=gParticle.NextBurstTime)
{
gParticle.NextBurstTime+=gParticle.BurstPeriod;
gParticle.SpawnAmount+=gParticle.BurstAmount;
}
gParticle.SpawnIndex+=gParticle.SpawnAmount;
gParticle.SpawnIndex=floor((gParticle.SpawnIndex*2000.0)+0.5)*0.00050000002;
if (gParticle.SpawnIndex>=2000.0)
{
gParticle.SpawnIndexRemainder=mod(gParticle.SpawnIndex,2000.0);
}
}
float l9_10=gParticle.Age;
bool l9_11=l9_10<=9.9999997e-05;
bool l9_12;
if (!l9_11)
{
l9_12=gParticle.Age>=(gParticle.Life-l9_7);
}
else
{
l9_12=l9_11;
}
float l9_13=gParticle.Index1DPerCopyF;
float l9_14=gParticle.SpawnIndex;
float l9_15=gParticle.Index1DPerCopyF;
float l9_16=gParticle.SpawnIndex;
float l9_17=gParticle.SpawnAmount;
float l9_18=gParticle.Index1DPerCopyF;
float l9_19=gParticle.SpawnIndexRemainder;
bool l9_20;
if (l9_12)
{
l9_20=((l9_13<=l9_14)&&(l9_15>=(l9_16-l9_17)))||(l9_18<=l9_19);
}
else
{
l9_20=l9_12;
}
if (l9_20)
{
ssGlobals l9_21=ssGlobals(sc_Time.x,l9_7,l9_9,overrideTimeElapsed[l9_6]);
float l9_22=max(Port_Import_N050,0.0099999998);
ssCalculateParticleSeed(gParticle,int(gParticle.CopyId));
float l9_24=floor(44.0);
gParticle.Position=(vec3(((floor(mod(gParticle.Index1DPerCopyF,l9_24))/44.0)*2.0)-1.0,((floor(gParticle.Index1DPerCopyF/l9_24)/44.0)*2.0)-1.0,0.0)*20.0)+vec3(1.0,1.0,0.0);
gParticle.Velocity=vec3(0.0);
gParticle.Color=vec4(1.0);
gParticle.Age=0.0;
gParticle.Life=16.0;
gParticle.Size=1.0;
gParticle.Mass=1.0;
gParticle.Matrix=mat3(vec3(1.0,0.0,0.0),vec3(0.0,1.0,0.0),vec3(0.0,0.0,1.0));
gParticle.Quaternion=vec4(0.0,0.0,0.0,1.0);
tempGlobals=l9_21;
vec3 l9_25=N42_system_getParticleRandomVec3(true,true,true,0.0);
vec3 l9_26=N42_system_getParticleRandomVec3(true,true,true,150.0);
float l9_27=1.0-clamp(Port_Import_N041,0.0,1.0);
float l9_28;
if (l9_27<=0.0)
{
l9_28=0.0;
}
else
{
l9_28=pow(l9_27,3.0);
}
vec3 l9_29=vec3(l9_28);
vec3 l9_30=mix(l9_29,vec3(1.0),l9_25);
float l9_31=l9_30.x;
float l9_32;
if (l9_31<=0.0)
{
l9_32=0.0;
}
else
{
l9_32=sqrt(l9_31);
}
float l9_33=l9_30.y;
float l9_34;
if (l9_33<=0.0)
{
l9_34=0.0;
}
else
{
l9_34=sqrt(l9_33);
}
float l9_35=l9_30.z;
float l9_36;
if (l9_35<=0.0)
{
l9_36=0.0;
}
else
{
l9_36=sqrt(l9_35);
}
vec3 l9_37=mix(vec3(-1.0),vec3(1.0),l9_26);
gParticle.Position=(((vec3(l9_32,l9_34,l9_36)*(l9_37/vec3(length(l9_37+vec3(9.9999997e-05)))))*Port_Import_N037)*Port_Import_N036)+Port_Import_N038;
tempGlobals=l9_21;
gParticle.Size=mix(Port_Import_N046*l9_22,Port_Import_N049*l9_22,ssGetParticleRandom(1,true,true,true,51.0,gParticle,20.0,tempGlobals.gTimeElapsed).x)/length(vfxLocalAabbMax-vfxLocalAabbMin);
gParticle.Mass=mix(Port_Import_N132,Port_Import_N133,ssGetParticleRandom(1,true,true,true,134.0,gParticle,0.0,sc_Time.x).x);
gParticle.Mass=max(9.9999997e-06,gParticle.Mass);
vec3 l9_38=gParticle.Position;
vec3 l9_39=Port_Import_N054-l9_38;
float l9_40=dot(l9_39,l9_39);
float l9_41;
if (l9_40>0.0)
{
l9_41=1.0/sqrt(l9_40);
}
else
{
l9_41=0.0;
}
gParticle.Force+=(vec3(Port_Import_N053)*(l9_39*l9_41));
gParticle.Color=mix(Port_Import_N117,Port_Import_N118,vec4(mix(Port_Min_N119,Port_Max_N119,ssGetParticleRandom(1,true,true,true,119.0,gParticle,0.0,sc_Time.x).x)));
gParticle.Life=Port_Value_N014;
gParticle.Life=clamp(gParticle.Life,0.1,3600.0);
gParticle.Velocity+=((gParticle.Force/vec3(gParticle.Mass))*0.033330001);
gParticle.Force=vec3(0.0);
gParticle.Position=(vfxModelMatrix[sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001]*vec4(gParticle.Position,1.0)).xyz;
int l9_42=sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001;
gParticle.Velocity=mat3(vfxModelMatrix[l9_42][0].xyz,vfxModelMatrix[l9_42][1].xyz,vfxModelMatrix[l9_42][2].xyz)*gParticle.Velocity;
int l9_43=sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001;
gParticle.Force=mat3(vfxModelMatrix[l9_43][0].xyz,vfxModelMatrix[l9_43][1].xyz,vfxModelMatrix[l9_43][2].xyz)*gParticle.Force;
gParticle.Size=max(length(vfxModelMatrix[sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001][0].xyz),max(length(vfxModelMatrix[sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001][1].xyz),length(vfxModelMatrix[sc_GetLocalInstanceIDInternal(sc_FallbackInstanceID)/2001][2].xyz)))*gParticle.Size;
gParticle.Spawned=true;
}
if (gParticle.SpawnIndexRemainder>(-1.0))
{
gParticle.SpawnIndex=gParticle.SpawnIndexRemainder;
}
if (gParticle.Index1D==gParticle.StateID)
{
gParticle.Dead=false;
}
if (gParticle.Dead)
{
sc_SetClipPosition(vec4(4334.0,4334.0,4334.0,0.0));
return;
}
ssGlobals l9_44=ssGlobals(sc_Time.x,l9_7,l9_9,overrideTimeElapsed[l9_6]);
tempGlobals=l9_44;
float l9_45=clamp(gParticle.Age/gParticle.Life,0.0,1.0);
vec4 l9_46=gParticle.Color;
l9_46.w=mix(Port_Import_N004,Port_Import_N017,clamp(l9_45/(Port_Import_N185/gParticle.Life),0.0,1.0)*clamp((1.0-l9_45)/(Port_Import_N188/gParticle.Life),0.0,1.0));
gParticle.Color=l9_46;
tempGlobals=l9_44;
vec3 l9_47=abs(gParticle.Velocity*gParticle.Mass)/vec3(tempGlobals.gTimeDelta);
gParticle.Force+=clamp((((((-gParticle.Velocity)*length(gParticle.Velocity))*Port_Import_N267)*Port_Import_N268)*Port_Import_N269)*0.5,-l9_47,l9_47);
gParticle.Quaternion=matrixToQuaternion(gParticle.Matrix);
gParticle.Age+=l9_7;
if (gParticle.Age>=gParticle.Life)
{
gParticle.Dead=true;
}
if (gParticle.Index1D==gParticle.StateID)
{
gParticle.Dead=false;
}
if (gParticle.Dead)
{
sc_SetClipPosition(vec4(4334.0,4334.0,4334.0,0.0));
return;
}
float l9_48;
if (abs(gParticle.Force.x)<0.0049999999)
{
l9_48=0.0;
}
else
{
l9_48=gParticle.Force.x;
}
gParticle.Force.x=l9_48;
float l9_49;
if (abs(gParticle.Force.y)<0.0049999999)
{
l9_49=0.0;
}
else
{
l9_49=gParticle.Force.y;
}
gParticle.Force.y=l9_49;
float l9_50;
if (abs(gParticle.Force.z)<0.0049999999)
{
l9_50=0.0;
}
else
{
l9_50=gParticle.Force.z;
}
gParticle.Force.z=l9_50;
gParticle.Mass=max(0.0049999999,gParticle.Mass);
if (l9_7!=0.0)
{
gParticle.Velocity+=((gParticle.Force/vec3(gParticle.Mass))*l9_7);
}
float l9_51;
if (abs(gParticle.Velocity.x)<0.0049999999)
{
l9_51=0.0;
}
else
{
l9_51=gParticle.Velocity.x;
}
gParticle.Velocity.x=l9_51;
float l9_52;
if (abs(gParticle.Velocity.y)<0.0049999999)
{
l9_52=0.0;
}
else
{
l9_52=gParticle.Velocity.y;
}
gParticle.Velocity.y=l9_52;
float l9_53;
if (abs(gParticle.Velocity.z)<0.0049999999)
{
l9_53=0.0;
}
else
{
l9_53=gParticle.Velocity.z;
}
gParticle.Velocity.z=l9_53;
gParticle.Position+=(gParticle.Velocity*l9_7);
vec2 l9_54=vec2(3.0,1.0)/vec2(2048.0,vfxTargetSizeWrite.y);
int l9_55=vfxOffsetInstancesWrite+l9_0;
float l9_56;
if (texture0.x<0.5)
{
l9_56=0.0;
}
else
{
l9_56=l9_54.x;
}
float l9_57;
if (texture0.y<0.5)
{
l9_57=0.0;
}
else
{
l9_57=l9_54.y;
}
sc_SetClipPosition(vec4(((vec2(l9_56,l9_57)+(vec2(float(l9_55%682),float(l9_55/682))*l9_54))*2.0)-vec2(1.0),1.0,1.0));
Interp_Particle_Index=l9_0;
Interp_Particle_Coord=texture0;
Interp_Particle_Force=gParticle.Force;
Interp_Particle_SpawnIndex=gParticle.SpawnIndex;
Interp_Particle_NextBurstTime=gParticle.NextBurstTime;
Interp_Particle_Position=gParticle.Position;
Interp_Particle_Velocity=gParticle.Velocity;
Interp_Particle_Life=gParticle.Life;
Interp_Particle_Age=gParticle.Age;
Interp_Particle_Size=gParticle.Size;
Interp_Particle_Color=gParticle.Color;
Interp_Particle_Quaternion=gParticle.Quaternion;
Interp_Particle_Mass=gParticle.Mass;
if (gParticle.Index1D==gParticle.StateID)
{
gParticle.Dead=false;
}
if (gParticle.Dead)
{
sc_SetClipPosition(vec4(4334.0,4334.0,4334.0,0.0));
return;
}
}
#elif defined FRAGMENT_SHADER // #if defined VERTEX_SHADER
#ifndef sc_FramebufferFetch
#define sc_FramebufferFetch 0
#elif sc_FramebufferFetch==1
#undef sc_FramebufferFetch
#define sc_FramebufferFetch 1
#endif
#ifndef sc_StereoRenderingMode
#define sc_StereoRenderingMode 0
#endif
#ifndef sc_StereoRendering_IsClipDistanceEnabled
#define sc_StereoRendering_IsClipDistanceEnabled 0
#endif
#ifndef sc_ShaderCacheConstant
#define sc_ShaderCacheConstant 0
#endif
#ifndef renderTarget0HasSwappedViews
#define renderTarget0HasSwappedViews 0
#elif renderTarget0HasSwappedViews==1
#undef renderTarget0HasSwappedViews
#define renderTarget0HasSwappedViews 1
#endif
#ifndef renderTarget0Layout
#define renderTarget0Layout 0
#endif
#ifndef renderTarget1HasSwappedViews
#define renderTarget1HasSwappedViews 0
#elif renderTarget1HasSwappedViews==1
#undef renderTarget1HasSwappedViews
#define renderTarget1HasSwappedViews 1
#endif
#ifndef renderTarget1Layout
#define renderTarget1Layout 0
#endif
#ifndef renderTarget2HasSwappedViews
#define renderTarget2HasSwappedViews 0
#elif renderTarget2HasSwappedViews==1
#undef renderTarget2HasSwappedViews
#define renderTarget2HasSwappedViews 1
#endif
#ifndef renderTarget2Layout
#define renderTarget2Layout 0
#endif
#ifndef renderTarget3HasSwappedViews
#define renderTarget3HasSwappedViews 0
#elif renderTarget3HasSwappedViews==1
#undef renderTarget3HasSwappedViews
#define renderTarget3HasSwappedViews 1
#endif
#ifndef renderTarget3Layout
#define renderTarget3Layout 0
#endif
uniform vec4 sc_UniformConstants;
flat in int varStereoViewID;
in float varClipDistance;
layout(location=0) out vec4 sc_FragData0;
layout(location=1) out vec4 sc_FragData1;
layout(location=2) out vec4 sc_FragData2;
layout(location=3) out vec4 sc_FragData3;
flat in int Interp_Particle_Index;
in vec3 Interp_Particle_Position;
in vec3 Interp_Particle_Velocity;
in float Interp_Particle_Life;
in float Interp_Particle_Age;
in float Interp_Particle_Size;
in vec4 Interp_Particle_Color;
in vec4 Interp_Particle_Quaternion;
in float Interp_Particle_Mass;
in float Interp_Particle_SpawnIndex;
in float Interp_Particle_NextBurstTime;
in vec2 Interp_Particle_Coord;
in vec4 varPosAndMotion;
in vec4 varNormalAndMotion;
in vec4 varTangent;
in vec4 varTex01;
in vec4 varScreenPos;
in vec2 varScreenTexturePos;
in vec2 varShadowTex;
in vec4 varColor;
in vec3 Interp_Particle_Force;
int sc_GetStereoViewIndex()
{
int l9_0;
#if (sc_StereoRenderingMode==0)
{
l9_0=0;
}
#else
{
l9_0=varStereoViewID;
}
#endif
return l9_0;
}
int renderTarget0GetStereoViewIndex()
{
int l9_0;
#if (renderTarget0HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec3 sc_SamplingCoordsViewToGlobal(vec2 uv,int renderingLayout,int viewIndex)
{
vec3 l9_0;
if (renderingLayout==0)
{
l9_0=vec3(uv,0.0);
}
else
{
vec3 l9_1;
if (renderingLayout==1)
{
l9_1=vec3(uv.x,(uv.y*0.5)+(0.5-(float(viewIndex)*0.5)),0.0);
}
else
{
l9_1=vec3(uv,float(viewIndex));
}
l9_0=l9_1;
}
return l9_0;
}
int renderTarget1GetStereoViewIndex()
{
int l9_0;
#if (renderTarget1HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
int renderTarget2GetStereoViewIndex()
{
int l9_0;
#if (renderTarget2HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
int renderTarget3GetStereoViewIndex()
{
int l9_0;
#if (renderTarget3HasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
vec4 ssEncodeFloat32(float Value,float Min,float Max,float RemapRange)
{
vec4 l9_0=fract(vec4(1.0,255.0,65025.0,16581375.0)*(0.0+(((clamp(Value,Min,Max)-Min)*(RemapRange-0.0))/(Max-Min))));
return l9_0-(l9_0.yzww*vec4(0.0039215689,0.0039215689,0.0039215689,0.0));
}
vec2 ssEncodeFloat16(float Value,float Min,float Max,float RemapRange)
{
vec4 l9_0=fract(vec4(1.0,255.0,65025.0,16581375.0)*(0.0+(((clamp(Value,Min,Max)-Min)*(RemapRange-0.0))/(Max-Min))));
return (l9_0-(l9_0.yzww*vec4(0.0039215689,0.0039215689,0.0039215689,0.0))).xy;
}
void main()
{
#if ((sc_StereoRenderingMode==1)&&(sc_StereoRendering_IsClipDistanceEnabled==0))
{
if (varClipDistance<0.0)
{
discard;
}
}
#endif
#if (renderTarget0Layout==2)
{
}
#else
{
}
#endif
#if (renderTarget1Layout==2)
{
}
#else
{
}
#endif
#if (renderTarget2Layout==2)
{
}
#else
{
}
#endif
#if (renderTarget3Layout==2)
{
}
#else
{
}
#endif
int l9_0=int(floor(Interp_Particle_Coord.x*3.0));
float l9_1;
float l9_2;
float l9_3;
float l9_4;
float l9_5;
float l9_6;
float l9_7;
float l9_8;
float l9_9;
float l9_10;
float l9_11;
float l9_12;
float l9_13;
float l9_14;
float l9_15;
float l9_16;
if (l9_0==0)
{
vec4 l9_17=ssEncodeFloat32(Interp_Particle_Position.x,-1000.0,1000.0,0.99998999);
vec4 l9_18=ssEncodeFloat32(Interp_Particle_Position.y,-1000.0,1000.0,0.99998999);
vec4 l9_19=ssEncodeFloat32(Interp_Particle_Position.z,-1000.0,1000.0,0.99998999);
vec4 l9_20=ssEncodeFloat32(Interp_Particle_Velocity.x,-1000.0,1000.0,0.99998999);
l9_16=l9_20.w;
l9_15=l9_20.z;
l9_14=l9_20.y;
l9_13=l9_20.x;
l9_12=l9_19.w;
l9_11=l9_19.z;
l9_10=l9_19.y;
l9_9=l9_19.x;
l9_8=l9_18.w;
l9_7=l9_18.z;
l9_6=l9_18.y;
l9_5=l9_18.x;
l9_4=l9_17.w;
l9_3=l9_17.z;
l9_2=l9_17.y;
l9_1=l9_17.x;
}
else
{
float l9_21;
float l9_22;
float l9_23;
float l9_24;
float l9_25;
float l9_26;
float l9_27;
float l9_28;
float l9_29;
float l9_30;
float l9_31;
float l9_32;
float l9_33;
float l9_34;
float l9_35;
float l9_36;
if (l9_0==1)
{
vec4 l9_37=ssEncodeFloat32(Interp_Particle_Velocity.y,-1000.0,1000.0,0.99998999);
vec4 l9_38=ssEncodeFloat32(Interp_Particle_Velocity.z,-1000.0,1000.0,0.99998999);
vec4 l9_39=ssEncodeFloat32(Interp_Particle_Life,0.0,3600.0,0.99998999);
vec4 l9_40=ssEncodeFloat32(Interp_Particle_Age,0.0,3600.0,0.99998999);
l9_36=l9_40.w;
l9_35=l9_40.z;
l9_34=l9_40.y;
l9_33=l9_40.x;
l9_32=l9_39.w;
l9_31=l9_39.z;
l9_30=l9_39.y;
l9_29=l9_39.x;
l9_28=l9_38.w;
l9_27=l9_38.z;
l9_26=l9_38.y;
l9_25=l9_38.x;
l9_24=l9_37.w;
l9_23=l9_37.z;
l9_22=l9_37.y;
l9_21=l9_37.x;
}
else
{
float l9_41;
float l9_42;
float l9_43;
float l9_44;
float l9_45;
float l9_46;
float l9_47;
float l9_48;
float l9_49;
float l9_50;
float l9_51;
float l9_52;
float l9_53;
float l9_54;
float l9_55;
float l9_56;
if (l9_0==2)
{
vec2 l9_57=ssEncodeFloat16(Interp_Particle_Size,0.0,100.0,0.99998999);
vec2 l9_58=ssEncodeFloat16(Interp_Particle_Quaternion.x,-1.0,1.0,0.99998999);
vec2 l9_59=ssEncodeFloat16(Interp_Particle_Quaternion.y,-1.0,1.0,0.99998999);
vec2 l9_60=ssEncodeFloat16(Interp_Particle_Quaternion.z,-1.0,1.0,0.99998999);
vec2 l9_61=ssEncodeFloat16(Interp_Particle_Quaternion.w,-1.0,1.0,0.99998999);
vec2 l9_62=ssEncodeFloat16(Interp_Particle_Mass,0.0,100.0,0.99998999);
float l9_63=1.0-0.0;
float l9_64=1.00001-0.0;
l9_56=0.0+(((clamp(Interp_Particle_Color.w,0.0,1.00001)-0.0)*l9_63)/l9_64);
l9_55=0.0+(((clamp(Interp_Particle_Color.z,0.0,1.00001)-0.0)*l9_63)/l9_64);
l9_54=0.0+(((clamp(Interp_Particle_Color.y,0.0,1.00001)-0.0)*l9_63)/l9_64);
l9_53=0.0+(((clamp(Interp_Particle_Color.x,0.0,1.00001)-0.0)*l9_63)/l9_64);
l9_52=l9_62.y;
l9_51=l9_62.x;
l9_50=l9_61.y;
l9_49=l9_61.x;
l9_48=l9_60.y;
l9_47=l9_60.x;
l9_46=l9_59.y;
l9_45=l9_59.x;
l9_44=l9_58.y;
l9_43=l9_58.x;
l9_42=l9_57.y;
l9_41=l9_57.x;
}
else
{
l9_56=0.0;
l9_55=0.0;
l9_54=0.0;
l9_53=0.0;
l9_52=0.0;
l9_51=0.0;
l9_50=0.0;
l9_49=0.0;
l9_48=0.0;
l9_47=0.0;
l9_46=0.0;
l9_45=0.0;
l9_44=0.0;
l9_43=0.0;
l9_42=0.0;
l9_41=0.0;
}
l9_36=l9_56;
l9_35=l9_55;
l9_34=l9_54;
l9_33=l9_53;
l9_32=l9_52;
l9_31=l9_51;
l9_30=l9_50;
l9_29=l9_49;
l9_28=l9_48;
l9_27=l9_47;
l9_26=l9_46;
l9_25=l9_45;
l9_24=l9_44;
l9_23=l9_43;
l9_22=l9_42;
l9_21=l9_41;
}
l9_16=l9_36;
l9_15=l9_35;
l9_14=l9_34;
l9_13=l9_33;
l9_12=l9_32;
l9_11=l9_31;
l9_10=l9_30;
l9_9=l9_29;
l9_8=l9_28;
l9_7=l9_27;
l9_6=l9_26;
l9_5=l9_25;
l9_4=l9_24;
l9_3=l9_23;
l9_2=l9_22;
l9_1=l9_21;
}
vec4 l9_65=vec4(l9_1,l9_2,l9_3,l9_4);
vec4 l9_66=vec4(l9_5,l9_6,l9_7,l9_8);
vec4 l9_67=vec4(l9_9,l9_10,l9_11,l9_12);
vec4 l9_68=vec4(l9_13,l9_14,l9_15,l9_16);
vec4 l9_69;
vec4 l9_70;
if (Interp_Particle_Index==((2001*((Interp_Particle_Index/2001)+1))-1))
{
vec2 l9_71=ssEncodeFloat16(Interp_Particle_NextBurstTime,0.0,300.0,0.99998999);
l9_70=vec4(l9_71.x,l9_71.y,l9_66.z,l9_66.w);
l9_69=ssEncodeFloat32(Interp_Particle_SpawnIndex,-1.0,500000.0,0.99998999);
}
else
{
l9_70=l9_66;
l9_69=l9_65;
}
vec4 l9_72;
if (dot(((l9_69+l9_70)+l9_67)+l9_68,vec4(0.23454))==0.34231836)
{
l9_72=l9_69+vec4(1e-06);
}
else
{
l9_72=l9_69;
}
vec4 l9_73;
#if (sc_ShaderCacheConstant!=0)
{
vec4 l9_74=l9_72;
l9_74.x=l9_72.x+(sc_UniformConstants.x*float(sc_ShaderCacheConstant));
l9_73=l9_74;
}
#else
{
l9_73=l9_72;
}
#endif
sc_FragData0=l9_73;
sc_FragData1=l9_70;
sc_FragData2=l9_67;
sc_FragData3=l9_68;
}
#endif // #elif defined FRAGMENT_SHADER // #if defined VERTEX_SHADER
