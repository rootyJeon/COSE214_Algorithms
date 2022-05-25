library verilog;
use verilog.vl_types.all;
entity Data_Forwarding is
    port(
        rs1_exe         : in     vl_logic_vector(4 downto 0);
        rs2_exe         : in     vl_logic_vector(4 downto 0);
        rd_mem          : in     vl_logic_vector(4 downto 0);
        rd_wb           : in     vl_logic_vector(4 downto 0);
        afwd            : out    vl_logic_vector(1 downto 0);
        bfwd            : out    vl_logic_vector(1 downto 0)
    );
end Data_Forwarding;
