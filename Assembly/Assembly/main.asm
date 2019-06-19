includelib msvcrt.lib
includelib kernel32.lib
includelib legacy_stdio_definitions.lib
includelib legacy_stdio_wide_specifiers.lib
includelib ucrt.lib
 
extern __imp_ExitProcess:QWORD
extern __imp_printf:QWORD
extern __imp__getch:QWORD

.data

msg db 'hello world %d', 0Ah, 'press any key...', 0
msg db 'hello world %d', 0Ah, 'press any key...', 0


.code

main proc
	sub rsp, 4*8
    lea rcx, msg
	mov rdx, 8
    call __imp_printf
    call __imp__getch
    mov rcx, 0
	call __imp_ExitProcess
main endp

end