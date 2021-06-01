#include <windows.h>
#include <initguid.h>
#include  <iostream>

using namespace std; 

// 不显示控制台
// #pragma comment( linker, "/subsystem:windows /entry:mainCRTStartup" )


// {c8900b66-a973-584b-8cae-355b7f55341b}
DEFINE_GUID(CLSID_StartMenuCacheAndAppResolver, 0x660b90c8, 0x73a9, 0x4b58, 0x8c, 0xae, 0x35, 0x5b, 0x7f, 0x55, 0x34, 0x1b);

// {46a6eeff-908e-4dc6-92a6-64be9177b41c}
DEFINE_GUID(IID_IAppResolver_7, 0x46a6eeff, 0x908e, 0x4dc6, 0x92, 0xa6, 0x64, 0xbe, 0x91, 0x77, 0xb4, 0x1c);

// {de25675a-72de-44b4-9373-05170450c140}
DEFINE_GUID(IID_IAppResolver_8, 0xde25675a, 0x72de, 0x44b4, 0x93, 0x73, 0x05, 0x17, 0x04, 0x50, 0xc1, 0x40);

struct IAppResolver_7 : public IUnknown
{
public:
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForShortcut() = 0;
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForWindow(HWND hWnd, WCHAR **pszAppId, void *pUnknown1, void *pUnknown2, void *pUnknown3) = 0;
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForProcess(DWORD dwProcessId, WCHAR **pszAppId, void *pUnknown1, void *pUnknown2, void *pUnknown3) = 0;
};

struct IAppResolver_8 : public IUnknown
{
public:
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForShortcut() = 0;
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForShortcutObject() = 0;
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForWindow(HWND hWnd, WCHAR **pszAppId, void *pUnknown1, void *pUnknown2, void *pUnknown3) = 0;
	virtual HRESULT STDMETHODCALLTYPE GetAppIDForProcess(DWORD dwProcessId, WCHAR **pszAppId, void *pUnknown1, void *pUnknown2, void *pUnknown3) = 0;
};

BOOL ShowAppId();
BOOL ShowAppId_7(HWND hWnd);
BOOL ShowAppId_8(HWND hWnd);

void main()
{
	if(SUCCEEDED(CoInitialize(NULL)))
	{
		ShowAppId();
		CoUninitialize();
	}
    ExitProcess(0);
}

BOOL ShowAppId()
{ 	
	POINT pt; 
    GetCursorPos(&pt); 

    HWND hWnd = WindowFromPoint(pt); 

	if(hWnd) 
		hWnd = GetAncestor(hWnd, GA_ROOT); 
	else 
		hWnd = GetShellWindow(); 

	return (ShowAppId_7(hWnd) || ShowAppId_8(hWnd));
}

BOOL ShowAppId_7(HWND hWnd)
{
	HRESULT hr;

	IAppResolver_7 *CAppResolver;
	hr = CoCreateInstance(CLSID_StartMenuCacheAndAppResolver, NULL, CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER, IID_IAppResolver_7, (void **)&CAppResolver);
	if(SUCCEEDED(hr))
	{
		WCHAR *pszAppId;
		hr = CAppResolver->GetAppIDForWindow(hWnd, &pszAppId, NULL, NULL, NULL);
		if(SUCCEEDED(hr))
		{
			//MessageBoxW(NULL, pszAppId, pszAppId, MB_OK);
			wcout<< pszAppId;
			CoTaskMemFree(pszAppId);
		}

		CAppResolver->Release();
	}

	return SUCCEEDED(hr);
}

BOOL ShowAppId_8(HWND hWnd)
{
	HRESULT hr;

	IAppResolver_8 *CAppResolver;
	hr = CoCreateInstance(CLSID_StartMenuCacheAndAppResolver, NULL, CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER, IID_IAppResolver_8, (void **)&CAppResolver);
	if(SUCCEEDED(hr))
	{
		WCHAR *pszAppId;
		hr = CAppResolver->GetAppIDForWindow(hWnd, &pszAppId, NULL, NULL, NULL);
		if(SUCCEEDED(hr))
		{
			//MessageBoxW(NULL, pszAppId, pszAppId, MB_OK);
			wcout<< pszAppId;
			CoTaskMemFree(pszAppId);
		}

		CAppResolver->Release();
	}

	return SUCCEEDED(hr);
}