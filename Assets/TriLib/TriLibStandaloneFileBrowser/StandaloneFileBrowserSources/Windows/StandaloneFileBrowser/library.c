#include <stddef.h>
#include <string.h>
#include <windows.h>
#include <ShlObj_core.h>
#include "library.h"

BOOL DialogOpenFilePanel(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR extension, BOOL multiselect) {
	OPENFILENAMEW openFileName;
	ZeroMemory(&openFileName, sizeof openFileName);
	openFileName.lStructSize = sizeof openFileName;
	openFileName.hwndOwner = unityHWND;
	openFileName.lpstrFile = buffer;
	openFileName.nMaxFile = bufferSize;
	openFileName.lpstrFilter = extension;
	openFileName.lpstrTitle = title;
	openFileName.lpstrInitialDir = directory;
	openFileName.Flags = OFN_PATHMUSTEXIST | OFN_NOCHANGEDIR;
	if (multiselect)
	{
		openFileName.Flags |= OFN_ALLOWMULTISELECT | OFN_EXPLORER;
	}
	return GetOpenFileName(&openFileName);
}

int CALLBACK BrowseCallbackProc(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData)
{
	if (uMsg == BFFM_INITIALIZED)
	{
		SendMessage(hwnd, BFFM_SETSELECTION, TRUE, lpData);
	}
	return 0;
}

BOOL DialogOpenFolderPanel(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, BOOL multiselect) {
	BROWSEINFO browseInfo;
	ZeroMemory(&browseInfo, sizeof browseInfo);
	browseInfo.lpfn = BrowseCallbackProc;
	browseInfo.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE;
	browseInfo.hwndOwner = unityHWND;
	browseInfo.lpszTitle = title;
	browseInfo.lParam = (LPARAM)directory;
	LPITEMIDLIST itemIdList = SHBrowseForFolder(&browseInfo);
	if (itemIdList != NULL)
	{
		SHGetPathFromIDList(itemIdList, buffer);
		return TRUE;
	}
	return FALSE;
}

BOOL DialogSaveFilePanel(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR defaultName, LPCWSTR filters) {
	OPENFILENAMEW openFileName;
	ZeroMemory(&openFileName, sizeof openFileName);
	wcscpy_s(buffer, bufferSize, defaultName);
	openFileName.lStructSize = sizeof openFileName;
	openFileName.hwndOwner = unityHWND;
	openFileName.lpstrFile = buffer;
	openFileName.nMaxFile = bufferSize;
	openFileName.lpstrFilter = filters;
	openFileName.lpstrTitle = title;
	openFileName.lpstrInitialDir = directory;
	openFileName.Flags = OFN_CREATEPROMPT | OFN_HIDEREADONLY | OFN_NOCHANGEDIR;
	return GetSaveFileName(&openFileName);
}

void DialogOpenFilePanelAsync(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR extension, BOOL multiselect, callbackFunc cb) {
	//todo: async
	cb(DialogOpenFilePanel(unityHWND, buffer, bufferSize, title, directory, extension, multiselect));
}

void DialogOpenFolderPanelAsync(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, BOOL multiselect, callbackFunc cb) {
	//todo: async
	cb(DialogOpenFolderPanel(unityHWND, buffer, bufferSize, title, directory, multiselect));
}

void DialogSaveFilePanelAsync(HWND unityHWND, LPWSTR buffer, SIZE_T bufferSize, LPCWSTR title, LPCWSTR directory, LPCWSTR defaultName, LPCWSTR filters, callbackFunc cb) {
	//todo: async
	cb(DialogSaveFilePanel(unityHWND, buffer, bufferSize, title, directory, defaultName, filters));
}