.data
intbuf: #读取的缓冲区
    .space 1
printbuf: #输出的缓冲区 共12字节
    .space 12
newline:
    .asciiz "\n"
    .set noreorder


.text
.global main
main:
    addi $s1, $zero, 1 # nowscore = 1
    add $s2, $zero, $zero # totalscore = 0
while_main:
    jal readint
    nop
    move $s0, $v0 #condition = readint()

    beq $s0, $zero, done_while # condition == 0
    nop
    
    addi $t0, $zero, -1
    beq $s0, $t0, done_while # condition == -1 
    nop

    addi $t0, $zero, 1
    beq $s0, $t0, cond_1 # condition == 1
    nop
    
cond_2:
    bne $s1, $t0, now_2 # nowscore != 1
    nop
    now_1:
        addi $s1, $zero, 2 # nowscore = 2
        j done_cond
        nop
    now_2:
        addi $s1, $s1, 2 # nowscore += 2
        j done_cond
        nop
cond_1:
    addi $s1, $zero, 1 # nowscore = 1

done_cond:
    add $s2, $s2, $s1 #totalscore += nowscore
    j while_main
    nop

done_while:
    move $a0, $s2 # call printint(totalscore)
    jal printint
    nop

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

.global printint #only positive
printint:
    la $s3, printbuf
    sw $zero, 0($s3)
    sw $zero, 4($s3)
    sw $zero, 8($s3)   #memset( buf, 0, sizeof(buf));

    li $s0, 0 # remainder
    li $s1, 1 # quotient
    li $s2, 0 # significant_bit

    beq $s1, $zero, done1 #if(quotient == 0) done
    nop
while1:  
    addi $t0, $zero, 10  # $t0 = 10
    div		$a0, $t0	# $a0 / 10 
    mflo	$s1		# $s1 = floor($a0 / 10) 
    mfhi	$s0		# $s0 = $a0 mod 10 
    add $t1, $s3, $s2 # $t1 = &buf[ significant_bit ]
    addi $s0, $s0, 48 # $s0 = remainder += '0'
    sb $s0, 0($t1) # buf[ significant_bit ] = remainder + '0'
    addi $s2, $s2, 1 # significant_bit ++
    move $a0, $s1 # a /= 10
    bne  $s1, $zero, while1
    nop
done1:
while2:
    addi $s2, $s2, -1  # significant_bit--
    add $t1, $s3, $s2 # $t1 = &buf[ significant_bit ]
    li $v0, 4004
    li $a0, 1
    move $a1, $t1 
    li $a2, 1
    syscall
    bne $s2, $zero, while2
    nop
done2:
    jr $ra
    nop
