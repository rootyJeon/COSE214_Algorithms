library verilog;
use verilog.vl_types.all;
entity MEM_WB_ff is
    port(
        clk             : in     vl_logic;
        EXE_MEM_rd      : in     vl_logic_vector(4 downto 0);
        MemRdata        : in     vl_logic_vector(31 downto 0);
        EXE_MEM_aluout  : in     vl_logic_vector(31 downto 0);
        EXE_MEM_memtoreg: in     vl_logic;
        EXE_MEM_regwrite: in     vl_logic;
        MEM_WB_rd       : out    vl_logic_vector(4 downto 0);
        MEM_WB_MemRdata : out    vl_logic_vector(31 downto 0);
        MEM_WB_aluout   : out    vl_logic_vector(31 downto 0);
        MEM_WB_memtoreg : out    vl_logic;
        MEM_WB_regwrite : out    vl_logic
    );
end MEM_WB_ff;
