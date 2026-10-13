target datalayout = "e-m:e-p:32:32-v1:8:8-i64:64-i128:128-n32"
target triple = "xtensa-unknown-none-elf"

define void @f(ptr %node, i32 %len, i32 %end) {
entry:
  %edges = getelementptr inbounds nuw i8, ptr %node, i32 2044
  %start = add nuw nsw i32 %len, 1
  br label %loop
loop:
  %i = phi i32 [ %start, %entry ], [ %next, %loop ]
  %next = add nuw nsw i32 %i, 1
  %slot = getelementptr inbounds nuw ptr, ptr %edges, i32 %i
  %child = load ptr, ptr %slot, align 4
  %parent = getelementptr inbounds nuw i8, ptr %child, i32 2024
  store ptr %node, ptr %parent, align 4
  %done = icmp eq i32 %i, %end
  br i1 %done, label %exit, label %loop
exit:
  ret void
}
