/*
 *  application.cpp
 *  YinYang
 *
 *  Created by Андрей Куницын on 04.09.11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "application.h"
#include <sb_chipmunk_bind.h>
#include <sb_accelerometer.h>
#include <ghl_system.h>
#include <sb_lua.h>
#include <luabind/sb_luabind.h>
#include <sb_lua_context.h>

#include <ghl_render.h>
#include <ghl_render_target.h>
#include <ghl_texture.h>
#include <ghl_shader.h>
#include <sb_shader.h>

#include <sb_graphics.h>
#include <sb_resources.h>
#include <sb_texture.h>

static GHL::UInt32 width = 512;
static GHL::UInt32 height = 512;

static GHL::RenderTarget* targets[3] = {0,0,0};
size_t frames_drawed = 0;
size_t crnt_target = 0;
size_t crnt_src = 0;

static Sandbox::ShaderPtr shader;
static Sandbox::ShaderPtr vshader;

static Sandbox::TexturePtr texture;

const float scale = 4.0;

Application::Application() {
	SetResourcesBasePath("data");
	SetLuaBasePath("scripts");
	SetClearColor(Sandbox::Color(0.2f,0.2f,0.2f,1.0f));
}

Application::~Application() {
    shader.reset();
    vshader.reset();
    texture.reset();
    if (targets[0]) {
        targets[0]->Release();
    }
    if (targets[1]) {
        targets[1]->Release();
    }
    if (targets[2]) {
        targets[2]->Release();
    }
}

static void draw_quad( GHL::Render* render, int x, int y, int w, int h, int tw, int th) {
    GHL::Vertex vertexes[4] = {
        { x,    y,   0.5f,   {0xff,0xff,0xff,0xff}, 0.0f,   0.0f},
        { x+w,  y,   0.5f,   {0xff,0xff,0xff,0xff}, float(w)/tw,   0.0f},
        { x+w,  y+h, 0.5f,   {0xff,0xff,0xff,0xff}, float(w)/tw,   float(h)/th},
        { x,    y+h, 0.5f,   {0xff,0xff,0xff,0xff}, 0.0f,   float(h)/th}
    };
    GHL::UInt16 indexes[6] = {
        0,1,2,0,2,3
    };
    render->DrawPrimitivesFromMemory(GHL::PRIMITIVE_TYPE_TRIANGLES, GHL::VERTEX_TYPE_SIMPLE, vertexes, 4, indexes, 2);
}

void Application::ConfigureDevice( GHL::System* system ) {
}

void Application::BindModules( Sandbox::LuaVM* lua ) {
    Sandbox::Application::BindModules(lua);
}

void Application::OnLoaded() {
    width = GetRender()->GetWidth();
    height = GetRender()->GetHeight();
    
    targets[0] = GetRender()->CreateRenderTarget(width/scale, height/scale, GHL::TEXTURE_FORMAT_RGBA, false);
    targets[1] = GetRender()->CreateRenderTarget(width/scale, height/scale, GHL::TEXTURE_FORMAT_RGBA, false);
    targets[2] = GetRender()->CreateRenderTarget(width/scale, height/scale, GHL::TEXTURE_FORMAT_RGBA, false);
    
    shader = GetResources()->GetShader("shaders/wave_v.glsl", "shaders/wave_f.glsl");
    vshader = GetResources()->GetShader("shaders/wave_v.glsl", "shaders/visualize_f.glsl");
    if (vshader) {
        vshader->SetTextureStage("texture_0", 0);
        vshader->SetTextureStage("texture_1", 1);
        vshader->GetVec2Uniform("texture_offset")->SetValue(Sandbox::Vector2f(1.0f/targets[0]->GetWidth(),
                                                                             1.0f/targets[0]->GetHeight()));
    }
    if (shader) {
        shader->SetTextureStage("texture_0", 0);
        shader->SetTextureStage("texture_1", 1);
        shader->GetVec2Uniform("texture_offset")->SetValue(Sandbox::Vector2f(1.0f/targets[0]->GetWidth(),
                                                                             1.0f/targets[0]->GetHeight()));
    }
    
    texture = GetResources()->GetTexture("images/pebbles.jpg", false);
}

void make_pass(GHL::Render* render, size_t src1, size_t src2,size_t dst) {
    render->BeginScene(targets[dst]);
    render->Clear(0.0f, 0.0f, 0.0f, 0.0f, 0);
    render->SetupBlend(false);
    if (frames_drawed > 3) {
        targets[src1]->GetTexture()->SetMagFilter(GHL::TEX_FILTER_LINEAR);
        targets[src1]->GetTexture()->SetMinFilter(GHL::TEX_FILTER_LINEAR);
        //targets[src1]->GetTexture()->SetWrapModeU(GHL::TEX_WRAP_REPEAT);
        //targets[src1]->GetTexture()->SetWrapModeV(GHL::TEX_WRAP_REPEAT);
        
        if (shader) {
//            if (crnt_index!=0) {
//
//            }
            shader->Set(render);
            shader->GetVec2Uniform("mouse_pos")->SetValue(Sandbox::Vector2f(-1,-1));
        }
        
        render->SetTexture(targets[src1]->GetTexture());     /// two frame age
        render->SetTexture(targets[src2]->GetTexture(),1);   /// one frame age
        
        draw_quad(render, 0, 0, width/scale, height/scale, targets[src1]->GetWidth(),targets[src1]->GetHeight());
    }
    
    render->SetTexture(0);
    render->SetTexture(0,1);
    
    render->EndScene();
}

void Application::UpdateRenderTargets(float dt,GHL::Render* render) {
    Sandbox::Application::UpdateRenderTargets(dt, render);
    if (targets[0] && targets[1] && targets[2]) {
        
        ++frames_drawed;
        /// 2(NW) = 1(CT)-0(NW)
        /// NW<->CT
        /// 0(NW) = 2(CT)-1(NW)
        /// NW<->CT
        /// 1(NW) = 0(CT)-2(NW)
        crnt_target = (crnt_src + 2) % 3;
        size_t next_src = (crnt_src+1)%3;
        make_pass( render, next_src, crnt_src, crnt_target);
        
        crnt_src = next_src;
    }
}

void Application::DrawFrame( Sandbox::Graphics& g ) const {
    GHL::Render* r = g.BeginNative();
    if (targets[crnt_target]) {
        targets[crnt_target]->GetTexture()->SetMagFilter(GHL::TEX_FILTER_LINEAR);
        r->SetTexture(targets[crnt_target]->GetTexture());
        if (texture) {
            texture->SetFiltered(true);
            r->SetTexture(texture->Present(GetResources()),1);
        }
        if (vshader) {
            vshader->Set(r);
        }
        draw_quad(r,0,0,r->GetWidth(),r->GetHeight(), targets[crnt_target]->GetWidth()*scale,
                  targets[crnt_target]->GetHeight()*scale);
    }
    g.EndNative(r);
}

void Application::Update(float dt) {
}

void Application::do_touch(int xx,int yy) {
    if (true) {
        if (shader) {
            Sandbox::ShaderVec2UniformPtr uniform = shader->GetVec2Uniform("mouse_pos");
            if (uniform) {
                float x = float(xx) / ( targets[0]->GetWidth() * scale );
                float y = float(yy) / ( targets[0]->GetHeight() * scale );
                
                uniform->SetValue(Sandbox::Vector2f(x,y));
            }
        }
    }
}
///
void GHL_CALL Application::OnMouseDown( GHL::MouseButton btn, GHL::Int32 x, GHL::Int32 y) {
    Sandbox::Application::OnMouseDown(btn, x, y);
    do_touch(x,y);
    
}
///
void GHL_CALL Application::OnMouseMove( GHL::MouseButton btn, GHL::Int32 x, GHL::Int32 y) {
    Sandbox::Application::OnMouseMove(btn, x, y);
    if (btn == GHL::MOUSE_BUTTON_LEFT) {
        do_touch(x,y);
    }
    
}
///
void GHL_CALL Application::OnMouseUp( GHL::MouseButton btn, GHL::Int32 x, GHL::Int32 y) {
    Sandbox::Application::OnMouseUp(btn, x, y);
}
///
void GHL_CALL Application::OnKeyDown( GHL::Key key ) {
   
}
///
void GHL_CALL Application::OnKeyUp( GHL::Key ) {
}
///
void GHL_CALL Application::OnChar( GHL::UInt32 ) {
}