.386
.MODEL FLAT, STDCALL
include grafika.inc
includelib masm32.lib
;--- stale z pliku .\include\windows.inc ---
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
GENERIC_READ                         equ 80000000h
GENERIC_WRITE                        equ 40000000h
CREATE_NEW                           equ 1
CREATE_ALWAYS                        equ 2
OPEN_EXISTING                        equ 3
OPEN_ALWAYS                          equ 4
TRUNCATE_EXISTING                    equ 5
FILE_FLAG_WRITE_THROUGH              equ 80000000h
FILE_FLAG_OVERLAPPED                 equ 40000000h
FILE_FLAG_NO_BUFFERING               equ 20000000h
FILE_FLAG_RANDOM_ACCESS              equ 10000000h
FILE_FLAG_SEQUENTIAL_SCAN            equ 8000000h
FILE_FLAG_DELETE_ON_CLOSE            equ 4000000h
FILE_FLAG_BACKUP_SEMANTICS           equ 2000000h
FILE_FLAG_POSIX_SEMANTICS            equ 1000000h
FILE_ATTRIBUTE_READONLY              equ 1h
FILE_ATTRIBUTE_HIDDEN                equ 2h
FILE_ATTRIBUTE_SYSTEM                equ 4h
FILE_ATTRIBUTE_DIRECTORY             equ 10h
FILE_ATTRIBUTE_ARCHIVE               equ 20h
FILE_ATTRIBUTE_NORMAL                equ 80h
FILE_ATTRIBUTE_TEMPORARY             equ 100h
FILE_ATTRIBUTE_COMPRESSED            equ 800h
FORMAT_MESSAGE_ALLOCATE_BUFFER       equ 100h
FORMAT_MESSAGE_IGNORE_INSERTS        equ 200h
FORMAT_MESSAGE_FROM_STRING           equ 400h
FORMAT_MESSAGE_FROM_HMODULE          equ 800h
FORMAT_MESSAGE_FROM_SYSTEM           equ 1000h
FORMAT_MESSAGE_ARGUMENT_ARRAY        equ 2000h
FORMAT_MESSAGE_MAX_WIDTH_MASK        equ 0FFh
FILE_BEGIN							 equ 0h ;MoveMethod dla SetFilePointe
FILE_CURRENT                         equ 1h ;MoveMethod dla SetFilePointe
FILE_END                             equ 2h ;MoveMethod dla SetFilePointe

;--- z pliku .\include\kernel32.inc ---
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD
lstrlenA PROTO :DWORD
GetCurrentDirectoryA PROTO :DWORD,:DWORD  
      ;;nBufferLength, lpBuffer; zwraca length
lstrcatA PROTO :DWORD,:DWORD              
      ;; lpString1, lpString2; zwraca lpString1
CreateFileA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD 
      ;; LPCTSTR lpszName, DWORD fdwAccess, 
      ;; DWORD fdwShareMode, LPSECURITY_ATTRIBUTES lpsa, DWORD fdwCreate, 
      ;; DWORD fdwAttrsAndFlags, HANDLE hTemplateFile
CloseHandle PROTO :DWORD      
      ;; BOOL CloseHandle(HANDLE hObject)
WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD    
   ;; BOOL WriteFile(
   ;; HANDLE hFile,	// handle to file to write to
   ;; LPCVOID lpBuffer,	// pointer to data to write to file
   ;; DWORD nNumberOfBytesToWrite,	// number of bytes to write
   ;; LPDWORD lpNumberOfBytesWritten,	// pointer to number of bytes written
   ;; LPOVERLAPPED lpOverlapped 	// pointer to structure needed for overlapped I/O 
   ;;);
ReadFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ;;BOOL ReadFile(
    ;;HANDLE hFile,	// handle of file to read 
    ;;LPVOID lpBuffer,	// address of buffer that receives data  
    ;;DWORD nNumberOfBytesToRead,	// number of bytes to read 
    ;;LPDWORD lpNumberOfBytesRead,	// address of number of bytes read 
    ;;LPOVERLAPPED lpOverlapped 	// address of structure for data 
    ;;);
GetLastError PROTO

ScanInt			PROTO
Multiply		PROTO
AddResult		PROTO
checkElement	PROTO

CSstyle		EQU CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
WNDstyle	EQU WS_CLIPCHILDREN + WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_MINIMIZEBOX
BSstyle		EQU	BS_PUSHBUTTON + WS_VISIBLE + WS_CHILD + WS_TABSTOP
EDTstyle	EQU WS_VISIBLE + WS_CHILD + WS_TABSTOP + WS_BORDER

.data
	;--- Podstawowe uchwyty ---
	hinst			DWORD	0
	handleIcon		DWORD	0
	handleCursor	DWORD	0
	handleBrush		DWORD	0

	msg		MSGSTRUCT		<?> 
	wndc	WNDCLASS		<?>

	;--- Zmienne do WindowClass i do komunikatów o b³êdach ---
	cname	DB	"MainClass", 0
	hwnd	DD	0
	hdc		DD	0
	tytul	DB	"Projekt - Igor Kucyk",0
	blad	DB	"Komunikat", 0
	terr	DB	"blad!", 0
	terr2	DB	"blad2!", 0
	bladMsg	DB	"Macierze s¹ b³êdnie wype³nione (pola s¹ puste lub posiadaj¹ znaki inne ni¿ cyfry i minus)!", 0
	bladMsg2	DB	"Nie znaleziono pliku!", 0

	;--- Nag³ówki ---
	naglow	DB	"Mno¿enie macierzy 3x3", 0
	rozmN	DD	0
	naglowA	DB	"Macierz A", 0
	rozmA	DD	0
	naglowB	DB	"Macierz B", 0
	rozmB	DD	0
	naglowC	DB	"Wynik", 0
	rozmC	DD	0
	mnoz	DB	"*", 0
	rozmM	DD	0
	rowne	DB	"=", 0
	rozmR	DD	0
	wzor	DB	"%i", 0

	;--- Tablice uchwytów do pól edycyjnych i tekstowych macierzy
	hedtAbuf	DWORD	9	dup(0)
	hedtBbuf	DWORD	9	dup(0)
	htxtCbuf	DWORD	9	dup(0)

	;--- Typy elementów ---
	tbut	BYTE	"BUTTON", 0
	tedt	BYTE	"EDIT", 0
	ttxt	BYTE	"STATIC", 0

	;--- Nag³ówki i uchwyty do przycisków ---
	zapisz	BYTE	"Zapisz", 0
	hzap	DWORD	0
	wczytaj	BYTE	"Wczytaj", 0
	hwcz	DWORD	0
	oblicz	BYTE	"Oblicz", 0
	hobl	DWORD	0

	;--- Tablice wartoœci macierzy ---
	macierzA	DWORD	9	dup(?)
	macierzB	DWORD	9	dup(?)
	macierzC	DWORD	9	dup(?)
	wiersz		DWORD	?
	kolumna		DWORD	?

	;--- Zmienne do dzia³ania na plikach ---
	fileName	BYTE	"\wynik.dat", 0
	hfile		DWORD	?
	amount		DWORD	0
	number		DWORD	?

	;--- Bufor ---
	bufor BYTE	128 dup(?)
	rbuf  DWORD 128
.code

createElements MACRO handleArray:REQ, arrayType:REQ, startX:REQ, offsetX:REQ, width:REQ
	lea EBX, handleArray
	mov EDI, 0
	mov ECX, 9
	mov EDX, startX
	mov ESI, 50
	@@:
	push ECX
	push EDX
	push ESI
	invoke CreateWindowExA, 0, OFFSET arrayType, 0, EDTstyle, EDX, ESI, width, 20, windowHandle, 0, hinst, 0
	mov DWORD PTR [EBX+EDI], EAX
	pop ESI
	pop EDX
	pop ECX
	add EDI, 4
	add EDX, offsetX
	.IF ECX == 7 || ECX == 4
		mov EDX, startX
		add ESI, 25
	.ENDIF
	loop @B
ENDM

createButton MACRO handleButton:REQ, buttonType:REQ, startX:REQ
	invoke CreateWindowExA, 0, OFFSET tbut, OFFSET buttonType, BSstyle, startX, 130, 60, 30, windowHandle, 0, hinst, 0
	mov handleButton, EAX
ENDM

checkElement PROC
	push EBP 
	mov EBP, ESP
	mov EBX, [EBP+12] 
	mov EDX, [EBP+8] 
	mov EDI, 0
	mov ESI, 0
	mov ECX, 9
	@@:
		xor EAX, EAX
		push ECX
		push EDX
		mov EAX, DWORD PTR [EBX+EDI]
		invoke SendMessageA, EAX, WM_GETTEXT, 4, OFFSET bufor
		invoke lstrlenA, OFFSET bufor
		mov rbuf, EAX
		cmp rbuf, 0 ;sprawdzanie d³ugoœci bufora
		je err3
		pop EDX
		mov ECX, rbuf
		pole:
			push ECX
			mov AL, BYTE PTR [OFFSET bufor+ESI]
			cmp AL, 02Dh   ;porównanie z kodem - 
			je dalej
			cmp AL, 030h   ;porównanie z kodem 0 
			jb err3
			cmp AL, 039h   ;porównanie z kodem 9 
			ja err3
			dalej:
				inc ESI
				pop ECX
				loop pole
		push OFFSET bufor
		call ScanInt
		mov DWORD PTR[EDX+EDI], EAX ;liczba jest poprawna, wiêc wstawiamy j¹ do macierza
		add EDI, 4
		mov bufor, 0
		mov rbuf, 0
		mov ESI, 0
		pop ECX
		loop @B
		jmp zakoncz
	err3:
		invoke MessageBoxA, 0, OFFSET bladMsg, OFFSET blad, 0
		mov EAX, 0
	zakoncz:
		mov   ESP, EBP   ; przywracamy wskaŸnik stosu ESP
		pop   EBP 
		ret 8
checkElement ENDP

showResults MACRO
	lea EBX, htxtCbuf
	lea EDX, macierzC
	mov EDI, 0
	mov ECX, 9
	@@:
		push ECX
		push EDX
		mov ECX, DWORD PTR [EBX+EDI]
		mov EAX, DWORD PTR [EDX+EDI]
		push ECX
		push EAX
		invoke wsprintfA, OFFSET bufor, OFFSET wzor
		pop EAX
		pop ECX
		invoke SendMessageA, ECX, WM_SETTEXT, 0, OFFSET bufor
		add EDI, 4
		pop EDX
		pop ECX
		loop @B
ENDM

Multiply PROC
	push EDX
	lea EBX, macierzA
	mov EAX, DWORD PTR[EBX+ESI]
	lea EBX, macierzB
	mov ECX, DWORD PTR[EBX+EDI]
	mul ECX
	pop EDX
	add EDX, EAX
	add ESI, 4
	add EDI, 12
	ret
multiply ENDP

AddResult PROC
	mov ESI, wiersz
	mov EDI, 0
	add kolumna, 4
	add EDI, kolumna
	lea EBX, macierzC
	mov DWORD PTR[EBX+EBP], EDX
	add EBP, 4
	mov EDX, 0
	ret
addResult ENDP

saveMatrix MACRO array:REQ
	lea EBX, array
	mov EDI, 0
	mov ECX, 9
	@@:
		push ECX
		mov EAX, DWORD PTR[EBX+EDI]
		mov number, EAX
		invoke WriteFile, hfile, OFFSET number, 4, OFFSET amount, 0
		invoke GetLastError
		add EDI, 4
		pop ECX
		loop @B
ENDM

readMatrix MACRO handleArray:REQ, array:REQ
	lea EBX, handleArray
	lea EDX, array
	mov EDI, 0
	mov ECX, 9
	@@:
		push ECX
		push EDX
		invoke ReadFile, hfile, OFFSET number, 4, OFFSET amount, 0
		mov EAX, number
		pop EDX
		mov DWORD PTR[EDX+EDI], EAX
		add EDI, 4
		pop ECX
		loop @B

	lea EBX, handleArray
	lea EDX, array
	mov EDI, 0
	mov ECX, 9
	@@:
		push ECX
		push EDX
		mov ECX, DWORD PTR [EBX+EDI]
		mov EAX, DWORD PTR [EDX+EDI]
		push ECX
		push EAX
		invoke wsprintfA, OFFSET bufor, OFFSET wzor
		pop EAX
		pop ECX
		invoke SendMessageA, ECX, WM_SETTEXT, 0, OFFSET bufor
		add EDI, 4
		pop EDX
		pop ECX
		loop @B
ENDM

deleteHandle MACRO handleArray:REQ
	lea EBX, handleArray
	mov EDI, 0
	mov ECX, 9
	@@:
		push ECX
		push EBX
		mov EAX, DWORD PTR[EBX+EDI]
		invoke DeleteObject, EAX
		add EDI, 4
		pop EBX
		pop ECX
		loop @B
ENDM

WndProc PROC uses EBX ESI EDI windowHandle:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	;--- Tworzenie elementów ---
	.IF uMSG == WM_CREATE
		;--- Pola edycyjne macierzy A i B oraz pola tekstowe macierza C (wynikowego) ---
		createElements hedtAbuf, tedt, 10, 25, 20
		createElements hedtBbuf, tedt, 100, 25, 20
		createElements htxtCbuf, ttxt, 190, 45, 40
		;--- Przyciski ZAPISZ, WCZYTAJ i OBLICZ ---
		createButton hzap, zapisz,  10
		createButton hwcz, wczytaj, 80
		createButton hobl, oblicz,  224

		jmp wndend
	.ENDIF
	
	;--- Obs³uga zdarzen dla okna ---
	.IF uMSG == WM_COMMAND
		mov EAX, hobl
		.IF lParam == EAX
			;--- Sprawdzenie, czy wszystkie pola s¹ poprawnie wype³nione ---
			push OFFSET hedtAbuf
			push OFFSET macierzA
			call checkElement
			cmp EAX, 0
			je wndend
			push OFFSET hedtBbuf
			push OFFSET macierzB
			call checkElement
			cmp EAX, 0
			je wndend

			;--- Mno¿enie macierzy ---
			mov ESI, 0 ;licznik macierza A (wiersze)
			mov EDI, 0 ;licznik macierza B (kolumny)
			push EBP
			mov EBP, 0 ;licznik do wynikowego macierza
			mov wiersz, ESI
			mov kolumna, EDI
			mov ECX, 3
			A:
				push ECX
				mov EDX, 0 ;suma
				mov ECX, 9
				B:
					push ECX
					call Multiply
					.IF ESI == 12 || ESI == 24 || ESI == 36
						call AddResult
					.ENDIF
					pop ECX
					loop B
				.IF kolumna == 12
					mov kolumna, 0
					mov EDI, kolumna
					add wiersz, 12
					mov ESI, wiersz
				.ENDIF
				pop ECX
				loop A
			pop EBP
			showResults
		.ENDIF

		mov EAX, hzap
		.IF lParam == EAX
			push OFFSET hedtAbuf
		    push OFFSET macierzA
			call checkElement
			cmp EAX, 0
			je wndend
			push OFFSET hedtBbuf
			push OFFSET macierzB
			call checkElement
			cmp EAX, 0
			je wndend
			push OFFSET htxtCbuf
			push OFFSET macierzC
			call checkElement
			cmp EAX, 0
			je wndend

			mov bufor, 0
			mov rbuf, 128
			invoke GetCurrentDirectoryA, rbuf, OFFSET bufor
			invoke lstrcatA, OFFSET bufor, OFFSET fileName
			invoke CreateFileA, OFFSET bufor, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
			mov hfile, EAX

			saveMatrix macierzA
			saveMatrix macierzB
			saveMatrix macierzC
			invoke CloseHandle, hfile
			mov amount, 0
		.ENDIF

		mov EAX, hwcz
		.IF lParam == EAX
			mov bufor, 0
			mov rbuf, 128
			invoke GetCurrentDirectoryA, rbuf, OFFSET bufor
			invoke lstrcatA, OFFSET bufor, OFFSET fileName
			invoke CreateFileA, OFFSET bufor, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
			mov hfile, EAX
			invoke GetLastError
			.IF EAX == 2
				invoke MessageBoxA, 0, OFFSET bladMsg2, OFFSET blad, 0
				invoke CloseHandle, hfile
				jmp wndend
			.ENDIF

			readMatrix hedtAbuf, macierzA
			readMatrix hedtBbuf, macierzB
			readMatrix htxtCbuf, macierzC
			invoke CloseHandle, hfile
			mov amount, 0

		.ENDIF

		jmp wndend
	.ENDIF

	.IF uMSG == WM_DESTROY
		invoke ReleaseDC, hwnd, hdc
		deleteHandle hedtAbuf
		deleteHandle hedtBbuf
		deleteHandle htxtCbuf
		invoke DeleteObject, handleIcon
		invoke DeleteObject, handleCursor
		invoke DeleteObject, handleBrush
		invoke DeleteObject, hzap
		invoke DeleteObject, hwcz
		invoke DeleteObject, hobl
		invoke DeleteObject, hfile
		invoke DestroyWindow, hwnd
		invoke PostQuitMessage, 0
	.ENDIF

	invoke DefWindowProcA, windowHandle, uMsg, wParam, lParam
	wndend:	
		ret
WndProc ENDP

main PROC
	;--- Przygotowanie okna ---
	mov [wndc.clsStyle], CSstyle
	mov [wndc.clsLpFnWndProc], OFFSET WndProc

	invoke GetModuleHandleA, 0
	mov hinst, EAX
	mov [wndc.clsHInstance], EAX

	mov [wndc.clsCbClsExtra], 0
	mov [wndc.clsCbWndExtra], 0

	invoke LoadIconA, 0, IDI_APPLICATION
	mov handleIcon, EAX
	mov [wndc.clsHIcon], EAX

	invoke LoadCursorA, 0, IDC_ARROW
	mov handleCursor, EAX
	mov [wndc.clsHCursor], EAX

	invoke GetStockObject, WHITE_BRUSH
	mov handleBrush, EAX
	mov [wndc.clsHbrBackground], EAX

	mov [wndc.clsLpszMenuName], 0
	mov [wndc.clsLpszClassName], OFFSET cname

	invoke RegisterClassA, OFFSET wndc
	.IF EAX == 0
		jmp err0
	.ENDIF

	invoke CreateWindowExA, 0, OFFSET cname, OFFSET tytul, WNDstyle, 500, 300, 345, 205, 0, 0, hinst, 0
	.IF EAX == 0
		jmp err2
	.ENDIF
	mov hwnd, EAX

	invoke ShowWindow, hwnd, SW_SHOWNORMAL
	invoke GetDC, hwnd
	mov hdc, EAX

	;--- Wyœwietlanie nag³ówków ---
	invoke lstrlenA, OFFSET naglow
	mov rozmN, EAX
	invoke TextOutA, hdc, 85, 5, OFFSET naglow, rozmN

	invoke lstrlenA, OFFSET naglowA
	mov rozmA, EAX
	invoke TextOutA, hdc, 13, 32, OFFSET naglowA, rozmA

	invoke lstrlenA, OFFSET mnoz
	mov rozmM, EAX
	invoke TextOutA, hdc, 87, 79, OFFSET mnoz, rozmM

	invoke lstrlenA, OFFSET naglowB
	mov rozmB, EAX
	invoke TextOutA, hdc, 103, 32, OFFSET naglowB, rozmB

	invoke lstrlenA, OFFSET rowne
	mov rozmR, EAX
	invoke TextOutA, hdc, 176, 78, OFFSET rowne, rozmR

	invoke lstrlenA, OFFSET naglowC
	mov rozmC, EAX
	invoke TextOutA, hdc, 235, 32, OFFSET naglowC, rozmC
	invoke UpdateWindow, hwnd

	;--- Pêtla programu ---
	msgloop:
		INVOKE GetMessageA, OFFSET msg, 0, 0, 0
		.IF EAX == 0
			jmp etkon
		.ENDIF
		.IF EAX == -1
			jmp err0
		.ENDIF

		invoke TranslateMessage, OFFSET msg
		invoke DispatchMessageA, OFFSET msg
	jmp msgloop

	;--- B³êdy ---
	err0:
		invoke MessageBoxA, 0, OFFSET terr, OFFSET blad, 0
		jmp etkon
	err2:
		invoke MessageBoxA, 0, OFFSET terr2, OFFSET blad, 0

	;--- Koniec ---
	etkon:
		INVOKE ExitProcess, 0
main ENDP

ScanInt   PROC 
;; funkcja ScanInt przekszta³ca ci¹g cyfr do liczby, któr¹ jest zwracana przez EAX 
;; argument - zakoñczony zerem wiersz z cyframi 
;; rejestry: EBX - adres wiersza, EDX - znak liczby, ESI - indeks cyfry w wierszu, EDI - tymczasowy 
;--- pocz¹tek funkcji 
   push   EBP 
   mov   EBP, ESP   ; wskaŸnik stosu ESP przypisujemy do EBP 
;--- odk³adanie na stos 
   push   EBX 
   push   ECX 
   push   EDX 
   push   ESI 
   push   EDI 
;--- przygotowywanie cyklu 
   mov   EBX, [EBP+8] 
   push   EBX 
   call   lstrlenA 
   mov   EDI, EAX   ;liczba znaków 
   mov   ECX, EAX   ;liczba powtórzeñ = liczba znaków 
   xor   ESI, ESI   ; wyzerowanie ESI 
   xor   EDX, EDX   ; wyzerowanie EDX 
   xor   EAX, EAX   ; wyzerowanie EAX 
   mov   EBX, [EBP+8] ; adres tekstu
;--- cykl -------------------------- 
pocz: 
   cmp   BYTE PTR [EBX+ESI], 0h   ;porównanie z kodem \0 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Dh   ;porównanie z kodem CR 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Ah   ;porównanie z kodem LF 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 02Dh   ;porównanie z kodem - 
   jne   @F 
   mov   EDX, 1 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 030h   ;porównanie z kodem 0 
   jae   @F 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 039h   ;porównanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
    push   EDX   ; do EDX procesor mo¿e zapisaæ wynik mno¿enia 
   mov   EDI, 10 
   mul   EDI      ;mno¿enie EAX * EDI 
   mov   EDI, EAX   ; tymczasowo z EAX do EDI 
   xor   EAX, EAX   ;zerowani EAX 
   mov   AL, BYTE PTR [EBX+ESI] 
   sub   AL, 030h   ; korekta: cyfra = kod znaku - kod 0    
   add   EAX, EDI   ; dodanie cyfry 
   pop   EDX 
nast:   
    inc   ESI 
   loop   pocz 
;--- wynik 
   or   EDX, EDX   ;analiza znacznika EDX 
   jz   @F 
   neg   EAX 
@@:    
et4:;--- zdejmowanie ze stosu 
   pop   EDI 
   pop   ESI 
   pop   EDX 
   pop   ECX 
   pop   EBX 
;--- powrót 
   mov   ESP, EBP   ; przywracamy wskaŸnik stosu ESP
   pop   EBP 
   ret	4
ScanInt   ENDP

END main