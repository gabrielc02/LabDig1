module circuito_exp4 (
    input clock, reset, iniciar,
    input [3:0] chaves,
    output pronto, acertou, errou,
    output db_igual, db_tem_jogada, db_clock, db_iniciar,
    output [3:0] leds, 
    output [6:0] db_contagem, db_memoria, db_jogadafeita, db_estado
);

//Sinais Gerais
wire sig_db_tem_jogada;

//Sinais Intermediario Display
wire [3:0] sig_db_contagem;
wire [3:0] sig_db_memoria;
wire [3:0] sig_db_jogada;
wire [3:0] sig_db_estado;
wire [6:0] hex2_jogada;
wire [6:0] hex0_contagem;
wire [6:0] hex1_memoria;
wire [6:0] hex5_estado;

//Sinais Intermediario UC & FD
//UC - FD
wire sig_contaC;
wire sig_zeraR;
wire sig_zeraC;
wire sig_registraR;
//FD - UC
wire sig_jogada;
wire sig_igual;
wire sig_fim;

// Fluxo de Dados
exp4_fluxo_dados FD (
    .chaves             ( chaves ),
    .clock              ( clock ),
    .contaC             ( sig_contaC ),
    .registraR          ( sig_registraR ),
    .zeraC              ( sig_zeraC ),
    .zeraR              ( sig_zeraR ),
    .igual				( db_igual ),
    .fimC               ( sig_fim ),
    .db_jogada          ( sig_db_jogada ),
    .db_tem_jogada      ( sig_db_tem_jogada ),
    .jogada_feita       ( sig_jogada), 
    .db_contagem        ( sig_db_contagem ), 
    .db_memoria         ( sig_db_memoria )
);

assign sig_igual = db_igual;

// Unidade de Controle
exp4_unidade_controle UC (
    .clock      ( clock ),
    .reset      ( reset ),
    .iniciar    ( iniciar ),
    .fim        ( sig_fim ),
    .jogada     ( sig_jogada ),
    .igual      ( sig_igual ),
    .zeraC      ( sig_zeraC ),
    .contaC     ( sig_contaC ),
    .zeraR      ( sig_zeraR ),
    .registraR  ( sig_registraR ),
    .pronto     ( pronto ),
	.acertou    ( acertou ),
	.errou      ( errou ),
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
assign db_clock =       clock;
assign db_iniciar =     iniciar;
assign db_tem_jogada =  sig_db_tem_jogada;
assign db_jogadafeita = hex2_jogada;
assign db_contagem =    hex0_contagem;
assign db_memoria =     hex1_memoria;
assign db_estado =      hex5_estado;
assign leds =           chaves;
endmodule