library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- questo modulo realizza il generatore convoluzionale
-- ha in ingresso un bit Ak, clock e reset che vengono connessi agli ShiftRegister
-- ha in uscita il bit Ak e il bit Ck
-- i Vettori Generatori vengono definiti come costanti di tipo intero
-- vengono convertiti e il relativo vettore di bit è dato in ingresso al RC_GeneratorVect 

entity GEN_CONV_CODE is 
	port (
		x	:	in std_ulogic;
		a_k	:	out std_ulogic;
		c_k :	out std_ulogic;
		clk	:	in std_ulogic;
		rst	:	in std_ulogic
	);
end GEN_CONV_CODE;

architecture rtl of GEN_CONV_CODE is
	component FF_D_SHIFTREG_N
		generic (Nbit : positive := 8);
		port(
				d : in std_ulogic;
				q : out std_ulogic_vector(0 to Nbit - 1);
				clk : in std_ulogic;
				rst : in std_ulogic
			);
	end component FF_D_SHIFTREG_N;

	component RC_GeneratorVect
		generic (Nbit : positive :=16);
		port (
			GenVect : in std_ulogic_vector(0 to Nbit-1);
			x	:	in std_ulogic_vector(0 to Nbit-1);
			y	:	out std_ulogic
		);
	end component RC_GeneratorVect;

constant Nbit : positive := 5;				-- dimensione primo ShiftRegister A
constant GenVect_1 : positive := (16+2+1);	-- costante vettore 10011 per A

constant Mbit : positive := 10;				-- dimensione secondo Shift Register B
constant GenVect_2 : positive := (4+1);		-- costante vettore 0000000101 per B

signal 	ak : std_ulogic_vector(0 to Nbit-1);	-- wire in uscita da ogni stadio dello ShiftRegister A
signal 	ck : std_ulogic_vector(0 to Mbit-1);	-- wire in uscita da ogni stadio dello ShiftRegister B

signal	y_1: std_ulogic;		-- wire in uscita dal GenVect1
signal	y_2: std_ulogic;		-- wire in uscita dal GenVect2

signal 	Logic_out : std_ulogic;	-- wire in ingresso al secondo ShiftRegister C

signal	GenVectSignal1 : std_ulogic_vector(0 to Nbit-1);	-- wire in ingresso al GenVect1
signal	GenVectSignal2 : std_ulogic_vector(0 to Mbit-1);	-- wire in ingresso al GenVect2

begin
	GenVectSignal1 <= std_ulogic_vector(TO_UNSIGNED(GenVect_1, Nbit)); 	-- conversione ed assegnamento del valore
	GenVectSignal2 <= std_ulogic_vector(TO_UNSIGNED(GenVect_2, Mbit));	-- dei due Vettori Generatori

	Logic_out <= y_1 xor y_2;
	c_k <= Logic_out;	-- output Ck
	a_k	<= ak(0);	-- output Ak

	A_Shiftreg : FF_D_SHIFTREG_N
		generic map(Nbit => Nbit)
		port map(
			d => x,
			q => ak,
			clk => clk,
			rst => rst
		);

	GenVect1 : RC_GeneratorVect
		generic map(Nbit => Nbit)
		port map(
			GenVect => GenVectSignal1,
			x => ak,
			y => y_1
		);

	GenVect2 : RC_GeneratorVect
		generic map(Nbit => Mbit)
		port map(
			GenVect => GenVectSignal2,
			x => ck,
			y => y_2
		);

	C_Shiftreg : FF_D_SHIFTREG_N
		generic map(Nbit => Mbit)
		port map(
			d => Logic_out,
			q => ck,
			clk => clk,
			rst => rst
		);
end rtl;