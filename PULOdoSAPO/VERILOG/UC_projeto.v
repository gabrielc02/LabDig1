/* --------------------------------------------------------------------
 * Arquivo   : UC_PROJETO
 * Projeto   : PULO DO SAPO
 * --------------------------------------------------------------------
 * Descricao : Unidade de controle do projeto final
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao       Autor             Descricao
 *    17/03/2025   2.0     Gabriel Chaves      versao atualizada
 * --------------------------------------------------------------------
*/

module UC_projeto ( 
    input      clock,
    input      iniciar,
    input      reset,
    input      modo,
    input      memory,
    //CONTADORES
    input      fimE,
    input      fimS,
    input      fimTMR,
    input      fimAM,
    input      fimAMZ,
    //COMPARADORES
    input      igualJ,
    input      igualS,
    //OUTROS
    input      jogada,
    //CONTADORES
    output reg contaE,
    output reg contaS,
    output reg contaTMR,
    output reg contaAM,
    output reg acerto_counter,
    output reg timeout_counter,
    output reg zeraE,
    output reg zeraS,
    output reg zeraTMR,
    output reg zeraAM,
    //REGISTRADOR & RAM
    output reg limpaM,
    output reg limpaR,
    output reg registraM,
    output reg registraR,
    //DISPLAY
    output reg [7:0] db_estado,
    //OUTROS
    output reg ledToshow,
    output reg perdeu,
    output reg ganhou,
	 output reg pode_jogar,
    output reg pronto
);

    // Define estados
    parameter inicial                       = 8'h00; // 0
    parameter inicializa_elementos          = 8'h01; // 1
    parameter inicia_sequencia              = 8'h02; // 2
    parameter inicia_amostragem             = 8'h03; // 3
    parameter amostra_valor                 = 8'h04; // 4
    parameter transicao_amostragem          = 8'h05; // 5
    parameter amostra_zero                  = 8'h06; // 6
    parameter compara_amostragem            = 8'h07; // 7
    parameter proxima_amostragem            = 8'h08; // 8
    parameter fim_amostragem                = 8'h09; // 9 
    parameter espera_jogada                 = 8'h0A; // 10
    parameter registra_jogada               = 8'h0B; // 11
    parameter compara_jogada                = 8'h0C; // 12
    parameter proxima_jogada                = 8'h0D; // 13
    parameter ultima_sequencia              = 8'h0E; // 14
    parameter proxima_sequencia             = 8'h0F; // 15
    parameter final_errou                   = 8'h10; // 16
    parameter final_acertou                 = 8'h11; // 17
    parameter timeout                       = 8'h12; // 18
    parameter memory_setup                  = 8'h13; // 19
    parameter inicia_cria_jogada            = 8'h14; // 20
    parameter espera_jogada_criacao         = 8'h15; // 21
    parameter proxima_jogada_criacao        = 8'h16; // 22
    parameter fim_jogada_criacao            = 8'h17; // 23
    parameter registra_jogada_criacao       = 8'h18; // 24
    parameter seleciona_modo                = 8'h19; // 25
    parameter inicia_modo1                  = 8'h1A; // 26
    parameter espera_jogada_modo1           = 8'h1B; // 27
    parameter registra_jogada_modo1         = 8'h1C; // 28  
    parameter compara_jogada_modo1          = 8'h1D; // 29
    parameter proxima_jogada_modo1          = 8'h1E; // 30
    parameter registra_timeout              = 8'h1F; // 31
    parameter registra_acertos              = 8'h20; // 32
    parameter amostra_valor_modo1           = 8'h21; // 33
    parameter transicao_amostragem_modo1    = 8'h22; // 34
    parameter amostra_zero_modo1            = 8'h23; // 35

    // Variaveis de estado
    reg [8:0] Eatual, Eprox;

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
            
            //ESTADOS INICIAIS
            inicial:                    Eprox = iniciar ? memory_setup : inicial;
            memory_setup:               Eprox = memory ? inicia_cria_jogada : inicializa_elementos;
            inicializa_elementos:       Eprox = seleciona_modo;
            seleciona_modo:             Eprox = modo ? inicia_modo1 : inicia_sequencia;
            inicia_sequencia:           Eprox = inicia_amostragem;
            
            //CRIA JOGADAS
            inicia_cria_jogada:         Eprox = espera_jogada_criacao;
            espera_jogada_criacao:      Eprox = jogada ? registra_jogada_criacao : espera_jogada_criacao;
            registra_jogada_criacao:    Eprox = proxima_jogada_criacao;
            proxima_jogada_criacao:     Eprox = fimS ? fim_jogada_criacao : espera_jogada_criacao;
            fim_jogada_criacao:         Eprox = inicializa_elementos;

            //MODO0
            //AMOSTRAGEM LEDS
            inicia_amostragem:          Eprox = amostra_valor; 
            amostra_valor:              Eprox = fimAM ? transicao_amostragem : amostra_valor;
            transicao_amostragem:       Eprox = amostra_zero;
            amostra_zero:               Eprox = fimAMZ ? compara_amostragem : amostra_zero;
            compara_amostragem:         Eprox = igualS ? fim_amostragem : proxima_amostragem;
            proxima_amostragem:         Eprox = inicia_amostragem;
            fim_amostragem: 	        Eprox = espera_jogada;

            //SEQUENCIA JOGADAS
            espera_jogada:              Eprox = fimTMR ? registra_timeout : (jogada ? registra_jogada : espera_jogada);
            registra_jogada:            Eprox = compara_jogada;
            compara_jogada:             Eprox = igualJ ? (igualS ? ultima_sequencia : proxima_jogada) : final_errou;
            proxima_jogada:			    Eprox = espera_jogada;
            ultima_sequencia:	        Eprox = fimS ? registra_acertos : proxima_sequencia;
            proxima_sequencia:          Eprox = inicia_sequencia;

            //MODO1
            inicia_modo1:               Eprox = amostra_valor_modo1;
            amostra_valor_modo1:        Eprox = fimAM ? transicao_amostragem_modo1 : amostra_valor_modo1;
            transicao_amostragem_modo1: Eprox = amostra_zero_modo1;
            amostra_zero_modo1:         Eprox = fimAMZ ? espera_jogada_modo1 : amostra_zero_modo1;
            espera_jogada_modo1:        Eprox = fimTMR ? registra_timeout : (jogada ? registra_jogada_modo1 : espera_jogada_modo1);
            registra_jogada_modo1:      Eprox = compara_jogada_modo1;
            compara_jogada_modo1:       Eprox = igualJ ? (fimS ? registra_acertos : proxima_jogada_modo1) : final_errou;
            proxima_jogada_modo1:       Eprox = amostra_valor_modo1;

            //FINAIS
            registra_timeout:           Eprox = timeout;
            timeout:                    Eprox = iniciar ? inicializa_elementos : timeout;
            registra_acertos:           Eprox = final_acertou;
			final_acertou:              Eprox = iniciar ? inicializa_elementos : final_acertou;
            final_errou:                Eprox = iniciar ? inicializa_elementos : final_errou;
            default:                    Eprox = inicial;
        
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin

        //SINAIS CONTROLE
        ledToshow = (Eatual == amostra_valor || Eatual == amostra_valor_modo1);
		  pode_jogar = (Eatual == espera_jogada_criacao || Eatual == espera_jogada || Eatual == espera_jogada_modo1);

        //CONTADORES
        //CONTADOR DE ROUND
        contaE      = (Eatual == proxima_sequencia);
        zeraE       = (Eatual == inicializa_elementos);

        //CONTADOR SEQUENCIA
        contaS      = (Eatual == proxima_jogada || Eatual == proxima_amostragem || Eatual == proxima_jogada_criacao || Eatual == proxima_jogada_modo1);
        zeraS       = (Eatual == inicializa_elementos || Eatual == fim_amostragem || Eatual == inicia_sequencia || Eatual ==  inicia_cria_jogada || Eatual == inicia_modo1);
        
        //CONTADOR NUMERO TIMEOUTS
        timeout_counter = (Eatual == registra_timeout);

        //CONTADOR NUMERO ACERTOS
        acerto_counter = (Eatual == registra_acertos);
        
        //TIMER AMOSTRAGEM
        contaAM     = (Eatual == amostra_valor || Eatual == amostra_zero || Eatual == amostra_valor_modo1 || Eatual == amostra_zero_modo1);
        zeraAM      = (Eatual == inicializa_elementos || Eatual == transicao_amostragem || Eatual == proxima_amostragem || Eatual == transicao_amostragem_modo1 || Eatual == proxima_jogada_modo1);

        //TIMER TIMEOUT
        zeraTMR     = (Eatual == inicial || Eatual == inicializa_elementos || Eatual == inicia_sequencia || Eatual == proxima_jogada || Eatual == inicia_modo1 || Eatual == proxima_jogada_modo1);
        contaTMR    = (Eatual == espera_jogada || Eatual == espera_jogada_modo1);
        
        //REGISTRADOR DE JOGADA
        registraR   = (Eatual == registra_jogada || Eatual == registra_jogada_criacao || registra_jogada_modo1);
        limpaR      = (Eatual == inicial || Eatual == inicializa_elementos);

        //MEMORIA RAM
        registraM   = (Eatual == registra_jogada_criacao);
        limpaM      = (Eatual == inicial);

        //SINAIS RESULTADO
        pronto      = (Eatual == final_acertou || Eatual == final_errou || Eatual == timeout);
        ganhou      = (Eatual == final_acertou);
        perdeu      = (Eatual == final_errou || Eatual == timeout);

        // Saida de depuracao (estado)
        case (Eatual)
        
            inicial:                        db_estado = 8'h00; // 0
            inicializa_elementos:           db_estado = 8'h01; // 1
            inicia_sequencia:               db_estado = 8'h02; // 2
            inicia_amostragem:              db_estado = 8'h03; // 3
            amostra_valor:                  db_estado = 8'h04; // 4
            transicao_amostragem:           db_estado = 8'h05; // 5
            amostra_zero:                   db_estado = 8'h06; // 6
            compara_amostragem:             db_estado = 8'h07; // 7
            proxima_amostragem:             db_estado = 8'h08; // 8
            fim_amostragem:                 db_estado = 8'h09; // 9 
            espera_jogada:                  db_estado = 8'h0A; // 10
            registra_jogada:                db_estado = 8'h0B; // 11
            compara_jogada:                 db_estado = 8'h0C; // 12
            proxima_jogada:                 db_estado = 8'h0D; // 13
            ultima_sequencia:               db_estado = 8'h0E; // 14
            proxima_sequencia:              db_estado = 8'h0F; // 15
            final_errou:                    db_estado = 8'h10; // 16
            final_acertou:                  db_estado = 8'h11; // 17
            timeout:                        db_estado = 8'h12; // 18
            memory_setup:                   db_estado = 8'h13; // 19
            inicia_cria_jogada:             db_estado = 8'h14; // 20   
            espera_jogada_criacao:          db_estado = 8'h15; // 21
            proxima_jogada_criacao:         db_estado = 8'h16; // 22
            fim_jogada_criacao:             db_estado = 8'h17; // 23
            registra_jogada_criacao:        db_estado = 8'h18; // 24
            seleciona_modo:                 db_estado = 8'h19; // 25
            inicia_modo1:                   db_estado = 8'h1A; // 26
            espera_jogada_modo1:            db_estado = 8'h1B; // 27
            registra_jogada_modo1:          db_estado = 8'h1C; // 28  
            compara_jogada_modo1:           db_estado = 8'h1D; // 29
            proxima_jogada_modo1:           db_estado = 8'h1E; // 30
            registra_timeout:               db_estado = 8'h1F; // 31
            registra_acertos:               db_estado = 8'h20; // 32
            amostra_valor_modo1:            db_estado = 8'h21; // 33
            transicao_amostragem_modo1:     db_estado = 8'h22; // 34
            amostra_zero_modo1:             db_estado = 8'h23; // 35
            default:	                    db_estado = 8'hFF; // FF (erro)

        endcase
    end
	
endmodule