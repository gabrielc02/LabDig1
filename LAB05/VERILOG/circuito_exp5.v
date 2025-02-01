module circuito_exp5 (
    input clock, 
    input reset, 
    input jogar,
    input [3:0] botoes,
    output pronto, 
    output ganhou, 
    output perdeu,
    output [3:0] leds,
    output db_chavesIgualMemoria,
    output db_enderecoIgualLimite,
	output db_clock,
    output db_tem_jogada,
    output [3:0] db_limite,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_jogada,
    output [6:0] db_estado
);

//Sinais Gerais
wire sig_db_tem_jogada;

//Sinais Intermediario Display
wire [3:0] sig_db_contagem;
wire [3:0] sig_db_memoria;
wire [3:0] sig_db_jogada;
wire [3:0] sig_db_estado;
wire [3:0] sig_db_sequencia;
wire [6:0] hex2_jogada;
wire [6:0] hex0_contagem;
wire [6:0] hex1_memoria;
wire [6:0] hex5_estado;

//Sinais Intermediario UC & FD
//FD - UC
wire sig_fimE;
wire sig_fimS;
wire sig_fimTMR;
wire sig_igualJ;
wire sig_igualS;
wire sig_jogada_feita;

//UC - FD
wire sig_contaE;
wire sig_contaS;
wire sig_contaTMR;
wire sig_limpaM;
wire sig_limpaR;
wire sig_registraM;
wire sig_registraR;
wire sig_zeraE;
wire sig_zeraS;
wire sig_zeraTMR;
wire sig_jogada;

// Fluxo de Dados
exp5_fluxo_dados FD (
    .botoes         ( botoes ),
    .clock          ( clock ),
    .contaE         ( sig_contaE ),
    .contaS         ( sig_contaS ),
    .contaTMR       ( sig_contaTMR ),
    .escreveM       ( 1'h0 ),
    .limpaM         ( sig_limpaM ),
    .limpaR         ( sig_limpaR ),
    .registraM      ( sig_registraM ),
    .registraR      ( sig_registraR ),
    .zeraE          ( sig_zeraE ),
    .zeraS          ( sig_zeraS ),
    .zeraTMR        ( sig_zeraTMR ),
	.db_limite		( db_limite ),
    .db_contagem    ( sig_db_contagem ),
    .db_jogada      ( sig_db_jogada ),
    .db_memoria     ( sig_db_memoria ),
    .db_sequencia   ( sig_db_sequencia ),
    .db_tem_jogada  ( sig_db_tem_jogada ),
    .fimE           ( sig_fimE ),
    .fimS           ( sig_fimS ),
    .fimTMR         ( sig_fimTMR ),
    .igualJ         ( sig_igualJ ),
    .igualS         ( sig_igualS ),
    .jogada_feita   ( sig_jogada_feita ),
    .leds           ( leds )
);

// Unidade de Controle
exp5_unidade_controle UC (
    .clock      ( clock ),
    .fimE       ( sig_fimE ),
    .fimS       ( sig_fimS ),
    .fimTMR     ( sig_fimTMR ),
    .igualJ     ( sig_igualJ ),
    .igualS     ( sig_igualS ),
    .iniciar    ( jogar ),
    .jogada     ( sig_jogada_feita ),
    .reset      ( reset ),
    .contaE     ( sig_contaE ),
    .contaS     ( sig_contaS ),
    .contaTMR   ( sig_contaTMR ),
    .ganhou     ( ganhou ),
    .limpaM     ( sig_limpaM ),
    .limpaR     ( sig_limpaR ),
    .perdeu     ( perdeu ),
    .pronto     ( pronto ),
    .registraM  ( sig_registraM ),
    .registraR  ( sig_registraR ),
    .zeraE      ( sig_zeraE ),
    .zeraS      ( sig_zeraS ),
    .zeraTMR    ( sig_zeraTMR ),
    .db_estado  ( sig_db_estado )
);

// Display 7 segmentos chaves
hexa7seg HEX2 (
    .hexa       ( sig_db_jogada ),
    .display    ( hex2_jogada )
);

// Display 7 segmentos contagem
hexa7seg HEX0 (
    .hexa       ( sig_db_contagem ),
    .display    ( hex0_contagem )
);

// Display 7 segmentos chaves
hexa7seg HEX1 (
    .hexa       ( sig_db_memoria ),
    .display    ( hex1_memoria )
);

// Display 7 estado
hexa7seg HEX5 (
    .hexa       ( sig_db_estado ),
    .display    ( hex5_estado )
);

//Depuracao
assign db_clock                 = clock;
assign db_tem_jogada            = sig_db_tem_jogada;
assign db_jogada                = hex2_jogada;
assign db_contagem              = hex0_contagem;
assign db_memoria               = hex1_memoria;
assign db_chavesIgualMemoria    = sig_igualJ;
assign db_enderecoIgualLimite   = sig_igualS;
assign db_estado                = hex5_estado;

endmodule