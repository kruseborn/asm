extern printf: PROC
extern sinf: PROC
extern cosf: PROC

Bullets struct
	x dd 2 dup (0)
	y dd 2 dup (0)
	angles dd 2 dup (0)
	count dd (0)
Bullets ends

.data
msg db 'hello world fucker', 0Ah, 00
value1 dd 1.0

vX dd 0.0
vY dd 0.0

accelerate dd 0.3
rotate dd 0.06
dragFactor dd 0.002

windowSize dd 1024.0f
zero dd 0.0f

speed dd 0.0

angle dd 0.0
 
.code

movePlayer proc
	;x
	movss xmm0, DWORD PTR[rcx] 
	movss xmm1, DWORD PTR[vX] 
	movss xmm2, xmm1 
	addss xmm0, xmm1

	movss DWORD PTR[rcx], xmm0
		
	;y
	movss xmm0, DWORD PTR[rdx] 
	movss xmm1, DWORD PTR[vY] 
	movss xmm2, xmm1 
	addss xmm0, xmm1
	movss DWORD PTR[rdx], xmm0
	ret
movePlayer endp

boundsCheck proc
	movss xmm0, DWORD PTR[rcx] ; x
	movss xmm1, DWORD PTR[rdx] ; y
	movss xmm3, DWORD PTR[windowSize]
	movss xmm4, DWORD PTR[zero]
	comiss xmm0,xmm3
	jbe L1
	mov DWORD PTR[rcx], 0
L1: 
	comiss xmm4, xmm0
	jbe L2
	movss DWORD PTR[rcx], xmm3
L2:
	comiss xmm1,xmm3
	jbe L3
	mov DWORD PTR[rdx], 0
L3: 
	comiss xmm4, xmm1
	jbe L4
	movss DWORD PTR[rdx], xmm3
L4:
	ret
boundsCheck endp

updateDragFactor proc
	movss xmm0, DWORD PTR[vX]
	movss xmm1, DWORD PTR[vY] 
	movss xmm2, xmm0
	movss xmm3, xmm1 

	mulss xmm2, DWORD PTR[dragFactor]
	mulss xmm3, DWORD PTR[dragFactor]

	subss xmm0, xmm2
	movss DWORD PTR[vX], xmm0
	subss xmm1, xmm3
	movss DWORD PTR[vY], xmm1
	ret
updateDragFactor endp


;rcx, rdx, r8, and r9 registers.
;All registers must be preserved across the call, except for rax, rcx, rdx, r8, r9, r10, and r11, which are scratch.
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
	call movePlayer
	call boundsCheck
	call updateDragFactor

	movss xmm0, DWORD PTR[angle] ; return value

	mov rsp, rbp
	pop rbp
	ret
updatePlayer endp

shootBullets proc
	push rbp
	mov rbp, rsp
	sub rsp, 40

 	cmp [r9].Bullets.count, 5
	je Finish
	add [r9].Bullets.count, 1
	mov eax, [r9].Bullets.count
	sub eax, 1

	movss xmm0, DWORD PTR[angle]
	lea r12, [r9].Bullets.angles
	movss DWORD PTR[r12 + rax*4], xmm0

	movss xmm0, DWORD PTR[rcx]
	lea r12, [r9].Bullets.x
	movss DWORD PTR[r12 + rax*4], xmm0

	movss xmm0, DWORD PTR[rdx]
	lea r12, [r9].Bullets.y
	movss DWORD PTR[r12 + rax*4], xmm0
Finish:
	mov rsp, rbp
	pop rbp
	ret
shootBullets endP

moveBullets proc
	push rbp
	mov rbp, rsp
	sub rsp, 40

	mov eax, [r9].Bullets.count
LOOPING:
	movss xmm0, [r9].Bullets.angles
	call cosf
	movss xmm1, xmm0
	movss xmm0, [r9].Bullets.angles
	call sinf
	movss xmm2, xmm0

	movss xmm3, DWORD PTR[rcx]
	movss xmm4, DWORD PTR[rdx]
	movss xmm2, DWORD PTR[angle] ; return value

	dec eax
	jnz LOOPING
FINISH:
	mov rsp, rbp
	pop rbp
	ret
moveBullets endp

printWorld proc
	sub rsp, 40

	add [r9].Bullets.count, 1

	call updatePlayer
	cmp r8, 4
	jne NO_SHOOT
	call shootBullets
NO_SHOOT:
	add rsp, 40
    ret
printWorld endp

End