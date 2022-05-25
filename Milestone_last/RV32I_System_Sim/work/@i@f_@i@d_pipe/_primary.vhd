library verilog;
use verilog.vl_types.all;
entity IF_ID_pipe is
    port(
        clk             : in     vl_logic;
        stall           : in     vl_logic;
        Inst_IF         : in     vl_logic_vector(31 downto 0);
        Inst_ID         : out    vl_logic_vector(31 downto 0)
    );
end IF_ID_pipe;
