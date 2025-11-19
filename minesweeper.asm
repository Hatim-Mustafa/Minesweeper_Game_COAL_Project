INCLUDE Irvine32.inc

.data
    visibleBoard BYTE 26*13 DUP('-')   ; Visible board, initialized with '-'
    actualBoard  BYTE 26*13 DUP('0')   ; Actual board with mines

    rows dword ?
    cols dword ?
    row dword ?
    col dword ?
    mines dword ?
    action byte ?
    first byte 1

    ; Board printing strings
    header1   BYTE 13 dup(' '),0
    header2   BYTE 13 dup(' '),0
    twoSpaces BYTE "  ",0
    indent    BYTE "                ",0

    ; Difficulty messages
    diff1 BYTE "Choose difficulty (1: Easy, 2: Medium, 3: Hard): ",0
    diff2 BYTE "Invalid difficulty selected. Please try again: ",0

    ; Input Messages
    rowInput BYTE "Enter row: ", 0
    colInput BYTE "Enter column: ", 0
    invalidInputMsg BYTE "Invalid input. Please enter values within the board range.",0
    actionMsg BYTE "Do you want to open (O) or flag (F): ",0

    ;Game Over Message
    gameOverMsg BYTE "Game Over! You hit a mine.",0

    ;Game Win Message
    gameWinMsg BYTE "Congratulations! You've cleared the minefield!",0

    ;Restart Message
    restartMsg BYTE "Do you want to restart the game (Y/N): ",0

.code

difficulty PROC
    pushad
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
        popad
        ret
difficulty ENDP

initialise PROC
    pushad

    ; Initialize visible board with '*'
    mov ecx, 26*13
    mov edi, OFFSET visibleBoard
    mov al, '-'
    fill_board:
        stosb
    loop fill_board

    mov ecx, 26*13
    mov edi, OFFSET actualBoard
    mov al, '0'
    fill_board_actual:
        stosb
    loop fill_board_actual

    call placeMines

    mov first, 1

    popad
    ret
initialise ENDP

placeMines PROC
    pushad
    call Randomize  

    mov ecx, mines
    place_mine_loop:
        mov eax, rows
        call RandomRange
        mov ebx, eax

        mov eax, cols
        call RandomRange
        mov edx, eax

        mov eax, ebx
        imul eax, cols
        add eax, edx

        mov bl, [actualBoard + eax]
        cmp bl, '*'
        je place_mine_loop

        mov [actualBoard + eax], '*'
    loop place_mine_loop
    popad
    ret
placeMines ENDP

replaceMine PROC
    push ebp
    mov ebp, esp

    call Randomize

    l1:
        mov eax, rows
        call RandomRange
        mov ebx, eax

        mov eax, cols
        call RandomRange
        mov edx, eax

        push edx
        push ebx
        call checkMine
    jz l1

    mov eax, ebx
    imul eax, cols
    add eax, edx
    mov [actualBoard + eax], '*'

    mov eax, [ebp+8]
    imul eax, cols
    add eax, [ebp+12]
    mov [actualBoard + eax], '0'

    pop ebp
    ret 8
replaceMine ENDP

validate PROC
    push ebp
    mov ebp, esp
    push eax

    mov eax, [ebp+8]
    cmp eax, 0
    jl invalid_input
    mov ebx, rows
    cmp eax, ebx
    jge invalid_input
    mov eax, [ebp+12]
    cmp eax, 0
    jl invalid_input
    mov ebx, cols
    cmp eax, ebx
    jge invalid_input
    or al, 1
    jmp done

    invalid_input:
    test al, 0

    done:
    pop eax
    pop ebp
    ret 8
validate ENDP


takeInput PROC
    pushad
    jmp l1

    l2:
    mov edx, OFFSET invalidInputMsg
    call WriteString
    call crlf

    l1:
    mov edx, offset rowInput
    call WriteString
    call ReadInt
    mov row, eax

    mov edx, offset colInput
    call WriteString
    call ReadInt
    mov col, eax

    push col
    push row
    call validate
    jz l2

    l3:
    mov edx, offset actionMsg
    call WriteString
    call ReadChar
    cmp al, 'O'
    jz next
    cmp al, 'o'
    jz next
    cmp al, 'F'
    jz next
    cmp al, 'f'
    jz next
    call crlf
    jmp l3
    next:
    mov action, al

    popad
    ret
takeInput ENDP

checkMine PROC
    push ebp
    mov ebp, esp
    push ebx

    mov eax, [ebp+8]
    imul eax, cols
    add eax, [ebp+12]
    mov bl, [actualBoard + eax]
    or al, 1
    cmp bl, '*'

    pop ebx
    pop ebp
    ret 8
checkMine ENDP

openCell PROC

    push ebp
    mov ebp, esp

    sub esp, 4
    mov eax, 0
    mov [ebp-4], eax

    mov eax, [ebp+8]
    imul eax, cols
    add eax, [ebp+12]
    mov cl, [visibleBoard + eax]
    cmp cl, '-'
    jne done_open

    mov ecx, [ebp+8]
    add ecx, 1
    push col
    push ecx
    call validate
    jz next
    push col
    push ecx
    call checkMine
    jnz next
    mov eax, 1
    add [ebp-4], eax

    next:
    mov ecx, [ebp+8]
    sub ecx, 1
    push col
    push ecx
    call validate
    jz next2
    push col
    push ecx
    call checkMine
    jnz next2
    mov eax, 1
    add [ebp-4], eax

    next2:
    mov ecx, [ebp+12]
    add ecx, 1
    push ecx
    push row
    call validate
    jz next3
    push ecx
    push row
    call checkMine
    jnz next3
    mov eax, 1
    add [ebp-4], eax

    next3:
    mov ecx, [ebp+12]
    sub ecx, 1
    push ecx
    push row
    call validate
    jz next4
    push ecx
    push row
    call checkMine
    jnz next4
    mov eax, 1
    add [ebp-4], eax

    next4:
    mov eax, [ebp+8]
    inc eax
    mov ecx, [ebp+12]
    inc ecx
    push ecx
    push eax
    call validate
    jz next5
    push ecx
    push eax
    call checkMine
    jnz next5
    mov eax, 1
    add [ebp-4], eax

    next5:
    mov eax, [ebp+8]
    dec eax
    mov ecx, [ebp+12]
    inc ecx
    push ecx
    push eax
    call validate
    jz next6
    push ecx
    push eax
    call checkMine
    jnz next6
    mov eax, 1
    add [ebp-4], eax

    next6:
    mov eax, [ebp+8]
    inc eax
    mov ecx, [ebp+12]
    dec ecx
    push ecx
    push eax
    call validate
    jz next7
    push ecx
    push eax
    call checkMine
    jnz next7
    mov eax, 1
    add [ebp-4], eax

    next7:
    mov eax, [ebp+8]
    dec eax
    mov ecx, [ebp+12]
    dec ecx
    push ecx
    push eax
    call validate
    jz l1
    push ecx
    push eax
    call checkMine
    jnz l1
    mov eax, 1
    add [ebp-4], eax

    l1:
    mov eax, [ebp-4]
    cmp eax, 0
    jnz set_count
    jz recurse

    set_count:
    mov ebx, [ebp-4]
    add ebx, '0'
    mov eax, [ebp+8]
    imul eax, cols
    add eax, [ebp+12]
    mov [VisibleBoard + eax], bl
    jmp done_open

    recurse:
    mov ecx, [ebp+8]
    add ecx, 1
    push col
    push ecx
    call validate
    jz nextR
    push col
    push ecx
    call openCell

    nextR:
    mov ecx, [ebp+8]
    sub ecx, 1
    push col
    push ecx
    call validate
    jz nextR2
    push col
    push ecx
    call openCell

    nextR2:
    mov ecx, [ebp+12]
    add ecx, 1
    push ecx
    push row
    call validate
    jz nextR3
    push ecx
    push row
    call openCell

    nextR3:
    mov ecx, [ebp+12]
    sub ecx, 1
    push ecx
    push row
    call validate
    jz nextR4
    push ecx
    push row
    call openCell

    nextR4:
    mov eax, [ebp+8]
    inc eax
    mov ecx, [ebp+12]
    inc ecx
    push ecx
    push eax
    call validate
    jz nextR5
    push ecx
    push eax
    call openCell

    nextR5:
    mov eax, [ebp+8]
    dec eax
    mov ecx, [ebp+12]
    inc ecx
    push ecx
    push eax
    call validate
    jz nextR6
    push ecx
    push eax
    call openCell

    nextR6:
    mov eax, [ebp+8]
    inc eax
    mov ecx, [ebp+12]
    dec ecx
    push ecx
    push eax
    call validate
    jz nextR7
    push ecx
    push eax
    call openCell

    nextR7:
    mov eax, [ebp+8]
    dec eax
    mov ecx, [ebp+12]
    dec ecx
    push ecx
    push eax
    call validate
    jz done_open
    push ecx
    push eax
    call openCell
    
    done_open:
    mov esp, ebp
    pop ebp
    ret 8
openCell ENDP

showMines PROC
    pushad

    mov  row, 0          
    rowL:
        mov ebx, rows
        cmp  row, ebx
        jge  done        

        mov  col, 0          
    colL:
        mov  ebx, cols
        cmp  col, ebx
        jge  next

        push col             
        push row             
        call checkMine       
    
        jz placemine 
        jmp skipcell

    placemine:
        mov  eax, row
        imul eax, cols
        add  eax, col
        mov  [VisibleBoard + eax], '*'

    skipcell:
        inc  col
        jmp  colL

    next:
        inc  row
        jmp  rowL

    done:
    popad
    ret
showMines ENDP

playMove PROC
    pushad

    call takeInput
    cmp action, 'F'
    je flag_cell
    cmp action, 'f'
    je flag_cell
    jmp open_cell

    flag_cell:
        mov eax, row
        imul eax, cols
        add eax, col
        mov bl, [visibleBoard + eax]
        cmp bl, 'F'
        je unflag_cell
        mov [visibleBoard + eax], 'F'
        jmp done_move

    unflag_cell:
        mov eax, row
        imul eax, cols
        add eax, col
        mov [visibleBoard + eax], '-'
        jmp done_move

    open_cell:
        push col
        push row
        call checkMine
        jz first_move
        jmp open

        first_move:
            cmp first, 0
            jnz replace_mine
            jmp done_move

        replace_mine:
            push col
            push row
            call replaceMine

        open:
        mov first, 0
        push col
        push row
        call openCell
        or al, 1

    done_move:
    popad
    ret
playMove ENDP

main PROC
    
    startGame:
        call Clrscr
        call difficulty
        call initialise

    nextMove:
        call checkWinCondition
        jz gameWin
        call printboard
        call playMove
        jnz nextMove
        jmp gameOver

    gameOver:
        call showMines
        call printboard
        mov edx, OFFSET gameOverMsg
        call WriteString
        jmp RestartProgram

    gameWin:
        call Clrscr
        mov edx, OFFSET gameWinMsg
        call WriteString
        call printboard

    RestartProgram:
        call crlf
        call crlf
        mov edx, OFFSET restartMsg
        call WriteString
        call ReadChar
        cmp al, 'Y'
        je startGame
        cmp al, 'y'
        je startGame
        jmp exitProgram


    exitProgram:
    exit
main ENDP

CheckWinCondition PROC
    pushad

    mov  row, 0          
    rowL:
        mov ebx, rows
        cmp  row, ebx
        jge  win         

        mov  col, 0          
    colL:
        mov  ebx, cols
        cmp  col, ebx
        jge  next         ; next row

        push col             
        push row             
        call checkMine       
    
        jz   skipcell        

        mov  eax, row
        imul eax, cols
        add  eax, col
        mov  al, [VisibleBoard + eax]

        cmp al, '-'
        jnz  skipcell        

        ; if closed non-mine cell found then...
        or   al, 1           
        jmp  Done

    skipcell:
        inc  col
        jmp  colL

    next:
        inc  row
        jmp  rowL

    win:
        test al, 0           

    Done:
    popad
    ret
CheckWinCondition ENDP

printboard PROC
    push ebp
    mov ebp, esp

    mov ebx, OFFSET VisibleBoard
    call Clrscr

    mov ecx, rows        ; total rows
    mov edi, cols        ; total columns

    ; Print column header - Tens
    mov esi, 0          ; column [ebp-4]er
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

END main