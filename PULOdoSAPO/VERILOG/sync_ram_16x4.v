module sync_ram_16x4 (
    input            clock,
    input            reset,        // Sinal de reset
    input            write_enable, // Sinal de escrita
    input      [3:0] address,      // Endereço de acesso
    input      [3:0] data_in,      // Entrada de dados
    output reg [3:0] data_out      // Saída de dados
);
    reg [3:0] memory [15:0]; // Memória de 16 posições, 4 bits cada

    always @ (posedge clock) begin
        if (reset) begin
            // Reset manual sem loop for
            memory[0]  <= 4'b0000;
            memory[1]  <= 4'b0000;
            memory[2]  <= 4'b0000;
            memory[3]  <= 4'b0000;
            memory[4]  <= 4'b0000;
            memory[5]  <= 4'b0000;
            memory[6]  <= 4'b0000;
            memory[7]  <= 4'b0000;
            memory[8]  <= 4'b0000;
            memory[9]  <= 4'b0000;
            memory[10] <= 4'b0000;
            memory[11] <= 4'b0000;
            memory[12] <= 4'b0000;
            memory[13] <= 4'b0000;
            memory[14] <= 4'b0000;
            memory[15] <= 4'b0000;
        end else if (write_enable) begin
            memory[address] <= data_in; // Escreve o dado no endereço desejado
        end
        data_out <= memory[address]; // Lê o dado armazenado
    end
endmodule