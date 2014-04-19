/*
 *  application.h
 *  YinYang
 *
 *  Created by Андрей Куницын on 04.09.11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef APPLICTION_H_INLUDED
#define APPLICTION_H_INLUDED

#include <sb_application.h>

class Application : public Sandbox::Application {
public:
	Application();
	~Application();
	virtual void BindModules( Sandbox::LuaVM* lua );
	virtual void OnLoaded();
	virtual void ConfigureDevice( GHL::System* system );
	virtual void DrawFrame( Sandbox::Graphics& g ) const;
    virtual void Update(float dt);
	virtual void UpdateRenderTargets(float dt,GHL::Render* render);
	///
	virtual void GHL_CALL OnMouseDown( GHL::MouseButton btn, GHL::Int32 x, GHL::Int32 y) ;
	///
	virtual void GHL_CALL OnMouseMove( GHL::MouseButton btn, GHL::Int32 x, GHL::Int32 y) ;
	///
	virtual void GHL_CALL OnMouseUp( GHL::MouseButton btn, GHL::Int32 x, GHL::Int32 y) ;
	///
	virtual void GHL_CALL OnKeyDown( GHL::Key key ) ;
	///
	virtual void GHL_CALL OnKeyUp( GHL::Key key ) ;
	///
	virtual void GHL_CALL OnChar( GHL::UInt32 ch ) ;
private:
    void do_touch(int x,int y);
};

#endif /*APPLICTION_H_INLUDED*/