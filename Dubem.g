grammar Dubem;

/*---------------- COMPILER INTERNALS ----------------*/

@header
{
    import java.util.ArrayList;
}

@members
{
    private static ArrayList<String> symbol_table;

    private static int stack_cur, stack_max;

    private static void emit(String bytecode, int delta) {
	System.out.println("   " + bytecode);
	stack_cur += delta;
	if (stack_max < stack_cur ) {stack_max  = stack_cur; }

    }

    public static void main(String[] args) throws Exception
    {
        ANTLRInputStream input = new ANTLRInputStream(System.in);
        DubemLexer lexer = new DubemLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        DubemParser parser = new DubemParser(tokens);

        symbol_table = new ArrayList<String>();        
        parser.program();
        //System.out.println("symbols: " + symbol_table);
    }
}

/*---------------- LEXER RULES ----------------*/

PLUS   		: '+' ;
MINUS   	: '-' ;
TIMES   	: '*' ;
OVER    	: '/' ;
REMAINDER	: '%' ;
OPEN_P		: '(' ;
CLOSE_P		: ')' ;
ATTRIB      : '=' ;

PRINT		: 'print'; 

COMMENT     : '#' ~('\n')* { skip(); };

NUMBER     	: '0'..'9'+ ;
NAME        : 'a'..'z'+ ;
SPACE   	: (' '|'\t')+ { skip(); } ;
NL		    : ('\r')?'\n' ;

/*---------------- PARSER RULES ----------------*/

program
    :  
	{ 
		System.out.println(".source Test.j");
		System.out.println(".class public Test"); 
		System.out.println(".super  java/lang/Object"); 
		System.out.println(".method public <init>()V");  
		System.out.println("aload_0");
		System.out.println("invokenonvirtual java/lang/Object/<init>()V");
		System.out.println("return");
		System.out.println(".end method");
		System.out.println(".method public static main([Ljava/lang/String;)V");
		


	} 	
	
	( statement )*
	
	{ 
		System.out.println("  return"); 
		System.out.println(".limit stack"+ " " + stack_max); 
		System.out.println(".limit locals"+ " " + 4); 
		System.out.println(".end method");
	} 	
    ;

statement
  :	NL | st_print | st_attrib
;

st_print
  :	PRINT
	{
		emit("getstatic java/lang/System/out Ljava/io/PrintStream;", +1);
	}
	exp_aritmetic NL
	{
		emit("invokevirtual java/io/PrintStream/println(I)V\n", -2);
	}

;
st_attrib
  : NAME ATTRIB
  	exp_aritmetic NL
  	{
  		if(symbol_table.indexOf($NAME.text) == -1){
  			symbol_table.add($NAME.text);
  		}

  		emit("istore "+symbol_table.indexOf($NAME.text), -1);
  	}
;
exp_aritmetic
    :   term ( op = ( PLUS | MINUS ) term 
		{ emit($op.type == PLUS ? "iadd" : "isub", -1); } 
	)*
	
;
term    
    :   factor ( op = ( TIMES  | OVER | REMAINDER) factor 
		{ emit($op.type == TIMES ? "imul" :
			($op.type == OVER ? "idiv": "irem"), -1); } 
	)*
	
;
    
factor
    :   NUMBER
        	{ emit(" ldc " + $NUMBER.text, +1); }
    |	OPEN_P exp_aritmetic CLOSE_P
    |   NAME
    		{  if(symbol_table.indexOf($NAME.text) >= 0)
    				emit(" iload "+symbol_table.indexOf($NAME.text), +1);
    			else
    				System.exit(0);
    		}
;