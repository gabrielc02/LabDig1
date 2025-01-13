/*
 * ------------------------------------------------------------------
 *  Arquivo   : circuito_exp2_ativ2-PARCIAL.v
 *  Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
 * ------------------------------------------------------------------
 *  Descricao : Circuito PARCIAL do fluxo de dados da Atividade 2
 * 
 *     1) COMPLETAR DESCRICAO
 * 
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      11/01/2024  1.0     Edson Midorikawa  versao inicial
 * ------------------------------------------------------------------
 */

module circuito_exp2_ativ2_desafio (clock, zera, carrega, conta, chaves, 
                            menor, maior, igual, fim, db_contagem);
    input        clock;
    input        zera;
    input        carrega;
    input        conta;
    input  [3:0] chaves;
    output       menor;
    output       maior;
    output       igual;
    output       fim;
    output [6:0] db_contagem;

    wire   [3:0] s_contagem;  // sinal interno para interligacao dos componentes contador e display
    wire   [6:0] c_contagem; // cinal interno para interligacao dos componentes display e db_contagem

    // contador_163
    contador_163 contador (
      .clock( clock ),
      .clr  ( ~zera ),
      .ld   ( ~carrega ),
      .ent  ( 1'b1 ),
      .enp  ( conta ),
      .D    ( chaves ),
      .Q    ( s_contagem ),
      .rco  ( fim )
    );

    // comparador_85
    comparador_85 comparador (
      .A   ( s_contagem ),
      .B   ( chaves ),
      .ALBi( 1'b0 ),
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( menor ),
      .AGBo( maior ),
      .AEBo( igual )
    );

    // Display 7 segmentos
    hexa7seg display (
      .hexa ( s_contagem ),
      .display ( c_contagem )
    );

    // saida de depuracao
    assign db_contagem = c_contagem;

 endmodule
