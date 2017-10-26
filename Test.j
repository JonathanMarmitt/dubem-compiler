.source Test.j
.class public Test
.super  java/lang/Object
.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method
.method public static main([Ljava/lang/String;)V
    ldc 1
   istore 0
    ldc 2
   istore 1
    ldc 3
   istore 2
    iload 0
    iload 1
   if_icmpne NOT_IF1
    iload 1
    iload 2
   if_icmpeq NOT_IF2
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 1
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

   goto END_ELSE2
NOT_IF2:
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 2
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

END_ELSE2:
   goto END_ELSE1
NOT_IF1:
    iload 0
    iload 1
   if_icmple NOT_IF3
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 1
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

   goto END_ELSE3
NOT_IF3:
    iload 0
    iload 1
   if_icmpge NOT_IF4
    iload 1
    iload 2
   if_icmple NOT_IF5
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 2
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

   goto END_ELSE5
NOT_IF5:
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 0
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

END_ELSE5:
   goto END_ELSE4
NOT_IF4:
END_ELSE4:
END_ELSE3:
END_ELSE1:
  return
.limit stack 2
.limit locals 31
.end method
