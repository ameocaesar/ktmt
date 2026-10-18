
        .data
thr:    .word 50, 100, 200, 300, 400, 9999          
price:  .word 1700, 1760, 2050, 2600, 2950, 3100    
Nhapgiatri: .asciiz "Nhap so kWh (0..9999): "
khonghople: .asciiz "Gia tri khong hop le, nhap lai.\n"
Tiendien:   .asciiz "Tien dien: "
vnd:        .asciiz " dong\n"

        .text
        .globl main
main:
doc:    la    $a0, Nhapgiatri           
        li    $v0, 4
        syscall
        li    $v0, 5                 
        syscall
        move  $s0, $v0               
        sltiu $t0, $s0, 10000       
        bne   $t0, $zero, ok         
        la    $a0, khonghople           
        li    $v0, 4
        syscall
        j     doc

ok:     la    $s3, thr               
        la    $s4, price
        li    $s1, 0                 
        li    $s2, 0                 

loop:   lw    $t0, 0($s3)            
        lw    $t1, 0($s4)            
        slt   $t2, $t0, $s0          
        beq   $t2, $zero, last       
        subu  $t3, $t0, $s2          
        mul   $t3, $t3, $t1          
        addu  $s1, $s1, $t3          
        move  $s2, $t0               
        addiu $s3, $s3, 4            
        addiu $s4, $s4, 4
        j     loop

last:   subu  $t3, $s0, $s2          
        mul   $t3, $t3, $t1
        addu  $s1, $s1, $t3          

        la    $a0, Tiendien           
        li    $v0, 4
        syscall
        move  $a0, $s1
        li    $v0, 1
        syscall
        la    $a0, vnd
        li    $v0, 4
        syscall
        li    $v0, 10                
        syscall