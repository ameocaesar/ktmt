
        .data
n_notes: .word 15
pitch:   .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
dur:     .word 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  1,  4

space:   .asciiz " "
newline: .asciiz "\n"
msg_est: .asciiz "Tong du kien (ms): "
msg_act: .asciiz "Thoi gian do duoc (ms): "

        .text
        .globl main
main:
        la    $s0, pitch            # Con tro mang cao do
        la    $s1, dur              # Con tro mang do dai
        lw    $s2, n_notes          # So luong not (15)
        li    $s3, 0                # Tong thoi luong du kien (ms)

        # Doc thoi gian bat dau (syscall 30)
        li    $v0, 30
        syscall
        move  $s4, $a0              # Luu thoi gian bat dau vao $s4

loop:
        beq   $s2, $zero, done
        lw    $t0, 0($s0)           # Lay cao do goc
        addiu $t0, $t0, 5           # Cong a = 5
        lw    $t1, 0($s1)           # Lay do dai (don vi nhip)
        li    $t2, 240              # 1 don vi nhip = 150 + 10*9 = 240 ms
        mul   $t1, $t1, $t2         # Thoi luong not (ms)
        addu  $s3, $s3, $t1         # Cong don vao tong du kien

        # In "<cao do> <ms>\n"
        move  $a0, $t0
        li    $v0, 1
        syscall
        la    $a0, space
        li    $v0, 4
        syscall
        move  $a0, $t1
        li    $v0, 1
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall

        # Phat not nhac (Cau hinh A: syscall 33)
        move  $a0, $t0              # Cao do
        move  $a1, $t1              # Thoi luong (ms)
        li    $a2, 24               # Nhac cu (b=9 % 4 = 1 -> 24)
        li    $a3, 100              # Am luong = 100
        li    $v0, 33               # Syscall 33 (phat dong bo)
        syscall

        addiu $s0, $s0, 4
        addiu $s1, $s1, 4
        addiu $s2, $s2, -1
        j     loop

done:
        # Doc thoi gian ket thuc (syscall 30)
        li    $v0, 30
        syscall
        subu  $s5, $a0, $s4         # Thoi gian do duoc = t_cuoi - t_dau

        # In Tong du kien (ms)
        la    $a0, msg_est
        li    $v0, 4
        syscall
        move  $a0, $s3
        li    $v0, 1
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall

        # In Thoi gian do duoc (ms)
        la    $a0, msg_act
        li    $v0, 4
        syscall
        move  $a0, $s5
        li    $v0, 1
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall

        li    $v0, 10
        syscall
