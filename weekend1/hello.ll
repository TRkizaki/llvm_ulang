; hello.ll — minimal LLVM IR that prints "hello, world" via libc's puts

target triple = "x86_64-pc-linux-gnu"

; Global string constant. 14 bytes = "hello, world\00" (null-terminated).
; The \00 is required because puts expects a C string.
@.str = private unnamed_addr constant [13 x i8] c"hello, world\00", align 1

; Declare puts as an external function. LLVM doesn't define it —
; the linker will resolve it against libc at link time.
declare i32 @puts(ptr)

; main returns i32 and takes no args (the (void) equivalent).
define i32 @main() {
entry:
  ; Get a pointer to the first byte of @.str and pass it to puts.
  %str_ptr = getelementptr [13 x i8], ptr @.str, i64 0, i64 0
  %call_result = call i32 @puts(ptr %str_ptr)
  ret i32 0
}
