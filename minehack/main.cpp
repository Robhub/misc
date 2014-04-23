#include <stdio.h>
#include <windows.h>
#include <psapi.h>
#include "resource.h"

#pragma comment(lib,"Psapi.lib")

HWND hDebug;
long field[255];
HINSTANCE instance;

void drawTable(HWND hMainWin) {

    HBITMAP hBitmap;
    HDC dc;
    PAINTSTRUCT ps;
    HBITMAP hBitmap0 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP0));
    HBITMAP hBitmap1 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP1));
    HBITMAP hBitmap2 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP2));
    HBITMAP hBitmap3 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP3));
    HBITMAP hBitmap4 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP4));
    HBITMAP hBitmap5 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP5));
    HBITMAP hBitmap6 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP6));
    HBITMAP hBitmap7 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP7));
    HBITMAP hBitmap8 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP8));
    HBITMAP hBitmap11 = LoadBitmap(instance, MAKEINTRESOURCE(IDB_BITMAP11));
    
    dc = BeginPaint(hMainWin, &ps);
    for (int y = 0; y < 16 ; y++) {
        for (int x = 0; x < 16 ; x++) {
            switch (field[y+x*16]) {
                case 0:
                hBitmap = hBitmap0;
                break;
                case 1:
                hBitmap = hBitmap1;
                break;
                case 2:
                hBitmap = hBitmap2;
                break;
                case 3:
                hBitmap = hBitmap3;
                break;
                case 4:
                hBitmap = hBitmap4;
                break;
                case 5:
                hBitmap = hBitmap5;
                break;
                case 6:
                hBitmap = hBitmap6;
                break;
                case 7:
                hBitmap = hBitmap7;
                break;
                case 8:
                hBitmap = hBitmap8;
                break;
                case 11:
                hBitmap = hBitmap11;
                break;
                default:
                hBitmap = 0;
                break;
            }
            if (hBitmap != 0) {
                DrawState(dc,NULL,NULL,(long)hBitmap,NULL,x*19,y*19,0,0,DST_BITMAP);
            }
        }
    }
    EndPaint(hMainWin, &ps);
    DeleteObject(hBitmap);
}

bool tblcmp(const long tblA[], const long tblB[], const long len) {
    int size = len / sizeof(long);
    for (int i = 0; i < size ; i++) {
        if (tblA[i] != tblB[i]) {
            return false;
        }
    }
    return true;
}


void getProc(const char *cProcName, HANDLE *hProc) {
    DWORD dwProcId = 0;
    TCHAR szName[MAX_PATH] = {
                                 0
                             };
    DWORD dwSize = 0;
    DWORD dwProcIdentifiers[256] = {
                                       0
                                   };
    if (!EnumProcesses(dwProcIdentifiers, sizeof( dwProcIdentifiers ), &dwSize))
        return;
    for (int i = 0; i < dwSize / sizeof(DWORD) ; i++) {
        HANDLE hProcModule = OpenProcess( PROCESS_ALL_ACCESS, 0, dwProcIdentifiers[i] );
        if( !hProcModule )
            continue;
        DWORD dwModuleSize = 0;
        HMODULE hModules[256] = {
                                    0
                                };
        EnumProcessModules( hProcModule, hModules, sizeof( hModules ), &dwModuleSize );
        GetModuleBaseName( hProcModule, hModules[0], szName, MAX_PATH );
        if (!_strcmpi(szName,"msnmsgr.exe")) {
            *hProc = hProcModule;
            return;
        }
        else {
            CloseHandle(hProcModule);
        }
    }
    return;
}

void getDll(const HANDLE hProc, DWORD *baseAddr) {
    TCHAR cModuleName[MAX_PATH] = {
                                      0
                                  };
    MODULEINFO modinfo;
    DWORD dwModuleSize = 0;
    HMODULE hModules[256] = {
                                0
                            };
    if (!EnumProcessModules(hProc, hModules, sizeof(hModules), &dwModuleSize))
        return;
    for (int i = 0; i < dwModuleSize / sizeof(HMODULE); i++) {
        if (!GetModuleBaseName(hProc,hModules[i],cModuleName,MAX_PATH))
            continue;
        if (!_strcmpi(cModuleName, "MineSweeper.dll")) {
            if (!GetModuleInformation(hProc, hModules[i], &modinfo, sizeof(MODULEINFO)))
                continue;
            *baseAddr = PtrToLong(modinfo.lpBaseOfDll);
            return;
        }
    }
    return;
}



LRESULT CALLBACK procedureFenetrePrincipale(HWND, UINT, WPARAM, LPARAM);


int WinMain (HINSTANCE cetteInstance, HINSTANCE precedenteInstance, LPSTR lignesDeCommande, int modeDAffichage) {
    HWND fenetrePrincipale;
    MSG message;
    WNDCLASS classeFenetre;
    
    instance = cetteInstance;
    
    classeFenetre.style = 0;
    classeFenetre.lpfnWndProc = procedureFenetrePrincipale;
    classeFenetre.cbClsExtra = 0;
    classeFenetre.cbWndExtra = 0;
    classeFenetre.hInstance = NULL;
    classeFenetre.hIcon = LoadIcon(instance, MAKEINTRESOURCE(IDI_ICON1));
    classeFenetre.hCursor = LoadCursor(NULL, IDC_ARROW);
    classeFenetre.hbrBackground = (HBRUSH)(1 + COLOR_BTNFACE);
    classeFenetre.lpszMenuName =  NULL;
    classeFenetre.lpszClassName = "MSN MineSweeper Hack v1.2 by Robi";
    
    // On prévoit quand même le cas où ça échoue
    if(!RegisterClass(&classeFenetre))
        return FALSE;
        
    fenetrePrincipale = CreateWindow("MSN MineSweeper Hack v1.2 by Robi", "MSN MineSweeper Hack v1.2 by Robi", WS_OVERLAPPEDWINDOW,
                                     CW_USEDEFAULT, CW_USEDEFAULT, 312, 346,
                                     NULL, NULL, cetteInstance, NULL);
    if (!fenetrePrincipale)
        return FALSE;
        
    ShowWindow(fenetrePrincipale, modeDAffichage);
    UpdateWindow(fenetrePrincipale);
    
    int color = 0;
    HANDLE hProc = 0;
    DWORD diff = 0;
    DWORD baseAddr = 0;
    DWORD caveAddr = 0;
    DWORD fieldAddr = 0;
    long injectAddr = 0xAFDD;
    char defaultCode[5] =
        {
            0x51, 0x51, 0x53, 0x56, 0x57
        };
    char caveCode[2] =
        {
            0x89, 0x0D
        };
    char jmpCode = 0xE9;
    char code = 0;
    
    
    
    
    long oldfield[255];
    
    while (GetMessage(&message, NULL, 0, 0)) {
        TranslateMessage(&message);
        DispatchMessage(&message);
        Sleep(1);
        
        
        if (!hProc) {
            getProc("msnmsgr.exe", &hProc);
            if (hProc) {
                DestroyWindow(hDebug);
                hDebug = CreateWindow("STATIC", "Process found.", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
            }
            continue;
        }
        if (!baseAddr) {
            getDll(hProc, &baseAddr);
            if (baseAddr) {
                DestroyWindow(hDebug);
                hDebug = CreateWindow("STATIC", "Module found.", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
                
                //MessageBox(fenetrePrincipale, "Module found.", "MineSweeper Hack", MB_ICONINFORMATION);
            }
            continue;
        }
        ReadProcessMemory(hProc,  LongToPtr(baseAddr + injectAddr), &code,  sizeof(code), NULL);
        //Too bored to compare the entire table...
        if (code == defaultCode[0]) {
            DestroyWindow(hDebug);
            hDebug = CreateWindow("STATIC", "Patching...", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
            
            caveAddr = PtrToLong(VirtualAllocEx(hProc, NULL, 20, MEM_RESERVE|MEM_COMMIT, PAGE_EXECUTE_READWRITE));
            if (caveAddr == 0) {
                DestroyWindow(hDebug);
                hDebug = CreateWindow("STATIC", "VirtualAllocEx Failed.", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
                continue;
            }
            DestroyWindow(hDebug);
            hDebug = CreateWindow("STATIC", "VirtualAllocEx Success.", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
            
            diff = caveAddr - baseAddr - injectAddr - 1;
            char newmema[5];
            Sleep(2500);
            memmove(&newmema[0], &jmpCode, 1);
            memmove(&newmema[1], &diff, 4);
            WriteProcessMemory(hProc, LongToPtr(baseAddr + injectAddr), newmema, 5, NULL);
            diff = baseAddr + injectAddr + 1 - caveAddr - 16;
            char newmemb[16];
            memmove(&newmemb[0], defaultCode, 5);
            memmove(&newmemb[5], caveCode, 2);
            memmove(&newmemb[7], &caveAddr, 4);
            memmove(&newmemb[11], &jmpCode, 1);
            memmove(&newmemb[12], &diff, 4);
            WriteProcessMemory(hProc, LongToPtr(caveAddr + 4), newmemb, 16, NULL);
        }
        else if (code == jmpCode) {
            ReadProcessMemory(hProc,  LongToPtr(baseAddr + injectAddr +1), &diff, 4, NULL);
            caveAddr = diff + baseAddr + injectAddr + 1;
        }
        
        
        
        
        if (ReadProcessMemory(hProc,  LongToPtr(caveAddr), &fieldAddr, sizeof(fieldAddr), NULL) != 0) {
            ReadProcessMemory(hProc,  LongToPtr(fieldAddr+4), field, sizeof(field), NULL);
            if (!tblcmp(oldfield, field, 255)) {
                DestroyWindow(hDebug);
                hDebug = CreateWindow("STATIC", "New Field Found.", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
                
                
                UpdateWindow(fenetrePrincipale);
                
                
                memmove(oldfield, field, 255);
            }
        }
    }
    return message.wParam;
}

LRESULT CALLBACK procedureFenetrePrincipale(HWND fenetrePrincipale, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
        case WM_CREATE:
        hDebug = CreateWindow("STATIC", "MSN MineSweeper Hack v1.2 by Robi", WS_CHILD | WS_VISIBLE | SS_CENTER , 2, 304, 308, 32, fenetrePrincipale, NULL, instance, NULL);
        return 0;
        case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
        case WM_PAINT: {
        
            drawTable(fenetrePrincipale);
            return 0;
        }
        default:
        return DefWindowProc(fenetrePrincipale, message, wParam, lParam);
    }
    
}
