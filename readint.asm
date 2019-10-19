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
    jal readint
    nop
    move $a0, $v0
    
    jal printint
    nop

    jal printline
    nop

    li $v0, 4001
    syscall
	nop


.global readint #用到$s0, $s1,调用时需压栈保存
readint: #去除空格/换行后读取数字直到再次遇见空格换行为止 //仅无符号数字有效 若EOF返回-1
    addi $sp, $sp, -8 #保存$s0和$s1 无递归调用不保存$ra
    sw  $s1, 4($sp)
    sw  $s0, 0($sp) 
ri_while_1:    
    li $v0, 4003 #系统调用read    
    li $a0, 0 #从stdin读取
    la $a1, intbuf
    li $a2, 1
    syscall

    addi $t0, $v0, -1 # $t0 = $v0 - 1
    bne $t0, $zero, ri_EOF #返回值$v0 != 1——非有效输入跳出循环
    nop

    move $t0, $a1 # $t0 = intbuf
    lbu $s0, 0($t0) #$s0 = 读取到的字符
    addi $t0, $zero, 32 #$t0 = ' '
    beq $s0, $t0, ri_while_1
    nop
    addi $t0, $zero, 10 #$t0 = '\n'
    beq $s0, $t0, ri_while_1
    nop
    addi $t0, $zero, 13 #$t0 = '\r'
    beq $s0, $t0, ri_while_1
    nop
    
    add $s1, $zero, $zero # result = 0
ri_while_2:
    addi    $t0, $zero, 10  # $t0 = 10
    mult	$s1, $t0			# $s1 * 10 = Hi and Lo registers
    mflo	$s1				# copy Lo to $s1, result *= 10
    addi    $s0, $s0, -48   # c -= '0'
    add $s1, $s1, $s0   # $s1 += c - '0' 

    li $v0, 4003 #系统调用read    
    li $a0, 0 #从stdin读取
    la $a1, intbuf
    li $a2, 1
    syscall

    addi $t0, $v0, -1 # $t0 = $v0 - 1
    bne $t0, $zero, ri_done #返回值$v0 != 1——EOF跳出循环
    nop

    move $t0, $a1 # $t0 = intbuf
    lbu $s0, 0($t0) #$s0 = 读取到的字符
    addi $t0, $zero, 32 #$t0 = ' '
    beq $s0, $t0, ri_done
    nop
    addi $t0, $zero, 10 #$t0 = '\n'
    beq $s0, $t0, ri_done
    nop
    addi $t0, $zero, 13 #$t0 = '\r'
    beq $s0, $t0, ri_done
    nop
    j   ri_while_2
    nop

ri_done:
    move $v0, $s1   # return result
    j   readint_exit
    nop
ri_EOF:    
    addi $v0, $zero, -1 # $v0 = -1 
readint_exit:       
    lw  $s0, 0($sp)
    lw  $s1, 4($sp)
    addi $sp, $sp, 8    #恢复现场
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
