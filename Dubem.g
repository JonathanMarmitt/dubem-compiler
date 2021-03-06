grammar Dubem;

/*---------------- COMPILER INTERNALS ----------------*/

@header
{
    import java.util.ArrayList;
}

@members
{
    private static ArrayList<String> symbol_table;
    private static ArrayList<String> symbol_table_not_used;
    private static ArrayList<Character> symbol_type;
    private static int count_while = 0;
    private static int count_if = 0;
    private static int count_for = 0;
    private static String args = "";
    private static boolean has_return = false;

    private static int stack_cur, stack_max, errors;

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
        symbol_table_not_used = new ArrayList<String>();
        symbol_type = new ArrayList<Character>();
        parser.program();
        //System.out.println("symbols: " + symbol_table);
        
        if(errors > 0)
        	System.exit(1);
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
COMMA       : ',' ;
SEMICOLON   : ';' ;
OPEN_B      : '[' ;
CLOSE_B     : ']' ;

EQ          : '==';
NE          : '!=';
LT          : '<' ;
LE          : '<=';
GT          : '>' ;
GE          : '>=';

ARRAY       : 'array';
LENGTH      : 'length';

PROCEDURE   : 'procedure';
FUNCTION    : 'function';
RETURN      : 'return';

PRINT		: 'print';
READ_INT    : 'read_int';
WHILE       : 'while';
IF          : 'if';
ELSE        : 'else';
FOR         : 'for';
END         : 'end';

READ_STRING : 'read_string';
STRING      : '"' ~('"')* '"';

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
		System.out.println(".end method\n\n");
	} 	
	
	(procedure | function | NL)*
	main
;
procedure
	: PROCEDURE NAME OPEN_P ( parameters )? CLOSE_P NL
	{
		String params = "";
		for(int x = 0; x < symbol_table.size(); x++)
			params += "I";

		System.out.println(".method public static "+$NAME.text+"("+params+")V");
	}
	
	( statement )* END NL
	
	{
		for(int i = 0; i < symbol_table_not_used.size(); i++)
		{
			System.err.println("WARNING: nao usou "+symbol_table_not_used.get(i));
			//errors++;
		}

		System.out.println("  return");
		System.out.println(".limit stack"+ " " + stack_max);
		System.out.println(".limit locals"+ " " + symbol_table.size());
		System.out.println(".end method\n\n");
		
		symbol_table.clear();
		symbol_table_not_used.clear();
		symbol_type.clear();
		stack_max = 0;
		stack_cur = 0;
	}
;
function
	: FUNCTION NAME OPEN_P ( parameters )? CLOSE_P NL
	{
		String params = "";
		for(int x = 0; x < symbol_table.size(); x++)
			params += "I";

		System.out.println(".method public static "+$NAME.text+"("+params+")I");
	}
	
	( statement )* 

	{
		if(!has_return) 
		{
			System.err.println("ERROR: statement return not found");
			errors++;
		}

		has_return = false;
	}

	END NL
	
	{
		for(int i = 0; i < symbol_table_not_used.size(); i++)
		{
			System.err.println("WARNING: nao usou "+symbol_table_not_used.get(i));
			//errors++;
		}

		System.out.println("  return");
		System.out.println(".limit stack"+ " " + stack_max);
		System.out.println(".limit locals"+ " " + symbol_table.size());
		System.out.println(".end method\n\n");
		
		symbol_table.clear();
		symbol_table_not_used.clear();
		symbol_type.clear();
		stack_max = 0;
		stack_cur = 0;
	}
;
parameters
	: NAME
	{
		symbol_table.add($NAME.text);
		symbol_table_not_used.add($NAME.text);

		symbol_type.add('i');
	}
	(COMMA NAME
		{
			if(symbol_table.indexOf($NAME.text) == -1){
				symbol_table.add($NAME.text);
				symbol_table_not_used.add($NAME.text);

				symbol_type.add('i');
			}
			else
			{
				System.err.println("ERROR: parameter already passed!");
				errors++;
			}
		}
	)*
;
main
	:
	{
		System.out.println(".method public static main([Ljava/lang/String;)V");
		
		symbol_table.add("args");
		symbol_type.add('i');
	}
	
	( statement )*
	
	{ 
		for(int i = 0; i < symbol_table_not_used.size(); i++)
		{
			System.err.println("WARNING: nao usou "+symbol_table_not_used.get(i));
			//errors++;
		}

		System.out.println("  return"); 
		System.out.println(".limit stack"+ " " + stack_max); 
		System.out.println(".limit locals"+ " " + symbol_table.size()); 
		System.out.println(".end method");
	}
;
statement
  :	NL | st_print | st_attrib NL | st_while | st_if | st_for | st_call | st_return
;
st_print
  :	PRINT
	{
		emit("getstatic java/lang/System/out Ljava/io/PrintStream;", +1);
	}
	e1 = exp_aritmetic 
	{
		if( $e1.type == 'i')
			emit(" invokevirtual java/io/PrintStream/print(I)V\n", -2);
		else
			emit(" invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n", -2);
	}
	(
		COMMA 
		{ emit("getstatic java/lang/System/out Ljava/io/PrintStream;", +1); } 
		e2 = exp_aritmetic
	    { 
	   		if($e2.type == 'i')
	   			emit(" invokevirtual java/io/PrintStream/print(I)V\n", -2);
	   		else
	   			emit(" invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n", -2);
	    }

	)* NL
	{
		emit("getstatic java/lang/System/out Ljava/io/PrintStream;", +1);
		emit(" invokevirtual java/io/PrintStream/println()V\n", -1);
	}
;
st_attrib
: NAME ( OPEN_B 
  {
     if (symbol_table.indexOf($NAME.text) == -1) {
       System.err.println("Undefined variable:" + $NAME.text );
       System.exit(1);
     }

     int end = symbol_table.indexOf($NAME.text);

     if (symbol_type.get(end) != 'v' ) {
      System.err.println("is not a vector");
      System.exit('1');
     }

      emit("aload " + end, +1);
  }

e2 = exp_aritmetic CLOSE_B )? ATTRIB
( e1 = exp_aritmetic
    {

      if(symbol_table.indexOf($NAME.text) == -1){
        symbol_table.add($NAME.text);
        symbol_table_not_used.add($NAME.text);

        if($e1.type == 'i')
          symbol_type.add('i');
        else if ($e1.type == 'a')
          symbol_type.add('a');
        
      }
    
    int end = symbol_table.indexOf($NAME.text);
    if (symbol_type.get(end) == 'i') {
      emit("istore " + end, -1);
    } else if (symbol_type.get(end) == 'a') {
      emit("astore " + end, -1);
    } else {
      emit ("iastore", -3);
    }
   System.out.println();
  }

  |ARRAY exp_aritmetic
    {       
        emit("newarray int", 0);
        symbol_table.add($NAME.text);
        symbol_type.add('v');
        emit("astore " + symbol_table.indexOf($NAME.text), -1);
        System.out.println(); 
    } 
  )
;
st_while
  	: WHILE 
  	{
  		int local = ++count_while;
  		System.out.println("BEGIN_WHILE_"+local+":");
  	}
  	s = exp_comparison NL 
  	{
  		emit($s.bytecode + " END_WHILE_" +local, -2);
  	}
  	(statement)*
  		{ emit("goto BEGIN_WHILE_"+local, 0); }
  	END NL
  		{ System.out.println("END_WHILE_"+local+":"); }
;
st_if
	: IF 
	{ int local = ++count_if; }
	s = exp_comparison	NL
		{ emit($s.bytecode + " NOT_IF"+local, -2); }
	(statement)*
	{ 
		emit("goto END_ELSE"+local, 0);
		System.out.println("NOT_IF"+local+":");
	}
	(ELSE NL (statement)* )?
		{ System.out.println("END_ELSE"+local+":"); }
	END NL		
;
st_for
	: FOR
	{ int local = ++count_for; }
	st_attrib SEMICOLON
		{ System.out.println("FOR_COMP_"+local+":"); }
	s = exp_comparison SEMICOLON
		{ 
			emit($s.bytecode + " END_FOR_"+local, -2);
			emit("goto FOR_"+local, 0);
			System.out.println("FOR_INC_"+local+":");
		}
	st_attrib NL
		{ 
			emit("goto FOR_COMP_"+local, 0);
			System.out.println("FOR_"+local+":"); 
		}
	(statement)*
		{ 
			emit("goto FOR_INC_"+local, 0);
			System.out.println("END_FOR_"+local+":"); 
		}
	END NL
;
st_call
	: NAME OPEN_P (arguments)? CLOSE_P NL
	{
		System.out.println("invokestatic Test/"+$NAME.text+"("+args+")V");
		args = "";
	}
;
st_return
	: RETURN exp_aritmetic
	{
		has_return = true;
		emit("ireturn", 0);
	}
	NL
;
arguments
	: exp_aritmetic
		{
			args = "I";
		}
		(COMMA exp_aritmetic
			{
				args += "I";
			}
		)*
;
exp_comparison returns [String bytecode]
	: e1 = exp_aritmetic op = ( EQ | NE | LT | LE | GT | GE ) e2 = exp_aritmetic
	{
		if($e1.type != $e2.type)
		{
			System.err.println("ERROR: cannot mix types");
			errors++;//System.exit(1);
		}

		if($op.type == EQ)      $bytecode = "if_icmpne";
		else if($op.type == NE) $bytecode = "if_icmpeq";
		else if($op.type == LT) $bytecode = "if_icmpge";
		else if($op.type == LE) $bytecode = "if_icmpgt";
		else if($op.type == GT) $bytecode = "if_icmple";
		else if($op.type == GE) $bytecode = "if_icmplt";	
	}
;
exp_aritmetic returns [char type]
    :   t1 = term ( op = ( PLUS | MINUS ) t2 = term 
		{ 
			if($t1.type != $t2.type)
			{
				System.err.println("ERROR: cannot mix types");
				errors++;//System.exit(1);
			}
			
			emit($op.type == PLUS ? "iadd" : "isub", -1);
		} 
	)*
		{ $type = $t1.type; }
	
;
term returns [char type]  
    :   f1 = factor ( op = ( TIMES  | OVER | REMAINDER) f2 = factor 
		{ 
			if($f1.type == 'a' || $f2.type == 'a')
			{
				System.err.println("ERROR: cannot mix types");
				errors++;
			}

			emit($op.type == TIMES ? "imul" :
			($op.type == OVER ? "idiv": "irem"), -1);
		} 
	)*
	{ $type = $f1.type; }
;
factor returns [char type]
:   NUMBER
		{ 
		  emit(" ldc " + $NUMBER.text, +1);
		  $type = 'i';
		}
	| OPEN_P exp_aritmetic CLOSE_P
		{
		  $type = $exp_aritmetic.type;
		}
	|   NAME ( OPEN_B 
		{
		     int end = symbol_table.indexOf($NAME.text);

		     if (symbol_type.get(end) != 'v' ) {
		      System.err.println("is not a vector");
		      System.exit('1');
		     }

		      emit("aload " + end, +1);
		}

	 	exp_aritmetic CLOSE_B )?
		{
		  	if(symbol_table.indexOf($NAME.text) >= 0){
		    
		    	if ((symbol_type.get(symbol_table.indexOf($NAME.text)) == 'v')) {
		      		emit(" iaload ", -1);      
		      		$type = 'i';
		    	} else {
		       		emit(" " + symbol_type.get(symbol_table.indexOf($NAME.text)) + "load " + symbol_table.indexOf($NAME.text), +1);
		       		symbol_table_not_used.remove($NAME.text);
		    	   	$type = symbol_type.get(symbol_table.indexOf($NAME.text));
		   		}
		  	}
		  	else
		  	{ 
		    	System.err.println("WARNING: Used non declared variable "+$NAME.text);
		    	errors++;
		  	}
		}
	|   READ_INT
		{ 
		  emit(" invokestatic Runtime/readInt()I", +1);
		  $type = 'i';
		}
	|   READ_STRING
		{
		  $type = 'a';
		}
	|   STRING
		{
		  emit(" ldc " + $STRING.text, +1); 
		  $type = 'a';
		}
	|   LENGTH NAME
		{
		  //ver se esta na tabela de simbolos
		  int end = symbol_table.indexOf($NAME.text);

		  emit("aload " +  end, +1);
		  emit("arraylength", +0); 
		  $type = 'i';
		}
	|   NAME OPEN_P (arguments)? CLOSE_P
			{
				System.out.println(" invokestatic Test/"+$NAME.text+"("+args+")I");
				args = "";
				$type = 'i';
			}
;