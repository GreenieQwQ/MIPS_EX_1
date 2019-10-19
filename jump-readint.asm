.data
intbuf: #读取的缓冲区
    .space 1
newline:
    .asciiz "\n"
    .set noreorder
    .set noat


.text
.global main
main:
while_main:
    jal readint
    nop
    move $t0, $v0
    addi $t0, $t0, 0x30
    la $t1, intbuf
    sb $t0, 0($t1)  #(intbuf) = $t0 = readint() + '0'

    li $v0, 4004
    li $a0, 1
    la $a1, intbuf
    li $a2, 1
    syscall
    
    jal printline
    nop

    li $v0, 4001
    syscall
	nop


.global readint
readint: #去除空格/换行读取一个字符 将其转换为无符号数字 若无有效输入返回-1
while:    
    li $v0, 4003 #系统调用read    
    li $a0, 0 #从stdin读取
    la $a1, intbuf
    li $a2, 1
    syscall
    addi $t0, $v0, -1 # $t0 = $v0 - 1
    bne $t0, $zero, done #返回值$v0 != 1——非有效输入跳出循环
    nop
    move $t0, $a1 # $t0 = intbuf
    lbu $v0, 0($t0) #$v0 = 读取到的字符
    addi $t0, $zero, 32 #$t0 = ' '
    beq $v0, $t0, while
    nop
    addi $t0, $zero, 10 #$t0 = '\n'
    beq $v0, $t0, while
    nop
    addi $t0, $zero, 13 #$t0 = '\n'
    beq $v0, $t0, while
    nop
    addi $v0, $v0, -48 #$v0 -= '0'
    j readint_exit
    nop 
done:    
    addi $v0, $zero, -1 # $v0 = -1 
readint_exit:       
    jr $ra
    nop

.global printline #输出一个空行
printline:
    li $v0, 4004
    li $a0, 1
    la $a1, newline
    li $a2, 1
    syscall
    jr $ra
    nop

