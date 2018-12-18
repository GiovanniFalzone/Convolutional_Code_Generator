library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- questo modulo realizza la logica relativa al Vettore Generatore
-- prende come ingresso il valore attuale dello stato dello ShiftRegister
-- prende come ingresso il vettore Generatore

entity RC_GeneratorVect is 
	generic (Nbit : positive :=16);
	port (
		GenVect : in std_ulogic_vector(0 to Nbit-1);	-- input Vettore Generatore
		x	:	in std_ulogic_vector(0 to Nbit-1);		-- input Settore Stato dello ShiftRegister
		y	:	out std_ulogic 							-- output
	);
end RC_GeneratorVect;

architecture rtl of RC_GeneratorVect is
	signal a : std_ulogic_vector(0 to Nbit-1); 		-- wire uscita della AND tra Stato e Vettore Generatore
	signal par : std_ulogic_vector(0 to Nbit-2);	-- wire per realizzare la cascata di XOR

	begin
		a <= x and GenVect;

	-- generation
		GEN: for i in 0 to Nbit-1  generate
			FIRST: if i = 0 generate
				par(0) <= a(0) xor a(1);	-- primo xor necessita dei primi due ingressi
			end generate FIRST;

			MIDDLE: if i > 0 and i < Nbit-1 generate
				par(i) <= par(i-1) xor a(i); -- cascata di XOR intermedi
			end generate MIDDLE;

			LAST: if i = Nbit-1 generate
				y <= par(i-1) xor a(i);		-- output dell'ultimo XOR è anche l'output del modulo
			end generate LAST;
		end generate GEN;
end rtl;