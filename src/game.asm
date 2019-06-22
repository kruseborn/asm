extern printf: PROC
extern sinf: PROC
extern cosf: PROC


.data
msg db 'hello world fucker', 0Ah, 00
value1 dd 1.0

vX dd 0.0
vY dd 0.0

accelerate dd 0.3
rotate dd 0.06
dragFactor dd 0.002

height dd 1024.0f
minHeight dd 0.0f

speed dd 0.0

angle dd 0.0

.code

;rcx, rdx, r8, and r9 registers.
;All registers must be preserved across the call, except for rax, rcx, rdx, r8, r9, r10, and r11, which are scratch.
;rcx, x, rdx, y, r8, dir, and r9 registers.
updatePlayer proc
	push rbp
	mov rbp, rsp
	sub rsp, 40
	
	movss xmm0, DWORD PTR[angle]
	cmp r8, 0
	jne DO_NOACC
DO_ACC:
	movss xmm0, DWORD PTR[angle]
	call sinf ;xmm0 xN
	movss xmm1, DWORD PTR[vX]
	movss xmm2, DWORD PTR[accelerate]
	mulss xmm0, xmm2
	addss xmm1, xmm0 ;vx += xN * acc
	movss DWORD PTR[vX], xmm1

	movss xmm0, DWORD PTR[angle]
	call cosf ;xmm0 xN
	movss xmm1, DWORD PTR[vY]
	movss xmm2, DWORD PTR[accelerate]
	mulss xmm0, xmm2
	addss xmm1, xmm0 ;vy += xN * acc
	movss DWORD PTR[vY], xmm1

	jmp DO_NOTHING
DO_NOACC:
	cmp r8, 1
	jne TURN_LEFT
	jmp DO_NOTHING
TURN_LEFT:
	cmp r8, 2
	jne TURN_RIGHT
	movss xmm2, DWORD PTR[rotate]
	subss xmm0, xmm2
	movss DWORD PTR[angle], xmm0

	jmp DO_NOTHING
TURN_RIGHT:
	cmp r8, 3
	jne DO_NOTHING
	movss xmm2, DWORD PTR[rotate]
	addss xmm0, xmm2
	movss DWORD PTR[angle], xmm0

	jmp DO_NOTHING

DO_NOTHING:
	;x
	movss xmm0, DWORD PTR[rcx] 
	movss xmm1, DWORD PTR[vX] 
	movss xmm2, xmm1 
	addss xmm0, xmm1

	xorps xmm5, xmm5
	
	movss DWORD PTR[rcx], xmm0
	movss xmm4, DWORD PTR[height]
	comiss xmm0,xmm4
	jbe L3
	mov DWORD PTR[rcx], 0
L3: 
	comiss xmm5, xmm0
	jbe L4
	movss DWORD PTR[rcx], xmm4
L4:
	mulss xmm1, DWORD PTR[dragFactor]
	subss xmm2, xmm1
	movss DWORD PTR[vX], xmm2 
	
	;y
	movss xmm0, DWORD PTR[rdx] 
	movss xmm1, DWORD PTR[vY] 
	movss xmm2, xmm1 
	addss xmm0, xmm1
	comiss xmm0, xmm4
	movss DWORD PTR[rdx], xmm0
	jbe L2
	mov DWORD PTR[rdx], 0
L2:
	comiss xmm5, xmm0
	jge L5
	movss DWORD PTR[rdx], xmm4
L5:
	mulss xmm1, DWORD PTR[dragFactor]
	subss xmm2, xmm1
	movss DWORD PTR[vY], xmm2

	movss xmm0, DWORD PTR[angle]
	mov rsp, rbp
	pop rbp
	ret
updatePlayer endp

printWorld proc
	sub rsp, 40
	call updatePlayer
	add rsp, 40
    ret
printWorld endp

End