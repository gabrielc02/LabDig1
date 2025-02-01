//------------------------------------------------------------------
// Arquivo   : exp4_unidade_controle.v
// Projeto   : Experiencia 4 - Desenvolvimento de Projeto de Circuitos Digitais em FPGA
//------------------------------------------------------------------
// Descricao : Unidade de controle
//
// usar este codigo como template (modelo) para codificar 
// máquinas de estado de unidades de controle            
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/01/2024  1.0     Edson Midorikawa  versao inicial
//     25/01/2025  1.2     T1B07             versao atualizada
//------------------------------------------------------------------
//
module exp4_unidade_controle (
    input      clock,
    input      igual,
    input      reset,
    input      iniciar,
    input      jogada,
    input      fim,
    output reg zeraC,
    output reg contaC,
    output reg zeraR,
    output reg registraR,
    output reg pronto,
    output reg acertou, errou,
    output reg [3:0] db_estado
);

    // Define estados
    parameter inicial               = 4'b0000;  // 0
    parameter inicializa_elementos  = 4'b0001;  // 1
    parameter espera_jogada         = 4'b0011;  // 3
    parameter registra_jogada       = 4'b0100;  // 4
    parameter proxima_jogada        = 4'b0101;  // 5
    parameter compara_jogada        = 4'b0110;  // 6
    parameter final_acertou         = 4'b0111;  // 7
    parameter final_errou           = 4'b1000;  // 8

    // Variaveis de estado
    reg [3:0] Eatual, Eprox;

    // Memoria de estado
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    // Logica de proximo estado
    always @* begin
        case (Eatual)
            inicial:                Eprox = iniciar ? inicializa_elementos : inicial;
            inicializa_elementos:   Eprox = espera_jogada;
            espera_jogada:          Eprox = jogada ? registra_jogada : espera_jogada;
            registra_jogada:        Eprox = compara_jogada;
            compara_jogada:         Eprox = igual ? (fim ? final_acertou : proxima_jogada) : final_errou;
            proxima_jogada:			Eprox = espera_jogada;
			final_acertou:          Eprox = iniciar ? inicializa_elementos : final_acertou;
            final_errou:            Eprox = iniciar ? inicializa_elementos : final_errou;
            default:                Eprox = inicial;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        zeraC     = (Eatual == inicial || Eatual == inicializa_elementos) ? 1'b1 : 1'b0;
        zeraR     = (Eatual == inicial) ? 1'b1 : 1'b0;
        registraR = (Eatual == registra_jogada) ? 1'b1 : 1'b0;
        contaC    = (Eatual == proxima_jogada) ? 1'b1 : 1'b0;
        pronto    = (Eatual == final_acertou || Eatual == final_errou) ? 1'b1: 1'b0;
        acertou   = (Eatual == final_acertou) ? igual : 1'b0;
        errou     = (Eatual == final_errou) ? (~igual) : 1'b0;

        // Saida de depuracao (estado)
        case (Eatual)
            inicial:                db_estado = 4'b0000;  // 0
            inicializa_elementos:   db_estado = 4'b0001;  // 1
            espera_jogada:          db_estado = 4'b0011;  // 3
            registra_jogada:        db_estado = 4'b0100;  // 4
            proxima_jogada:         db_estado = 4'b0101;  // 5
            compara_jogada:         db_estado = 4'b0110;  // 6
            final_acertou:          db_estado = 4'b0111;  // 7
            final_errou:            db_estado = 4'b1000;  // 8
            default:                db_estado = 4'b1110;  // E (erro)
        endcase
    end
	

endmodule