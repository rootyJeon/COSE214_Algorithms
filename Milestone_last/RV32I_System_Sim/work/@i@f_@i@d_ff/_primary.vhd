library verilog;
use verilog.vl_types.all;
entity IF_ID_ff is
    port(
        clk             : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        stall           : in     vl_logic;
        IF_ID_inst      : out    vl_logic_vector(31 downto 0);
        IF_ID_pc        : out    vl_logic_vector(31 downto 0)
    );
end IF_ID_ff;
