#ifndef STANDALONEFILEBROWSER_LIBRARY_H
#define STANDALONEFILEBROWSER_LIBRARY_H

#include <windows.h>

#define DllExport __declspec( dllexport )

typedef void (*callbackFunc)(BOOL);

int CALLBACK BrowseCallbackProc(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData);

BOOL DllExport DialogOpenFilePanel(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR extension, BOOL multiselect);
BOOL DllExport DialogOpenFolderPanel(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, BOOL multiselect);
BOOL DllExport DialogSaveFilePanel(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR defaultName, LPCWSTR filters);
void DllExport DialogOpenFilePanelAsync(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR extension, BOOL multiselect, callbackFunc cb);
void DllExport DialogOpenFolderPanelAsync(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, BOOL multiselect, callbackFunc cb);
void DllExport DialogSaveFilePanelAsync(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR defaultName, LPCWSTR filters, callbackFunc cb);

#endif