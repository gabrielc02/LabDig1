//------------------------------------------------------------------
// Arquivo   : exp5_unidade_controle.v
// Projeto   : Experiencia 5 - Projeto de um Jogo de Sequências de Jogadas
//------------------------------------------------------------------
// Descricao : Unidade de controle
//            
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/01/2024  1.0     Edson Midorikawa  versao inicial
//     25/01/2025  1.2     T1B07             versao atualizada
//     27/01/2025  1.3     T1BB7             nova UC
//------------------------------------------------------------------
//
module exp5_unidade_controle ( 
    input      clock,
    input      fimE,
    input      fimS,
    input      fimTMR,
    input      igualJ,
    input      igualS,
    input      iniciar,
    input      jogada,
    input      reset,
    output reg contaE,
    output reg contaS,
    output reg contaTMR,
    output reg ganhou,
    output reg limpaM,
    output reg limpaR,
    output reg perdeu,
    output reg pronto,
    output reg registraM,
    output reg registraR,
    output reg zeraE,
    output reg zeraS,
    output reg zeraTMR,
    output reg [3:0] db_estado
);

    // Define estados
    parameter inicial               = 4'h0;  // 0
    parameter inicializa_elementos  = 4'h1;  // 1
    parameter inicia_sequencia      = 4'h2;  // 2
    parameter espera_jogada         = 4'h3;  // 3
    parameter registra_jogada       = 4'h4;  // 4
    parameter compara_jogada        = 4'h5;  // 5
    parameter proxima_jogada        = 4'h6;  // 6
    parameter ultima_sequencia      = 4'h7;  // 7
    parameter proxima_sequencia     = 4'h8;  // 8
    parameter final_errou           = 4'h9;  // 9
    parameter final_acertou         = 4'hA;  // 10
    parameter timeout               = 4'HB;  // 11   
 

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
            inicializa_elementos:   Eprox = inicia_sequencia;
            inicia_sequencia:       Eprox = espera_jogada;
            espera_jogada:          Eprox = fimTMR ? timeout :  (jogada ? registra_jogada : espera_jogada);
            registra_jogada:        Eprox = compara_jogada;
            compara_jogada:         Eprox = igualJ ? (igualS ? ultima_sequencia : proxima_jogada) : final_errou;
            proxima_jogada:			Eprox = espera_jogada;
            ultima_sequencia:	    Eprox = fimS ? final_acertou : proxima_sequencia;
            proxima_sequencia:      Eprox = inicia_sequencia;
            timeout:                Eprox = iniciar ? inicializa_elementos : timeout;
			final_acertou:          Eprox = iniciar ? inicializa_elementos : final_acertou;
            final_errou:            Eprox = iniciar ? inicializa_elementos : final_errou;
            default:                Eprox = inicial;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        contaE      = (Eatual == proxima_sequencia);
        contaS      = (Eatual == proxima_jogada);
        registraR   = (Eatual == registra_jogada);
        limpaR      = (Eatual == inicial || Eatual == inicializa_elementos);
        zeraE       = (Eatual == inicial || Eatual == inicializa_elementos);
        zeraS       = (Eatual == inicial || Eatual == inicializa_elementos || Eatual == inicia_sequencia);
        zeraTMR     = (Eatual == inicial || Eatual == inicializa_elementos || Eatual == inicia_sequencia || Eatual == proxima_jogada);
        contaTMR    = (Eatual == espera_jogada);
        pronto      = (Eatual == final_acertou || Eatual == final_errou || timeout);
        ganhou      = (Eatual == final_acertou);
        perdeu      = (Eatual == final_errou || Eatual == timeout);

        // Saida de depuracao (estado)
        case (Eatual)
            inicial:                db_estado = 4'h0;  // 0
            inicializa_elementos:   db_estado = 4'h1;  // 1
            inicia_sequencia:       db_estado = 4'h2;  // 2
            espera_jogada:          db_estado = 4'h3;  // 3
            registra_jogada:        db_estado = 4'h4;  // 4
            compara_jogada:         db_estado = 4'h5;  // 5
            proxima_jogada:         db_estado = 4'h6;  // 6
            ultima_sequencia:       db_estado = 4'h7;  // 7
            proxima_sequencia:      db_estado = 4'h8;  // 8
            final_errou:            db_estado = 4'h9;  // 9
            final_acertou:          db_estado = 4'hA;  // 10
            timeout:                db_estado = 4'HB;  // 11  
            default:                db_estado = 4'HF;  // F (erro)
        endcase
    end
	
endmodule