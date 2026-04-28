; hello_freestanding.ll — no libc, raw syscalls, custom _start

target triple = "x86_64-unknown-linux-gnu"

; The string we want to print. 13 bytes. No null terminator needed —
; the write syscall takes a length, not a C string.
@msg = private constant [13 x i8] c"hello, world\0A", align 1

; _start is the entry point the kernel jumps to when the process begins.
; It takes no arguments in the C sense — argc/argv are on the stack,
; but we're ignoring them this weekend.
; It must never return — there's nothing to return to.
define void @_start() noreturn {
entry:
  ; Get a pointer to the start of the message.
  %msg_ptr = getelementptr [13 x i8], ptr @msg, i64 0, i64 0

  ; --- syscall: write(fd=1, buf=%msg_ptr, count=13) ---
  ; On x86-64 Linux:
  ;   syscall number goes in rax
  ;   args go in rdi, rsi, rdx, r10, r8, r9 (in that order)
  ;   the `syscall` instruction transitions to the kernel
  ;   return value comes back in rax
  ;
  ; write is syscall number 1.
  ; The constraint string "={rax},{rax},{rdi},{rsi},{rdx},~{rcx},~{r11},~{memory}"
  ; means:
  ;   ={rax}  — output goes in rax
  ;   {rax}   — first input in rax (syscall number)
  ;   {rdi}   — second input in rdi (fd)
  ;   {rsi}   — third input in rsi (buffer)
  ;   {rdx}   — fourth input in rdx (count)
  ;   ~{rcx}, ~{r11} — these registers are clobbered by syscall (kernel uses them)
  ;   ~{memory} — memory may have changed (the kernel wrote to fd, etc.)
  %write_ret = call i64 asm sideeffect
    "syscall",
    "={rax},{rax},{rdi},{rsi},{rdx},~{rcx},~{r11},~{memory}"
    (i64 1, i64 1, ptr %msg_ptr, i64 13)

  ; --- syscall: exit(0) ---
  ; exit is syscall number 60. Takes one arg: the exit status.
  call i64 asm sideeffect
    "syscall",
    "={rax},{rax},{rdi},~{rcx},~{r11},~{memory}"
    (i64 60, i64 0)

  ; unreachable tells LLVM "control flow does not continue past this point."
  ; Without it, LLVM might complain that a void function with `noreturn`
  ; falls off the end.
  unreachable
}
