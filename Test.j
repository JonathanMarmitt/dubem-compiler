.source Test.j
.class public Test
.super  java/lang/Object
.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method
.method public static main([Ljava/lang/String;)V
    ldc 10
   istore 0
    iload 0
    ldc 10
   if_icmpne NOT_IF
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 0
    ldc 5
   iadd
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

   goto END_ELSE
NOT_IF:
   getstatic java/lang/System/out Ljava/io/PrintStream;
    ldc 99
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

END_ELSE:
  return
.limit stack 3
.limit locals 11
.end method
