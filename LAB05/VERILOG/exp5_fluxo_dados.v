/* --------------------------------------------------------------------
 * Arquivo   : exp4_fluxo_dados.v
 * Projeto   : Experiencia 4 - Desenvolvimento de Projeto de Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : Fluxo de Dados da Experiencia 4
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     24/01/2025  1.1     Ts1B7  versao inicial
 * --------------------------------------------------------------------
*/

module exp5_fluxo_dados (
    input [3:0] botoes,
    input clock,
    input contaE,
    input contaS,
    input contaTMR,
    input escreveM,
    input limpaM,
    input limpaR,
    input registraM,
    input registraR,
    input zeraE,
    input zeraS,
    input zeraTMR,
    output [3:0] db_contagem,
    output [3:0] db_jogada,
    output [3:0] db_memoria,
    output [3:0] db_sequencia,
	 output [3:0] db_limite,
    output db_tem_jogada,
    output fimE,
    output fimS,
    output fimTMR,
    output igualJ,
    output igualS,
    output jogada_feita,
    output [3:0] leds
);

// Sinais Intermediarios
wire [3:0] sig_mem_address;
wire [3:0] sig_mem_out;
wire [3:0] sig_reg_out;
wire [3:0] sig_contaS_out;
wire sig_db_tem_jogada; 
assign sig_db_tem_jogada = |botoes;

// contador_163 Sequencia
contador_163 contadorSequencia (
    .clock  ( clock ),
    .clr    ( ~zeraS ),
    .ld     ( 1'b1 ),
    .ent    ( 1'b1 ),
    .enp    ( contaS ),
    .D      ( 4'h0 ),
    .Q      ( sig_contaS_out ),
    .rco    ( fimS )
);

// contador_163 Rodada
contador_163 contadorRodada (
    .clock  ( clock ),
    .clr    ( ~zeraE ),
    .ld     ( 1'b1 ),
    .ent    ( 1'b1 ),
    .enp    ( contaE ),
    .D      ( 4'h0 ),
    .Q      ( sig_mem_address ),
    .rco    ( fimE )
);

// contador_timeout
contador_m timeout (
    .clock      ( clock ),
    .conta      ( contaTMR ),
    .zera_as    ( zeraTMR ),
    .zera_s     ( 1'b0 ),
    .Q          ( ),
    .fim        ( fimTMR ),
    .meio       ()

);

// Registrador 4 Bits
registrador_4 reg4Bits (
    .clock   ( clock ),
    .clear   ( limpaR ),
    .enable  ( registraR ),
    .D       ( botoes ),
    .Q       ( sig_reg_out )
);

//Detector de jogadas
edge_detector detector (
    .clock   ( clock ),
    .reset   ( limpaR ),
    .sinal   ( sig_db_tem_jogada ),
    .pulso   ( jogada_feita )
);

// sync_rom_16x4
sync_rom_16x4 memoria (
    .clock      ( clock ),
    .address    ( sig_contaS_out ),
    .data_out   ( sig_mem_out )
);

// comparador_85 Rodada
comparador_85 comparadorRodada (
    .A      ( sig_mem_out ),
    .B      ( sig_reg_out ),
    .ALBi   ( 1'b0 ),
    .AGBi   ( 1'b0 ),
    .AEBi   ( 1'b1 ),
    .ALBo   (  ),
    .AGBo   (  ),
    .AEBo   ( igualJ )
);

// comparador_85 Sequencia
comparador_85 comparadoSequencia (
    .A      ( sig_contaS_out ),
    .B      ( sig_mem_address ),
    .ALBi   ( 1'b0 ),
    .AGBi   ( 1'b0 ),
    .AEBi   ( 1'b1 ),
    .ALBo   (  ),
    .AGBo   (  ), 
    .AEBo   ( igualS )
);

assign db_jogada        = sig_reg_out;
assign db_contagem      = sig_mem_address;
assign db_memoria       = sig_mem_out;
assign db_tem_jogada    = sig_db_tem_jogada;
assign db_limite        = sig_contaS_out;
assign leds             = botoes;
endmodule