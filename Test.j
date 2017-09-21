.source Test.j
.class public Test
.super  java/lang/Object
.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method
.method public static main([Ljava/lang/String;)V
    ldc 4
   istore 0
    iload 0
   istore 1
   getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 1
    ldc 9
   iadd
   invokevirtual java/io/PrintStream/println(I)V

  return
.limit stack 3
.limit locals 4
.end method
