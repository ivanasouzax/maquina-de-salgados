library IEEE; 
use IEEE.std_logic_1164.all; 

entity Maquina is 
port (
		liberar: in std_logic; 
		clk: in std_logic; 
		iniciar: in std_logic; 
		reset: in std_logic; 
		selecionar: in std_logic; 
		confirmar_salgado: in std_logic; 
		moedas: in std_logic_vector(1 downto 0); 
		confirmar_moeda: in std_logic; 
		
		
		saldo_dinheiro: buffer integer range 0 to 999 := 0; 
		valor_salgado: buffer integer range 0 to 999 := 0; 
		estado: out std_logic_vector(2 downto 0); 
		
		
		display_salgado: out std_logic_vector(6 downto 0); 
		display_dinheiro_centena: out std_logic_vector(6 downto 0); 
		display_dinheiro_dezena: out std_logic_vector(6 downto 0); 
		display_dinheiro_unidade: out std_logic_vector(6 downto 0); 
		
		
		led_vermelho: out std_logic; 
		led_verde: out std_logic 
	);
end Maquina; 

architecture hardware of Maquina is 
	
	
	signal salgado_selecionado: integer range 1 to 6 := 1; 
	signal troco: integer range 0 to 999 := 0; 
	
	
	type estados is (estado_inicial, estado_salgado, estado_estoque, estado_moeda, estado_final, estado_reiniciar);
    signal estado_atual, proximo_estado: estados; 
    
    
    signal estoque_salgado1: integer range 0 to 10 := 1; 
	signal estoque_salgado2: integer range 0 to 10 := 5; 
	signal estoque_salgado3: integer range 0 to 10 := 5; 
	signal estoque_salgado4: integer range 0 to 10 := 1; 
	signal estoque_salgado5: integer range 0 to 10 := 5; 
    
    
	function converterDisplay7 (numero: integer) return std_logic_vector is
		variable saida: std_logic_vector(6 downto 0); 
	begin
		case (numero) is
			when 0 => saida := "1000000"; 
			when 1 => saida := "1111001"; 
			when 2 => saida := "0100100"; 
			when 3 => saida := "0110000"; 
			when 4 => saida := "0011001"; 
			when 5 => saida := "0010010"; 
			when 6 => saida := "0000010"; 
			when 7 => saida := "1111000"; 
			when 8 => saida := "0000000"; 
			when 9 => saida := "0010000"; 
			when others =>
		end case;
	return saida; 
	end converterDisplay7; 

begin 

	
	process(clk)
	begin
		if (clk'event and clk = '1') then
			estado_atual <= proximo_estado;
		end if;
	end process;
	
	
	process_selecionar_salgado: process (clk, selecionar)
		variable numero : integer range 1 to 6 := 1;
	begin
		if (clk = '1' and estado_atual = estado_inicial) then
			numero := 1;
			salgado_selecionado <= 1;
		elsif ((selecionar'event and selecionar = '0') and estado_atual = estado_salgado) then
			numero := numero + 1; 
			if (numero = 6) then 
				numero := 1; 
			end if;
			salgado_selecionado <= numero; 
		end if;
	end process;
	
	
	process_somar_moedas: process (clk, moedas, confirmar_moeda)
	begin
		if (clk = '1' and estado_atual = estado_inicial) then
			saldo_dinheiro <= 0;
		elsif ((confirmar_moeda'event and confirmar_moeda = '0') and estado_atual = estado_moeda) then
			case (moedas) is
				when "01" => saldo_dinheiro <= saldo_dinheiro + 25; 
				when "10" => saldo_dinheiro <= saldo_dinheiro + 50; 
				when "11" => saldo_dinheiro <= saldo_dinheiro + 100; 
				when others =>
			end case;
		end if;
	end process;

	
	process_maquina_estados: process (clk, reset)
	begin
	if (clk'event and clk = '1') then
		
		case (estado_atual) is
			when estado_inicial =>
				estado <= "001"; 
				led_vermelho <= '1'; 
				led_verde    <= '1'; 
				
				if (iniciar = '1') then
					proximo_estado <= estado_salgado;
				end if;
				
			when estado_salgado =>
				estado <= "010"; 
				led_vermelho <= '0'; 
				led_verde    <= '1'; 
				
				if (confirmar_salgado = '0') then
					proximo_estado <= estado_estoque;
				elsif (reset = '0') then
					proximo_estado <= estado_reiniciar;
				end if;
			
			when estado_estoque =>
				estado <= "011"; 
				led_vermelho <= '0'; 
				led_verde    <= '0'; 
				
				case (salgado_selecionado) is
					when 1 =>
						if (estoque_salgado1 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 2 =>
						if (estoque_salgado2 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 3 =>
						if (estoque_salgado3 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
				

	when 4 =>
						if (estoque_salgado4 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 5 =>
						if (estoque_salgado5 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					
					when others =>
				end case;
			
			when estado_moeda =>
				estado <= "100"; 
				led_vermelho <= '0'; 
				led_verde    <= '1'; 

				if (saldo_dinheiro >= valor_salgado) then
					proximo_estado <= estado_final;
				elsif (reset = '0') then
					proximo_estado <= estado_reiniciar;
				end if;
				
			when estado_final =>
				estado <= "101"; 
				led_vermelho <= '0'; 
				led_verde    <= '0'; 
				
				if (liberar = '1') then
					case (salgado_selecionado) is
						
						when 1 => estoque_salgado1 <= estoque_salgado1 - 1;
						when 2 => estoque_salgado2 <= estoque_salgado2 - 1;
						when 3 => estoque_salgado3 <= estoque_salgado3 - 1;
						when 4 => estoque_salgado4 <= estoque_salgado4 - 1;
						when 5 => estoque_salgado5 <= estoque_salgado5 - 1;
						when others =>
					end case;
					proximo_estado <= estado_reiniciar;
				end if;
				
			when estado_reiniciar =>
				estado <= "000"; 
				led_vermelho <= '1'; 
				led_verde    <= '0'; 
				proximo_estado <= estado_inicial; 
			
			when others =>
		end case;
		
	end if;
	end process; 

	
	process_atualizar_display: process(clk)
		variable centena, dezena, unidade : integer range 0 to 999; 
	begin
	if (clk'event and clk = '1') then
	
		case (estado_atual) is
			when estado_inicial =>
				display_salgado          <= "1111111"; 
				display_dinheiro_centena <= "1111111"; 
				display_dinheiro_dezena  <= "1111111"; 
				display_dinheiro_unidade <= "1111111"; 
				
			when estado_salgado =>
				display_salgado <= converterDisplay7(salgado_selecionado); 
				
				case (salgado_selecionado) is
					when 1 => 
						valor_salgado <= 250; 
						display_dinheiro_centena <= converterDisplay7(2); 
						display_dinheiro_dezena  <= converterDisplay7(5); 
						display_dinheiro_unidade <= converterDisplay7(0); 
						
					when 2 => 
						valor_salgado <= 150; 
						display_dinheiro_centena <= converterDisplay7(1); 
						display_dinheiro_dezena  <= converterDisplay7(5); 
						display_dinheiro_unidade <= converterDisplay7(0); 
						
					when 3 => 
						valor_salgado <= 75; 
						display_dinheiro_centena <= converterDisplay7(0); 
						display_dinheiro_dezena  <= converterDisplay7(7); 
						display_dinheiro_unidade <= converterDisplay7(5); 
						
					when 4 => 
						valor_salgado <= 350; 
						display_dinheiro_centena <= converterDisplay7(3); 
						display_dinheiro_dezena  <= converterDisplay7(5); 
						display_dinheiro_unidade <= converterDisplay7(0); 
						
					when 5 => 
						valor_salgado <= 200; 
						display_dinheiro_centena <= converterDisplay7(2); 
						display_dinheiro_dezena  <= converterDisplay7(0); 
						display_dinheiro_unidade <= converterDisplay7(0); 
					
					when others =>
				end case;
			
			when estado_moeda =>
				
				unidade := (saldo_dinheiro mod 10);
				dezena := (saldo_dinheiro / 10) mod 10;
				centena := (saldo_dinheiro / 100) mod 10;

				display_dinheiro_centena <= converterDisplay7(centena); 
				display_dinheiro_dezena  <= converterDisplay7(dezena); 
				display_dinheiro_unidade <= converterDisplay7(unidade); 
			
			when estado_final =>
				
				troco <= saldo_dinheiro - valor_salgado;
				unidade := (troco mod 10);
				dezena := (troco / 10) mod 10;
				centena := (troco / 100) mod 10;

				display_dinheiro_centena <= converterDisplay7(centena); 
				display_dinheiro_dezena  <= converterDisplay7(dezena); 
				display_dinheiro_unidade <= converterDisplay7(unidade); 
			
			when estado_reiniciar =>
				display_salgado          <= converterDisplay7(0); 
				display_dinheiro_centena <= converterDisplay7(0); 
				display_dinheiro_dezena  <= converterDisplay7(0); 
				display_dinheiro_unidade <= converterDisplay7(0); 
			
			when others =>
		end case;
		
	end if;
	end process; 

end hardware; 