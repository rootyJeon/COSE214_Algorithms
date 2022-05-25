library verilog;
use verilog.vl_types.all;
entity Interlock is
    port(
        rs1_id          : in     vl_logic_vector(4 downto 0);
        rs2_id          : in     vl_logic_vector(4 downto 0);
        rd_exe          : in     vl_logic_vector(4 downto 0);
        MemRead_exe     : in     vl_logic;
        stall           : out    vl_logic
    );
end Interlock;
