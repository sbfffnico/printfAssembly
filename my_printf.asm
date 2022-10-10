; Nico Edrich
; Hamming Distance assignment

%include "/usr/local/share/csc314/asm_io.inc"

segment .data

	str1 	db 	"Hello world",10,0
	str2 	db 	"str3 is '%s', isn’t that cool?",10,0
	str3 	db 	"woot woot",0
	str4 	db 	"%c is a char, but so is %%, %s again!",10,0

segment .bss


segment .text
	global  asm_main
	;extern	printf

asm_main:
	push	ebp
	mov		ebp, esp
	; ********** CODE STARTS HERE **********

	push str1
	call printf
	add esp, 4

	push str3
	push str2
	call printf
	add esp, 8

	push str3
	push 'A'
	push str4
	call printf
	add esp, 8

	; *********** CODE ENDS HERE ***********
	mov		eax, 0
	mov		esp, ebp
	pop		ebp
	ret

printf:
	;prologue
	push 	ebp
	mov 	ebp, esp

	mov		esi, DWORD [ebp + 8]
	mov		edi, 0
	strlen_loop:
	cmp		BYTE [esi + edi], 0
	je		strlen_end
	inc		edi
	jmp		strlen_loop
	strlen_end:

	sub		esp, 16				; local variables
	mov		DWORD [ebp - 4], edi
	mov		edi, -1				; counter for loop
	mov		esi, 0				; counter for number of percentage symbols found

	mov		ecx, DWORD [ebp + 8]

	print_loop:
	inc		edi
	cmp		edi, DWORD [ebp - 4]
	jge		print_end
	mov		eax, 4				; sys_write
	mov		ebx, 1				; stdout
	;mov		ecx, DWORD [ebp + 8]
	mov		edx, 1
	cmp		BYTE [ecx], 37		; check for %
	je		check_which
	return_from_same:
	int		0x80
	inc		ecx
	jmp		print_loop
	print_end:
	jmp		end_printf

	check_which:
	inc		ecx
	inc		esi
	cmp		BYTE [ecx], 115		; check for s
	je		s_found
	cmp		BYTE [ecx], 99		; check for c
	je		c_found
	cmp		BYTE [ecx], 37		; check for %
	je		percent_found

	s_found:
	mov		eax, DWORD [ebp + 8 + esi * 4]
	mov		ebx, 0
	sstrlen_loop:
	cmp		BYTE [eax + ebx], 0
	je		sstrlen_end
	inc		ebx
	jmp		sstrlen_loop
	sstrlen_end:
	mov		DWORD [ebp - 8], ebx
	mov		DWORD [ebp - 12], ecx
	mov		ecx, eax
	mov		edx, ebx
	mov		eax, 4
	mov		ebx, 1
	int		0x80
	mov		ecx, DWORD [ebp - 12]
	inc		ecx
	jmp		print_loop

	c_found:
	mov		DWORD [ebp - 8], ecx
	mov		eax, 4
	mov		ebx, 1
	lea		ecx, [ebp + 8 + esi * 4]
	mov		edx, 1
	int 	0x80
	mov		ecx, DWORD [ebp - 8]
	inc		ecx
	jmp		print_loop

	percent_found:
	dec		esi					;decrement count of esi to avoid missing items in stack
	mov		eax, 4
	mov		ebx, 1
	mov		edx, 1
	int		0x80
	inc		ecx
	jmp		print_loop

	end_printf:
	add 	esp, 16
	;epilogue
	mov 	esp, ebp
	pop		ebp
	ret






