.source Test.j
.class public Test
.super  java/lang/Object
.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method
.method public static main([Ljava/lang/String;)V
    ldc 2
   istore 0
    iload 0
    ldc 3
   imul
   istore 1
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 0
   invokevirtual java/io/PrintStream/print(I)V

   getstatic java/lang/System/out Ljava/io/PrintStream;
    invokevirtual java/io/PrintStream/println()V

  return
.limit stack 2
.limit locals 21
.end method
