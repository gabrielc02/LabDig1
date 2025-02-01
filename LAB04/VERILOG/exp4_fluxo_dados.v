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

module exp4_fluxo_dados (
    input [3:0] chaves,
    input clock, contaC, registraR, zeraC, zeraR,
    output igual, fimC, jogada_feita, db_tem_jogada,
    output [3:0] db_jogada, db_contagem, db_memoria
);

wire [3:0] sig_mem_address;
wire [3:0] sig_mem_out;
wire [3:0] sig_reg_out;
wire sig_fim;
wire sig_jogada_feita;
wire sig_db_tem_jogada;
assign sig_db_tem_jogada = |chaves; 
wire reset_detector;
assign reset_detector = zeraC;

// contador_163
contador_163 contador (
    .clock  ( clock ),
    .clr    ( ~zeraC ),
    .ld     ( 1'b1 ),
    .ent    ( 1'b1 ),
    .enp    ( contaC ),
    .D      ( 4'b0000 ),
    .Q      ( sig_mem_address ),
    .rco    ( sig_fim )
);

// Registrador 4 Bits
registrador_4 reg4Bits (
    .clock   ( clock ),
    .clear   ( zeraR ),
    .enable  ( registraR ),
    .D       ( chaves ),
    .Q       ( sig_reg_out )
);

//Detector de jogadas
edge_detector detector (
    .clock   ( clock ),
    .reset   ( reset_detector ),
    .sinal   ( sig_db_tem_jogada ),
    .pulso   ( sig_jogada_feita )
);

// sync_rom_16x4
sync_rom_16x4 memoria (
    .clock      ( clock ),
    .address    ( sig_mem_address ),
    .data_out   ( sig_mem_out )
);

// comparador_85
comparador_85 comparador (
    .A      ( sig_mem_out ),
    .B      ( sig_reg_out ),
    .ALBi   ( 1'b0 ),
    .AGBi   ( 1'b0 ),
    .AEBi   ( 1'b1 ),
    .ALBo   (  ),
    .AGBo   (  ),
    .AEBo   ( igual )
);

assign fimC =           sig_fim;
assign db_jogada =      sig_reg_out;
assign db_contagem =    sig_mem_address;
assign db_memoria =     sig_mem_out;
assign db_tem_jogada =  sig_db_tem_jogada;
assign jogada_feita =   sig_jogada_feita;

endmodule