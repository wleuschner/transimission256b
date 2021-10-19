;Should be run at around 20k cycles in dosbox
org 100h

push 0xa000
pop es
mov al,13h
int 10h

palloop:
mov ax,cx
mov dx,0x3c8
out dx,al    ; select palette color
inc dx
xor ax,dx
out dx,al    ; write red value (0..63)
out dx,al    ; write green value (0..63)
out dx,al    ; write blue value (0..63)
loop palloop

mainloop:
mov ax,0xCCCD
mul di
xor ax,ax

cmp bl,64
jbe short checker
cmp bl,128
jbe short left_side

mov ah,dl
cmp dl,127
jbe left_side
add ah,bl;[bp+0]
test ah,16
jnz short lower
sub ah,dh
test ah,16
jnz short lower
mov al,ah
jmp short lower

left_side:
sub ah,bl
add ah,dh
xor ah,dh
test ah,16
jz lower
mov al,ah

lower:
cmp dh,128
jbe fill
checker:
mov bh,255
sub bh,dh
cmp dl,bh
jbe fill

mov ah,dl
add ah,bh
cmp ah,bh
jbe fill

;draw triangles
mov al,dh
add al,bl
and al,31
mov bh,dl
mov ah,dl
test ah,16
jnz no_adjust
mov bh,15
and ah,bh
sub bh,ah
mov ah,bh
no_adjust:
and ah,15
sub al,ah
add al,bl
jbe fill

fill:
mov si,bx
jmp ring_jsr
ring_enter:
mov bx,si
add al, bl
stosb

loop mainloop

inc bl

;some music
or al,0x4B
out 0x42,al
out 0x61,al

in al,60h
dec al
jnz mainloop

ret

;Ring Subroutine
ring_jsr:
push ax

mov al,dh
sub al,127
imul al
mov bx,ax

mov al,dl
sub al,128
imul al
add ax,bx
mov bx,20
add bx,si
and bx,127
imul bx,bx

cmp ax,bx
jge inner_radius
pop ax
jmp ring_enter

inner_radius:
add bx,400
cmp ax,bx
jbe draw_ring
pop ax
jmp ring_enter

draw_ring:
;stosb
end_ring:
;loop ring
pop dx
jmp ring_enter
