/* --------------------------------------------------------------------
 * Arquivo   : registrador_N
 * Projeto   : PULO DO SAPO
 * --------------------------------------------------------------------
 * Descricao : Registrador parametrizavel
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao       Autor             Descricao
 *     16/03/2025   2.0     Gabriel Chaves      versao atualizada
 * --------------------------------------------------------------------
*/

module registrador_N #(parameter N=4)
(
    input        clock,
    input        clear,
    input        enable,
    input  [N-1:0] D,
    output [N-1:0] Q
);

    reg [N-1:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule