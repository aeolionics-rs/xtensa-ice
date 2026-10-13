target datalayout = "e-m:e-p:32:32-v1:8:8-i64:64-i128:128-n32"
target triple = "xtensa-unknown-none-elf"




define dso_local { ptr, i32 } @_RINvMs10_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB7_16BalancingContexthAhjb8_E8do_mergeNCINvB2_20merge_tracking_childNtNtBd_5alloc6GlobalE0INtB7_7NodeRefNtNtB7_6marker3MuthB1k_NtB2G_14LeafOrInternalEB24_ECs8pLgv9eiclp_9btree_ice(ptr dead_on_return noalias noundef readonly align 4 captures(none) dereferenceable(28) %self) unnamed_addr {
start:
  %0 = load ptr, ptr %self, align 4
  %1 = getelementptr inbounds nuw i8, ptr %self, i32 4
  %2 = load i32, ptr %1, align 4
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 2030
  %_2.i = load i16, ptr %3, align 2
  %_0.i.i = zext i16 %_2.i to i32
  %4 = getelementptr inbounds nuw i8, ptr %self, i32 12
  %5 = load ptr, ptr %4, align 4
  %6 = getelementptr inbounds nuw i8, ptr %self, i32 16
  %7 = load i32, ptr %6, align 4
  %8 = getelementptr inbounds nuw i8, ptr %5, i32 2030
  %_2.i6 = load i16, ptr %8, align 2
  %_0.i.i7 = zext i16 %_2.i6 to i32
  %9 = getelementptr inbounds nuw i8, ptr %self, i32 20
  %10 = load ptr, ptr %9, align 4
  %11 = getelementptr inbounds nuw i8, ptr %10, i32 2030
  %_2.i9 = load i16, ptr %11, align 2
  %_0.i.i10 = zext i16 %_2.i9 to i32
  %_15 = add nuw nsw i32 %_0.i.i7, 1
  %new_left_len = add nuw nsw i32 %_15, %_0.i.i10
  %_16 = icmp samesign ult i32 %new_left_len, 12
  br i1 %_16, label %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceAhjb8_ECs8pLgv9eiclp_9btree_ice.exit, label %bb5

bb5:                                              ; preds = %start
  unreachable

_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceAhjb8_ECs8pLgv9eiclp_9btree_ice.exit: ; preds = %start
  %12 = getelementptr inbounds nuw i8, ptr %self, i32 8
  %parent_idx = load i32, ptr %12, align 4
  %_50 = add i32 %parent_idx, 1
  %_0.i.i.i6.i = icmp ult i32 %_50, %_0.i.i
  br i1 %_0.i.i.i6.i, label %bb5.i, label %_RINvMsp_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB6_7NodeRefNtNtB6_6marker3MuthAhjb8_NtB1a_8InternalE30correct_childrens_parent_linksINtNtNtCsdKk7EqVcRUz_4core3ops5range5RangejEECs8pLgv9eiclp_9btree_ice.exit

bb5.i:                                            ; preds = %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceAhjb8_ECs8pLgv9eiclp_9btree_ice.exit, %bb5.i
  %iter.sroa.0.07.i = phi i32 [ %_0.i.i.i.i.i, %bb5.i ], [ %_50, %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceAhjb8_ECs8pLgv9eiclp_9btree_ice.exit ]
  %_0.i.i.i.i.i = add nuw nsw i32 %iter.sroa.0.07.i, 1
  %exitcond.not.i = icmp eq i32 %_0.i.i.i.i.i, %_0.i.i
  br i1 %exitcond.not.i, label %_RINvMsp_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB6_7NodeRefNtNtB6_6marker3MuthAhjb8_NtB1a_8InternalE30correct_childrens_parent_linksINtNtNtCsdKk7EqVcRUz_4core3ops5range5RangejEECs8pLgv9eiclp_9btree_ice.exit, label %bb5.i

_RINvMsp_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB6_7NodeRefNtNtB6_6marker3MuthAhjb8_NtB1a_8InternalE30correct_childrens_parent_linksINtNtNtCsdKk7EqVcRUz_4core3ops5range5RangejEECs8pLgv9eiclp_9btree_ice.exit: ; preds = %bb5.i, %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceAhjb8_ECs8pLgv9eiclp_9btree_ice.exit
  %_56 = icmp ugt i32 %2, 1
  br i1 %_56, label %bb25, label %bb40

bb25:                                             ; preds = %_RINvMsp_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB6_7NodeRefNtNtB6_6marker3MuthAhjb8_NtB1a_8InternalE30correct_childrens_parent_linksINtNtNtCsdKk7EqVcRUz_4core3ops5range5RangejEECs8pLgv9eiclp_9btree_ice.exit
  %_67 = add nuw nsw i32 %_0.i.i10, 1
  %_4.i44 = getelementptr inbounds nuw i8, ptr %5, i32 2044
  %new_len.i.i.i = sub nsw i32 %new_left_len, %_0.i.i7
  %_3.i46 = icmp eq i32 %_67, %new_len.i.i.i
  br i1 %_3.i46, label %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceINtNtNtCsdKk7EqVcRUz_4core3ptr8non_null7NonNullINtB2_8LeafNodehAhjb8_EEECs8pLgv9eiclp_9btree_ice.exit, label %bb2.i47

bb2.i47:                                          ; preds = %bb25
  unreachable

_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceINtNtNtCsdKk7EqVcRUz_4core3ptr8non_null7NonNullINtB2_8LeafNodehAhjb8_EEECs8pLgv9eiclp_9btree_ice.exit: ; preds = %bb25
  br label %bb5.i52

bb5.i52:                                          ; preds = %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceINtNtNtCsdKk7EqVcRUz_4core3ptr8non_null7NonNullINtB2_8LeafNodehAhjb8_EEECs8pLgv9eiclp_9btree_ice.exit, %bb5.i52
  %iter.sroa.0.07.i53 = phi i32 [ %_0.i.i.i.i.i54, %bb5.i52 ], [ %_15, %_RINvNtNtNtCsbIaysLmJLTs_5alloc11collections5btree4node13move_to_sliceINtNtNtCsdKk7EqVcRUz_4core3ptr8non_null7NonNullINtB2_8LeafNodehAhjb8_EEECs8pLgv9eiclp_9btree_ice.exit ]
  %_0.i.i.i.i.i54 = add nuw nsw i32 %iter.sroa.0.07.i53, 1
  %_0.i.i.i.i2.i56 = getelementptr inbounds nuw ptr, ptr %_4.i44, i32 %iter.sroa.0.07.i53
  %_0.i.i1.i.i.i57 = load ptr, ptr %_0.i.i.i.i2.i56, align 4
  %22 = getelementptr inbounds nuw i8, ptr %_0.i.i1.i.i.i57, i32 2024
  store ptr %5, ptr %22, align 4
  %exitcond.not.i60 = icmp eq i32 %iter.sroa.0.07.i53, %new_left_len
  br i1 %exitcond.not.i60, label %bb40, label %bb5.i52

bb40:                                             ; preds = %bb5.i52, %_RINvMsp_NtNtNtCsbIaysLmJLTs_5alloc11collections5btree4nodeINtB6_7NodeRefNtNtB6_6marker3MuthAhjb8_NtB1a_8InternalE30correct_childrens_parent_linksINtNtNtCsdKk7EqVcRUz_4core3ops5range5RangejEECs8pLgv9eiclp_9btree_ice.exit
  %23 = insertvalue { ptr, i32 } poison, ptr %5, 0
  %24 = insertvalue { ptr, i32 } %23, i32 %7, 1
  ret { ptr, i32 } %24
}
