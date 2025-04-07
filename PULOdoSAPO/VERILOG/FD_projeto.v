/* --------------------------------------------------------------------
 * Arquivo   : FD_PROJETO
 * Projeto   : PULO DO SAPO
 * --------------------------------------------------------------------
 * Descricao : Fluxo de Dados do projeto final
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao       Autor             Descricao
 *     15/03/2025   2.0     Gabriel Chaves      versao atualizada
 * --------------------------------------------------------------------
*/

module FD_projeto (
    input clock,
    input memory,
    input [3:0] botoes,
    //CONTADORES
    input contaE,
    input contaS,
    input contaTMR,
    input contaAM,
    input zeraE,
    input zeraS,
    input zeraAM,
    input zeraTMR,
    output fimE,
    output fimS,
    output fimTMR,
    output fimAM,
    output fimAMZ,
    //COMPARADORES
    output igualJ,
    output igualS,
    //REGISTRADOR & RAM
    input limpaM,
    input limpaR,
    input registraM,
    input registraR,
    //OUTROS
    input ledToshow,
    input acerto_counter,
    input timeout_counter,
    input [1:0] metrica_selector,
    //DISPLAY
    output [3:0] round,
    output [3:0] jogada,
    output [3:0] memoria,
    output [3:0] metrica,
    //OUTROS
    output tem_jogada,
    output jogada_feita,    
    output [3:0] leds
);

// Sinais Intermediarios
wire [3:0] sig_mem_address;
wire [3:0] sig_mem_out;
wire [3:0] sig_mem_out0;
wire [3:0] sig_mem_out1;
wire [3:0] sig_reg_out;
wire [3:0] sig_contaS_out;
wire sig_fim;
wire sig_tem_jogada; 
assign sig_tem_jogada = |botoes;
wire [13:0] sig_user_time;

// contador Rodada
contador_m #(.M(16), .N(4)) contadorRound (
    .clock      ( clock ),
    .conta      ( contaE ),
    .zera_as    ( zeraE ),
    .zera_s     ( 1'b0 ),
    .Q          ( sig_mem_address ),
    .fim        ( fimE ),
    .meio       ( )
);

// contador sequencia
contador_m #(.M(16), .N(4)) contadorSequencia (
    .clock      ( clock ),
    .conta      ( contaS ),
    .zera_as    ( zeraS ),
    .zera_s     ( 1'b0 ),
    .Q          ( sig_contaS_out ),
    .fim        ( sig_fim ),
    .meio       ( )
);

// contador timeout
contador_m #(.M(10000), .N(14)) TimerTimeout (
    .clock      ( clock ),
    .conta      ( contaTMR ),
    .zera_as    ( zeraTMR ),
    .zera_s     ( 1'b0 ),
    .Q          ( sig_user_time ),
    .fim        ( fimTMR ),
    .meio       ()

);

// contador tempo de amostragem
contador_m #(.M(1000), .N(10)) TimerAmostragem (
    .clock      ( clock ),
    .conta      ( contaAM ),
    .zera_as    ( zeraAM ),
    .zera_s     ( 1'b0 ),
    .Q          ( ),
    .fim        ( fimAM ),
    .meio       ( fimAMZ )
);

// comparador Rodada
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

// comparador Sequencia
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

// Registrador 4 Bits
registrador_N #(.N(4)) reg4Bits (
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
    .sinal   ( sig_tem_jogada ),
    .pulso   ( jogada_feita )
);

// sync_rom_16x4
sync_rom_16x4 memoria0 (
    .clock      ( clock ),
    .address    ( sig_contaS_out ),
    .data_out   ( sig_mem_out0 )
);

// sync_ram_16x4
sync_ram_16x4 memoria1 (
    .clock          ( clock ),
    .write_enable   ( registraM ),
    .reset          ( limpaM ),
    .address        ( sig_contaS_out ),
    .data_in        ( sig_reg_out ),
    .data_out       ( sig_mem_out1 )
);

// Metricas
//Timeouts
contador_m #(.M(16), .N(4)) num_timeout (
    .clock      ( clock),
    .conta      ( timeout_counter ),
    .zera_as    ( limpaM ),
    .zera_s     ( 1'b0 ),
    .Q          ( num_timeouts ),
    .fim        ( ),
    .meio       ( )

);

//Acertos
contador_m #(.M(16), .N(4)) num_acerto (
    .clock      ( clock ),
    .conta      ( acerto_counter ),
    .zera_as    ( limpaM ),
    .zera_s     ( 1'b0 ),
    .Q          ( num_acertos ),
    .fim        ( ),
    .meio       ( )

);

//TEMPO MEDIO
/*wire [3:0] avg_time;
wire [3:0] alu_time;
wire [5:0] temp_sum;
// Soma antes da divisão
assign tem_sum = avg_time + sig_user_time;
// Divisão segura, evita divisão por zero
assign alu_time = (sig_mem_address != 0) ? (temp_sum / sig_mem_address) : 4'b0000; 
registrador_N #(.N(4)) AVGTime (
    .clock   ( clock ),
    .clear   ( limpaR ),
    .enable  ( registraR ),
    .D       ( alu_time ),
    .Q       ( avg_time )
);*/

assign jogada        = sig_reg_out;
assign round         = sig_mem_address;
assign tem_jogada    = sig_tem_jogada;
assign fimS          = sig_fim;
assign sig_mem_out   = memory ? sig_mem_out1 : sig_mem_out0;
assign memoria       = sig_mem_out;
assign leds          = ledToshow ? sig_mem_out : botoes; 
assign metrica       = metrica_selector[0] ? num_acertos : num_timeouts;

endmodule