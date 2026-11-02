# =====================================================================
# CE119 - Lab 02: Mang, chuoi, thu tuc va ngan xep
# MSSV : 25520295   (d = 5, k = 8)
# Cong cu: MARS 4.5
# Noi dung: TN2 (stats, histogram), Phan mo rong (draw_hist),
#           TN3 (check_brackets)
# Quy uoc: thu tuc chi dung $a, $v, $t va la thu tuc la (khong co jal)
# =====================================================================
.data
# --- Mang diem ca nhan: S[i] = (A0[i] + 5) mod 11, n = 12 -------------
S:          .word 0, 8, 2, 3, 7, 10, 1, 7, 0, 3, 9, 8
# --- Bo du lieu kiem thu T2, T3 --------------------------------------
t2:         .word 10
t3:         .word 4, 4, 4, 4, 4
# --- Bang tra nhom: grade_tab[s] = nhom cua diem s (11 byte) ----------
#   diem: 0 1 2 3 | 4 5 6 | 7 8 | 9 10
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
.align 2
hist:       .word 0, 0, 0, 0

# --- Chuoi dung cho in ket qua ----------------------------------------
msg_min:    .asciiz "min="
msg_max:    .asciiz " max="
msg_colon:  .asciiz ": ("
msg_comma:  .asciiz ", "
msg_close:  .asciiz ")\n"

# --- Chuoi kiem thu check_brackets (chuoi P dat dau tien) -------------
sP:         .asciiz "([{([{([])}])}])"
s1:         .asciiz "(a+b)*[c-{d/e}]"
s2:         .asciiz "f(x[i]{j}))"
s3:         .asciiz "{[(])}"
s4:         .asciiz "((a)"
s5:         .asciiz ""
s6:         .asciiz "no brackets here"
s7:         .asciiz "]"
s8:         .asciiz "([)]"
.align 2
str_tab:    .word sP, s1, s2, s3, s4, s5, s6, s7, s8

.text
main:
    # ---------------- TN2: thong ke diem ----------------
    # Doi bo du lieu: T1 (mac dinh) | T2: la $s1, t2 va li $s2, 1
    #                               | T3: la $s1, t3 va li $s2, 5
    la   $s1, S              # $s1 = dia chi mang diem
    li   $s2, 12             # $s2 = n

    move $a0, $s1
    move $a1, $s2
    jal  stats
    move $s3, $v0            # $s3 = min
    move $s4, $v1            # $s4 = max

    move $a0, $s1
    move $a1, $s2
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    # in dong 1: min=<..> max=<..>
    la   $a0, msg_min
    li   $v0, 4
    syscall
    move $a0, $s3
    li   $v0, 1
    syscall
    la   $a0, msg_max
    li   $v0, 4
    syscall
    move $a0, $s4
    li   $v0, 1
    syscall
    li   $a0, 10
    li   $v0, 11
    syscall

    # in dong 2: g0=<..> g1=<..> g2=<..> g3=<..>
    la   $s5, hist           # $s5 = con tro hist
    li   $s6, 0              # $s6 = chi so nhom
main_pr:
    li   $t0, 4
    beq  $s6, $t0, main_pr_end
    beq  $s6, $zero, main_nospace
    li   $a0, 32             # ' '
    li   $v0, 11
    syscall
main_nospace:
    li   $a0, 103            # 'g'
    li   $v0, 11
    syscall
    move $a0, $s6
    li   $v0, 1
    syscall
    li   $a0, 61             # '='
    li   $v0, 11
    syscall
    lw   $a0, 0($s5)
    li   $v0, 1
    syscall
    addi $s5, $s5, 4
    addi $s6, $s6, 1
    j    main_pr
main_pr_end:
    li   $a0, 10
    li   $v0, 11
    syscall

    # ---------------- Phan mo rong: ve pho diem ----------------
    la   $a0, hist
    li   $a1, 4
    jal  draw_hist

    # ---------------- TN3: kiem tra ngoac ----------------
    # Thu tu: P, 1, 2, ..., 8 (P dat dau de breakpoint o Buoc 3.5
    # dung vao chuoi P)
    la   $s1, str_tab        # $s1 = con tro bang chuoi
    li   $s2, 0              # $s2 = chi so bo (0 = P)
main_cb:
    li   $t0, 9
    beq  $s2, $t0, main_exit
    lw   $a0, 0($s1)
    jal  check_brackets
    move $s3, $v0
    move $s4, $v1
    # in nhan bo: P hoac so 1..8
    bne  $s2, $zero, main_cb_num
    li   $a0, 80             # 'P'
    li   $v0, 11
    syscall
    j    main_cb_lbl
main_cb_num:
    move $a0, $s2
    li   $v0, 1
    syscall
main_cb_lbl:
    la   $a0, msg_colon
    li   $v0, 4
    syscall
    move $a0, $s3
    li   $v0, 1
    syscall
    la   $a0, msg_comma
    li   $v0, 4
    syscall
    move $a0, $s4
    li   $v0, 1
    syscall
    la   $a0, msg_close
    li   $v0, 4
    syscall
    addi $s1, $s1, 4
    addi $s2, $s2, 1
    j    main_cb
main_exit:
    li   $v0, 10
    syscall

# ---------------------------------------------------------------------
# stats: tim gia tri nho nhat va lon nhat cua mang word (mot luot duyet)
# Tham so : $a0 = dia chi mang word, $a1 = n (n >= 1)
# Tra ve  : $v0 = min, $v1 = max
# Thanh ghi dung: $a0, $a1 (bi thay doi), $t0, $v0, $v1. Khong ghi bo nho.
# ---------------------------------------------------------------------
stats:
    lw   $v0, 0($a0)         # min = max = phan tu dau
    move $v1, $v0
    addi $a0, $a0, 4
    addi $a1, $a1, -1
st_loop:
    beq  $a1, $zero, st_done
    lw   $t0, 0($a0)
    slt  $t1, $t0, $v0       # t0 < min ?
    beq  $t1, $zero, st_chkmax
    move $v0, $t0
st_chkmax:
    slt  $t1, $v1, $t0       # max < t0 ?
    beq  $t1, $zero, st_next
    move $v1, $t0
st_next:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    st_loop
st_done:
    jr   $ra

# ---------------------------------------------------------------------
# histogram: dem so diem trong tung nhom xep loai
# Tham so : $a0 = dia chi mang diem (word), $a1 = n,
#           $a2 = dia chi grade_tab (byte), $a3 = dia chi hist (4 word)
# Tra ve  : khong; hist[grade_tab[s]] duoc tang them 1 voi moi diem s
# Thanh ghi dung: $a0, $a1 (bi thay doi), $t0..$t4
# ---------------------------------------------------------------------
histogram:
hg_loop:
    beq  $a1, $zero, hg_done
    lw   $t0, 0($a0)         # s = diem
    add  $t1, $a2, $t0       # dia chi grade_tab[s] (mang byte: khong nhan 4)
    lbu  $t2, 0($t1)         # g = nhom
    sll  $t2, $t2, 2         # offset byte trong hist (mang word)
    add  $t3, $a3, $t2       # dia chi hist[g]
    lw   $t4, 0($t3)
    addi $t4, $t4, 1
    sw   $t4, 0($t3)
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    hg_loop
hg_done:
    jr   $ra

# ---------------------------------------------------------------------
# draw_hist: ve pho diem bang ky tu '|' (phan mo rong)
# Tham so : $a0 = dia chi mang hist, $a1 = so nhom (4)
# Tra ve  : khong (in ra Run I/O)
# Thanh ghi dung: $t0 = con tro hist, $t1 = chi so nhom, $t2 = bo dem
#                 ($a0, $v0 bi syscall ghi de nen con tro cat sang $t0)
# ---------------------------------------------------------------------
draw_hist:
    move $t0, $a0
    li   $t1, 0
dh_row:
    beq  $t1, $a1, dh_done
    li   $v0, 11
    li   $a0, 103            # 'g'
    syscall
    li   $v0, 1
    move $a0, $t1            # chi so nhom
    syscall
    li   $v0, 11
    li   $a0, 58             # ':'
    syscall
    li   $a0, 32             # ' '
    syscall
    lw   $t2, 0($t0)         # so sinh vien cua nhom
dh_bar:
    beq  $t2, $zero, dh_nl
    li   $v0, 11
    li   $a0, 124            # '|'
    syscall
    addi $t2, $t2, -1
    j    dh_bar
dh_nl:
    li   $v0, 11
    li   $a0, 10             # xuong dong
    syscall
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    j    dh_row
dh_done:
    jr   $ra

# ---------------------------------------------------------------------
# check_brackets: kiem tra ngoac ( ) [ ] { } can bang bang ngan xep
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = vi tri (dem tu 1), $v1 = ma loi (0,1,2,3)
#           0: hop le (v0 = 0)
#           1: ngoac dong khac loai ngoac mo o dinh (v0 = vi tri ngoac dong)
#           2: ngoac dong khi ngan xep rong (v0 = vi tri ngoac dong)
#           3: het chuoi nhung con ngoac mo (v0 = do dai chuoi + 1)
# Thanh ghi dung: $a0 (con tro chuoi, bi thay doi), $t0 = vi tri,
#                 $t1 = ky tu, $t2 = $sp luc vao (day ngan xep),
#                 $t3, $t4 = ky tu mo tuong ung, $t5 = phan tu pop ra
# Ngan xep: moi phan tu 1 word (ma ky tu ngoac mo). Moi duong thoat deu
#           qua cb_exit de khoi phuc $sp = $t2.
# ---------------------------------------------------------------------
check_brackets:
    move $t2, $sp            # luu $sp luc vao (day ngan xep)
    li   $t0, 1              # vi tri ky tu hien tai
cb_loop:
    lbu  $t1, 0($a0)
    beq  $t1, $zero, cb_end  # gap ky tu ket thuc chuoi
    li   $t3, 40             # '('
    beq  $t1, $t3, cb_push
    li   $t3, 91             # '['
    beq  $t1, $t3, cb_push
    li   $t3, 123            # '{'
    beq  $t1, $t3, cb_push
    li   $t4, 40             # mong doi '(' neu gap ')'
    li   $t3, 41             # ')'
    beq  $t1, $t3, cb_close
    li   $t4, 91             # mong doi '[' neu gap ']'
    li   $t3, 93             # ']'
    beq  $t1, $t3, cb_close
    li   $t4, 123            # mong doi '{' neu gap '}'
    li   $t3, 125            # '}'
    beq  $t1, $t3, cb_close
    j    cb_next             # ky tu khac: bo qua
cb_push:
    addi $sp, $sp, -4        # push ngoac mo
    sw   $t1, 0($sp)
    j    cb_next
cb_close:                    # <-- dat breakpoint tai lenh ke tiep (Buoc 3.5)
    beq  $sp, $t2, cb_err2   # ngan xep rong
    lw   $t5, 0($sp)         # pop
    addi $sp, $sp, 4
    bne  $t5, $t4, cb_err1   # khac loai
cb_next:
    addi $a0, $a0, 1
    addi $t0, $t0, 1
    j    cb_loop
cb_err1:
    move $v0, $t0
    li   $v1, 1
    j    cb_exit
cb_err2:
    move $v0, $t0
    li   $v1, 2
    j    cb_exit
cb_end:
    beq  $sp, $t2, cb_ok     # ngan xep rong -> hop le
    move $v0, $t0            # $t0 = do dai chuoi + 1
    li   $v1, 3
    j    cb_exit
cb_ok:
    li   $v0, 0
    li   $v1, 0
cb_exit:
    move $sp, $t2            # khoi phuc $sp tren moi duong thoat
    jr   $ra