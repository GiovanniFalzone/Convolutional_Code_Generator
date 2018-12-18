library IEEE;
use IEEE.std_logic_1164.all;

entity FF_D is 
	port (
		d	:	in std_ulogic;
		q	:	out std_ulogic;
		clk	:	in std_ulogic;
		rst	:	in std_ulogic
	);
end FF_D;

architecture rtl of FF_D is
begin
	FF_D_p : process(clk,rst)
	begin
		if rst = '1' then
			q <= '0';
		elsif (clk = '1' and clk'event) then
			q <= d;
		end if;
	end process;
end rtl;