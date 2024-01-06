# frozen_string_literal: true

require './src/zodiac/lexer'

module Zodiac
  # Base parsing class for the Zodiac language.

  # Here is the syntax of Ruby in pseudo BNF. For more detail, see parse.y in Ruby distribution.

  # ARG		: LHS `=' ARG
  # 		| LHS OP_ASGN ARG
  # 		| ARG `..' ARG
  # 		| ARG `...' ARG
  # 		| ARG `+' ARG
  # 		| ARG `-' ARG
  # 		| ARG `*' ARG
  # 		| ARG `/' ARG
  # 		| ARG `%' ARG
  # 		| ARG `**' ARG
  # 		| `+' ARG
  # 		| `-' ARG
  # 		| ARG `|' ARG
  # 		| ARG `^' ARG
  # 		| ARG `&' ARG
  # 		| ARG `<=>' ARG
  # 		| ARG `>' ARG
  # 		| ARG `>=' ARG
  # 		| ARG `<' ARG
  # 		| ARG `<=' ARG
  # 		| ARG `==' ARG
  # 		| ARG `===' ARG
  # 		| ARG `!=' ARG
  # 		| ARG `=~' ARG
  # 		| ARG `!~' ARG
  # 		| `!' ARG
  # 		| `~' ARG
  # 		| ARG `<<' ARG
  # 		| ARG `>>' ARG
  # 		| ARG `&&' ARG
  # 		| ARG `||' ARG
  # 		| defined? ARG
  # 		| PRIMARY

  # PRIMARY		: `(' COMPSTMT `)'
  # 		| LITERAL
  # 		| VARIABLE
  # 		| PRIMARY `::' IDENTIFIER
  # 		| `::' IDENTIFIER
  # 		| PRIMARY `[' [ARGS] `]'
  # 		| `[' [ARGS [`,']] `]'
  # 		| `{' [(ARGS|ASSOCS) [`,']] `}'
  # 		| return [`(' [CALL_ARGS] `)']
  # 		| yield [`(' [CALL_ARGS] `)']
  # 		| defined? `(' ARG `)'
  #                 | FUNCTION
  # 		| FUNCTION `{' [`|' [BLOCK_VAR] `|'] COMPSTMT `}'
  # 		| if EXPR THEN
  # 		  COMPSTMT
  # 		  (elsif EXPR THEN COMPSTMT)*
  # 		  [else COMPSTMT]
  # 		  end
  # 		| unless EXPR THEN
  # 		  COMPSTMT
  # 		  [else COMPSTMT]
  # 		  end
  # 		| while EXPR DO COMPSTMT end
  # 		| until EXPR DO COMPSTMT end
  # 		| case COMPSTMT
  # 		  (when WHEN_ARGS THEN COMPSTMT)+
  # 		  [else COMPSTMT]
  # 		  end
  # 		| for BLOCK_VAR in EXPR DO
  # 		  COMPSTMT
  # 		  end
  # 		| begin
  # 		  COMPSTMT
  # 		  [rescue [ARGS] DO COMPSTMT]+
  # 		  [else COMPSTMT]
  # 		  [ensure COMPSTMT]
  # 		  end
  # 		| class IDENTIFIER [`<' IDENTIFIER]
  # 		  COMPSTMT
  # 		  end
  # 		| module IDENTIFIER
  # 		  COMPSTMT
  # 		  end
  # 		| def FNAME ARGDECL
  # 		  COMPSTMT
  # 		  end
  # 		| def SINGLETON (`.'|`::') FNAME ARGDECL
  # 		  COMPSTMT
  # 		  end

  # WHEN_ARGS	: ARGS [`,' `*' ARG]
  # 		| `*' ARG

  # THEN		: TERM
  # 		| then
  # 		| TERM then

  # DO		: TERM
  # 		| do
  # 		| TERM do

  # BLOCK_VAR	: LHS
  # 		| MLHS

  # MLHS		: MLHS_ITEM `,' [MLHS_ITEM (`,' MLHS_ITEM)*] [`*' [LHS]]
  #                 | `*' LHS

  # MLHS_ITEM	: LHS
  # 		| '(' MLHS ')'

  # LHS		: VARIABLE
  # 		| PRIMARY `[' [ARGS] `]'
  # 		| PRIMARY `.' IDENTIFIER

  # MRHS		: ARGS [`,' `*' ARG]
  # 		| `*' ARG

  # CALL_ARGS	: ARGS
  # 		| ARGS [`,' ASSOCS] [`,' `*' ARG] [`,' `&' ARG]
  # 		| ASSOCS [`,' `*' ARG] [`,' `&' ARG]
  # 		| `*' ARG [`,' `&' ARG]
  # 		| `&' ARG
  # 		| COMMAND

  # ARGS 		: ARG (`,' ARG)*

  # ARGDECL		: `(' ARGLIST `)'
  # 		| ARGLIST TERM

  # ARGLIST		: IDENTIFIER(`,'IDENTIFIER)*[`,'`*'[IDENTIFIER]][`,'`&'IDENTIFIER]
  # 		| `*'IDENTIFIER[`,'`&'IDENTIFIER]
  # 		| [`&'IDENTIFIER]

  # SINGLETON	: VARIABLE
  # 		| `(' EXPR `)'

  # ASSOCS		: ASSOC (`,' ASSOC)*

  # ASSOC		: ARG `=>' ARG

  # VARIABLE	: VARNAME
  # 		| nil
  # 		| self

  # LITERAL		: numeric
  # 		| SYMBOL
  # 		| STRING
  # 		| STRING2
  # 		| HERE_DOC
  # 		| REGEXP
  class Parser
    def initialize(raw_string)
      @raw_string = raw_string
      @cur_index = 0

      @tokens = Lexer.new(raw_string).lex

      @tree = []
    end

    def parse
      parse_program
    end

    private

    # PROGRAM		: COMPSTMT
    def parse_program
      cmp_stmts = []

      cmp_stmts << parse_compstmt while @cur_index < @tokens.length

      { kind: 'PROGRAM', cmp_stmts: }
    end

    # COMPSTMT	: STMT (TERM EXPR)* [TERM]
    def parse_compstmt
      { kind: 'COMPSTMT', value: nil }
    end

    # STMT		: CALL do [`|' [BLOCK_VAR] `|'] COMPSTMT end
    #                 | undef FNAME
    # 		| alias FNAME FNAME
    # 		| STMT if EXPR
    # 		| STMT while EXPR
    # 		| STMT unless EXPR
    # 		| STMT until EXPR
    #                 | `BEGIN' `{' COMPSTMT `}'
    #                 | `END' `{' COMPSTMT `}'
    #                 | LHS `=' COMMAND [do [`|' [BLOCK_VAR] `|'] COMPSTMT end]
    # 		| EXPR
    def parse_stmt
      { kind: 'STMT', value: nil }
    end

    # EXPR		: MLHS `=' MRHS
    # 		| return CALL_ARGS
    # 		| yield CALL_ARGS
    # 		| EXPR and EXPR
    # 		| EXPR or EXPR
    # 		| not EXPR
    # 		| COMMAND
    # 		| `!' COMMAND
    # 		| ARG
    def parse_expr
      { kind: 'EXPR', value: nil }
    end

    # TERM		: `;'
    # 		| `\n'
    def parse_term
      cur_token = @tokens[@cur_index]

      unless cur_token[:kind] == 'NEWLINE' || (cur_token[:kind] == 'SYMBOL' && cur_token[:value] == ';')
        raise ParseError,
              "Expected a newline or a semicolon. Received #{cur_token[:value]}"
      end

      { kind: 'TERM', value: cur_token[:value] }
    end

    # CALL		: FUNCTION
    #                 | COMMAND
    def parse_call
      { kind: 'CALL', value: nil }
    end

    # COMMAND		: OPERATION CALL_ARGS
    # 		| PRIMARY `.' OPERATION CALL_ARGS
    # 		| PRIMARY `::' OPERATION CALL_ARGS
    # 		| super CALL_ARGS
    def parse_command
      { kind: 'COMMAND', value: nil }
    end

    # FUNCTION        : OPERATION [`(' [CALL_ARGS] `)']
    # 		| PRIMARY `.' OPERATION `(' [CALL_ARGS] `)'
    # 		| PRIMARY `::' OPERATION `(' [CALL_ARGS] `)'
    # 		| PRIMARY `.' OPERATION
    # 		| PRIMARY `::' OPERATION
    # 		| super `(' [CALL_ARGS] `)'
    # 		| super
    def parse_function
      { kind: 'FUNCTION', value: nil }
    end
  end
end
