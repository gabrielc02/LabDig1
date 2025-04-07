/* --------------------------------------------------------------------
 * Arquivo   : circuito_projeto
 * Projeto   : PULO DO SAPO
 * --------------------------------------------------------------------
 * Descricao : circuito logico do projeto final
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao       Autor             Descricao
 *     15/03/2025   2.0     Gabriel Chaves      versao atualizada
 * --------------------------------------------------------------------
*/

module circuito_projeto (
    //ENTRADAS
    input clock_in, 
    input reset, 
    input jogar,
    input modo,
    input memory,
    input pausa,
    input [1:0] metrica_selector,
    input [3:0] botoes,
    
    //SAIDAS
    output pronto, 
    output ganhou, 
    output perdeu,
	 output pode_jogar,
    output modo_state,
    output memory_state,
    output pausa_state,
    output [3:0] leds, 
    output [3:0] display_round,
    output [6:0] display_metricas,
    output [7:0] state,

    //DEPURACAO
    output db_tem_jogada,
    output [6:0] db_StateMSB,
    output [6:0] db_StateLSB,
    output [6:0] db_Memoria,
    output [6:0] db_Jogada,
	output db_jogar,
	output db_clock
);

//clock
wire clock;
wire zclock;
assign zclock = clock & ~clock_in;

//Pausa Universal
wire sig_pausa_mux;
assign sig_pausa_mux = pausa ? 0 : clock;

//Sinais Intermediario Display
//ENTRADA
wire [3:0] sig_metrica;
wire [3:0] sig_round;
wire [3:0] sig_memoria;
wire [3:0] sig_jogada;
wire [3:0] sig_estadoLSB;
wire [3:0] sig_estadoMSB;
//SAIDA
wire [6:0] display_memoria;
wire [6:0] display_jogada;
wire [6:0] display_estadoMSB;
wire [6:0] display_estadoLSB;
wire [7:0] sig_estadoTotal;
assign sig_estadoLSB = sig_estadoTotal[3:0];
assign sig_estadoMSB = sig_estadoTotal[7:4];

//Sinais Intermediario UC & FD
//FD - UC
//CONTADORES
wire sig_fimE;
wire sig_fimS;
wire sig_fimTMR;
wire sig_fimAM;
wire sig_fimAMZ;
//COMPARADORES
wire sig_igualJ;
wire sig_igualS;
//DETECTOR
wire sig_jogada_feita;

//UC - FD
//CONTADORES
wire sig_contaE;
wire sig_contaS;
wire sig_contaTMR;
wire sig_contaAM;
wire sig_zeraE;
wire sig_zeraS;
wire sig_zeraTMR;
wire sig_zeraAM;
//REGISTRADOR & RAM
wire sig_limpaM;
wire sig_limpaR;
wire sig_registraM;
wire sig_registraR;
//OUTROS
wire sig_ledToshow;
wire sig_acerto_counter;
wire sig_timeout_counter;
wire sig_botoes;

// Buttons handler
buttons_handler Buttons_handler (
    .clock              ( sig_pausa_mux ),
    .buttons_in         ( botoes ),
    .reset              ( reset ),
    .buttons_out        ( sig_botoes )
);

// Fluxo de Dados
FD_projeto FD (
    .clock              ( sig_pausa_mux ),
    .memory             ( memory ),
    .botoes             ( botoes ),
    //CONTADORES
    .contaE             ( sig_contaE ),
    .contaS             ( sig_contaS ),
    .contaTMR           ( sig_contaTMR ),
    .contaAM            ( sig_contaAM ),
    .zeraE              ( sig_zeraE ),
    .zeraS              ( sig_zeraS ),
    .zeraAM             ( sig_zeraAM ),
    .zeraTMR            ( sig_zeraTMR ),
    .fimE               ( sig_fimE ),
    .fimS               ( sig_fimS ),
    .fimTMR             ( sig_fimTMR ),
    .fimAM              ( sig_fimAM ),
    .fimAMZ             ( sig_fimAMZ ),
    //COMPARADORES
    .igualJ             ( sig_igualJ ),
    .igualS             ( sig_igualS ),
    //REGISTRADOR & RAM
    .limpaM             ( sig_limpaM ),
    .limpaR             ( sig_limpaR ),
    .registraM          ( sig_registraM ),
    .registraR          ( sig_registraR ),
    //DISPLAY
    .round              ( display_round ),
    .jogada             ( sig_jogada ),
    .memoria            ( sig_memoria ),
	 .metrica            ( sig_metrica ),
    .metrica_selector   ( metrica_selector ),
    //OUTROS
    .ledToshow          ( sig_ledToshow ),
    .acerto_counter     ( sig_acerto_counter ),
    .timeout_counter    ( sig_timeout_counter ),
    .tem_jogada         ( db_tem_jogada ),
    .jogada_feita       ( sig_jogada_feita ),
    .leds               ( leds )
);

// Unidade de Controle
UC_projeto UC (
    .clock              ( sig_pausa_mux ),
    .iniciar            ( jogar ),
    .reset              ( reset ),
    .modo               ( modo ),
	.memory				( memory ),
    //CONTADORES
    .contaE             ( sig_contaE ),
    .contaS             ( sig_contaS ),
    .contaTMR           ( sig_contaTMR ),
    .contaAM            ( sig_contaAM ),
    .acerto_counter     ( sig_acerto_counter ),
    .timeout_counter    ( sig_timeout_counter ),
    .zeraE              ( sig_zeraE ),
    .zeraS              ( sig_zeraS ),
    .zeraTMR            ( sig_zeraTMR ),
    .zeraAM             ( sig_zeraAM ),
    .fimE               ( sig_fimE ),
    .fimS               ( sig_fimS ),
    .fimTMR             ( sig_fimTMR ),
    .fimAM              ( sig_fimAM ),
    .fimAMZ             ( sig_fimAMZ ),
    //COMPARADORES
    .igualJ             ( sig_igualJ ),
    .igualS             ( sig_igualS ),
    //REGISTRADOR & RAM
    .limpaM             ( sig_limpaM ),
    .limpaR             ( sig_limpaR ),
    .registraM          ( sig_registraM ),
    .registraR          ( sig_registraR ),
    //DISPLAY
    .db_estado          ( sig_estadoTotal ),
    //OUTROS
    .ledToshow          ( sig_ledToshow ),
    .jogada             ( sig_jogada_feita ),
	 .pode_jogar			( pode_jogar ),
    .perdeu             ( perdeu ),
    .ganhou             ( ganhou ),
    .pronto             ( pronto )
);


// Display 7 segmentos ROUND
hexa7seg ROUND (
    .hexa       ( sig_round ),
    .display    ( )
);

// Display 7 segmentos MEMORIA
hexa7seg MEMORIA (
    .hexa       ( sig_memoria ),
    .display    ( display_memoria )
);

// Display 7 segmentos BOTOES
hexa7seg BOTOES (
    .hexa       ( sig_jogada ),
    .display    ( display_jogada )
);

// Display 7 segmentos estado LSB
hexa7seg ESTADOLSB (
    .hexa       ( sig_estadoLSB ),
    .display    ( display_estadoLSB )
);

// Display 7 segmentos estado MSB
hexa7seg ESTADOMSB (
    .hexa       ( sig_estadoMSB ),
    .display    ( display_estadoMSB )
);

// corretor clock
contador_m #(.M(50000), .N(16)) conversor_clock (
    .clock      ( clock_in ),
    .conta      ( 1'b1 ),
    .zera_as    ( zclock ),
    .zera_s     ( 1'b0 ),
    .Q          ( ),
    .fim        ( clock ),
    .meio       ( )
);

//METRICAS
// Display 7 segmentos Metricas
hexa7seg Metricas (
    .hexa       ( sig_metrica ),
    .display    ( display_metricas )
);

//Sinais Gerais
assign modo_state       = modo;
assign memory_state     = memory;
assign pausa_state		= pausa;
assign state            = sig_estadoTotal;

//Depuracao
assign db_StateMSB      = display_estadoMSB;
assign db_StateLSB      = display_estadoLSB;
assign db_Memoria       = display_memoria;
assign db_Jogada        = display_jogada;
assign db_clock			= sig_pausa_mux;
assign db_jogar			= jogar;

endmodule