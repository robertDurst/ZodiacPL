# frozen_string_literal: true

require './src/zodiac/lexer'

module Zodiac
  # Base parsing class for the Zodiac language.
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
      parse_stmt

      while @cur_index < @tokens.length
        parse_term
        parse_expr
      end

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

    # THEN		: TERM
    # 		| then
    # 		| TERM then
    def parse_then
      { kind: 'THEN', value: nil }
    end

    # DO		: TERM
    # 		| do
    # 		| TERM do
    def parse_do
      { kind: 'DO', value: nil }
    end

    # BLOCK_VAR	: LHS
    # 		| MLHS
    def parse_block_var
      { kind: 'BLOCK_VAR', value: nil }
    end

    # MLHS		: MLHS_ITEM `,' [MLHS_ITEM (`,' MLHS_ITEM)*] [`*' [LHS]]
    #                 | `*' LHS
    def parse_mlhs
      { kind: 'MLHS', value: nil }
    end

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
    def parse_arg
      { kind: 'ARG', value: nil }
    end

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
    def parse_primary
      { kind: 'PRIMARY', value: nil }
    end

    # WHEN_ARGS	: ARGS [`,' `*' ARG]
    # 		| `*' ARG
    def parse_when_args
      { kind: 'WHEN_ARGS', value: nil }
    end

    # MLHS_ITEM	: LHS
    # 		| '(' MLHS ')'
    def parse_mlhs_item
      { kind: 'MLHS_ITEM', value: nil }
    end

    # LHS		: VARIABLE
    # 		| PRIMARY `[' [ARGS] `]'
    # 		| PRIMARY `.' IDENTIFIER
    def parse_lhs
      { kind: 'LHS', value: nil }
    end

    # MRHS		: ARGS [`,' `*' ARG]
    # 		| `*' ARG
    def parse_mrhs
      { kind: 'MRHS', value: nil }
    end

    # CALL_ARGS	: ARGS
    # 		| ARGS [`,' ASSOCS] [`,' `*' ARG] [`,' `&' ARG]
    # 		| ASSOCS [`,' `*' ARG] [`,' `&' ARG]
    # 		| `*' ARG [`,' `&' ARG]
    # 		| `&' ARG
    # 		| COMMAND
    def parse_call_args
      { kind: 'CALL_ARGS', value: nil }
    end

    # ARGS 		: ARG (`,' ARG)*
    def parse_args
      { kind: 'ARGS', value: nil }
    end

    # ARGDECL		: `(' ARGLIST `)'
    # 		| ARGLIST TERM
    def parse_argdecl
      { kind: 'ARGDECL', value: nil }
    end

    # ARGLIST		: IDENTIFIER(`,'IDENTIFIER)*[`,'`*'[IDENTIFIER]][`,'`&'IDENTIFIER]
    # 		| `*'IDENTIFIER[`,'`&'IDENTIFIER]
    # 		| [`&'IDENTIFIER]
    def parse_arglist
      { kind: 'ARGLIST', value: nil }
    end

    # SINGLETON	: VARIABLE
    # 		| `(' EXPR `)'
    def parse_singleton
      { kind: 'SINGLETON', value: nil }
    end

    # ASSOCS		: ASSOC (`,' ASSOC)*
    def parse_assocs
      { kind: 'ASSOCS', value: nil }
    end

    # ASSOC		: ARG `=>' ARG
    def parse_assoc
      { kind: 'ASSOC', value: nil }
    end

    # VARIABLE	: VARNAME
    # 		| nil
    # 		| self
    def parse_variable
      { kind: 'VARIABLE', value: nil }
    end

    # LITERAL		: numeric
    # 		| SYMBOL
    # 		| STRING
    # 		| STRING2
    # 		| HERE_DOC
    # 		| REGEXP
    def parse_literal
      { kind: 'LITERAL', value: nil }
    end
  end
end
