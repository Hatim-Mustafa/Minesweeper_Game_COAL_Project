INCLUDE Irvine32.inc

.data
    visibleBoard BYTE 26*13 DUP(?)   ; Visible board, initialized with '*'
    actualBoard  BYTE 26*13 DUP(?)   ; Actual board with mines

    rows dword ?
    cols dword ?
    row dword ?
    col dword ?
    mines BYTE ?

    ; ===== Board printing strings =====
    header1   BYTE 13 dup(' '),0
    header2   BYTE 13 dup(' '),0
    twoSpaces BYTE "  ",0
    indent    BYTE "                ",0
    newlines  BYTE 13,10,0

    ; ===== Difficulty messages =====
    diff1 BYTE "Choose difficulty (1: Easy, 2: Medium, 3: Hard): ",0
    diff2 BYTE "Invalid difficulty selected. Please try again: ",0

    ; ===== Input Messages =====
    rowInput BYTE "Enter row: ", 0
    colInput BYTE "Enter column: ", 0
    invalidInputMsg BYTE "Invalid input. Please enter values within the board range.",0

.code

difficulty PROC
    mov edx, OFFSET diff1
    call WriteString

    difficultyInput:
        call ReadInt

        cmp eax,1
        je easy
        cmp eax,2
        je medium
        cmp eax,3
        je hard
        jmp invalid

    easy:
        mov rows, 12
        mov cols, 9
        mov mines, 10
        jmp done
    medium:
        mov rows, 19
        mov cols, 10
        mov mines, 35
        jmp done
    hard:
        mov rows, 26
        mov cols, 13
        mov mines, 75
        jmp done
    invalid:
        mov edx, OFFSET diff2
        call WriteString
        jmp difficultyInput
    done:
        ret
difficulty ENDP

printboard PROC
    push ebp
    mov ebp, esp

    mov ebx, OFFSET visibleBoard
    call Clrscr

    mov ecx, rows        ; total rows
    mov edi, cols        ; total columns

    ; Print column header - Tens
    mov esi, 0          ; column counter
    mov edx, OFFSET indent ; indent to align headers with board
    call WriteString

print_tens_loop:
    cmp esi, edi
    jge tens_done

    cmp esi, 9
    jle tens_space

    ; >=10, print tens digit + space
    mov eax, 1
    call WriteDec
    mov al,' '
    call WriteChar
    jmp tens_continue

tens_space:
    mov edx, OFFSET twoSpaces
    call WriteString

tens_continue:
    inc esi
    jmp print_tens_loop
tens_done:
    call Crlf

    ; Print column header - Ones
    mov esi, 0

    mov edx, OFFSET indent
    call WriteString 
print_ones_loop:
    cmp esi, edi
    jge ones_done

    mov eax, esi
    mov edx, 0
    mov ebp, 10
    div ebp
    mov al, dl
    call WriteDec
    mov al,' '
    call WriteChar

    inc esi
    jmp print_ones_loop
ones_done:
    call Crlf

    ; Print board rows
    mov ecx, 0 ; row index

row_loop:
    cmp ecx, rows
    jge end_print

    mov edx, OFFSET indent
    call WriteString

    mov esi, 0 ; column index
col_loop:
    cmp esi, edi
    jge row_done

    mov eax, ecx
    mul edi
    add eax, esi    ; index = row*cols + col
    mov al, [ebx + eax]
    call WriteChar
    mov al,' '
    call WriteChar

    inc esi
    jmp col_loop

row_done:
    mov eax, ecx
    call WriteDec     ; print row number
    call Crlf

    inc ecx
    jmp row_loop

end_print:
    pop ebp
    ret
printboard ENDP

validateInput PROC
    pushad

    mov eax, row
    cmp eax, 0
    jl invalid_input
    mov ebx, rows
    cmp eax, ebx
    jge invalid_input
    mov eax, col
    cmp eax, 0
    jl invalid_input
    mov ebx, cols
    cmp eax, ebx
    jge invalid_input
    ; Valid input
    or al, 1
    jmp done

    invalid_input:
        mov edx, OFFSET invalidInputMsg
        call WriteString
        call crlf
        test al, 0

    done:
    popad
    ret
validateInput ENDP



takeInput PROC
    pushad

    l1:
    mov edx, offset rowInput
    call WriteString
    call ReadInt
    mov row, eax

    mov edx, offset colInput
    call WriteString
    call ReadInt
    mov col, eax

    call validateInput
    jz l1
    popad
    ret
takeInput ENDP

main PROC
    call difficulty

    ; Initialize visible board with '*'
    mov ecx, 26*13
    mov edi, OFFSET visibleBoard
    mov al, '*'
    fill_board:
        stosb
        loop fill_board

    call printboard

    call takeInput

    exit
main ENDP

END main
