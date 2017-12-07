.source Test.j
.class public Test
.super  java/lang/Object
.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method


.method public static cubo()V
    ldc 4
   istore 0
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 0
    iload 0
   imul
    iload 0
   imul
    invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

  return
.limit stack 3
.limit locals 11
.end method


.method public static main([Ljava/lang/String;)V
    ldc 1
   istore 0
invokestatic Test/cubo()V
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 0
    invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

  return
.limit stack 2
.limit locals 11
.end method
