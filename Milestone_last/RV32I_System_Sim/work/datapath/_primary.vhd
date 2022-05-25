library verilog;
use verilog.vl_types.all;
entity datapath is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        auipc           : in     vl_logic;
        lui             : in     vl_logic;
        regwrite        : in     vl_logic;
        memtoreg        : in     vl_logic;
        memwrite        : in     vl_logic;
        memread         : in     vl_logic;
        alusrc          : in     vl_logic;
        alucontrol      : in     vl_logic_vector(4 downto 0);
        branch          : in     vl_logic;
        jal             : in     vl_logic;
        jalr            : in     vl_logic;
        MemRdata        : in     vl_logic_vector(31 downto 0);
        pc              : out    vl_logic_vector(31 downto 0);
        EXE_MEM_aluout  : out    vl_logic_vector(31 downto 0);
        IF_ID_inst      : out    vl_logic_vector(31 downto 0);
        EXE_MEM_memwrite: out    vl_logic;
        MemWdata        : out    vl_logic_vector(31 downto 0)
    );
end datapath;
